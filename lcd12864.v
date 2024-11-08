//LCD12864驱动模块
/*
汉字编码链接：
https://www.qqxiuzi.cn/bianma/zifuji.php
*/
module lcd12864(
    input               clk            ,
    input               rstn           ,
    output              lcd_rs         , 
    output              lcd_rw         , 
    output              lcd_en         , 
    output      [7:0]   lcd_data        
);   

reg        clk_lcd;                                         
reg [16:0] cnt    ;                                                      
always @(posedge clk or negedge rstn)
    begin
        if(!rstn)begin 
            cnt     <= 17'b0;
            clk_lcd <= 0;
        end else if(cnt == 17'd7999)begin
            cnt     <= 17'd0;
            clk_lcd <= !clk_lcd;
        end else begin
            cnt <= cnt +1'b1;
        end
    end                  
reg [8:0] state_lcd; 
parameter IDLE              = 4'd0;
parameter CMD_WIDTH         = 4'd1;
parameter CMD_SET           = 4'd2;
parameter CMD_CURSOR        = 4'd3;
parameter CMD_CLEAR         = 4'd4;
parameter CMD_ACCESS        = 4'd5;
parameter CMD_DDRAM         = 4'd6;
parameter DATA_WRITE        = 4'd7;
parameter STOP              = 4'd8;

reg       lcd_rs_r;
reg [5:0] cnt_time;
reg [7:0] lcd_data_r;
reg [7:0] data_buff;

assign lcd_rs   = lcd_rs_r;
assign lcd_rw   = 1'b0; 
assign lcd_en   = clk_lcd;  
assign lcd_data = lcd_data_r;

always @(posedge clk_lcd or negedge rstn)
    begin
        if(!rstn)
        begin
            lcd_rs_r   <= 1'b0;
            state_lcd  <= IDLE;
            lcd_data_r <= 8'bzzzzzzzz;       
            cnt_time   <= 6'd0;
        end
        else 
        begin
            case(state_lcd)
                IDLE:  
                begin  
                    lcd_rs_r   <= 1'b0;
                    cnt_time   <= 6'd0;
                    state_lcd  <= CMD_WIDTH;
                    lcd_data_r <= 8'bzzzzzzzz;  
                end
                CMD_WIDTH:                    
                begin
                    lcd_rs_r   <= 1'b0;
                    state_lcd  <= CMD_SET;    
                    lcd_data_r <= 8'h30;                  
                end
                CMD_SET:
                begin
                    lcd_rs_r   <= 1'b0;
                    state_lcd  <= CMD_CURSOR;
                    lcd_data_r <= 8'h30;             
                end
                CMD_CURSOR:
                begin
                    lcd_rs_r   <= 1'b0;
                    state_lcd  <= CMD_CLEAR;
                    lcd_data_r <= 8'h0c;      
                end
                CMD_CLEAR:
                begin
                    lcd_rs_r   <= 1'b0;
                    state_lcd  <= CMD_ACCESS;
                    lcd_data_r <= 8'h01;          
                end
                CMD_ACCESS:
                begin
                    lcd_rs_r   <= 1'b0;
                    state_lcd  <= CMD_DDRAM;
                    lcd_data_r <= 8'h06;    
                end
                CMD_DDRAM:                  
                begin
                    lcd_rs_r  <= 1'b0;
                    state_lcd <= DATA_WRITE;
                    case (cnt_time)
                        6'd0:  lcd_data_r <= 8'h80;
                        6'd16: lcd_data_r <= 8'h90;
                        6'd32: lcd_data_r <= 8'h88;
                        6'd48: lcd_data_r <= 8'h98;
                    endcase
                end
                DATA_WRITE:                               
                begin
                    lcd_rs_r <= 1'b1;
                    cnt_time <= cnt_time + 1'b1;
                    lcd_data_r <= data_buff;
                    case (cnt_time)
                        6'd15: state_lcd <= CMD_DDRAM;
                        6'd31: state_lcd <= CMD_DDRAM;
                        6'd47: state_lcd <= CMD_DDRAM;
                        6'd63: state_lcd <= STOP;
                        default:
                            state_lcd <= DATA_WRITE;
                    endcase
                end
                STOP:
                begin
                    lcd_rs_r <= 1'b0;
                    state_lcd <= CMD_DDRAM;
                    lcd_data_r <= 8'h80;                
                    cnt_time <= 6'd0;
                end
                default: 
                    state_lcd <= IDLE;
            endcase
        end
    end
always @(posedge clk) 
    begin
        case (cnt_time)
             6'd0:  data_buff <= "*";
             6'd1:  data_buff <= "*";
             6'd2:  data_buff <= "*";
             6'd3:  data_buff <= "*";
             6'd4:  data_buff <= 8'hE7;
             6'd5:  data_buff <= 8'hB3;
             6'd6:  data_buff <= 8'hBA;
             6'd7:  data_buff <= 8'hEC;
             6'd8:  data_buff <= 8'hBD;
             6'd9:  data_buff <= 8'hAA;
            6'd10:  data_buff <= 8'hC3;
            6'd11:  data_buff <= 8'hCE;
            6'd12:  data_buff <= "*";
            6'd13:  data_buff <= "*";
            6'd14:  data_buff <= "*";
            6'd15:  data_buff <= "*";
            
            6'd16:  data_buff <= "1";
            6'd17:  data_buff <= "2";
            6'd18:  data_buff <= "3";
            6'd19:  data_buff <= "4";
            6'd20:  data_buff <= "5";
            6'd21:  data_buff <= "6";
            6'd22:  data_buff <= "7";
            6'd23:  data_buff <= "8";
            6'd24:  data_buff <= "9";
            6'd25:  data_buff <= "A";
            6'd26:  data_buff <= "B";
            6'd27:  data_buff <= "C";
            6'd28:  data_buff <= "D";
            6'd29:  data_buff <= "E";
            6'd30:  data_buff <= "F";
            6'd31:  data_buff <= "G";
            
            6'd32:  data_buff <= "!";
            6'd33:  data_buff <= "@";
            6'd34:  data_buff <= "#";
            6'd35:  data_buff <= "$";
            6'd36:  data_buff <= "%";
            6'd37:  data_buff <= "^";
            6'd38:  data_buff <= "&";
            6'd39:  data_buff <= "*";
            6'd40:  data_buff <= "(";
            6'd41:  data_buff <= ")";
            6'd42:  data_buff <= "{";
            6'd43:  data_buff <= "}";
            6'd44:  data_buff <= "[";
            6'd45:  data_buff <= "]";
            6'd46:  data_buff <= "+";
            6'd47:  data_buff <= "-";
            
            6'd48:  data_buff <= "*";
            6'd49:  data_buff <= "/";
            6'd50:  data_buff <= ".";
            6'd51:  data_buff <= ".";
            6'd52:  data_buff <= ".";
            6'd53:  data_buff <= ".";
            6'd54:  data_buff <= ".";
            6'd55:  data_buff <= ".";
            6'd56:  data_buff <= ".";
            6'd57:  data_buff <= ".";
            6'd58:  data_buff <= ".";
            6'd59:  data_buff <= ".";
            6'd60:  data_buff <= ".";
            6'd61:  data_buff <= ".";
            6'd62:  data_buff <= ".";
            6'd63:  data_buff <= ".";

            default :  data_buff <= " ";
        endcase
    end
endmodule 
