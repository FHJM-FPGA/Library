//超声波测距模块
module HC_SR04(
    input            clk   ,
    input            rstn  ,
    input            echo  ,
    output reg       trig  ,
    output reg [9:0] length 
);
//length   2cm~400cm
reg [25:0] cnt_t;
parameter  num_t = 50000000;//距离刷新时间间隔
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt_t <= 0;
        end else if(cnt_t >= num_t)begin
            cnt_t <= 0;
        end else begin
            cnt_t <= cnt_t+1;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            trig <= 0;
        end else if(cnt_t < 750)begin
            trig <= 1;
        end else begin
            trig <= 0;
        end
    end
reg [1:0] echo_d;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            echo_d <= 0;
        end else begin
            echo_d <= {echo_d[0],echo};
        end
    end
reg [9:0] cnt_r;
reg       clk1us;
always@(posedge clk1us or negedge rstn)
    begin
        if(!rstn)begin
            cnt_r <= 0;
        end else if(echo_d[1])begin
            cnt_r <= cnt_r+1;
        end else begin
            cnt_r <= 0;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            length <= 0;
        end else if(echo_d == 2)begin
            length <= cnt_r*17/1000;//cnt_r/1000000 * 340/2(单位米) ==> cnt_r/1000000 * 34000/2(单位厘米)  1000
        end
    end
reg [5:0] cnt;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt <= 0;
            clk1us <= 0;
        end else if(cnt >= 24)begin
            cnt <= 0;
            clk1us <= !clk1us;
        end else begin
            cnt <= cnt+1;
        end
    end
endmodule
