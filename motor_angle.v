//四相五线步进电机驱动模块
module motor_angle(
    input             clk       ,   //系统时钟50MHz
    input             rstn      ,   //系统复位，低有效
    input             en        ,   //输入使能
    input             dir       ,   //方向控制
    input       [3:0] count     ,   //运动圈数（暂时未用）
    input       [8:0] angle     ,   //输入角度
    output  reg       motor_done,   //命令执行完毕
    output  reg [3:0] IN            //控制输出到步进电机
);
reg [9:0] reg_angle;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            reg_angle <= 0;
        end else begin
            reg_angle <= angle*64/45; //512/360
        end
    end
parameter num_once = 511;
reg busy;
wire flag;
reg [2:0] state_IN;
reg [13:0] cnt_4096;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            busy <= 0;
        end else if(en)begin
            busy <= 1;
        end else if(cnt_4096 >= reg_angle && flag && state_IN == 3)begin
            busy <= 0;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            motor_done <= 0;
        end else if(cnt_4096 >= reg_angle && flag && state_IN == 3)begin
            motor_done <= 1;
        end else begin
            motor_done <= 0;
        end
    end
parameter num = 129999;
reg [25:0] cnt;
always@(posedge clk or negedge rstn)
	begin
		if(!rstn)begin
			cnt <= 0;
		end else if(busy)begin
			if(cnt == num)begin
				cnt <= 0;
			end else begin
				cnt <= cnt+1;
			end
		end else begin
            cnt <= 0;
        end
	end
assign flag = (cnt == num) ? 1 : 0;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            IN       <= 0;
            state_IN <= 0;
        end else if(busy)begin
            if(flag)begin
                if(dir)begin
                    case(state_IN)
                        0:begin IN<=4'b0001; state_IN<=1; end
                        1:begin IN<=4'b0010; state_IN<=2; end
                        2:begin IN<=4'b0100; state_IN<=3; end
                        3:begin IN<=4'b1000; state_IN<=0; end
                    endcase
                end else begin
                    case(state_IN)
                        0:begin IN<=4'b1000; state_IN<=1; end
                        1:begin IN<=4'b0100; state_IN<=2; end
                        2:begin IN<=4'b0010; state_IN<=3; end
                        3:begin IN<=4'b0001; state_IN<=0; end
                    endcase
                end
            end
        end else begin
            IN       <= 0;
            state_IN <= 0;
        end
    end

always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt_4096 <= 0;
        end else if(busy)begin
            if(cnt_4096 == num_once && flag && state_IN == 3)begin
                cnt_4096 <= 0;
            end else if(flag && state_IN == 3)begin
                cnt_4096 <= cnt_4096+1;
            end
        end else begin
            cnt_4096 <= 0;
        end
    end

endmodule
