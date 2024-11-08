//独立按键消抖
module shake(        
    input      clk   ,          
    input      rstn  ,    
    input      key   ,      
    output reg shape   
);
parameter delay=999999;
reg [19:0]t20ms;
reg [ 1:0]key_d;
reg [ 1:0]state;

always@(posedge clk)
    key_d <= {key_d[0],key};
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            shape <= 0;
            t20ms <= 0;
            state <= 0;
        end else case(state)
            0:begin
                if(key_d==2)begin
                    state <= 1;
                    shape <= 0;
                    t20ms <= 0;
                end else begin
                    shape <= 0;
                    t20ms <= 0;
                    state <= 0;
                end 
            end
            1:begin
                if(t20ms >= delay)begin
                    shape <= 0;
                    t20ms <= 0;
                    state <= 2;
                end else begin
                    shape <= 0;
                    t20ms <= t20ms+1;
                    state <= 1;
                end
            end
            2:begin 
                if(key_d==1)begin
                    shape <= 0;
                    t20ms <= 0;
                    state <= 3;
                end else begin
                    shape <= 0;
                    t20ms <= 0;
                    state <= 2;
                end
            end
            3:begin
                if(t20ms >= delay)begin
                    shape <= 1;
                    t20ms <= 0;
                    state <= 0;
                end else begin
                    shape <= 0;
                    t20ms <= t20ms+1;
                    state <= 3;
                end
            end
            default:begin
                shape <= 0;
                t20ms <= 0;
                state <= 0;
            end
        endcase
    end
    
endmodule
