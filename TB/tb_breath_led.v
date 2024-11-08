`timescale 1ns / 1ps
module tb_breath_led();
reg      clk ;
reg      rstn;
wire     pwm ;
always#10 clk <= !clk;
initial begin
    clk  = 0;
    rstn = 0;
    #100;
    rstn = 1;
end
breath_led uu(
    .clk   (clk ),  //input  clk ,     //系统时钟
    .rstn  (rstn),  //input  rstn,     //低电平复位
    .pwm   (pwm )   //output pwm       //输出pwm波，接led
);
endmodule

