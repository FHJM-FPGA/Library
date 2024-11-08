/*
汉字编码链接：
https://www.qqxiuzi.cn/bianma/zifuji.php
*/
//LCD14432驱动代码
module lcd14432(
    input         clk     ,   //--50MHz
    input         rstn    ,   //--系统复位信号
    output        LCD_RS  ,   //--寄存器选择信号
    output        LCD_RW  ,   //--液晶读写信号
    output        LCD_EN  ,   //--液晶时钟信号
    output [7:0]  LCD_Data    //--液晶数据信号        
);

reg rLCD_RS;         //--寄存器选择信号
reg rLCD_RW;         //--液晶读写信号
reg rLCD_EN;        //--液晶时钟信号
reg [7:0]rLCD_Data;    //--液晶数据信号

reg clk_500Hz;
reg [16:0]clk_500Hz_cnt;
always @(posedge clk or negedge rstn)
    if(!rstn)
        begin
            clk_500Hz <= 1'b0;
            clk_500Hz_cnt <= 17'd0;
        end
    else if(clk_500Hz_cnt == 17'd100_0)
        begin
            clk_500Hz <= !clk_500Hz;
            clk_500Hz_cnt <= 17'd0;
        end
    else
        begin
            clk_500Hz_cnt <= clk_500Hz_cnt + 1'b1;
        end
reg [7:0] data[31:0];
reg [5:0] i;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            for(i=0;i<32;i=i+1)
                data[i] <= " ";
        end else begin
            data[ 0] <= " ";
            data[ 1] <= " ";
            data[ 2] <= " ";
            data[ 3] <= " ";
            data[ 4] <= " ";
            data[ 5] <= " ";
            data[ 6] <= " ";
            data[ 7] <= " ";
            data[ 8] <= " ";
            data[ 9] <= " ";
            data[10] <= " ";
            data[11] <= " ";
            data[12] <= " ";
            data[13] <= " ";
            data[14] <= " ";
            data[15] <= " ";
            data[16] <= " ";
            data[17] <= " ";
            data[18] <= " ";
            data[19] <= " ";
            data[20] <= " ";
            data[21] <= " ";
            data[22] <= " ";
            data[23] <= " ";
            data[24] <= " ";
            data[25] <= " ";
            data[26] <= " ";
            data[27] <= " ";
            data[28] <= " ";
            data[29] <= " ";
            data[30] <= " ";
            data[31] <= " ";
        end
    end
reg [15:0]Cnt;
always @(posedge clk_500Hz or negedge rstn)
    if(!rstn)
        Cnt <= 16'd0;
    else if(Cnt >= 500)
        Cnt <= 16'd0;
    else
        begin
            Cnt <= Cnt + 1'b1;
            case(Cnt)
                16'd3  : rLCD_RS<=1'b0;
                16'd4  : rLCD_RW<=1'b0;
                16'd5  : rLCD_Data<=8'h30;//--基本指令集
                16'd7  : rLCD_EN<=1'b1;
                16'd10 : rLCD_EN<=1'b0;

                16'd13 : rLCD_RS<=1'b0;
                16'd14 : rLCD_RW<=1'b0;
                16'd15 : rLCD_Data<=8'h06;//--起始点设定
                16'd17 : rLCD_EN<=1'b1;
                16'd20 : rLCD_EN<=1'b0;
                
                16'd23 : rLCD_RS<=1'b0;
                16'd24 : rLCD_RW<=1'b0;
                16'd25 : rLCD_Data<=8'h01;//--清除显示DDRAM
                16'd27 : rLCD_EN<=1'b1;
                16'd30 : rLCD_EN<=1'b0;
                
                16'd33 : rLCD_RS<=1'b0;
                16'd34 : rLCD_RW<=1'b0;
                16'd35 : rLCD_Data<=8'h0C;//--显示状态开关
                16'd37 : rLCD_EN<=1'b1;
                16'd40 : rLCD_EN<=1'b0;
                
                16'd43 : rLCD_RS<=1'b0;
                16'd44 : rLCD_RW<=1'b0;
                16'd45 : rLCD_Data<=8'h02;//--地址归零
                16'd47 : rLCD_EN<=1'b1;
                16'd50 : rLCD_EN<=1'b0;
                
                16'd53 : rLCD_RS<=1'b0;
                16'd54 : rLCD_RW<=1'b0;
                16'd55 : rLCD_Data<=8'hC0;//--写地址
                16'd57 : rLCD_EN<=1'b1;
                16'd60 : rLCD_EN<=1'b0;
                
                //GB2312编码--百
                16'd63 : rLCD_RS<=1'b1;
                16'd64 : rLCD_RW<=1'b0;
                16'd65 : rLCD_Data<=data[0];//--写数据
                16'd67 : rLCD_EN<=1'b1;
                16'd70 : rLCD_EN<=1'b0;
                
                16'd73 : rLCD_RS<=1'b1;
                16'd74 : rLCD_RW<=1'b0;
                16'd75 : rLCD_Data<=data[1];//--写数据
                16'd77 : rLCD_EN<=1'b1;
                16'd80 : rLCD_EN<=1'b0;
                
                //GB2312编码--科
                16'd83 : rLCD_RS<=1'b1;
                16'd84 : rLCD_RW<=1'b0;
                16'd85 : rLCD_Data<=data[2];//--写数据
                16'd87 : rLCD_EN<=1'b1;
                16'd90 : rLCD_EN<=1'b0;
                
                16'd93 : rLCD_RS<=1'b1;
                16'd94 : rLCD_RW<=1'b0;
                16'd95 : rLCD_Data<=data[3];//--写数据
                16'd97 : rLCD_EN<=1'b1;
                16'd100 : rLCD_EN<=1'b0;
                
                //GB2312编码--荣
                16'd103 : rLCD_RS<=1'b1;
                16'd104 : rLCD_RW<=1'b0;
                16'd105 : rLCD_Data<=data[4];//--写数据
                16'd107 : rLCD_EN<=1'b1;
                16'd110 : rLCD_EN<=1'b0;
                
                16'd113 : rLCD_RS<=1'b1;
                16'd114 : rLCD_RW<=1'b0;
                16'd115 : rLCD_Data<=data[5];//--写数据
                16'd117 : rLCD_EN<=1'b1;
                16'd120 : rLCD_EN<=1'b0;
                
                //GB2312编码--创
                16'd123 : rLCD_RS<=1'b1;
                16'd124 : rLCD_RW<=1'b0;
                16'd125 : rLCD_Data<=data[6];//--写数据
                16'd127 : rLCD_EN<=1'b1;
                16'd130 : rLCD_EN<=1'b0;
                
                16'd133 : rLCD_RS<=1'b1;
                16'd134 : rLCD_RW<=1'b0;
                16'd135 : rLCD_Data<=data[7];//--写数据
                16'd137 : rLCD_EN<=1'b1;
                16'd140 : rLCD_EN<=1'b0;
                
                //GB2312编码--（
                16'd143 : rLCD_RS<=1'b1;
                16'd144 : rLCD_RW<=1'b0;
                16'd145 : rLCD_Data<=data[8];//--写数据
                16'd147 : rLCD_EN<=1'b1;
                16'd150 : rLCD_EN<=1'b0;
                
                16'd153 : rLCD_RS<=1'b1;
                16'd154 : rLCD_RW<=1'b0;
                16'd155 : rLCD_Data<=data[9];//--写数据
                16'd157 : rLCD_EN<=1'b1;
                16'd160 : rLCD_EN<=1'b0;
                
                //GB2312编码--北
                16'd163 : rLCD_RS<=1'b1;
                16'd164 : rLCD_RW<=1'b0;
                16'd165 : rLCD_Data<=data[10];//--写数据
                16'd167 : rLCD_EN<=1'b1;
                16'd170 : rLCD_EN<=1'b0;
                
                16'd173 : rLCD_RS<=1'b1;
                16'd174 : rLCD_RW<=1'b0;
                16'd175 : rLCD_Data<=data[11];//--写数据
                16'd177 : rLCD_EN<=1'b1;
                16'd180 : rLCD_EN<=1'b0;
                
                //GB2312编码--京
                16'd183 : rLCD_RS<=1'b1;
                16'd184 : rLCD_RW<=1'b0;
                16'd185 : rLCD_Data<=data[12];//--写数据
                16'd187 : rLCD_EN<=1'b1;
                16'd190 : rLCD_EN<=1'b0;
                
                16'd193 : rLCD_RS<=1'b1;
                16'd194 : rLCD_RW<=1'b0;
                16'd195 : rLCD_Data<=data[13];//--写数据
                16'd197 : rLCD_EN<=1'b1;
                16'd200 : rLCD_EN<=1'b0;
                
                //GB2312编码--）
                16'd203 : rLCD_RS<=1'b1;
                16'd204 : rLCD_RW<=1'b0;
                16'd205 : rLCD_Data<=data[14];//--写数据
                16'd207 : rLCD_EN<=1'b1;
                16'd210 : rLCD_EN<=1'b0;
                
                16'd213 : rLCD_RS<=1'b1;
                16'd214 : rLCD_RW<=1'b0;
                16'd215 : rLCD_Data<=data[15];//--写数据
                16'd217 : rLCD_EN<=1'b1;
                16'd220 : rLCD_EN<=1'b0;
                
                
                
                
                
                
                
                //重新设置第二行显示地址
                16'd223 : rLCD_RS<=1'b0;
                16'd224 : rLCD_RW<=1'b0;
                16'd225 : rLCD_Data<=8'h02;//--地址归零
                16'd227 : rLCD_EN<=1'b1;
                16'd230 : rLCD_EN<=1'b0;
                
                16'd233 : rLCD_RS<=1'b0;
                16'd234 : rLCD_RW<=1'b0;
                16'd235 : rLCD_Data<=8'hD0+8'h01;//--写地址,第二行偏移一列
                16'd237 : rLCD_EN<=1'b1;
                16'd240 : rLCD_EN<=1'b0;
                
                //GB2312编码--科
                16'd243 : rLCD_RS<=1'b1;
                16'd244 : rLCD_RW<=1'b0;
                16'd245 : rLCD_Data<=data[16];//--写数据
                16'd247 : rLCD_EN<=1'b1;
                16'd250 : rLCD_EN<=1'b0;
                
                16'd253 : rLCD_RS<=1'b1;
                16'd254 : rLCD_RW<=1'b0;
                16'd255 : rLCD_Data<=data[17];//--写数据
                16'd257 : rLCD_EN<=1'b1;
                16'd260 : rLCD_EN<=1'b0;
                
                //GB2312编码--技
                16'd263 : rLCD_RS<=1'b1;
                16'd264 : rLCD_RW<=1'b0;
                16'd265 : rLCD_Data<=data[18];//--写数据
                16'd267 : rLCD_EN<=1'b1;
                16'd270 : rLCD_EN<=1'b0;
                
                16'd273 : rLCD_RS<=1'b1;
                16'd274 : rLCD_RW<=1'b0;
                16'd275 : rLCD_Data<=data[19];//--写数据
                16'd277 : rLCD_EN<=1'b1;
                16'd280 : rLCD_EN<=1'b0;
                
                //GB2312编码--发
                16'd283 : rLCD_RS<=1'b1;
                16'd284 : rLCD_RW<=1'b0;
                16'd285 : rLCD_Data<=data[20];//--写数据
                16'd287 : rLCD_EN<=1'b1;
                16'd290 : rLCD_EN<=1'b0;
                
                16'd293 : rLCD_RS<=1'b1;
                16'd294 : rLCD_RW<=1'b0;
                16'd295 : rLCD_Data<=data[21];//--写数据
                16'd297 : rLCD_EN<=1'b1;
                16'd300 : rLCD_EN<=1'b0;
                
                //GB2312编码--展
                16'd303 : rLCD_RS<=1'b1;
                16'd304 : rLCD_RW<=1'b0;
                16'd305 : rLCD_Data<=data[22];//--写数据
                16'd307 : rLCD_EN<=1'b1;
                16'd310 : rLCD_EN<=1'b0;
                
                16'd313 : rLCD_RS<=1'b1;
                16'd314 : rLCD_RW<=1'b0;
                16'd315 : rLCD_Data<=data[23];//--写数据
                16'd317 : rLCD_EN<=1'b1;
                16'd320 : rLCD_EN<=1'b0;
                
                //GB2312编码--有
                16'd323 : rLCD_RS<=1'b1;
                16'd324 : rLCD_RW<=1'b0;
                16'd325 : rLCD_Data<=data[24];//--写数据
                16'd327 : rLCD_EN<=1'b1;
                16'd340 : rLCD_EN<=1'b0;
                
                16'd343 : rLCD_RS<=1'b1;
                16'd344 : rLCD_RW<=1'b0;
                16'd345 : rLCD_Data<=data[25];//--写数据
                16'd347 : rLCD_EN<=1'b1;
                16'd350 : rLCD_EN<=1'b0;
                
                //GB2312编码--限
                16'd353 : rLCD_RS<=1'b1;
                16'd354 : rLCD_RW<=1'b0;
                16'd355 : rLCD_Data<=data[26];//--写数据
                16'd357 : rLCD_EN<=1'b1;
                16'd360 : rLCD_EN<=1'b0;
                
                16'd363 : rLCD_RS<=1'b1;
                16'd364 : rLCD_RW<=1'b0;
                16'd365 : rLCD_Data<=data[27];//--写数据
                16'd367 : rLCD_EN<=1'b1;
                16'd370 : rLCD_EN<=1'b0;
                
                //GB2312编码--公
                16'd373 : rLCD_RS<=1'b1;
                16'd374 : rLCD_RW<=1'b0;
                16'd375 : rLCD_Data<=data[28];//--写数据
                16'd377 : rLCD_EN<=1'b1;
                16'd380 : rLCD_EN<=1'b0;
                
                16'd383 : rLCD_RS<=1'b1;
                16'd384 : rLCD_RW<=1'b0;
                16'd385 : rLCD_Data<=data[29];//--写数据
                16'd387 : rLCD_EN<=1'b1;
                16'd390 : rLCD_EN<=1'b0;
    
                //GB2312编码--司
                16'd393 : rLCD_RS<=1'b1;
                16'd394 : rLCD_RW<=1'b0;
                16'd395 : rLCD_Data<=data[30];//--写数据
                16'd397 : rLCD_EN<=1'b1;
                16'd400 : rLCD_EN<=1'b0;
                
                16'd403 : rLCD_RS<=1'b1;
                16'd404 : rLCD_RW<=1'b0;
                16'd405 : rLCD_Data<=data[31];//--写数据
                16'd407 : rLCD_EN<=1'b1;
                16'd410 : rLCD_EN<=1'b0;
            endcase
        end



assign LCD_RS = rLCD_RS;
assign LCD_RW = rLCD_RW;
assign LCD_EN = rLCD_EN;
assign LCD_Data = rLCD_Data;


endmodule
