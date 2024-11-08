`timescale 1ns / 1ps
module tb_shakeA();
reg          clk  ;
reg          rstn ;
reg   [5:0]  key  ;
wire  [5:0]  shape;
always#10 clk <= !clk;
initial begin
    clk = 0;
    rstn = 0;
    key = ~0;
    #100;
    rstn = 1;#500;
    key[0] = 0;#1000;
    key[0] = 1;
end
shakeA shakeA(
    .clk    (clk  ),  //input             clk  ,
    .rstn   (rstn ),  //input             rstn ,
    .key    (key  ),  //input      [3:0]  key  ,
    .shape  (shape)   //output reg [3:0]  shape 
);
defparam shakeA.num = 20;
 
endmodule
