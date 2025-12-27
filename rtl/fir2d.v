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
// Additional Comments: coeffs: s.8
// 
//////////////////////////////////////////////////////////////////////////////////

module fir2d
#(  parameter W_H = 5,
    parameter W_L = 5)
(
    input                clk,
    
    input                dv_i,
    input                hs_i,
    input                vs_i,
    input        [7 : 0] r_i,
    input        [7 : 0] g_i,
    input        [7 : 0] b_i,
    
    input signed [W_H * W_L * 16 - 1 : 0] coeffs, 
    
    output               dv_o,
    output               hs_o,
    output               vs_o,
    output       [7 : 0] r_o,
    output       [7 : 0] g_o,
    output       [7 : 0] b_o
);

// RED
wire [W_H*8-1:0] r_buf_out;
// Delay: 1
component_buffer #(
    .W_H(W_H),
    .ROW_LEN(2048)
 ) r_buf (
    .clk(clk),
    .rst(hs_i),
    .en(1),
    .din(r_i),
    .dout(r_buf_out)
);

// GREEN
wire [W_H*8-1:0] g_buf_out;
// Delay: 1
component_buffer #(
    .W_H(W_H),
    .ROW_LEN(2048)
 ) g_buf (
    .clk(clk),
    .rst(hs_i),
    .en(1),
    .din(g_i),
    .dout(g_buf_out)
);

// BLUE
wire [W_H*8-1:0] b_buf_out;
// Delay: 1
component_buffer #(
    .W_H(W_H),
    .ROW_LEN(2048)
 ) b_buf (
    .clk(clk),
    .rst(hs_i),
    .en(1),
    .din(b_i),
    .dout(b_buf_out)
);




wire signed [47:0] r_mac_out [W_H - 1 : 0];
wire signed [47:0] g_mac_out [W_H - 1 : 0];
wire signed [47:0] b_mac_out [W_H - 1 : 0];

// Delay: W_L + 1
genvar k;
generate
    for(k = 0; k < W_H; k = k + 1) begin
        mac #(
            .W_L(W_L)
        ) r_mac (
            .clk(clk),
    
            .coeffs(coeffs[(k + 1) * W_L * 16 - 1 : k * W_L * 16]),
            .component(r_buf_out[(k + 1) * 8 - 1 : k * 8]),
    
            .p(r_mac_out[k])
        );
        
        mac #(
            .W_L(W_L)
        ) g_mac (
            .clk(clk),
    
            .coeffs(coeffs[(k + 1) * W_L * 16 - 1 : k * W_L * 16]),
            .component(g_buf_out[(k + 1) * 8 - 1 : k * 8]),
    
            .p(g_mac_out[k])
        );
        
        mac #(
            .W_L(W_L)
        ) b_mac (
            .clk(clk),
    
            .coeffs(coeffs[(k + 1) * W_L * 16 - 1 : k * W_L * 16]),
            .component(b_buf_out[(k + 1) * 8 - 1 : k * 8]),
    
            .p(b_mac_out[k])
        );
    end
endgenerate

// Summing the mac outputs. Delay: 1
reg signed [47:0] r_sum;
reg signed [47:0] g_sum;
reg signed [47:0] b_sum;
integer i;
always @(posedge clk) begin
    r_sum = 0;
    g_sum = 0;
    b_sum = 0;
    for(i=0;i<W_H;i=i+1) begin
        r_sum = r_sum + r_mac_out[i];
        g_sum = g_sum + g_mac_out[i];
        b_sum = b_sum + b_mac_out[i];
    end
end


// Saturation. Delay: 1
reg [7:0] r_o_reg;
always @(posedge clk) begin
    if(r_sum[47])
        r_o_reg = 0;
    else
        r_o_reg = r_sum[15:8];
end
assign r_o = r_o_reg;


reg [7:0] g_o_reg;
always @(posedge clk) begin
    if(g_sum[47])
        g_o_reg = 0;
    else
        g_o_reg = g_sum[15:8];
end
assign g_o = g_o_reg;


reg [7:0] b_o_reg;
always @(posedge clk) begin
    if(b_sum[47])
        b_o_reg = 0;
    else
        b_o_reg = b_sum[15:8];
end
assign b_o = b_o_reg;




// Delaying the control signals. Delay: W_L + 4
reg [W_L + 4 - 1 : 0] dv_dl;
reg [W_L + 4 - 1 : 0] hs_dl;
reg [W_L + 4 - 1 : 0] vs_dl;

always @(posedge clk) begin
    for(i = 0; i < W_L + 4; i = i + 1) begin
        dv_dl[i] <= (i == W_L + 4 - 1) ? dv_i : dv_dl[i + 1];
        hs_dl[i] <= (i == W_L + 4 - 1) ? hs_i : hs_dl[i + 1];
        vs_dl[i] <= (i == W_L + 4 - 1) ? vs_i : vs_dl[i + 1];
    end 
end

assign dv_o = dv_dl[0];
assign hs_o = hs_dl[0];
assign vs_o = vs_dl[0];

endmodule
