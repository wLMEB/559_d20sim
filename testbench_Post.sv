// `timescale 1ns/1ps

module testbench;

    // Parameters
    parameter NUM_BITS = 8;

    // Testbench signals
    logic clk;
    logic reset;
    logic next;
    logic write = 0;
    logic [4:0] data;
    logic [31:0] addr;
    logic signed [NUM_BITS-1:0] mod;
    logic signed [NUM_BITS-1:0] target;
    logic [4:0] random_num;
    logic signed [NUM_BITS-1:0] final_num;
    logic hit;

    reg [7:0] bits_mem[0:31];

    // DUT instantiation
    top #(
        .NUM_BITS(NUM_BITS)
    ) dut (
        .clk(clk),
        .next(next),
        .reset(reset),
        .write(write),
        .mod(mod),
        .target(target),
        .data(data),
        .addr(addr),
        .random_num(random_num),
        .final_num(final_num),
        .hit(hit)
    );

    // Testbench logic
    initial begin
        $fsdbDumpfile("test.fsdb");
        $fsdbDumpvars(0, testbench);
        clk = 0; // Initialize clock
        mod = 0;
        target = 0;
        next = 0;
        reset = 1;
        addr = 0;
    
        // Load memory
        $readmemb("bits.txt", bits_mem);
        //remeber to dumpfile for debugging

        $display("Contents of bits_mem:");
        for (int i = 0; i < 32; i++) begin
            $display("bits_mem[%0d] = %b", i, bits_mem[i]);
        end 
        $display("write is %d", write);
        
        
        #100
        reset = 0;
        write = 1;
        // $display("write is 1");
        // #100
        // write = 0;
        // $display("write is %d", write);
        
        #1000000

        // End simulation
        $finish;
    end

    always #5 clk = ~clk;   // Generate clock


    always @(negedge write) begin
    // Test case 1: mod = 5, target = 10

        // for (int i = 0; i < 32; i++) begin
        //     $display("bits_mem[%0d] = %b", i, bits_mem[i]);
        // end 


        if (!reset) begin

            reset = 1;
            #100
            reset = 0;
            #10
            $display("neg write triggerd");
            mod = 5;
            target = 10;
            #100; // Wait for a few clock cycles

            $display("Time: %0t | random_num: %0d | modifer: %0d | final_num: %0d | target: %0d| hit: %0b", 
                    $time, random_num, mod,final_num, target, hit);
            next = 1;
            #10;
            next = 0;


            // Test case 2: mod = -3, target = 0
            mod = -3;
            target = 10;
            #100;
            $display("Time: %0t | random_num: %0d | modifer: %0d | final_num: %0d | target: %0d| hit: %0b", 
                    $time, random_num, mod,final_num, target, hit);
            next = 1;
            #10;
            next = 0;
            // Test case 3: mod = 0, target = 15
            mod = 0;
            target = 15;
            #100;
            $display("Time: %0t | random_num: %0d | modifer: %0d | final_num: %0d | target: %0d| hit: %0b", 
                    $time, random_num, mod,final_num, target, hit);
            next = 1;
            #10;
            next = 0;
            for (int i = -3; i <= 10; i++) begin
                mod = i;
                target = 10;
                #100;
                 $display("pc: %0d, imem_inst.data_o: %0d", dut.imem_inst.addr_o, dut.imem_inst.data_o);
                $display("Time: %0t | random_num: %0d | modifer: %0d | final_num: %0d | target: %0d | hit: %0b", 
                        $time, random_num, mod, final_num, target, hit);
                next = 1;
                #10;
                next = 0;
                #20;
            end
        end
    end
    
    always @(posedge clk) begin


        if(write) begin
            if (addr < 31) begin
                data <= bits_mem[addr];
                addr<=addr+1;
                $display("addr %00d | data: %0d | imem_inst.data_i: %0d", addr, data, dut.imem_inst.data_i);

            end else begin
                write = 0;
            end
        end

        
    end

endmodule