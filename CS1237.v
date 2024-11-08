module  CS1237
(
    input   wire            sys_clk     ,   //系统时钟，频率25MHz
    input   wire            sys_rst_n   ,   //复位信号，低电平有效
 
    inout   reg             adc         ,   //数据端口
    output  reg             sclk        ,   //时钟端口
    
    output  reg     [7:0]   bat_power        
 
);
 
parameter   S_STOP      =   3'd0,   //时钟高电平，休眠状态
            S_WAIT_R    =   3'd1,   //时钟低电平，等待数据转换完成
            S_READ      =   3'd2,   //1-24时钟，读取数据
            S_WAIT_W    =   3'd3,   //25-29时钟，准备写
            S_WRITE     =   3'd4,   //30-37时钟，发送写寄存器指令，37时钟用于过渡
            S_CONFIG    =   3'd5;   //38-47时钟，写寄存器，47时钟是为了让46时钟完整
 
parameter   T_STOP      =   8'd250; //us，休眠状态时长，根据自己需求修改
reg     [2:0]   state       ;   //状态机状态
reg             adc_d1      ;   //总线信号打一拍
wire            adc_fall    ;   //总线下降沿
reg     [4:0]   cnt         ;   //时钟分频计数器
reg             clk_1us     ;   //1us时钟
reg     [7:0]   cnt_us      ;   //us计数器
reg             en_sclk     ;   //输出时钟使能
reg     [5:0]   bit_cnt     ;   //字节计数器
    
reg     [23:0]  data_adc    ;   //adc采集的数据
//对adc信号打拍，检测总线信号的下降沿
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        adc_d1  <=  1'b0 ;
    else
        adc_d1  <=  adc  ;
assign  adc_fall =   (adc_d1)  & (~adc)   ;
//cnt:分频计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt <=  5'd0;
    else    if(cnt == 5'd24)
        cnt <=  5'd0;
    else
        cnt <=  cnt + 1'b1;
 
//clk_1us：产生单位时钟为1us的时钟
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        clk_1us <=  1'b0;
    else    if(cnt == 5'd24)
        clk_1us <=  1'b0;
    else    if(cnt == 5'd12)
        clk_1us <=  1'b1;
    else
        clk_1us <=  clk_1us;
 
//微秒计数器
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        cnt_us <= 8'd0;
    else    if(state == S_STOP && cnt_us == T_STOP)
        cnt_us   <=  8'd0;
    else    if(state == S_STOP)
        cnt_us   <=  cnt_us + 8'd1;
    else
        cnt_us   <=  8'd0;
//输出sclk管脚输出1us时钟使能，确保输出的时钟的第一个周期完整
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        en_sclk <= 1'b0;
    else    if(state == S_STOP)
        en_sclk <= 1'b0;
    else    if(state == S_READ && clk_1us == 1'b0)
        en_sclk <= 1'b1;
    else
        en_sclk <= en_sclk;
 
 
//状态机状态跳转
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        state   <=  S_STOP  ;
    else
        case(state)
        S_STOP:
            if(cnt_us == T_STOP)
                state   <=  S_WAIT_R;
            else
                state   <=  S_STOP;
        
        S_WAIT_R:
            if(adc_fall == 1'b1 && sclk == 1'b0)
                state   <=  S_READ;
            else
                state   <=  S_WAIT_R;
        
        S_READ:
            if(bit_cnt == 6'd25)
                state   <=  S_WAIT_W;
            else
                state   <=  S_READ;
        
        S_WAIT_W:
            if(bit_cnt == 6'd29)
                state   <=  S_WRITE;
            else
                state   <=  S_WAIT_W;
        
        S_WRITE:
            if(bit_cnt == 6'd37)
                state   <=  S_CONFIG;
            else
                state   <=  S_WRITE;
        
        S_CONFIG:
            if(bit_cnt == 6'd47)
                state   <=  S_STOP;
            else
                state   <=  S_CONFIG;
        
        default:
            state   <=  S_STOP;
        endcase
//数据端口控制，默认高阻态
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        adc <= 1'dz;
    else
        case(state)
        S_STOP:     adc <= 1'dz;
        S_WAIT_R:   adc <= 1'dz;
        S_READ:     adc <= 1'dz;
        S_WAIT_W:   adc <= 1'dz;
        S_WRITE:    if(bit_cnt == 6'd30)    //写入0x65，写寄存器指令
                        adc <= 1'd1;
                    else    if(bit_cnt == 6'd32)
                        adc <= 1'd0;
                    else    if(bit_cnt == 6'd34)
                        adc <= 1'd1;
                    else    if(bit_cnt == 6'd35)
                        adc <= 1'd0;
                    else    if(bit_cnt == 6'd36)
                        adc <= 1'd1;
                    else
                        adc <= adc;
        
        S_CONFIG:   adc <= 1'd0;    //寄存器写入全0，将128倍的PGA改为1倍，其他不变
 
        default:
            adc <= 1'dz;
        endcase
//sclk时钟输出
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        sclk <= 1'b0;
    else
        case(state)
            S_STOP      :   sclk <= 1'b1;
            S_WAIT_R    :   sclk <= 1'b0;
            default     :   if(en_sclk == 1'b1)
                                sclk <= clk_1us;
                            else
                                sclk <= 1'b0;
        endcase
//bit_cnt：读出数据bit位数计数器
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bit_cnt <=  6'd0;
    else    if(bit_cnt == 6'd47)
        bit_cnt <=  6'd0;
    else    if(state != S_STOP && state != S_WAIT_R && en_sclk == 1'b1)
        bit_cnt <=  bit_cnt + 1'b1;
    else
        bit_cnt <=  6'd0;
 
//data_adc:将读出的数据寄存在data_adc中
always@(posedge sys_clk or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        data_adc    <=  24'd0;
    else    if(cnt == 6'd12 && en_sclk == 1'b1 && bit_cnt <= 6'd24)
        data_adc[24 - bit_cnt]   <=  adc;
    else
        data_adc    <=  data_adc;
//数据转换：锂电池电量显示1%-99%
//(这里认定电池电量与电压关系为线性，实际情况为非线性)
//认定正常使用锂电池情况下，满电量电压为4.2V，最低使用电压为3.2V
//差值4.2-3.2=1V，分100份，每份10mV
//ADC采集的电量减去3.2V，再除10mV，得到当前所占份数，即百分比电量
//CS1237采集满量程为7FFFFFh(5V基准)
//10mV对应(5V)比例数值为4189h(0100 0001 1000 1001b)
//近似忽略后几位数值，看成4000h(0100 0000 0000 0000b)误差2.34%
//除以4000h即可看成除以2的14次方，即data_adc[23:0]的后14位数忽略即可
always@(posedge clk_1us or  negedge sys_rst_n)
    if(sys_rst_n == 1'b0)
        bat_power    <=  8'd0;
    else    
    if(bit_cnt == 6'd25)    //读取完数据后更新数据
        if(data_adc[23] == 1'b1)    //负电压显示1%电量
            bat_power    <=  8'd1;
        else    if(data_adc[22:14]<9'h147) //低于3.2V显示1%电量
            bat_power    <=  8'd1;
        else    if(data_adc[22:14]>9'h1AE) //高于4.2V显示99%电量
            bat_power    <=  8'd99;
        else
            bat_power    <=  (data_adc[22:14]-9'h147); //显示1-99%电量
    else
        bat_power    <=  bat_power; 
endmodule