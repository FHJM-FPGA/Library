`timescale 1ns / 1ps
module tb_remote_rcv_sel();
reg          sys_clk  ;
reg          sys_rst_n;
reg          remote_in;
wire         repeat_en;
wire         data_en  ;
wire [7:0]   data     ;
always#10 sys_clk <= !sys_clk;
initial begin
    sys_clk   = 0;
    sys_rst_n = 0;
    remote_in = 1;
    #100;
    sys_rst_n = 1;
    #5000;
    // remote_in = 0;#218680;
    // remote_in = 1;#218680;
    remote_in = 0;
    #9000000;
    remote_in = 1;
    #4500000;

    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;

    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;

    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;

    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #560000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
    #1680000;
    remote_in = 0;
    #560000;
    remote_in = 1;
end
remote_rcv uu(
    .sys_clk    (sys_clk  ),  //input                  sys_clk   ,  //系统时钟
    .sys_rst_n  (sys_rst_n),  //input                  sys_rst_n ,  //系统复位信号，低电平有效
    .remote_in  (remote_in),  //input                  remote_in ,  //红外接收信号
    .repeat_en  (repeat_en),  //output    reg          repeat_en ,  //重复码有效信号
    .data_en    (data_en  ),  //output    reg          data_en   ,  //数据有效信号
    .data       (data     )   //output    reg  [7:0]   data         //红外控制码
);

endmodule
