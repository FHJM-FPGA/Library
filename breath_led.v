//频率1秒的呼吸灯模块
module breath_led(
    input  clk ,     //系统时钟
    input  rstn,     //低电平复位
    output pwm       //输出pwm波，接led
);
reg [19:0]countH; //计数周期大
reg [19:0]countL; //计数周期小
parameter count = 7070;
reg       HL;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)
            countL <= 1'b0;
        else if(countL >= count)
            countL <= 1'b0;
        else
            countL <= countL + 1'b1;
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            countH <= 1'b0;
            HL     <= 1'b0;
        end else if(countH >= count)begin
            countH <= 1'b0;
            HL     <= !HL;
        end else if(countL == 1'b1)
            countH <= countH + 1'b1;
    end

assign pwm = (HL==1'b1)?((countH>=countL)?1'b1:1'b0):((countH<=countL)?1'b1:1'b0);
//HL==1时，代表吸，逐渐变亮；HL！=1时，代表呼，逐渐熄灭。
endmodule