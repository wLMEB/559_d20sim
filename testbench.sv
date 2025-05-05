// `timescale 1ns/1ps

// module testbench();

//     parameter NUM_BITS = 8;
//     logic clk;
//     logic signed [NUM_BITS-1:0] mod;
//     logic signed [NUM_BITS-1:0] target;
//     logic [4:0] random_num;
//     logic signed [NUM_BITS-1:0] final_num;
//     logic hit;
//     logic reset;
    
//     // Instantiate the module under test
//     top # (
//         .NUM_BITS(NUM_BITS)
//     ) DUT (
//         .random_num(random_num),
//         .clk(clk),
//         .reset(reset),
//         .mod(mod),
//         .final_num(final_num),
//         .target(target),
//         .hit(hit)
//     );

   

//     // Clock generation
//     always #10 clk = ~clk; // Generate a clock with a period of 10 time units

//     initial begin
//         clk = 0; // Initialize clock
//         mod = 5; // Initialize modifier
//         reset = 1;
//         target = 10; // Set the target value for comparison
//         #10 reset = 0;
        


//         // // Initialize memory using the task in the top module
//         // $display("Initializing memory...");
//         // DUT.init_memory("bits.txt");

//         // // Display memory contents for debugging
//         // $display("Displaying memory contents:");
//         // DUT.display_memory(); // Call the task through the top module

//         // Run the simulation for 10 clock cycles
//         for (int i = 0; i < 100; i++) begin
//             #10;
//             $display("random_num = %d, mod = %d, final_num = %d, target = %d, hit = %d", 
//                      random_num, mod, final_num, target, hit);
//         end

//         $finish; // End the simulation
//     end

// endmodule
// Filepath: testing/rtl/test_number.sv
`timescale 1ns/1ps

module testbench;

    // Parameters
    parameter NUM_BITS = 8;

    // Testbench signals
    logic clk;
    logic reset;
    logic next;
    logic signed [NUM_BITS-1:0] mod;
    logic signed [NUM_BITS-1:0] target;
    logic [4:0] random_num;
    logic signed [NUM_BITS-1:0] final_num;
    logic hit;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk; // 10ns clock period
    end

    // DUT instantiation
    top #(
        .NUM_BITS(NUM_BITS)
    ) dut (
        .clk(clk),
        .next(next),
        .reset(reset),
        .mod(mod),
        .target(target),
        .random_num(random_num),
        .final_num(final_num),
        .hit(hit)
    );

    // Testbench logic
    initial begin
        // Initialize memory
        $readmemb("bits.txt",dut.imem_inst.RAM);

        // Apply reset
        reset = 1;
        #10;
        reset = 0;

        // Test case 1: mod = 5, target = 10
        mod = 5;
        target = 10;
        #100; // Wait for a few clock cycles

        next = 1;
        #10;
        next = 0;

        // Test case 2: mod = -3, target = 0
        mod = -3;
        target = 0;
        #100;
        
        next = 1;
        #10;
        next = 0;
        // Test case 3: mod = 0, target = 15
        mod = 0;
        target = 15;
        #100;
        next = 1;
        #10;
        next = 0;
        // Test case 4: mod = 7, target = -5
        mod = 7;
        target = -5;
        #100;
        next = 1;
        #10;
        next = 0;
        // End simulation
        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        #5
        $monitor("Time: %0t | random_num: %0d | modifer: %0d | final_num: %0d | target: %0d| hit: %0b", 
                 $time, random_num, mod,final_num, target, hit);
    end

endmodule