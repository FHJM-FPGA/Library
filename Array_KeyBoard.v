module Array_KeyBoard(
    input                     clk       ,
    input                     rstn      ,
    input            [3:0]    col       ,
    output    reg    [3:0]    row       ,
    output           [15:0]   key_pulse ,
    output    reg             key_en    ,
    output    reg    [3:0]    key_data    
);
    
localparam            STATE0 = 2'b00;
localparam            STATE1 = 2'b01;
localparam            STATE2 = 2'b10;
localparam            STATE3 = 2'b11;

parameter            CNT_200HZ = 60000;
/*
因使用4x4矩阵按键，通过扫描方法实现，所以这里使用状态机实现，共分为4种状态
在其中的某一状态时间里，对应的4个按键相当于独立按键，可按独立按键的周期采样法采样
周期采样时每隔20ms采样一次，对应这里状态机每隔20ms循环一次，每个状态对应5ms时间
对矩阵按键实现原理不明白的，请去了解矩阵按键实现原理
*/

//计数器计数分频实现5ms周期信号clk_200hz
reg    [15:0]    key_out   ;
reg        [15:0]        cnt;
reg                    clk_200hz;
always@(posedge clk or negedge rstn) begin  //复位时计数器cnt清零，clk_200hz信号起始电平为低电平
    if(!rstn) begin
        cnt <= 16'd0;
        clk_200hz <= 1'b0;
    end else begin
        if(cnt >= ((CNT_200HZ>>1) - 1)) begin  //数字逻辑中右移1位相当于除2
            cnt <= 16'd0;
            clk_200hz <= ~clk_200hz;  //clk_200hz信号取反
        end else begin
            cnt <= cnt + 1'b1;
            clk_200hz <= clk_200hz;
        end
    end
end

reg        [1:0]        c_state;
//状态机根据clk_200hz信号在4个状态间循环，每个状态对矩阵按键的行接口单行有效
always@(posedge clk_200hz or negedge rstn) begin
    if(!rstn) begin
        c_state <= STATE0;
        row <= 4'b1110;
    end else begin
        case(c_state)
            //状态c_state跳转及对应状态下矩阵按键的row输出
            STATE0: begin c_state <= STATE1; row <= 4'b1101; end
            STATE1: begin c_state <= STATE2; row <= 4'b1011; end
            STATE2: begin c_state <= STATE3; row <= 4'b0111; end
            STATE3: begin c_state <= STATE0; row <= 4'b1110; end
            default:begin c_state <= STATE0; row <= 4'b1110; end
        endcase
    end
end

reg    [15:0]    key,key_r;
//因为每个状态中单行有效，通过对列接口的电平状态采样得到对应4个按键的状态，依次循环
always@(negedge clk_200hz or negedge rstn) begin
    if(!rstn) begin
        key_out <= 16'hffff; key_r <= 16'hffff; key <= 16'hffff; 
    end else begin
        case(c_state)
            //采集当前状态的列数据赋值给对应的寄存器位
            //对键盘采样数据进行判定，连续两次采样低电平判定为按键按下
            STATE0: begin key_out[ 3: 0] <= key_r[ 3: 0]|key[ 3: 0]; key_r[ 3: 0] <= key[ 3: 0]; key[ 3: 0] <= col; end
            STATE1: begin key_out[ 7: 4] <= key_r[ 7: 4]|key[ 7: 4]; key_r[ 7: 4] <= key[ 7: 4]; key[ 7: 4] <= col; end
            STATE2: begin key_out[11: 8] <= key_r[11: 8]|key[11: 8]; key_r[11: 8] <= key[11: 8]; key[11: 8] <= col; end
            STATE3: begin key_out[15:12] <= key_r[15:12]|key[15:12]; key_r[15:12] <= key[15:12]; key[15:12] <= col; end
            default:begin key_out <= 16'hffff; key_r <= 16'hffff; key <= 16'hffff; end
        endcase
    end
end

reg        [15:0]        key_out_r;
//Register low_sw_r, lock low_sw to next clk
always @ ( posedge clk  or  negedge rstn )
    if (!rstn) key_out_r <= 16'hffff;
    else  key_out_r <= key_out;   //将前一刻的值延迟锁存

//wire    [15:0]         key_pulse;
//Detect the negedge of low_sw, generate pulse
assign key_pulse= key_out_r & ( ~key_out);   //通过前后两个时刻的值判断

always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            key_en   <= 0;
            key_data <= 0;
        end else begin  
            case(key_pulse)
                16'b0000_0000_0000_0001:begin key_en<=1; key_data<=1;    end
                16'b0000_0000_0000_0010:begin key_en<=1; key_data<=2;    end
                16'b0000_0000_0000_0100:begin key_en<=1; key_data<=3;    end
                16'b0000_0000_0000_1000:begin key_en<=1; key_data<=4'hA; end
                16'b0000_0000_0001_0000:begin key_en<=1; key_data<=4;    end
                16'b0000_0000_0010_0000:begin key_en<=1; key_data<=5;    end
                16'b0000_0000_0100_0000:begin key_en<=1; key_data<=6;    end
                16'b0000_0000_1000_0000:begin key_en<=1; key_data<=4'hB; end
                16'b0000_0001_0000_0000:begin key_en<=1; key_data<=7;    end
                16'b0000_0010_0000_0000:begin key_en<=1; key_data<=8;    end
                16'b0000_0100_0000_0000:begin key_en<=1; key_data<=9;    end
                16'b0000_1000_0000_0000:begin key_en<=1; key_data<=4'hC; end
                16'b0001_0000_0000_0000:begin key_en<=1; key_data<=4'hE; end
                16'b0010_0000_0000_0000:begin key_en<=1; key_data<=0;    end
                16'b0100_0000_0000_0000:begin key_en<=1; key_data<=4'hF; end
                16'b1000_0000_0000_0000:begin key_en<=1; key_data<=4'hD; end
                default:begin
                    key_en   <= 0;
                end
            endcase
        end 
    end
endmodule
