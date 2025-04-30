`timescale 1ns/1ps

module top #(
    parameter NUM_BITS = 8
) (
    input logic clk, // Trigger for new random number
    input logic reset,
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

    // Task to initialize memory
    // task init_memory(input string file_name);
    // $readmemb(file_name, imem_inst.RAM);

    task init_memory();
        imem_inst.RAM[1] = 5'b00000;
       imem_inst.RAM[1] = 5'b00001;
       imem_inst.RAM[2] = 5'b00010;
       imem_inst.RAM[3] = 5'b00011;
       imem_inst.RAM[4] = 5'b00111;
       imem_inst.RAM[5] = 5'b00101;
    endtask

    // Task to display memory contents
    // task display_memory();
    //     imem_inst.display_memory();
    // endtask

endmodule


module number #(
    parameter NUM_BITS = 8
)(
    input logic clk, // Trigger for new random number
    input logic reset, // Reset signal
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
initial begin
    for (int i = 0; i < 6; i++) begin
        $display("RAM[%0d] = %b", i, imem_inst.RAM[i]);
    end
end
always @(posedge clk or posedge reset) begin
    if (reset) begin
        random_num <= 0;
        final_num <= 0;
        hit <= 0;
    end else begin
        if (bits >= 1 && bits <= 20) begin
            random_num <= bits;
            ran_8 <= signed'({3'b000, $signed(bits)});
            final_num <= ran_8 + mod;
            hit <= (final_num >= target) ? 1 : 0;
        end else begin
            pc <= (pc + 1) % 32; // Increment the program counter
            // $display("Time: %0t | pc: %0d | bits: %0d", $time, pc, bits);
        end
    end
    
end
endmodule

module imem #(
    parameter int NUM_GROUP = 32
) (
    input  logic [31:0] addr_i,
    output logic [4:0] data_o
); 
    logic [4:0] RAM[NUM_GROUP-1:0];

    // always_comb begin

    assign data_o = RAM[addr_i % NUM_GROUP];
    // end
//   assign pc = (pc+1)%32;
//   task display_memory();
//         for (int i = 0; i < NUM_GROUP; i++) begin
//             $display("RAM[%0d] = %b", i, RAM[i]);
//         end
//         $display("addr_i", addr_i);
//           $display("data_o", data_o);
//     endtask
endmodule  
