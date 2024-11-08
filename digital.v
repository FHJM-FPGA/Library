`timescale 1ns / 1ps
//6位共阳极数码管动态扫描模块
module digital(
    input            clk  ,
    input            rstn ,
    input      [3:0] data1,
    input      [3:0] data2,
    input      [3:0] data3,
    input      [3:0] data4,
    input      [3:0] data5,
    input      [3:0] data6, 
    input      [5:0] dp   ,
    output reg [7:0] seg  ,
    output reg [5:0] sel   
);

reg [15:0]cn1;
reg clk1k;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cn1   <=0;
            clk1k <=0;
        end else if(cn1>=24999)begin
            clk1k <=!clk1k;
            cn1   <=0;
        end else begin
            cn1   <=cn1+1;
        end
    end
reg [3:0] tub;
reg [2:0] state;
always@(posedge clk1k or negedge rstn)
    begin
        if(!rstn)begin
            tub    <= 0;
            state  <= 0;
            sel    <= 0;
            seg[7] <= 1;
        end else begin
            case(state)
                0:begin tub<=data1;sel<=6'b011111;state<=1;seg[7]<=dp[0];end
                1:begin tub<=data2;sel<=6'b101111;state<=2;seg[7]<=dp[1];end
                2:begin tub<=data3;sel<=6'b110111;state<=3;seg[7]<=dp[2];end
                3:begin tub<=data4;sel<=6'b111011;state<=4;seg[7]<=dp[3];end
                4:begin tub<=data5;sel<=6'b111101;state<=5;seg[7]<=dp[4];end
                5:begin tub<=data6;sel<=6'b111110;state<=0;seg[7]<=dp[5];end
                default:state<=0;
            endcase
        end
    end
always@(*)
    if(!rstn)
        seg[6:0]<=7'b100_0000;
    else    
        case(tub)
            0:seg[6:0]<=7'b100_0000;
            1:seg[6:0]<=7'b111_1001;
            2:seg[6:0]<=7'b010_0100;
            3:seg[6:0]<=7'b011_0000;
            4:seg[6:0]<=7'b001_1001;
            5:seg[6:0]<=7'b001_0010;
            6:seg[6:0]<=7'b000_0010;
            7:seg[6:0]<=7'b111_1000;
            8:seg[6:0]<=7'b000_0000;
            9:seg[6:0]<=7'b001_0000;
//            10:seg[6:0]<=7'b000_1000;
//            11:seg[6:0]<=7'b000_0011;
//            12:seg[6:0]<=7'b100_0110;
//            13:seg[6:0]<=7'b010_0001;
//            14:seg[6:0]<=7'b000_0110;
            15:seg[6:0]<=7'b111_1111;
            default:seg[6:0]<=7'b100_0000;
        endcase

endmodule
