module shake_3x3(
    input               clk      ,
    input               rstn     ,
    input       [2:0]   col      ,
    output  reg [2:0]   row      ,
    output      [8:0]   key_pulse
);
//parameter            CNT_200HZ = 50;    //仿真使用
parameter            CNT_200HZ = 2400;    //下开发板使用

reg     [15:0]      cnt      ;
reg                 clk_200hz;
always@(posedge clk or negedge rstn) 
    begin  
        if(!rstn) begin
            cnt       <= 0;
            clk_200hz <= 0;
        end else begin
            if(cnt >= ((CNT_200HZ>>1) - 1)) begin  
                cnt       <= 0;
                clk_200hz <= !clk_200hz;  
            end else begin
                cnt       <= cnt + 1'b1;
            end
        end
    end

reg    [1:0]     state    ;
reg    [8:0]     key      ;
reg    [8:0]     key_r    ;
reg    [8:0]     key_out  ;
reg    [8:0]     key_out_r;
always@(posedge clk_200hz or negedge rstn) begin
    if(!rstn) begin
        state <= 0;
        row     <= 3'b110;
    end else begin
        case(state)
            0: begin state <= 1; row <= 3'b101; end
            1: begin state <= 2; row <= 3'b011; end
            2: begin state <= 0; row <= 3'b110; end
            default:begin state <= 0; row <= 3'b110; end
        endcase
    end
end
always@(negedge clk_200hz or negedge rstn) 
    begin
        if(!rstn)begin
            key_out <= 9'h1ff; 
            key_r   <= 9'h1ff; 
            key     <= 9'h1ff; 
        end else begin
            case(state)
                0: begin key_out[2:0] <= key_r[2:0]|key[2:0]; key_r[2:0] <= key[2:0]; key[2:0] <= col; end
                1: begin key_out[5:3] <= key_r[5:3]|key[5:3]; key_r[5:3] <= key[5:3]; key[5:3] <= col; end
                2: begin key_out[8:6] <= key_r[8:6]|key[8:6]; key_r[8:6] <= key[8:6]; key[8:6] <= col; end
                default:begin key_out <= 9'h1ff; key_r <= 9'h1ff; key <= 9'h1ff; end
            endcase
        end
    end
always@(posedge clk or negedge rstn)
    begin
        if (!rstn)begin
            key_out_r <= 9'h1ff;
        end else begin
            key_out_r <= key_out;   
        end
    end
assign key_pulse= key_out_r & (~key_out);  
    
endmodule
