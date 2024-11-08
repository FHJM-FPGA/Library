`timescale 1ns / 1ps
module tb_UartSend();

reg        clk     ;
reg        rstn    ;
reg        SendEn  ;
reg  [7:0] SendData;
wire       SendBusy;
wire       SendDone;
wire       UartTx  ;
always#10 clk <= !clk;
initial begin
    clk      = 0;
    rstn     = 0;
    SendEn   = 0;
    SendData = 0;
    #100;
    rstn = 1;
    #200;
    SendEn   = 1;
    SendData = 8'h12;
    #20;
    SendEn   = 0;
end
UartSend uu(
    .clk       (clk     ),  //input            clk     ,
    .rstn      (rstn    ),  //input            rstn    ,
    .SendEn    (SendEn  ),  //input            SendEn  ,//写使能
    .SendData  (SendData),  //input      [7:0] SendData,//写数据
    .SendBusy  (SendBusy),  //output reg       SendBusy,//发送忙
    .SendDone  (SendDone),  //output           SendDone,//发送完成
    .UartTx    (UartTx  )   //output reg       UartTx   //串口接口
);
endmodule
