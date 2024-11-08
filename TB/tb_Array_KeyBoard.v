`timescale 1ns / 1ps
module tb_Array_KeyBoard();
reg                clk      ;
reg                rstn     ;
reg      [3:0]     col     ;
wire     [3:0]     row     ;
wire     [15:0]    key_pulse;
wire               key_en   ;
wire     [3:0]     key_data ;
always#10 clk <= !clk;
initial begin
    clk   = 0;
    rstn = 0;
    col   = 4'b1111;
    #100;
    rstn = 1;
    #2590;
    col = 4'b0111;
    #1000;
    col = 4'b1111;
    #3000;
    col = 4'b0111;
    #1000;
    col = 4'b1111;
end
Array_KeyBoard Array_KeyBoard(
    .clk        (clk      ),  //input                     clk       ,
    .rstn       (rstn     ),  //input                     rstn      ,
    .col        (col      ),  //input            [3:0]    col       ,
    .row        (row      ),  //output    reg    [3:0]    row       ,
    .key_pulse  (key_pulse),  //output           [15:0]   key_pulse ,
    .key_en     (key_en   ),  //output    reg             key_en    ,
    .key_data   (key_data )   //output    reg    [3:0]    key_data    
);
defparam Array_KeyBoard.CNT_200HZ=50;
endmodule
