`timescale 1ns/1ps

module top #(
    parameter NUM_BITS = 8
) (
    input logic clk, // Trigger for new random number
    input logic reset, 
    input logic next, // Update next PC 
    input logic write, // For writing into the memory
    input logic signed [NUM_BITS-1:0] mod, // Signed modifier
    input logic signed [NUM_BITS-1:0] target, // Target number for comparison
    input logic [4:0] data,
    input logic [31:0] addr,
    output logic [4:0] random_num, // 5-bit random number (1 to 20)
    output logic signed [NUM_BITS-1:0] final_num, // Signed 8-bit output
    output logic hit // 1 if final_num >= target, 0 otherwise
);

    logic [31:0] pc; // Program counter
    logic [4:0] value; // 5-bit value fetched from memory

    // Instantiate the number module
    number #(
        .NUM_BITS(NUM_BITS)
    ) number_inst (
        .clk(clk),
        .reset(reset),
        .next(next),
        .bits(value),
        .mod(mod),
        .target(target),
        .pc(pc), // Connect pc to the number module
        .random_num(random_num),
        .final_num(final_num),
        .hit(hit)
    );

    // Instantiate the imem module
    imem #(
        .DATA_LENGTH(32)
    ) imem_inst (
        .clk(clk),
        .write(write),
        .addr_o(pc), // Pass pc as the address input
        .addr_i(addr),
        .data_i(data),
        .data_o(value)
    );



endmodule


module number #(
    parameter NUM_BITS = 8
)(
    input logic clk, // Trigger for new random number
    input logic reset, // Reset signal
    input logic next,   // Next PC
    input logic [4:0] bits, // 5-bit randomness
    input logic signed [NUM_BITS-1:0] mod, // Signed modifier
    input logic signed [NUM_BITS-1:0] target, // Target number for comparison
    output logic [31:0] pc, // Program counter
    output logic [4:0] random_num, // 5-bit random number (1 to 20)
    output logic signed [NUM_BITS-1:0] final_num, // Signed 8-bit output
    output logic hit // 1 if final_num >= target, 0 otherwise
);

    logic signed [NUM_BITS-1:0] ran_8;

    logic valid_random; // Flag to indicate a valid random number

always @(posedge clk or posedge reset) begin
    
    if (reset) begin
        pc <= 0;
        random_num <= 0;
        valid_random <= 0;
        
        
    end else begin
        if (bits >= 1 && bits <= 20) begin
            random_num <= bits;
            valid_random <= 1;
        end else begin
            pc <= (pc + 1) % 32;
            valid_random <= 0;
        end
        if (next) begin
            pc <= (pc + 1) % 32;
        end

    end
    
end

always_comb begin
    if (valid_random) begin
        ran_8 = signed'({3'b000, $signed(random_num)});
        final_num = ran_8 + mod;
        hit = (final_num >= target) ? 1 : 0;
    end else begin
        final_num = 0;
        hit = 0;
    end
end
endmodule

(* dont_touch = "true" *) module imem #(
    parameter int DATA_LENGTH = 32
) (
    input logic clk,
    input logic write,
    input  logic [31:0] addr_i,
    input  logic [31:0] addr_o,
    input logic [4:0] data_i,
    output logic [4:0] data_o
); 
   (* syn_preserve = 1, syn_keep = 1, dont_touch = "true" *) reg [4:0] RAM[0:DATA_LENGTH-1];

    always @(posedge clk) begin
        if (write) begin
            RAM[addr_i % DATA_LENGTH] <=data_i;
        end 
        else begin
            data_o <= RAM[addr_o % DATA_LENGTH];
        end
    end
endmodule  
