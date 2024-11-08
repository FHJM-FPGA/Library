module shakeA(
    input               clk  ,
    input               rstn ,
    input      [bit:0]  key  ,
    output reg [bit:0]  shape 
);
parameter   bit = 5;
reg [bit:0]  key_d1;
reg [bit:0]  key_d2;
reg [bit:0]  key_d3;
reg [bit:0]  key_d4;
reg [19:0]   cnt   ;
reg          flag  ;
parameter   num = 1000000;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            cnt <= 0;
        end else if(cnt >= num)begin
            cnt <= 0;
        end else begin
            cnt <= cnt+1;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            flag <= 0;
        end else if(cnt >= num)begin
            flag <= 1;
        end else begin
            flag <= 0;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            key_d1 <= ~0;
            key_d2 <= ~0;
        end else if(flag)begin
            key_d1 <= key;
            key_d2 <= key_d1;
        end else begin
            key_d1 <= key_d1;
            key_d2 <= key_d2;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            key_d3 <= ~0;
        end else begin
            key_d3 <= key_d1 | key_d2;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            key_d4 <= ~0;
        end else begin
            key_d4 <= key_d3;
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            shape <= 0;
        end else begin
            shape <= key_d3 & (~key_d4);
        end
    end
endmodule
