`timescale 1ns / 1ps
module tb_remote_rcv();

parameter T = 20;
parameter ADDR_CODE = 8'h5a; // 8'b01011010
parameter DATA_CODE = 8'h45;

reg         clk        ;
reg         rstn       ;
reg         remote_in  ;
reg  [7:0]  data       ;
wire        repeat_en  ;
wire        data_en    ;
wire [7:0]  remote_data;
initial begin
    clk = 1'b0;
    rstn = 1'b0;
    #(T+1)
    rstn = 1'b1;
 
end
 
always #(T/2) clk = ~clk;
 
initial begin
    remote_in = 1'b1;
	data = 8'd0;
	
    #100_000 remote_in = 1'b0;
    #9_000_000 remote_in = 1'b1;
    #4_500_000 remote_in = 1'b0;
    
    data = ADDR_CODE;
    repeat(8) begin
        #560_000 remote_in = 1'b1;
        if(data[0])
            #1_690_000 remote_in = 1'b0;
        else
            #560_000 remote_in = 1'b0;
        data = data >>1;
    end
 
    data = ~ADDR_CODE;
    repeat(8) begin
        #560_000 remote_in = 1'b1;
        if(data[0])
            #1_690_000 remote_in = 1'b0;
        else
            #560_000 remote_in = 1'b0;
        data = data >>1;
    end
    data = DATA_CODE;
    repeat(8) begin
        #560_000 remote_in = 1'b1;
        if(data[0])
            #1_690_000 remote_in = 1'b0;
        else
            #560_000 remote_in = 1'b0;
        data = data >>1;
    end
 
    data = ~DATA_CODE;
    repeat(8) begin
        #560_000 remote_in = 1'b1;
        if(data[0])
            #1_690_000 remote_in = 1'b0;
        else
            #560_000 remote_in = 1'b0;
        data = data >>1;
    end
    #560_000 remote_in = 1'b1;
    // 重复码
    #50_000_000 remote_in = 1'b0;
    #9_000_000 remote_in = 1'b1;
    #2_250_000 remote_in = 1'b0;
    #560_000 remote_in = 1'b1;
end
remote_rcv uu(
    .clk        (clk        ),  //input                  clk       ,  //系统时钟
    .rstn       (rstn       ),  //input                  rstn      ,  //系统复位信号，低电平有效
    .remote_in  (remote_in  ),  //input                  remote_in ,  //红外接收信号
    .repeat_en  (repeat_en  ),  //output    reg          repeat_en ,  //重复码有效信号
    .data_en    (data_en    ),  //output    reg          data_en   ,  //数据有效信号
    .data       (remote_data)   //output    reg  [7:0]   data         //红外控制码
);
endmodule

