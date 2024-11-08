//*******************************//
//闲鱼号：绯红姜梦
//哔站号：绯红姜梦
//QQ号：2943115420
//FPGA交流群（FPGA与友）：689408654
//完成日期2022.10.27
//*******************************//
module Driver595(
    input                 clk     ,
    input                 rstn    ,
    input         [15:0]  data595 ,
    output    reg         SCLK    ,
    output    reg         RCLK    ,
    output    reg         DIO     
);
reg [5:0] state;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            state <= 0;
            SCLK  <= 0;
            RCLK  <= 0;
            DIO   <= 0;
        end else begin
            case(state)
                0:begin state <=  1; SCLK <= 1'b0; DIO <= data595[15]; RCLK <= 1'b1;end
                1:begin state <=  2; SCLK <= 1'b1;                     RCLK <= 1'b0;end
                2:begin state <=  3; SCLK <= 1'b0; DIO <= data595[14];end
                3:begin state <=  4; SCLK <= 1'b1; end
                4:begin state <=  5; SCLK <= 1'b0; DIO <= data595[13];end
                5:begin state <=  6; SCLK <= 1'b1; end
                6:begin state <=  7; SCLK <= 1'b0; DIO <= data595[12];end
                7:begin state <=  8; SCLK <= 1'b1; end
                8:begin state <=  9; SCLK <= 1'b0; DIO <= data595[11];end
                9:begin state <= 10; SCLK <= 1'b1; end
                10:begin state <= 11; SCLK <= 1'b0; DIO <= data595[10];end
                11:begin state <= 12; SCLK <= 1'b1; end
                12:begin state <= 13; SCLK <= 1'b0; DIO <= data595[ 9];end
                13:begin state <= 14; SCLK <= 1'b1; end 
                14:begin state <= 15; SCLK <= 1'b0; DIO <= data595[ 8];end
                15:begin state <= 16; SCLK <= 1'b1; end 
                16:begin state <= 17; SCLK <= 1'b0; DIO <= data595[ 7];end
                17:begin state <= 18; SCLK <= 1'b1; end 
                18:begin state <= 19; SCLK <= 1'b0; DIO <= data595[ 6];end
                19:begin state <= 20; SCLK <= 1'b1; end 
                20:begin state <= 21; SCLK <= 1'b0; DIO <= data595[ 5];end
                21:begin state <= 22; SCLK <= 1'b1; end 
                22:begin state <= 23; SCLK <= 1'b0; DIO <= data595[ 4];end
                23:begin state <= 24; SCLK <= 1'b1; end 
                24:begin state <= 25; SCLK <= 1'b0; DIO <= data595[ 3];end
                25:begin state <= 26; SCLK <= 1'b1; end 
                26:begin state <= 27; SCLK <= 1'b0; DIO <= data595[ 2];end
                27:begin state <= 28; SCLK <= 1'b1; end 
                28:begin state <= 29; SCLK <= 1'b0; DIO <= data595[ 1];end
                29:begin state <= 30; SCLK <= 1'b1; end 
                30:begin state <= 31; SCLK <= 1'b0; DIO <= data595[ 0];end
                31:begin state <=  0; SCLK <= 1'b1; end
            endcase
        end
    end
    
endmodule
