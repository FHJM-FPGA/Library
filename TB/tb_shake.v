`timescale 1ns / 1ps
module tb_shake();
reg      clk  ;
reg      rstn ;
reg      key  ;
wire     shape;
always#10 clk <= !clk;
initial begin
    clk  = 0;
    rstn = 0;
    key  = 1;
    #100;
    rstn = 1;
    #200;
    repeat(20)begin
        key  = 1;#20;
        key  = 0;#20;
    end
    #500;
    repeat(20)begin
        key  = 0;#20;
        key  = 1;#20;
    end
end
shake shake(        
    .clk    (clk  ),  //input      clk   ,          
    .rstn   (rstn ),  //input      rstn  ,    
    .key    (key  ),  //input      key   ,      
    .shape  (shape)   //output reg shape   
);
defparam shake.delay=45;
endmodule
