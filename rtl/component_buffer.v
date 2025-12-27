//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/25/2025 05:58:54 PM
// Design Name: 
// Module Name: component_buffer
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


module component_buffer
#(  parameter W_H = 5,
    parameter ROW_LEN = 2048)
(
    input                           clk,
    input                           rst,
    input                           en,
    input  [7:0]                    din,
    output [W_H*8-1:0]              dout
    );
    
reg [$clog2(ROW_LEN)-1:0]  curr_col;
always @(posedge clk) begin
    if(rst) 
        curr_col <= 0;
    else
        curr_col <= curr_col + 1;
end

wire [W_H*8-1:0] curr_data;
assign curr_data[7:0] = din;
genvar k;
generate
    for(k=0;k<W_H-1;k=k+1) begin
        sp_bram #(.WIDTH(8), .DEPTH(ROW_LEN)) row(
            .clk(clk),
            .we(1'b1),
            .en(en),
            .addr(curr_col),
            .din(curr_data[(k+1)*8-1:k*8]),
            .dout(curr_data[(k+2)*8-1:(k+1)*8])
         );
    end
endgenerate

assign dout = curr_data;
    
endmodule
