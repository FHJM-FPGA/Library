//测重模块
module hx711(
    input             clk   ,
    input             rstn  ,
    input             Dout  ,
    output reg        PD_SCK,
    output reg [15:0] hx_out 
);

reg        clk_1us;
reg [9:0]  cnt_1us;
parameter  num_1us = 24;//50/2-1
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt_1us <= 0;
        end else if(cnt_1us >= num_1us)begin
            cnt_1us <= 0;
        end else begin
            cnt_1us <= cnt_1us+1;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            clk_1us <= 0;
        end else if(cnt_1us >= num_1us)begin
            clk_1us <= !clk_1us;
        end
    end
reg [3:0] state;
reg [5:0] state_tx;
always@(posedge clk_1us or negedge rstn)
    begin
        if(!rstn)begin
            state    <= 0;
            state_tx <= 0;
        end else begin
            case(state)
                0:begin
                    if(!Dout)begin
                        state <= 1;
                    end else begin
                        state <= 0;
                    end
                    state_tx <= 0;
                end
                1:begin
                    if(!Dout)begin
                        state <= 2;
                    end else begin
                        state <= 0;
                    end
                    state_tx <= 0;
                end
                2:begin
                    if(state_tx >= 51)begin
                        state    <= 0;
                        state_tx <= 0;
                    end else begin
                        state_tx <= state_tx+1;
                    end
                end
                default:
                    state <= 0;
            endcase
        end
    end
reg [23:0] weight;
always@(posedge clk_1us or negedge rstn)
    begin
        if(!rstn)begin
            PD_SCK <= 0;
            weight <= 0;
        end else if(state > 1)begin
            case(state_tx)
                0 :begin PD_SCK<=1; weight     <= weight; end
                1 :begin PD_SCK<=0; weight[23] <= Dout  ; end
                2 :begin PD_SCK<=1; weight     <= weight; end
                3 :begin PD_SCK<=0; weight[22] <= Dout  ; end
                4 :begin PD_SCK<=1; weight     <= weight; end
                5 :begin PD_SCK<=0; weight[21] <= Dout  ; end
                6 :begin PD_SCK<=1; weight     <= weight; end
                7 :begin PD_SCK<=0; weight[20] <= Dout  ; end
                8 :begin PD_SCK<=1; weight     <= weight; end
                9 :begin PD_SCK<=0; weight[19] <= Dout  ; end
                10:begin PD_SCK<=1; weight     <= weight; end
                11:begin PD_SCK<=0; weight[18] <= Dout  ; end
                12:begin PD_SCK<=1; weight     <= weight; end
                13:begin PD_SCK<=0; weight[17] <= Dout  ; end
                14:begin PD_SCK<=1; weight     <= weight; end
                15:begin PD_SCK<=0; weight[16] <= Dout  ; end
                16:begin PD_SCK<=1; weight     <= weight; end
                17:begin PD_SCK<=0; weight[15] <= Dout  ; end
                18:begin PD_SCK<=1; weight     <= weight; end
                19:begin PD_SCK<=0; weight[14] <= Dout  ; end
                20:begin PD_SCK<=1; weight     <= weight; end
                21:begin PD_SCK<=0; weight[13] <= Dout  ; end
                22:begin PD_SCK<=1; weight     <= weight; end
                23:begin PD_SCK<=0; weight[12] <= Dout  ; end
                24:begin PD_SCK<=1; weight     <= weight; end
                25:begin PD_SCK<=0; weight[11] <= Dout  ; end
                26:begin PD_SCK<=1; weight     <= weight; end
                27:begin PD_SCK<=0; weight[10] <= Dout  ; end
                28:begin PD_SCK<=1; weight     <= weight; end
                29:begin PD_SCK<=0; weight[9]  <= Dout  ; end
                30:begin PD_SCK<=1; weight     <= weight; end
                31:begin PD_SCK<=0; weight[8]  <= Dout  ; end
                32:begin PD_SCK<=1; weight     <= weight; end
                33:begin PD_SCK<=0; weight[7]  <= Dout  ; end
                34:begin PD_SCK<=1; weight     <= weight; end
                35:begin PD_SCK<=0; weight[6]  <= Dout  ; end
                36:begin PD_SCK<=1; weight     <= weight; end
                37:begin PD_SCK<=0; weight[5]  <= Dout  ; end
                38:begin PD_SCK<=1; weight     <= weight; end
                39:begin PD_SCK<=0; weight[4]  <= Dout  ; end
                40:begin PD_SCK<=1; weight     <= weight; end
                41:begin PD_SCK<=0; weight[3]  <= Dout  ; end
                42:begin PD_SCK<=1; weight     <= weight; end
                43:begin PD_SCK<=0; weight[2]  <= Dout  ; end
                44:begin PD_SCK<=1; weight     <= weight; end
                45:begin PD_SCK<=0; weight[1]  <= Dout  ; end
                46:begin PD_SCK<=1; weight     <= weight; end
                47:begin PD_SCK<=0; weight[0]  <= Dout  ; end
                48:begin PD_SCK<=1; weight     <= weight; end
                49:begin PD_SCK<=0; weight     <= weight; end
                50:begin PD_SCK<=0; weight     <= weight; end
                51:begin PD_SCK<=0; weight     <= weight; end
                default:begin
                    PD_SCK <= 0;
                end
            endcase
        end else begin
            PD_SCK <= 0;
        end
    end
always@(posedge clk_1us or negedge rstn)
    begin
        if(!rstn)begin
            hx_out <= 0;
        end else if(state_tx == 50)begin
            hx_out <= weight/429 + 26534;//429计算系数429.5   补偿值要计算，每个模块起始值不一样
        end
    end
endmodule
