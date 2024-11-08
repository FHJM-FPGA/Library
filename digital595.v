//*******************************//
//闲鱼号：深红的乌姜梦
//哔站号：深红的乌姜梦
//QQ号：2943115420
//FPGA交流群（FPGA与友）：689408654
//完成日期2022.10.26
//*******************************//
`timescale 1ns / 1ps
module digital595(
    input            clk  ,
    input            rstn ,
    input      [3:0] data1,
    input      [3:0] data2,
    input      [3:0] data3,
    input      [3:0] data4,
    input      [3:0] data5,
    input      [3:0] data6,
    input      [3:0] data7,
    input      [3:0] data8,
    output reg [7:0] seg  ,
    output reg [7:0] sel
);

reg [15:0]cn1;
reg clk1k;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)
            begin
                cn1<=0;
                clk1k<=0;
            end
        else if(cn1>=24999)//仿真 1   下板子 24999
            begin
                clk1k<=!clk1k;
                cn1<=0;
            end
        else cn1<=cn1+1;
    end
reg [3:0] tub;
reg [2:0] con;
always@(posedge clk1k or negedge rstn)
    begin
        if(!rstn)
            begin
                tub      <= 0;
                con      <= 0;
                sel      <= 0;
            end
        else begin
            case(con)
                0:begin tub<=data8;sel<=8'b00000001;con<=1;end
                1:begin tub<=data7;sel<=8'b00000010;con<=2;end
                2:begin tub<=data6;sel<=8'b00000100;con<=3;end
                3:begin tub<=data5;sel<=8'b00001000;con<=4;end
                4:begin tub<=data4;sel<=8'b00010000;con<=5;end
                5:begin tub<=data3;sel<=8'b00100000;con<=6;end
                6:begin tub<=data2;sel<=8'b01000000;con<=7;end
                7:begin tub<=data1;sel<=8'b10000000;con<=0;end
                default:con<=0;
            endcase
        end
    end
always@(*)
    if(!rstn)
        seg<=8'b1100_0000;
    else    
        case(tub)
            0:seg<=8'b1100_0000;
            1:seg<=8'b1111_1001;
            2:seg<=8'b1010_0100;
            3:seg<=8'b1011_0000;
            4:seg<=8'b1001_1001;
            5:seg<=8'b1001_0010;
            6:seg<=8'b1000_0010;
            7:seg<=8'b1111_1000;
            8:seg<=8'b1000_0000;
            9:seg<=8'b1001_0000;
            10:seg<=8'b1111_1111;//全灭休眠
//            11:seg<=8'b1000_0011;
//            12:seg<=8'b1100_0110;
//            13:seg<=8'b1010_0001;
//            14:seg<=8'b1000_0110;
            15:seg<=8'b1111_1111;
            default:seg<=8'b1100_0000;
        endcase

endmodule
