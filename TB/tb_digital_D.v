`timescale 1ns / 1ps
//1位阳数码管静态显示
module tb_digital_D();

reg  [3:0] data;
wire [6:0] hex ;
always#20 data <= data+1;
initial begin
    data = 0;
end
digital_D digital_D(
    .data  (data),  //input      [3:0] data,
    .hex   (hex )   //output reg [6:0] hex   
);

endmodule
