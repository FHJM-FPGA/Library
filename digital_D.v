`timescale 1ns / 1ps
//1位阳数码管静态显示
module digital_D(
    input      [3:0] data,
    output reg [6:0] hex   
);
always@(*) 
    case(data)
        0:hex<=7'b100_0000;
        1:hex<=7'b111_1001;
        2:hex<=7'b010_0100;
        3:hex<=7'b011_0000;
        4:hex<=7'b001_1001;
        5:hex<=7'b001_0010;
        6:hex<=7'b000_0010;
        7:hex<=7'b111_1000;
        8:hex<=7'b000_0000;
        9:hex<=7'b001_0000;
        10:hex<=7'b000_1000;
        11:hex<=7'b000_0011;
        12:hex<=7'b100_0110;
        13:hex<=7'b010_0001;
        14:hex<=7'b000_0110;
        15:hex<=7'b111_1111;
        default:hex<=7'b100_0000;
    endcase

endmodule
