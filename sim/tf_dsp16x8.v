`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2025 10:14:42 PM
// Design Name: 
// Module Name: tf_dsp16x8
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module tb_dsp16x8;

    // -----------------------------------------------------------
    // 1. Signals & Configuration
    // -----------------------------------------------------------
    reg clk;
    
    // Inputs
    reg signed [15:0] a;      // Coefficient (Signed)
    reg [7:0]         b;      // Pixel (Unsigned)
    reg signed [47:0] pc_i;   // Cascade Input
    
    // Output
    wire signed [47:0] p_o;   // Result

    // Clock Period
    localparam CLK_PERIOD = 10;

    // -----------------------------------------------------------
    // 2. DUT Instantiation
    // -----------------------------------------------------------
    dsp16x8 uut (
        .clk(clk),
        .a(a),
        .b(b),
        .pc_i(pc_i),
        .p_o(p_o)
    );

    // -----------------------------------------------------------
    // 3. Clock Generation
    // -----------------------------------------------------------
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // -----------------------------------------------------------
    // 4. Test Stimulus
    // -----------------------------------------------------------
    initial begin
        // Setup Logging
        $display("Time |    A (Signed)   | B (Unsigned) | PC_IN (Accum) |    Expected Calculation    |      Result (P_O)     | Status");
        $display("--------------------------------------------------------------------------------------------------------------------------");

        // Initialize
        a = 0; b = 0; pc_i = 0;
        #(CLK_PERIOD * 2); // Wait for pipeline flush

        // =========================================================
        // Test Case 1: Simple Positive Multiplication
        // 10 * 5 + 0 = 50
        // =========================================================
        a = 16'sd10;  
        b = 8'd5;
        pc_i = 48'sd0;
        
        // Wait 2 cycles for pipeline (Mul -> Add -> Out)
        #(CLK_PERIOD * 2); 
        check_result(50);


        // =========================================================
        // Test Case 2: Negative Coefficient (Signed Logic Check)
        // -10 * 5 + 100 = 50
        // =========================================================
        // If the signed fix is missing, -10 (0xFFF6) is treated as 65526
        // Result would be HUGE (327,730) instead of -50.
        a = -16'sd10; 
        b = 8'd5;
        pc_i = 48'sd100;
        
        #(CLK_PERIOD * 2);
        check_result(50); // -50 + 100 = 50


        // =========================================================
        // Test Case 3: Large Values (Width Check)
        // Max Neg (-32768) * Max Pos (255) + 0 
        // Expected: -8,355,840
        // =========================================================
        // If width is only 17 bits, this will overflow/truncate.
        a = -16'sd32768;
        b = 8'd255;
        pc_i = 0;
        
        #(CLK_PERIOD * 2);
        check_result(-8355840);

        // =========================================================
        // Test Case 4: Accumulation Chain Simulation
        // =========================================================
        a = 16'sd2;
        b = 8'd50;   // 2 * 50 = 100
        pc_i = 48'sd5000; // Previous sum
        
        #(CLK_PERIOD * 2);
        check_result(5100); // 5000 + 100

        $display("--------------------------------------------------------------------------------------------------------------------------");
        $display("Test Complete");
        $finish;
    end

    // -----------------------------------------------------------
    // Helper Task: Automatic Checker
    // -----------------------------------------------------------
    task check_result;
        input signed [47:0] expected;
        begin
            // Sample slightly after edge to avoid race conditions
            #1; 
            if (p_o === expected) begin
                $display("%4t | %6d (0x%h) |  %3d (0x%h)  | %6d        | %6d + (%6d * %3d) | %6d (0x%h) | PASS", 
                         $time, a, a, b, b, pc_i, pc_i, a, b, p_o, p_o);
            end else begin
                 $display("%4t | %6d (0x%h) |  %3d (0x%h)  | %6d        | %6d + (%6d * %3d) | %6d (0x%h) | FAIL (Exp: %d)", 
                         $time, a, a, b, b, pc_i, pc_i, a, b, p_o, p_o, expected);
            end
            // Restore timing
            #(CLK_PERIOD - 1);
        end
    endtask

endmodule