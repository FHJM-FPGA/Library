//独立按键，点击和长按输出
module shake_long(
    input      clk         ,
    input      rstn        ,
    input      key         ,
    output reg shake_click ,
    output reg shake_LPress 
);
    parameter num_10ms = 999999;
    parameter num_3s = 49999999;
    reg [1:0] key_reg;
    always@(posedge clk)
        begin
            key_reg <= {key_reg[0],key};
        end
    wire key_HL;
    wire key_LH;
    assign key_HL =  key_reg[1] && !key_reg[0];
    assign key_LH = !key_reg[1] &&  key_reg[0];

    reg [2:0] state;
    reg [25:0] cnt_10ms;
    reg [29:0] cnt_3s;
    always@(posedge clk or negedge rstn)
        begin
            if(!rstn)begin
                state <= 0;
                shake_click  <= 0;
                shake_LPress <= 0;
            end else begin
                case(state)
                    0:begin
                        if(key_HL)begin
                            state <= 1;
                        end else begin
                            state <= 0;
                            shake_click  <= 0;
                            shake_LPress <= 0;
                        end
                    end
                    1:begin
                        if(cnt_10ms == num_10ms)begin
                            state <= 2;
                        end else begin
                            state <= 1;
                            shake_click  <= 0;
                        end
                    end
                    2:begin
                        if(key_LH)begin
                            state <= 3;
                        end else if(cnt_3s == num_3s)begin
                            state <= 4;
                        end else begin
                            state <= 2;
                            shake_click  <= 0;
                        end
                    end
                    3:begin
                        if(cnt_10ms == num_10ms)begin
                            state <= 0;
                            shake_click  <= 1;
                        end else begin
                            state <= 3;
                            shake_click  <= 0;
                        end
                    end 
                    4:begin
                        if(key_LH)begin
                            state <= 5;
                        end else begin
                            state <= 4;
                            shake_click  <= 0;
                        end
                    end
                    5:begin
                        if(cnt_10ms == num_10ms)begin
                            state <= 0;
                            shake_LPress <= 1;
                        end else begin
                            state <= 5;
                            shake_click  <= 0;
                        end
                    end
                    default:state <= 0;
                endcase
            end
        end
    always@(posedge clk or negedge rstn)
        begin
            if(!rstn)begin
                cnt_10ms <= 0;
            end else if(state == 1 || state == 3 || state == 5)begin
                if(cnt_10ms == num_10ms)begin
                    cnt_10ms <= 0;
                end else begin  
                    cnt_10ms <= cnt_10ms+1;
                end
            end else begin
                cnt_10ms <= 0;
            end
        end
    always@(posedge clk or negedge rstn)
        begin
            if(!rstn)begin
                cnt_3s <= 0;
            end else if(state == 2)begin
                if(cnt_3s == num_3s)begin
                    cnt_3s <= 0;
                end else begin  
                    cnt_3s <= cnt_3s+1;
                end
            end else begin
                cnt_3s <= 0;
            end
        end
endmodule
