//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2025 09:56:34 PM
// Design Name: 
// Module Name: dsp16x9
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


module dsp16x8(
    input clk,
    
    input signed [15:0] a,
    input [7:0] b,
    
    input signed [47:0] pc_i,
    
    output signed [47:0] p_o 
    );

reg signed [15:0] a_reg;
reg [7:0] b_reg;
reg signed [23:0] mul;
reg signed [47:0] p_o_reg;    
always @(posedge clk) begin
    a_reg <= a;
    b_reg <= b;
    mul <= a * $signed({1'b0, b});
    p_o_reg <= mul + pc_i;
end

assign p_o = p_o_reg;

endmodule
