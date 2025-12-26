`timescale 1ns / 1ps

module component_buffer_tb;
    
    // -----------------------------------------------------------
    // 1. Configuration
    // -----------------------------------------------------------
    parameter W_H = 3;       
    parameter ROW_LEN = 10; 
    parameter CLK_PERIOD = 10;

    // -----------------------------------------------------------
    // 2. Signals
    // -----------------------------------------------------------
    reg clk;
    reg rst;
    reg en;
    reg [7:0] din;
    
    // FIX: This must be a flattened vector to match the module port!
    wire [W_H*8-1:0] dout; 

    // -----------------------------------------------------------
    // 3. DUT Instantiation
    // -----------------------------------------------------------
    component_buffer #(
        .W_H(W_H),
        .ROW_LEN(ROW_LEN)
    ) dut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .din(din),
        .dout(dout)
    );

    // -----------------------------------------------------------
    // 4. Clock Generation
    // -----------------------------------------------------------
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // -----------------------------------------------------------
    // 5. Test Stimulus
    // -----------------------------------------------------------
    integer i, row;
    
    initial begin
        // Setup Logging
        $display("Time | Row | Col | In (Row N) | Out[1] (Row N-1) | Out[2] (Row N-2)");
        $display("------------------------------------------------------------------");

        // Initialize
        rst = 1; en = 0; din = 0;
        #(CLK_PERIOD * 5);
        
        rst = 0;
        #(CLK_PERIOD * 2);

        // --- Loop through 4 Rows of Data ---
        for (row = 0; row < 4; row = row + 1) begin
            $display("--- Starting Row %0d ---", row);
            
            for (i = 0; i < ROW_LEN; i = i + 1) begin
                // Drive Inputs
                en = 1;
                // Generate data: 0xA0, 0xB0, 0xC0 based on row
                din = (row * 8'h10) + i; 

                // Check Outputs (Sampled at negedge to catch stable values)
                #1; 
                
                // Print Status every pixel
                // FIX: Manually slice the vector because 'dout' is now flat
                // Row 0 = [7:0]
                // Row 1 = [15:8]
                // Row 2 = [23:16]
                $display("%4t |  %1d  |  %1d  |    %h    |       %h       |       %h", 
                         $time, row, i, 
                         dout[7:0],      
                         dout[15:8],     
                         dout[23:16]);

                #(CLK_PERIOD - 1); // Wait for next clock
            end
            
            // Simulate Horizontal Blanking (Pause between rows)
            en = 0;
            din = 8'hFF; // Garbage data (should not be written)
            #(CLK_PERIOD * 5);
        end

        $display("--- Test Complete ---");
        $finish;
    end
endmodule