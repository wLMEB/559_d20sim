`timescale 1ns/1ps

module top #(
    parameter NUM_BITS = 8
) (
    input logic clk, // Trigger for new random number
    input logic reset, 
    input logic next, // Update next PC 
    input logic signed [NUM_BITS-1:0] mod, // Signed modifier
    input logic signed [NUM_BITS-1:0] target, // Target number for comparison
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
        .NUM_GROUP(32)
    ) imem_inst (
        .addr_i(pc), // Pass pc as the address input
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
    parameter int NUM_GROUP = 32
) (
    input  logic [31:0] addr_i,
    output logic [4:0] data_o
); 
   (* syn_preserve = 1, syn_keep = 1, dont_touch = "true" *) reg [4:0] RAM[0:NUM_GROUP-1];
    assign data_o = RAM[addr_i % NUM_GROUP];
    always @(posedge addr_i[0]) begin
        RAM[0] <=  5'b00001;
    end
endmodule  
