//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2025 06:55:23 PM
// Design Name: 
// Module Name: sp_bram
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


module sp_bram
#(  parameter WIDTH = 8,
    parameter DEPTH = 2048)
(
    input   clk,
    input   we,
    input   en,
    input [$clog2(DEPTH)-1:0] addr,
    input [WIDTH-1:0] din,
    output [WIDTH-1:0] dout
    );
    
    reg [WIDTH-1:0] memory [DEPTH-1:0];
    reg [WIDTH-1:0] dout_reg;
    
    // Read-First Memory
    always @(posedge clk) begin
        if(en) begin
            if(we) begin
                memory[addr] <= din;
            end
            dout_reg <= memory[addr];
        end
     end
     
     assign dout = dout_reg;
endmodule
