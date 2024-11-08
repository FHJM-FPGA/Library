//串口发送
module UartSend(
    input            clk     ,
    input            rstn    ,
    input            SendEn  ,//写使能
    input      [7:0] SendData,//写数据
    output reg       SendBusy,//发送忙
    output reg       SendDone,//发送完成
    output reg       UartTx   //串口接口
);
parameter SystemClk = 50000000;//采样时钟
parameter Bps       = 115200;//波特率
wire [19:0] BpsNum;
assign BpsNum = SystemClk/Bps;

reg [19:0] BpsCnt;
reg [3:0]  UartState;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            SendBusy <= 0;
        end else if(SendEn)begin
            SendBusy <= 1;
        end else if(UartState == 9 && BpsCnt == BpsNum-1)begin
            SendBusy <= 0;
        end else begin
            SendBusy <= SendBusy;
        end
    end

always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            BpsCnt <= 0;
        end else if(SendBusy)begin
            if(BpsCnt == BpsNum-1)begin
                BpsCnt <= 0;
            end else begin
                BpsCnt <= BpsCnt+1;
            end
        end else begin
            BpsCnt <= 0;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            UartState <= 0;
        end else if(SendBusy)begin
            if(UartState == 9 && BpsCnt == BpsNum-1)begin
                UartState <= 0;
            end else if(BpsCnt == BpsNum-1)begin
                UartState <= UartState+1;
            end else begin
                UartState <= UartState;
            end 
        end else begin
            UartState <= 0;
        end
    end

reg [7:0] RegSendData;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            RegSendData <= 0;
        end else if(SendEn)begin
            RegSendData <= SendData;
        end else begin
            RegSendData <= RegSendData;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            UartTx    <= 1;
        end else if(SendBusy)begin
            case(UartState)
                0: begin UartTx <= 0;              end
                1: begin UartTx <= RegSendData[0]; end
                2: begin UartTx <= RegSendData[1]; end
                3: begin UartTx <= RegSendData[2]; end
                4: begin UartTx <= RegSendData[3]; end
                5: begin UartTx <= RegSendData[4]; end
                6: begin UartTx <= RegSendData[5]; end
                7: begin UartTx <= RegSendData[6]; end
                8: begin UartTx <= RegSendData[7]; end
                9: begin UartTx <= 1;              end
            endcase
        end else begin
            UartTx    <= 1;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            SendDone <= 0;
        end else if(UartState == 9 && BpsCnt == BpsNum-1)begin
            SendDone <= 1;
        end else begin
            SendDone <= 0;
        end
    end

endmodule
