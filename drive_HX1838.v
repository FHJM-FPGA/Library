//红外传感器模块
module drive_HX1838(
    input            clk       ,
    input            rstn      ,
    input            single    ,
    output           dout_en   ,
    output     [7:0] dout_data  
);
reg [1:0] single_d;
always@(posedge clk )
    begin
        single_d <= {single_d[0],single};
    end
wire pose;
wire nege;
assign pose = !single_d[1] && single_d[0];
assign nege =  single_d[1] && !single_d[0];
//引导码：9ms 高电平 + 4.5ms 低电平
reg [25:0] cnt_9ms;
parameter num_9ms = 449999;//449999
reg [25:0] cnt_4_5ms;
parameter num_4_5ms = 224999;//224999
//1 码 ：0.56 ms 高电平 + 0.56 ms 低电平
//0 码 ： 0.56ms 高电平 + 1.68 ms 低电平
reg [25:0] cnt_560us;
parameter num_560us = 27999;
//reg [25:0] cnt_1680us;
//parameter num_1680us = 77999;

reg [4:0] state;
reg [31:0] addr;
reg [5:0]  cnt;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            state <= 0;
            addr  <= 0;
            cnt   <= 0;
        end else begin
            case(state)
                0:begin
                    state <= (nege) ? 1 : 0;
                    addr  <= 0;
                    cnt   <= 0;
                end
                1:begin
                    if(cnt_9ms == num_9ms)begin
                        state <= 2;
                    end else 
						  if(pose)begin
                        state <= 0;
                    end
                end
                2:begin
                    if(cnt_4_5ms == num_4_5ms)begin
                        state <= 3;
//                        addr  <= 0;
                        cnt   <= 0;
                    end else 
						  if(nege)begin
                        state <= 0;
                    end
                end
                3:begin
                    if(nege)begin
                        if(cnt_560us > num_560us+5)begin
                            addr[31-cnt] <= 1;
                        end else begin
                            addr[31-cnt] <= 0;
                        end
                        state <= 4;
                        cnt   <= cnt+1;
                    end else begin
                        state <= 3;
                        cnt   <= cnt;
                    end
                end
                4:begin
                    if(cnt == 31 && pose)begin
                        state <= 5;
                    end else if(pose)begin
                        state <= 3;
                    end
                end
                5:begin
                    state <= 0;
                    cnt   <= 0;
                end
                default:
                    state <= 0;
            endcase
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt_9ms <= 0;
        end else if(state == 1)begin
            if(cnt_9ms == num_9ms)begin
                cnt_9ms <= 0;
            end else begin
                cnt_9ms <= cnt_9ms+1;
            end
        end else begin
            cnt_9ms <= 0;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt_4_5ms <= 0;
        end else if(state == 2)begin
			cnt_4_5ms <= cnt_4_5ms+1;
        end else begin
            cnt_4_5ms <= 0;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt_560us <= 0;
        end else if(state == 3)begin
			cnt_560us <= cnt_560us+1;
        end else begin
            cnt_560us <= 0;
        end
    end
wire [7:0] address  ;
wire [7:0] address_f;
wire [7:0] data     ;
wire [7:0] data_f   ;
assign dout_en   = (state == 5) ? 1 : 0;
assign dout_data = (state == 5) ? addr[15:8]  : dout_data;
assign address   = (state == 5) ? addr[31:24] : address  ;
assign address_f = (state == 5) ? addr[23:16] : address_f;
assign data      = (state == 5) ? addr[15:8]  : data     ;
assign data_f    = (state == 5) ? addr[7:0]   : data_f   ;

endmodule
