//10进制转16进制
module bin_to_bcd
(
input                 rstn    ,   
input       [4:0]     bin_code,  //需要进行BCD转码的二进制数据
output reg  [7:0]     bcd_code   //转码后的BCD码型数据输出
);
reg   [12:0]  shift_reg; 
always@(bin_code or rstn)begin
	shift_reg = {8'h0,bin_code};
	if(!rstn) bcd_code = 0; 
	else begin 
		repeat(5) begin //循环16次  
			//BCD码各位数据作满5加3操作，
			if (shift_reg[8:5] >= 5) shift_reg[8:5] = shift_reg[8:5] + 2'b11;
			if (shift_reg[12:9] >= 5) shift_reg[12:9] = shift_reg[12:9] + 2'b11;
			shift_reg = shift_reg << 1; 
		end
		bcd_code = shift_reg[35:16];   
	end  
end

endmodule
