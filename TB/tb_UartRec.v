`timescale 1ns / 1ps
module tb_UartRec();

reg          clk    ;
reg          rstn   ;
reg   [19:0] BpsNum ;
reg          UartRx ;
wire         done   ;
wire  [7:0]  RecData;
always#10 clk <= !clk;
initial begin
    clk    = 0;
    rstn   = 0;
    BpsNum = 434;
    UartRx = 1;
    #100;
    rstn = 1;
    #100;
    UartRx = 1;#10000;
    UartRx = 0;#8680;
    UartRx = 1;#8680;
    UartRx = 0;#8680;
    UartRx = 1;#8680;
    UartRx = 0;#8680;
    UartRx = 1;#8680;
    UartRx = 0;#8680;
    UartRx = 1;#8680;
    UartRx = 0;#8680;
    UartRx = 1;#8680;
end
UartRec UartRec(
    .clk      (clk    ),  //input             clk    ,
    .rstn     (rstn   ),  //input             rstn   ,
    .BpsNum   (BpsNum ),  //input      [19:0] BpsNum ,//波特率计数值
    .UartRx   (UartRx ),  //input             UartRx ,//串口接收
    .done     (done   ),  //output reg        done   ,//接收完成
    .RecData  (RecData)   //output reg [7:0]  RecData //接收数据
);

endmodule
