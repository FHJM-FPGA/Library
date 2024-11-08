//LCD1602驱动
module lcd1602(
    input             clk      ,  //系统时钟输入
    input             rstn     ,  //系统复位信号，低电平有效
    output  reg       lcd_rs   ,  //lcd的寄存器选择输出信号
    output            lcd_rw   ,  //lcd的读、写操作选择输出信号
    output            lcd_en   ,  //lcd使能信号
    output  reg [7:0] lcd_data    //lcd的数据总线(不进行读操作，故为输出)
);
//寄存器定义
// reg        lcd_rs    ;
reg        clk_div   ;
reg [17:0] delay_cnt ;
// reg [7:0]  lcd_data  ;
reg [4:0]  char_cnt  ; 
reg [7:0]  data_disp ;
reg [9:0]  state     ; 
parameter   idle         = 10'b000000000, //初始状态，下一个状态为CLEAR
            clear        = 10'b000000001, //清屏
            set_function = 10'b000000010, //功能设置:8位数据接口/2行显示/5*8点阵字符
            switch_mode  = 10'b000000100, //显示开关控制:开显示，光标和闪烁关闭
            set_mode     = 10'b000001000, //输入方式设置:数据读写操作后，地址自动加一/画面不动
            shift        = 10'b000010000, //光标、画面位移设置:光标向左平移一个字符位(光标显示是关闭的，所以实际上设置是看不出效果的)
            set_ddram1   = 10'b000100000, //设置DDRAM的地址:第一行起始为0x00(注意输出时DB7一定要为1)
            set_ddram2   = 10'b001000000, //设置DDRAM的地址:第二行为0x40(注意输出时DB7一定要为1)
            write_ram1   = 10'b010000000, //数据写入DDRAM相应的地址
            write_ram2   = 10'b100000000; //数据写入DDRAM相应的地址
assign lcd_rw = 1'b0; //没有读操作，R/W信号始终为低电平
assign lcd_en = clk_div; //E信号出现高电平以及下降沿的时刻与LCD时钟相同
//时钟分频
always@(posedge clk or negedge rstn)
begin 
    if(!rstn)begin
        delay_cnt<=18'd0;
        clk_div<=1'b0;
    end else if(delay_cnt==18'd249999)begin
        delay_cnt<=18'd0;
        clk_div<=~clk_div;
    end else begin
        delay_cnt<=delay_cnt+1'b1;
        clk_div<=clk_div;
    end
end
always@(posedge clk_div or negedge rstn) //State Machine 
    begin
        if(!rstn)begin
            state    <= idle;
            lcd_data <= 8'b0;
            char_cnt <= 5'd0; 
            lcd_rs   <=1'b0;
        end else begin
            case(state)
                idle:begin //初始状态
                    state    <= clear;
                    lcd_data <= 8'b0;
                end
                clear:begin //清屏
                    state    <= set_function;
                    lcd_rs   <=1'b0;
                    lcd_data <= 8'b00000001; 
                end 
                set_function:begin //功能设置(38H):8位数据接口/2行显示/5*8点阵字符
                    state    <= switch_mode;
                    lcd_rs   <=1'b0;
                    lcd_data <= 8'b00111000; 
                end
                switch_mode:begin //显示开关控制(0CH):开显示，光标和闪烁关闭
                    state    <= set_mode;
                    lcd_rs   <=1'b0;
                    lcd_data <= 8'b00001110;
                end 
                set_mode:begin //输入方式设置(06H):数据读写操作后，地址自动加一/画面不动
                    state    <= shift; 
                    lcd_rs   <=1'b0;
                    lcd_data <= 8'b00000110;
                end
                shift:begin //光标、画面位移设置(10H):光标向左平移一个字符位(光标显示是关闭的，所以实际上设置是看不出效果的)
                    state    <= set_ddram1;
                    lcd_rs   <=1'b0;
                    lcd_data <= 8'b0001_0000; 
                end 
                set_ddram1:begin //设置DDRAM的地址:第一行起始为00H(注意输出时DB7一定要为1) 
                    state    <= write_ram1; 
                    lcd_rs   <=1'b0;
                    lcd_data <= 8'b1000_0011;//Line1
                end
                set_ddram2:begin //设置DDRAM的地址:第二行为40H(注意输出时DB7一定要为1)
                    state    <= write_ram2;
                    lcd_rs   <=1'b0;
                    lcd_data <= 8'b1100_0000;//Line2 
                end
                write_ram1:begin 
                    if(char_cnt <=5'd10)begin
                        char_cnt <= char_cnt + 1'b1; 
                        lcd_rs   <=1'b1;
                        lcd_data <= data_disp;
                        state    <= write_ram1;
                    end else begin
                        state <= set_ddram2; 
                    end 
                end
                write_ram2:begin 
                    if(char_cnt <=5'd26)begin
                        char_cnt <= char_cnt + 1'b1; 
                        lcd_rs   <=1'b1;
                        lcd_data <= data_disp;
                        state    <= write_ram2;
                    end else begin
                        char_cnt <=5'd0;
                        state    <= shift; 
                    end 
                end
                default: state <= idle;
            endcase
        end
    end
always @(char_cnt) //输出的字符
    begin
        case (char_cnt)
            5'd0: data_disp = "W"; //a+8'b0011_0000;
            5'd1: data_disp = "e"; 
            5'd2: data_disp = "l"; 
            5'd3: data_disp = "c"; 
            5'd4: data_disp = "o"; 
            5'd5: data_disp = "m"; 
            5'd6: data_disp = "e"; 
            5'd7: data_disp = " "; 
            5'd8: data_disp = "t"; 
            5'd9: data_disp = "o"; 
            5'd10: data_disp = " "; 
            5'd11: data_disp = "F"; 
            5'd12: data_disp = "H"; 
            5'd13: data_disp = "J"; 
            5'd14: data_disp = "M"; 
            5'd15: data_disp = "F"; 
            5'd16: data_disp = "p"; 
            5'd17: data_disp = "G"; 
            5'd18: data_disp = "A"; 
            5'd19: data_disp = "2"; 
            5'd20: data_disp = "0"; 
            5'd21: data_disp = "2"; 
            5'd22: data_disp = "4"; 
            5'd23: data_disp = "0"; 
            5'd24: data_disp = "3";
            5'd25: data_disp = "1";
            5'd26: data_disp = "3";
            default : data_disp =" "; 
        endcase
    end
endmodule
