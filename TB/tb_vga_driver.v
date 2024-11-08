`timescale 1ns / 1ps
module tb_vga_driver();
reg           clk       ;
reg           rstn      ;
wire          vga_hs    ;
wire          vga_vs    ;
wire  [15:0]  vga_rgb   ;
reg   [15:0]  pixel_data;
wire          data_req  ;
wire  [10:0]  pixel_xpos;
wire  [10:0]  pixel_ypos;
always#10 clk <= !clk;
initial begin
    clk = 0;
    rstn = 0;
    pixel_data = 0;
    #100;
    rstn = 1;
    #100;
end
always#40 pixel_data <= pixel_data+1;
vga_driver uu(
    .clk         (clk       ),  //input           clk       ,   //VGA驱动时钟
    .rstn        (rstn      ),  //input           rstn      ,   //复位信号
    .vga_hs      (vga_hs    ),  //output          vga_hs    ,   //行同步信号
    .vga_vs      (vga_vs    ),  //output          vga_vs    ,   //场同步信号
    .vga_rgb     (vga_rgb   ),  //output  [15:0]  vga_rgb   ,   //红绿蓝三原色输出
    .pixel_data  (pixel_data),  //input   [15:0]  pixel_data,   //像素点数据
    .data_req    (data_req  ),  //output          data_req  ,   //请求像素点颜色数据输入 
    .pixel_xpos  (pixel_xpos),  //output  [10:0]  pixel_xpos,   //像素点横坐标
    .pixel_ypos  (pixel_ypos)   //output  [10:0]  pixel_ypos    //像素点纵坐标    
);   

endmodule
