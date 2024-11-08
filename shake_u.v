//独立按键点击
module shake_u(        
    input      clk   ,
    input      rstn  ,
    input      key   ,
    output reg shape  
);
//parameter delay=45;         //仿真使用
parameter delay=999999;     //下开发板使用
reg [20:0]t20ms;
reg [ 1:0]key_d;
reg [ 1:0]state;

always@(posedge clk)
    key_d <= {key_d[0],key};
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            state <= 0;
        end else begin
            case(state)
                0: state <= (key_d == 2    ) ? 1 : 0;
                1: state <= (t20ms >= delay) ? 2 : 1;
                2: state <= (key_d == 1    ) ? 3 : 2;
                3: state <= (t20ms >= delay) ? 0 : 3;
                default:begin
                    state <= 0;
                end
            endcase
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            t20ms <= 0;
        end else if(state==1 || state==3)begin
            t20ms <= t20ms+1;
        end else begin
            t20ms <= 0;
        end
    end
always@(posedge clk)
    shape <= (state==3 && t20ms>=delay) ? 1 : 0;

endmodule
