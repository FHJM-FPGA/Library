`timescale 1ns / 1ps
module tb_dht11_drive();

reg              clk       ;
reg              rstn      ;
reg              dht       ;
wire             dht11     ;
wire   [31:0]    data_valid;
always#10 clk <= !clk;
initial begin
    clk  = 0;
    rstn = 0;
    dht  = 0;
    #100;
    rstn = 1;
    #1000000000;
    #18000000;
    #12000;
    #80000;dht  = 1;
    #20000;dht  = 0;
    #80000;dht  = 1;
    #20000;dht  = 0;
    #80000;dht  = 1;
    repeat(4)begin
        #80000;dht   = 1;#10000;dht  = 0;
        #120000;dht  = 1;#10000;dht  = 0;
        #80000;dht   = 1;#10000;dht  = 0;
        #120000;dht  = 1;#10000;dht  = 0;
        #120000;dht  = 1;#10000;dht  = 0;
        #80000;dht   = 1;#10000;dht  = 0;
        #120000;dht  = 1;#10000;dht  = 0;
        #120000;dht  = 1;#10000;dht  = 0;
    end
    #120000;dht  = 1;#10000;dht  = 0;
    #120000;dht  = 1;#10000;dht  = 0;
    #120000;dht  = 1;#10000;dht  = 0;
    #80000;dht   = 1;#10000;dht  = 0;
    #120000;dht  = 1;#10000;dht  = 0;
    #120000;dht  = 1;#10000;dht  = 0;
    #80000;dht   = 1;#10000;dht  = 0;
    #80000;dht   = 1;#10000;dht  = 0;
    dht  = 0;
end
assign dht11 = dht;
dht11_drive uu(
    .clk         (clk       ),  //input                      clk          ,        //系统时钟，50M
    .rstn        (rstn      ),  //input                      rstn         ,        //低电平有效的复位信号    
    .dht11       (dht11     ),  //inout                      dht11        ,        //单总线（双向信号）
    .data_valid  (data_valid)   //output    reg    [31:0]    data_valid            //输出的有效数据，位宽32
);
endmodule
