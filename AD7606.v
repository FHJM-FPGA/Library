module AD7606(
    input        clk,
    input        res,
    input        dout_a,     //ad7606通道a输入串行读取数据
    input        dout_b,    //ad7606通道b输入串行读取数据
    input        ad_busy,   //ad7606输入busy信号
    input        caiji_flag,  //外界输入开始数据采集的标志
    
    output   reg ad_cs,     //读ad7606的使能信号
    output   reg ad_rd,     //读ad7606的时钟信号
    output   reg ad_convstab  //ad7606开始转换信号,低电平有效
);
 
parameter     IDLE         = 9'b0_0000_0001;
parameter     AD_CONV      = 9'b0_0000_0010;
parameter     WAIT_1       = 9'b0_0000_0100;
parameter     WAIT_BUSY    = 9'b0_0000_1000;
parameter     READ_CH15    = 9'b0_0001_0000;
parameter     READ_CH26    = 9'b0_0010_0000;
parameter     READ_CH37    = 9'b0_0100_0000;
parameter     READ_CH48    = 9'b0_1000_0000;
parameter     READ_STOP    = 9'b1_0000_0000; 
parameter     CONV_TIME         =  5; //AD_CONV状态持续时间等价转换信号低电平持续时间
parameter     WAIT_TIME         =  5; //WAIT_1状态持续时间
parameter     FIV_CLK           =  4;
parameter     CNT_CLK           =  16;   //每个通道一次发送的时钟个数
reg           [8:0]stata;
reg           [5:0]cnt  ;   //在数据读取状态表示分频系数
reg           [4:0]cnt_bite;
reg           [15:0]databuffa;  //a通道串并转换后存储
reg           [15:0]databuffb;  //b通道串并转换后存储
//存储八个通道采集到的数据
reg           [15:0] data_ch1;
reg           [15:0] data_ch2;
reg           [15:0] data_ch3;
reg           [15:0] data_ch4;
reg           [15:0] data_ch5;
reg           [15:0] data_ch6;
reg           [15:0] data_ch7;
reg           [15:0] data_ch8;
reg           [2 :0] over;
wire               caiji_over;
always@(posedge clk or negedge res)
    if(!res)
       cnt <= 'd0;
    else if(stata == AD_CONV)
       if(cnt == CONV_TIME)
          cnt <= 'd0;
       else 
          cnt <= cnt + 1;
    else if(stata == WAIT_1)
       if(cnt == WAIT_TIME)
          cnt <= 'd0;
       else  
          cnt <= cnt + 1;
    else if(stata == WAIT_BUSY)  //为了在下一个状态，cnt从6开始计数,为了让CS和RD信号前后有延时
       if(ad_busy == 1'b0)
          cnt <= 'd6;
       else 
          cnt <= cnt;
    else if(stata == READ_CH15 || stata == READ_CH26 || stata == READ_CH37 || stata == READ_CH48)
       if(cnt == (2*FIV_CLK-1))
          cnt <= 'd0;
       else
          cnt <= cnt + 1;
always@(posedge clk or negedge res)
    if(!res)
       cnt_bite <=  'd0;
    else if(stata == READ_CH15 )
       if(cnt_bite == (CNT_CLK) && cnt == (2*FIV_CLK-1))
          cnt_bite <= 'd0;
       else if(cnt == (2*FIV_CLK-1))
          cnt_bite <= cnt_bite + 1;
       else 
          cnt_bite <= cnt_bite;
    else if( stata == READ_CH26 || stata == READ_CH37 || stata == READ_CH48)
       if(cnt_bite == (CNT_CLK -1) && cnt == (2*FIV_CLK-1))
          cnt_bite <= 'd0;
       else if(cnt == (2*FIV_CLK-1))
          cnt_bite <= cnt_bite + 1;
       else 
          cnt_bite <= cnt_bite;
    else 
       cnt_bite <= 'd0;
    
          
always@(posedge clk or negedge res)
    if(!res)
       stata <= 4'd0;
    else begin
       case(stata)
          IDLE         :  if(caiji_flag == 1'b1)
                              stata <= AD_CONV;
                          else 
                              stata <= IDLE;
          AD_CONV      :  if(cnt == CONV_TIME)
                              stata <= WAIT_1;
                          else 
                              stata <= AD_CONV;
          WAIT_1       :  if(cnt == WAIT_1)
                              stata <= WAIT_BUSY;
                          else 
                              stata <= WAIT_1;
          WAIT_BUSY    :  if(ad_busy == 1'b0)
                              stata <= READ_CH15;
                          else
                              stata <= WAIT_BUSY;                          
          READ_CH15    :  if(cnt_bite == (CNT_CLK ) && cnt == (2*FIV_CLK-1))
                              stata <= READ_CH26;
                          else 
                              stata <= READ_CH15;
                              
          READ_CH26    :  if(cnt_bite == (CNT_CLK -1) && cnt == (2*FIV_CLK-1))
                              stata <= READ_CH37;
                          else 
                              stata <= READ_CH26;
          READ_CH37    :  if(cnt_bite == (CNT_CLK -1) && cnt == (2*FIV_CLK-1))
                              stata <= READ_CH48;
                          else 
                              stata <= READ_CH37;
          READ_CH48    :  if(cnt_bite == (CNT_CLK -1) && cnt == (2*FIV_CLK-1))
                              stata <= READ_STOP;
                          else 
                              stata <= READ_CH48;
          READ_STOP    :  stata <= IDLE;
          default:stata <= IDLE;
       endcase
    end 
 
//输出信号
always@(posedge clk or negedge res)
    if(!res)
       ad_convstab <=  1'b1; 
    else if(stata == AD_CONV)
       ad_convstab <=  1'b0;
    else 
       ad_convstab <= 1'b1;
always@(posedge clk or negedge res)
    if(!res)
      ad_cs <= 1'b1;
    else if(stata == WAIT_BUSY && ad_busy == 1'b0)
      ad_cs <= 1'b0;
    else if(stata == READ_STOP)
      ad_cs <= 1'b1;
    else 
      ad_cs <= ad_cs;
always@(posedge clk or negedge res)
    if(!res)
      ad_rd <= 1'b1;
    else if(stata == READ_CH15 || stata == READ_CH26 || stata == READ_CH37 || stata == READ_CH48)
      if(cnt == (FIV_CLK-1))
        ad_rd <= 1'b0;
      else if(cnt == 2*FIV_CLK-1)
        ad_rd <= 1'b1;
      else 
        ad_rd <= ad_rd;
    else 
      ad_rd <= 1'b1;
//处理输入的串行数据
always@(posedge clk or negedge res)
    if(!res)begin
       databuffa <= 16'd0;
       databuffb <= 16'd0;
    end 
    else if(stata == READ_CH15 || stata == READ_CH26 || stata == READ_CH37 || stata == READ_CH48)begin
       if(cnt == FIV_CLK && ad_rd == 1'b0)begin
           databuffa <= {databuffa[14:0],dout_a};
           databuffb <= {databuffb[14:0],dout_b};
       end 
       else begin
           databuffa <= databuffa;
           databuffb <= databuffb; 
       end       
    end 
    else begin
       databuffa <= 16'd0;
       databuffb <= 16'd0;   
    end 
    
//将采集到的数据存储到data_ch1-data_ch8中          
always@(posedge clk or negedge res)
    if(!res)begin
        data_ch1   <=   16'd0;
        data_ch2   <=   16'd0;
        data_ch3   <=   16'd0;
        data_ch4   <=   16'd0;
        data_ch5   <=   16'd0;
        data_ch6   <=   16'd0;
        data_ch7   <=   16'd0;
        data_ch8   <=   16'd0;
    end 
    else if(stata == READ_CH15 && cnt_bite == (CNT_CLK) && cnt == (2*FIV_CLK-1))begin
        data_ch1   <= databuffa;
        data_ch5   <= databuffb;
    end 
    else if(stata == READ_CH26 && cnt_bite == (CNT_CLK -1) && cnt == (2*FIV_CLK-1))begin
        data_ch2   <= databuffa;
        data_ch6   <= databuffb;
    end
    else if(stata == READ_CH37 && cnt_bite == (CNT_CLK -1) && cnt == (2*FIV_CLK-1))begin
        data_ch3   <= databuffa;
        data_ch7   <= databuffb;
    end
    else if(stata == READ_CH48 && cnt_bite == (CNT_CLK -1) && cnt == (2*FIV_CLK-1))begin
        data_ch4   <= databuffa;
        data_ch8   <= databuffb;
    end
    else begin
        data_ch1   <=   data_ch1 ;
        data_ch2   <=   data_ch2 ;
        data_ch3   <=   data_ch3 ;
        data_ch4   <=   data_ch4 ;
        data_ch5   <=   data_ch5 ;
        data_ch6   <=   data_ch6 ;
        data_ch7   <=   data_ch7 ;
        data_ch8   <=   data_ch8 ;
    end 
 
//八个通道采集结束后，对over信号打拍处理，输出over_flag
assign caiji_over = over[2];    
always@(posedge clk or negedge res)
    if(!res)
        over <= 3'd0;
    else if(stata == READ_STOP)begin
        over[0] <= 1'b1;    
        over[1] <= over[0];
        over[2] <= over[1];
    end
    else begin
        over[0] <= 1'b0;    
        over[1] <= over[0];
        over[2] <= over[1];       
    end        
endmodule