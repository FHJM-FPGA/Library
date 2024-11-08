//串口连续发送控制
module control_uart_send(
    input              clk     ,
    input              rstn    ,
    input              flag1   ,
    input              flag2   ,
    input              flag3   ,
    output reg         SendEn  ,
    output reg   [7:0] SendData,
    input              SendDone 
);
reg shaniu;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            shaniu <= 1;
        end else begin
            shaniu <= 0;
        end
    end
//二零六零华人牌傻妞为您服务
wire  [7:0] kaiji[30:0];
assign kaiji[ 0] = 8'hFD;
assign kaiji[ 1] = 8'h00;
assign kaiji[ 2] = 8'h1C;
assign kaiji[ 3] = 8'h01;
assign kaiji[ 4] = 8'h01;
assign kaiji[ 5] = 8'hE6;
assign kaiji[ 6] = 8'hFE;
assign kaiji[ 7] = 8'hC1;
assign kaiji[ 8] = 8'hE3;
assign kaiji[ 9] = 8'hC1;
assign kaiji[10] = 8'hF9;
assign kaiji[11] = 8'hC1;
assign kaiji[12] = 8'hE3;
assign kaiji[13] = 8'hBB;
assign kaiji[14] = 8'hAA;
assign kaiji[15] = 8'hC8;
assign kaiji[16] = 8'hCB;
assign kaiji[17] = 8'hC5;
assign kaiji[18] = 8'hC6;
assign kaiji[19] = 8'hC9;
assign kaiji[20] = 8'hB5;
assign kaiji[21] = 8'hE6;
assign kaiji[22] = 8'hA4;
assign kaiji[23] = 8'hCE;
assign kaiji[24] = 8'hAA;
assign kaiji[25] = 8'hC4;
assign kaiji[26] = 8'hFA;
assign kaiji[27] = 8'hB7;
assign kaiji[28] = 8'hFE;
assign kaiji[29] = 8'hCE;
assign kaiji[30] = 8'hF1;
//欢迎光临
wire  [7:0] data1[12:0];
assign data1[0]  = 8'hFD;
assign data1[1]  = 8'h00;
assign data1[2]  = 8'h0A;
assign data1[3]  = 8'h01;
assign data1[4]  = 8'h01;
assign data1[5]  = 8'hBB;
assign data1[6]  = 8'hB6;
assign data1[7]  = 8'hD3;
assign data1[8]  = 8'hAD;
assign data1[9]  = 8'hB9;
assign data1[10] = 8'hE2;
assign data1[11] = 8'hC1;
assign data1[12] = 8'hD9;
//支付成功
wire [7:0] data2[12:0]; 
assign data2[0]  = 8'hFD;
assign data2[1]  = 8'h00;
assign data2[2]  = 8'h0A;
assign data2[3]  = 8'h01;
assign data2[4]  = 8'h01;
assign data2[5]  = 8'hD6; 
assign data2[6]  = 8'hA7; 
assign data2[7]  = 8'hB8; 
assign data2[8]  = 8'hB6; 
assign data2[9]  = 8'hB3; 
assign data2[10] = 8'hC9; 
assign data2[11] = 8'hB9; 
assign data2[12] = 8'hA6;

//支付失败
wire [7:0] data3[12:0]; 
assign data3[0]  = 8'hFD;
assign data3[1]  = 8'h00;
assign data3[2]  = 8'h0A;
assign data3[3]  = 8'h01;
assign data3[4]  = 8'h01;
assign data3[5]  = 8'hD6; 
assign data3[6]  = 8'hA7; 
assign data3[7]  = 8'hB8; 
assign data3[8]  = 8'hB6; 
assign data3[9]  = 8'hCA; 
assign data3[10] = 8'hA7; 
assign data3[11] = 8'hB0; 
assign data3[12] = 8'hDC;

reg [7:0] data[30:0];
reg [6:0] i;
reg [5:0] num;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            for(i=0;i<31;i=i+1)begin
                data[i] <= 0;
            end
            num <= 0; 
        end else if(shaniu)begin//开机   二零六零华人牌傻妞为您服务
            num <= 31;
            for(i=0;i<31;i=i+1)
                data[i] <= kaiji[i];
        end else if(flag1)begin//铃声1赋值
            num      <= 13;
            for(i=0;i<13;i=i+1)
                data[i] <= data1[i];
        end else if(flag2)begin//铃声2赋值
            num      <= 13;
            for(i=0;i<13;i=i+1)
                data[i] <= data2[i];
        end else if(flag3)begin
            num      <= 13;
            for(i=0;i<13;i=i+1)
                data[i] <= data3[i];
        end
    end
reg       flag;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            flag <= 0;
        end else if(shaniu || flag1 || flag2 || flag3)begin//开始串口数据使能
            flag <= 1;
        end else begin
            flag <= 0;
        end
    end
reg [5:0] count;
reg [2:0] state;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            count    <= 0;
            state    <= 0;
            SendEn   <= 0;
            SendData <= 0;
        end else begin
            case(state)
                0:begin
                    if(flag)begin//状态机开始
                        count    <= count+1;
                        state    <= 1;
                        SendEn   <= 1;
                        SendData <= data[count];
                    end else begin
                        count    <= 0;
                        state    <= 0;
                        SendEn   <= 0;
                        SendData <= 0;
                    end
                end
                1:begin
                    if(SendDone)begin//串口发送一个字节数据结束
                        state    <= 2;
                        SendEn   <= 1;
                        count    <= count+1;
                        SendData <= data[count];
                    end else begin
                        SendEn   <= 0;
                    end
                end
                2:begin
                    if(count >= num)begin//判断一个铃声数据是否结束
                        state    <= 0;
                        SendEn   <= 0;
                    end else begin
                        state    <= 1;
                        SendEn   <= 0;
                    end
                end 
                default:
                    state    <= 0;
            endcase
        end
    end

endmodule
