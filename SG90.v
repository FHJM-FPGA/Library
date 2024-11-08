//舵机驱动
module SG90(
    input            clk   ,
    input            rstn  ,
    input            flag1 ,
    input            flag2 ,
    output  reg      sg_pwm
);

reg [19:0] cnt;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt <= 0;
        end else if(cnt >= 1000000)begin
            cnt <= 0;
        end else begin
            cnt <= cnt+1;
        end
    end
reg pwm_0  ;
reg pwm_45 ;
reg pwm_90 ;
reg pwm_135;
reg pwm_180;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            pwm_0   <= 0;
            pwm_45  <= 0;
            pwm_90  <= 0;
            pwm_135 <= 0;
            pwm_180 <= 0;
        end else begin
            pwm_0   <= (cnt <= 25000) ? 1 : 0;
            pwm_45  <= (cnt <= 50000) ? 1 : 0;
            pwm_90  <= (cnt <= 75000) ? 1 : 0;
            pwm_135 <= (cnt <= 100000) ? 1 : 0;
            pwm_180 <= (cnt <= 125000) ? 1 : 0;
        end
    end
reg [2:0] state;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            state <= 0;
        end else if(flag1)begin
            state <= 1;
        end else if(flag2)begin
            state <= 0;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            sg_pwm <= 0;
        end else begin
            case(state)
                0:sg_pwm <= pwm_180;
                1:sg_pwm <= pwm_90;
            endcase
        end
    end
endmodule
