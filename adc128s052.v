module adc128s052(
    input             clk      ,//系统时钟
    input             rstn     ,//系统复位
    
    input      [2:0]  Channel  ,//通道选择
    input             Start    ,//开始标志位
    output reg        Conv_done,//完成标志位
    output reg [11:0] DATA     ,//并行数字信号
    
    output reg        ADC_CS_N ,//片选
    output reg        ADC_DIN  ,//串行数据送给ADC芯片
    output reg        ADC_SCLK ,//工作时钟
    input             ADC_OUT   //串行数字信号
);

reg ADC_State;            //AD采集状态标志
reg [2:0] r_Channel;    //通道地址寄存
reg [11:0] r_data;    //采集数据缓存，一次性输出

parameter DIV_PARAM = 8;//分频系数 50/8 = 6.25Mhz
reg [7:0] DIV_cnt;        //分频计数器
reg SCLK2X;                    //SCLK二倍频
reg [5:0] SCLK_GEN_CNT;    //SCLK序列生成计数器

always@(posedge clk or negedge rstn)//数据缓存
    if(!rstn)
        r_Channel <= 3'd0;
    else if(Start)
        r_Channel <= Channel;
    else
        r_Channel <= r_Channel;

always@(posedge clk or negedge rstn)//分频计数器
    if(!rstn)
        DIV_cnt <= 8'd0;
    else if(ADC_State) begin
        if(DIV_cnt == DIV_PARAM/2 - 1)
            DIV_cnt <= 8'd0;
        else
            DIV_cnt <= DIV_cnt + 1'b1;
    end
    else
        DIV_cnt <= 8'd0;

always@(posedge clk or negedge rstn)//SCLK二倍频
    if(!rstn)
        SCLK2X <= 1'b0;
    else if(ADC_State && (DIV_cnt == DIV_PARAM/2 - 1))
        SCLK2X <= 1'b1;
    else
        SCLK2X <= 1'b0;
    
always@(posedge clk or negedge rstn)//生成序列计数器，对SCLK脉冲进行计数
    if(!rstn)
        SCLK_GEN_CNT <= 6'd0;
    else if(ADC_State)
        if(SCLK2X) begin
            if(SCLK_GEN_CNT == 33)
                SCLK_GEN_CNT <= 6'd0;
            else
                SCLK_GEN_CNT <= SCLK_GEN_CNT + 1'b1;
        end
        else
            SCLK_GEN_CNT <= SCLK_GEN_CNT;
    else
        SCLK_GEN_CNT <= 6'd0;

always@(posedge clk or negedge rstn)//线性序列机发送数据
    if(!rstn) begin
        ADC_SCLK <= 1'b1;
        ADC_CS_N <= 1'b1;
        ADC_DIN <= 1'b1;
    end
    else if(SCLK2X)
        case(SCLK_GEN_CNT)
            0: begin ADC_CS_N <= 1'b0; ADC_SCLK <= 1'b1; end
            1: ADC_SCLK <= 1'b0;
            2: ADC_SCLK <= 1'b1;
            3: ADC_SCLK <= 1'b0;
            4: ADC_SCLK <= 1'b1;
            5: begin ADC_SCLK <= 1'b0; ADC_DIN <= r_Channel[2]; end
            6: ADC_SCLK <= 1'b1;
            7: begin ADC_SCLK <= 1'b0; ADC_DIN <= r_Channel[1]; end
            8: ADC_SCLK <= 1'b1;
            9: begin ADC_SCLK <= 1'b0; ADC_DIN <= r_Channel[0]; end
            11,13,15,17,19,21,23,25,27,29,31: ADC_SCLK <= 1'b0;
            10:begin ADC_SCLK <= 1'b1; r_data[11] <= ADC_OUT; end
            12:begin ADC_SCLK <= 1'b1; r_data[10] <= ADC_OUT; end
            14:begin ADC_SCLK <= 1'b1; r_data[9] <= ADC_OUT; end
            16:begin ADC_SCLK <= 1'b1; r_data[8] <= ADC_OUT; end
            18:begin ADC_SCLK <= 1'b1; r_data[7] <= ADC_OUT; end
            20:begin ADC_SCLK <= 1'b1; r_data[6] <= ADC_OUT; end
            22:begin ADC_SCLK <= 1'b1; r_data[5] <= ADC_OUT; end
            24:begin ADC_SCLK <= 1'b1; r_data[4] <= ADC_OUT; end
            26:begin ADC_SCLK <= 1'b1; r_data[3] <= ADC_OUT; end
            28:begin ADC_SCLK <= 1'b1; r_data[2] <= ADC_OUT; end
            30:begin ADC_SCLK <= 1'b1; r_data[1] <= ADC_OUT; end
            32:begin ADC_SCLK <= 1'b1; r_data[0] <= ADC_OUT; end
            33:ADC_CS_N <= 1'b1;
            default:ADC_CS_N <= 1'b1;
        endcase

always@(posedge clk or negedge rstn)
    if(!rstn)
        ADC_State <= 1'b0;
    else if(Start)
        ADC_State <= 1'b1;
    else if((SCLK_GEN_CNT == 33) && SCLK2X && ADC_State)
        ADC_State <= 1'b0;
    
always@(posedge clk or negedge rstn)
    if(!rstn) begin
        Conv_done <= 1'b0;
        DATA <= 12'd0;
    end
    else if((SCLK_GEN_CNT == 33) && SCLK2X && ADC_State)
        begin
            Conv_done <= 1'b1;
            DATA <= r_data;
        end
    else begin
        Conv_done <= 1'b0;
        DATA <= DATA;
    end    

endmodule
