`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/17/2024 11:13:08 AM
// Design Name: 
// Module Name: tf_rgb2y
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


module tf_fir2d();

reg                 clk = 0;
    
wire                dv_i;
wire                hs_i;
wire                vs_i;
wire          [7:0] r_i;
wire          [7:0] g_i;
wire          [7:0] b_i;

wire                dv_o;
wire                hs_o;
wire                vs_o;
wire          [7:0] r_o;
wire          [7:0] g_o;
wire          [7:0] b_o;

// Laplace-filter
wire signed [399:0] laplace_coeffs;

assign laplace_coeffs = {
    // Row 4 (Bottom)
    -16'sd256, -16'sd256, -16'sd256, -16'sd256, -16'sd256, 
    // Row 3
    -16'sd256, -16'sd256, -16'sd256, -16'sd256, -16'sd256, 
    // Row 2 (Center) -> 24 * 256 = 6144
    -16'sd256, -16'sd256,  16'sd6144, -16'sd256, -16'sd256, 
    // Row 1
    -16'sd256, -16'sd256, -16'sd256, -16'sd256, -16'sd256, 
    // Row 0 (Top)
    -16'sd256, -16'sd256, -16'sd256, -16'sd256, -16'sd256 
};

fir2d UUT(
    .clk    (clk ),

    .dv_i   (dv_i),
    .hs_i   (hs_i),
    .vs_i   (vs_i),
    .r_i    (r_i ),
    .g_i    (g_i ),
    .b_i    (b_i ),

    .coeffs(laplace_coeffs),

    .dv_o   (dv_o),
    .hs_o   (hs_o),
    .vs_o   (vs_o),
    .r_o    (r_o ),
    .g_o    (g_o ),
    .b_o    (b_o )
);


localparam RES = 512;

always #5 clk <= ~clk;

integer file_in, file_out;
initial
begin
    //file_in  = $fopen("check.raw", "rb");
    file_in  = $fopen("lena.raw", "rb");
    file_out = $fopen("img_out.raw", "wb");
end


reg [7:0] mem_in[RES*RES*3-1:0];

initial
begin
    $fread(mem_in, file_in);
    $fclose(file_in);
    
    @(posedge vs_o);
    @(negedge vs_o);
    $fclose(file_out);
    $stop;
end

always @(negedge clk) begin
    if (dv_o) begin
        $fwrite(file_out, "%c", r_o);
        $fwrite(file_out, "%c", g_o);
        $fwrite(file_out, "%c", b_o);
    end
end


reg [15:0] col = -1;
reg [15:0] row = -1;

always @ (negedge clk)
begin
    if (col==(RES+50))
    begin    
        col <= 'h0;
    end
    else
    begin
        col <= col + 1;
    end

    if (col==(RES+50))
    begin
        if (row==(RES+50))
        begin
            row <= 'h0;
        end
        else
        begin
            row <= row + 1;
        end
    end
end

assign dv_i = (col<RES) & (row<RES);
assign hs_i = (col>(RES+10)) & (col<(RES+20));
assign vs_i = (row>(RES+10)) & (row<(RES+20));
assign r_i  = mem_in[row*RES*3 + col*3 + 0];
assign g_i  = mem_in[row*RES*3 + col*3 + 1];
assign b_i  = mem_in[row*RES*3 + col*3 + 2];


endmodule

