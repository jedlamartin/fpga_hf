`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2025 10:34:00 PM
// Design Name: 
// Module Name: mac
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


module mac
#(  parameter W_L = 5
)(
    input clk,
    
    input signed [W_L*16-1:0] coeffs,
    input [7:0] component,
    
    output signed [47:0] p
    );
    
wire signed [47:0] accu [0:W_L];
assign accu[0] = 0;    

genvar k;
generate
    for(k=0;k<W_L;k=k+1) begin
        dsp16x8 tap(         
            .clk(clk),
            
            .a(coeffs[(k+1)*16-1:k*16]),
            .b(component),
            
            .pc_i(accu[k]),
            
            .p_o(accu[k+1]) 
        );
    end
endgenerate     

assign p = accu[W_L];

endmodule
