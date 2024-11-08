`timescale 1ns / 1ps
module tb_digital();
reg         clk  ;
reg         rstn ;
reg   [3:0] data1;
reg   [3:0] data2;
reg   [3:0] data3;
reg   [3:0] data4;
reg   [3:0] data5;
reg   [3:0] data6;
reg   [5:0] dp   ;
wire  [7:0] seg  ;
wire  [5:0] sel  ;
always#10 clk <= !clk;
initial begin
    clk   = 0;
    rstn  = 0;
    data1 = 1;
    data2 = 2;
    data3 = 3;
    data4 = 4;
    data5 = 5;
    data6 = 6;
    dp    = 6'b101011;
    #100;
    rstn = 1;
end
digital uu(
    .clk    (clk  ),  //input            clk  ,
    .rstn   (rstn ),  //input            rstn ,
    .data1  (data1),  //input      [3:0] data1,
    .data2  (data2),  //input      [3:0] data2,
    .data3  (data3),  //input      [3:0] data3,
    .data4  (data4),  //input      [3:0] data4,
    .data5  (data5),  //input      [3:0] data5,
    .data6  (data6),  //input      [3:0] data6, 
    .dp     (dp   ),  //input      [5:0] dp   ,
    .seg    (seg  ),  //output reg [7:0] seg  ,
    .sel    (sel  )   //output reg [5:0] sel   
);

endmodule
