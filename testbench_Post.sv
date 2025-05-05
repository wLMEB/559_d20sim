// `timescale 1ns/1ps

module testbench;

    // Parameters
    parameter NUM_BITS = 8;

    // Testbench signals
    reg clk;
    reg reset;
    reg next;
    reg signed [NUM_BITS-1:0] mod;
    reg signed [NUM_BITS-1:0] target;
    wire [4:0] random_num;
    wire signed [NUM_BITS-1:0] final_num;
    wire hit;

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
        
    end

    // DUT instantiation
    top #( 
    ) dut (
        .clk(clk),
        .reset(reset),
        .next(next),
        .mod(mod),
        .target(target),
        .random_num(random_num),
        .final_num(final_num),
        .hit(hit)
    );

    // Testbench logic
    initial begin
        $fsdbDumpfile("test.fsdb");
        $fsdbDumpvars(0, testbench);
        // Apply reset and initialize
        
        // $readmemh("../bits.txt",dut.imem_inst);
        #20;
        $display("pc: %0d", dut.number_inst.pc);
        #20;
        reset = 1;
        #10;
        reset = 0;

        // Test case 1: mod = 5, target = 10
        mod = 5;
        target = 10;
        #100;

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

        // End simulation

        $finish;
    end

    // Monitor outputs
    always @(posedge clk) begin
        #5;
        $display("Time: %0t | random_num: %0d | mod: %0d | final_num: %0d | target: %0d | hit: %b", 
                 $time, random_num, mod, final_num, target, hit);
        $display("addr: %0d, data out %0d", dut.imem_inst.addr_i, dut.imem_inst.data_o);
        $display("pc: %0d", dut.number_inst.pc);
    end

endmodule
