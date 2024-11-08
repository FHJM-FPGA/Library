//串口接收:
module UartRec(
    input             clk    ,
    input             rstn   ,
    input      [19:0] BpsNum ,//波特率计数值
    input             UartRx ,//串口接收
    output reg        done   ,//接收完成
    output reg [7:0]  RecData //接收数据
);
//parameter SystemClk = 50000000;
//parameter Bps       = 115200;
//wire [19:0] BpsNum;
//assign BpsNum = SystemClk/Bps;
reg [1:0] UartRx_d0;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            UartRx_d0 <= 3;
        end else begin
            UartRx_d0 <= {UartRx_d0[0],UartRx};
        end
    end

reg        UartBusy ;
reg [2:0]  Start    ;
reg [3:0]  UartState;
reg [19:0] BpsCnt   ;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            UartBusy <= 0;
        end else if(UartRx_d0 == 2)begin
            UartBusy <= 1;
        end else if(Start >= 3)begin
            UartBusy <= 0;
        end else if(UartState == 9 && BpsCnt == BpsNum[19:1])begin
            UartBusy <= 0;
        end else begin
            UartBusy <= UartBusy;
        end
    end

always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            BpsCnt <= 0;
        end else if(UartBusy)begin
            if(BpsCnt == BpsNum-1)begin
                BpsCnt <= 0;
            end else begin
                BpsCnt <= BpsCnt+1;
            end
        end else begin
            BpsCnt <= 0;
        end
    end

reg [2:0] RegRecData[7:0];
reg       Flag;
always@(posedge clk)
    begin
        Flag = (BpsCnt == (BpsNum/7*1) || BpsCnt == (BpsNum/7*2) || BpsCnt == (BpsNum/7*3) || BpsCnt == (BpsNum/7*4) || BpsCnt == (BpsNum/7*5) || BpsCnt == (BpsNum/7*6)) ? 1 : 0;
    end

always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            UartState     <= 0;
            Start         <= 0;
            done          <= 0;
            RecData       <= 0;
            RegRecData[0] <= 0;
            RegRecData[1] <= 0;
            RegRecData[2] <= 0;
            RegRecData[3] <= 0;
            RegRecData[4] <= 0;
            RegRecData[5] <= 0;
            RegRecData[6] <= 0;
            RegRecData[7] <= 0;
        end else if(UartBusy)begin
            case(UartState)
                0:begin
                    if(Start<3 && BpsCnt == BpsNum-1)begin
                        UartState <= 1;
                        Start     <= 0;
                    end else if(Flag)begin
                        Start <= Start+UartRx;
                    end else begin
                        UartState <= 0;
                        done      <= 0;
                    end
                end
                1:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 2;
                    end else if(Flag)begin
                        RegRecData[0] <= RegRecData[0]+UartRx;
                    end else begin
                        UartState <= 1;
                    end
                end
                2:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 3;
                    end else if(Flag)begin
                        RegRecData[1] <= RegRecData[1]+UartRx;
                    end else begin
                        UartState <= 2;
                    end
                end
                3:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 4;
                    end else if(Flag)begin
                        RegRecData[2] <= RegRecData[2]+UartRx;
                    end else begin
                        UartState <= 3;
                    end
                end
                4:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 5;
                    end else if(Flag)begin
                        RegRecData[3] <= RegRecData[3]+UartRx;
                    end else begin
                        UartState <= 4;
                    end
                end
                5:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 6;
                    end else if(Flag)begin
                        RegRecData[4] <= RegRecData[4]+UartRx;
                    end else begin
                        UartState <= 5;
                    end
                end
                6:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 7;
                    end else if(Flag)begin
                        RegRecData[5] <= RegRecData[5]+UartRx;
                    end else begin
                        UartState <= 6;
                    end
                end
                7:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 8;
                    end else if(Flag)begin
                        RegRecData[6] <= RegRecData[6]+UartRx;
                    end else begin
                        UartState <= 7;
                    end
                end
                8:begin
                    if(BpsCnt == BpsNum-1)begin
                        UartState <= 9;
                    end else if(Flag)begin
                        RegRecData[7] <= RegRecData[7]+UartRx;
                    end else begin
                        UartState <= 8;
                    end
                end
                9:begin
                    if(BpsCnt == BpsNum[19:1])begin
                        UartState <= 0;
                        done      <= 1;
                        RecData   <= {RegRecData[7][2],RegRecData[6][2],RegRecData[5][2],RegRecData[4][2],RegRecData[3][2],RegRecData[2][2],RegRecData[1][2],RegRecData[0][2]};
                    end else begin
                        UartState <= 9;
                    end
                end
            endcase
        end else begin
            UartState     <= 0;
            Start         <= 0;
            done          <= 0;
            RegRecData[0] <= 0;
            RegRecData[1] <= 0;
            RegRecData[2] <= 0;
            RegRecData[3] <= 0;
            RegRecData[4] <= 0;
            RegRecData[5] <= 0;
            RegRecData[6] <= 0;
            RegRecData[7] <= 0;
        end 
    end

endmodule
