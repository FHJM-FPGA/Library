`timescale 1ns / 1ps
module tb_DS18b20();

reg           clk      ;
reg           rstn     ;
wire          dq       ;
wire [19:0]   temp_data;
wire          sign     ;

reg temp;
always#10 clk <= !clk;
initial begin
    clk  = 0;
    rstn = 0;
    temp = 1;
    #100;
    rstn = 1;
    #570000;
    temp = 0;
    #780000000;//仿真要等很长时间
    repeat(40)begin
        temp = 1;#570000;
        temp = 0;#570000;
    end
end
assign dq = temp;
DS18b20 uu(
    .clk        (clk      ),  //input               clk      ,        //系统时钟，50M
    .rstn       (rstn     ),  //input               rstn     ,       //低电平有效的复位信号    
    .dq         (dq       ),  //inout               dq       ,        //单总线（双向信号）
    .temp_data  (temp_data),  //output reg [19:0]   temp_data,       // 转换后得到的温度值
    .sign       (sign     )   //output reg          sign           // 符号位
);

endmodule
