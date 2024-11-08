module MyCORDIC(
	input             clk      ,
	input             rstn     ,
	input      [15:0] theta    ,
	output reg [15:0] sin_theta,
	output reg [15:0] cos_theta 
);

parameter Kn  = 'd19898;    // 0.607253*2^15
parameter iKn = 'd53961;    // 1.64676*2^15 

parameter arctan_0 = 8192    ;  // arctan(1/2)
parameter arctan_1 = 4836    ;  // arctan(1/2^1)
parameter arctan_2 = 2555    ;  // arctan(1/2^2)
parameter arctan_3 = 1297    ;  // arctan(1/2^3)
parameter arctan_4 = 651     ;  // arctan(1/2^4)
parameter arctan_5 = 326     ;  // arctan(1/2^5)
parameter arctan_6 = 163     ;  // arctan(1/2^6)
parameter arctan_7 = 81      ;  // arctan(1/2^7)
parameter arctan_8 = 41      ;  // arctan(1/2^8)
parameter arctan_9 = 20      ;  // arctan(1/2^9)
parameter arctan_10 = 10     ;  // arctan(1/2^10)
parameter arctan_11 = 5      ;  // arctan(1/2^11)

reg signed [15:0] x [11:0];
reg signed [15:0] y [11:0];
reg signed [15:0] z [11:0];

wire [15:0]x_tmp;
wire [15:0]y_tmp;

reg signed [15:0]theta_1;
wire [2:0] Quadrant;//theta角所在的象限

// 象限判断
assign Quadrant = theta[15:14] + 1;

always@(*)
begin
	begin
		theta_1 <= {2'b00,theta[13:0]};
		if(Quadrant==1)
		begin
			theta_1 <= theta;
		end
		else if(Quadrant==2)
		begin
			theta_1 <= 32768 - theta;
		end
		else if(Quadrant==3)
		begin
			theta_1 <= theta - 32768;
		end
		else if(Quadrant==4)
		begin
			theta_1 <= 65536 - theta;
		end
	end
end

always@(posedge clk or negedge rstn)
begin
	if(!rstn)
	begin
		x[0] <= 16'd0;
		y[0] <= 16'd0;
		z[0] <= 16'd0;
	end
	else
	begin
		x[0] <= Kn;
		y[0] <= 16'd0;
		z[0] <= theta_1;
	end
end

always@(posedge clk or negedge rstn) // i=0
begin
	if(!rstn)
	begin
		x[1] <= 16'd0;
		y[1] <= 16'd0;
		z[1] <= 16'd0;
	end
	else
	begin
		if(z[0][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[1] <= x[0] + y[0];
			y[1] <= y[0] - x[0];
			z[1] <= z[0] + arctan_0;
		end          // 剩余角度为正数，顺时针旋转，d=+1
		else
		begin
			x[1] <= x[0] - y[0];
			y[1] <= y[0] + x[0];
			z[1] <= z[0] - arctan_0;
		end
	end
end

// >>>符号表示算术右移，不改变符号位
always@(posedge clk or negedge rstn) // i=1
begin
	if(!rstn)
	begin
		x[2] <= 16'd0;
		y[2] <= 16'd0;
		z[2] <= 16'd0;
	end
	else
	begin
		if(z[1][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[2] <= x[1] + (y[1] >>> 1);
			y[2] <= y[1] - (x[1] >>> 1);
			z[2] <= z[1] + arctan_1;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[2] <= x[1] - (y[1] >>> 1);
			y[2] <= y[1] + (x[1] >>> 1);
			z[2] <= z[1] - arctan_1;
		end
	end
end

always@(posedge clk or negedge rstn) // i=2
begin
	if(!rstn)
	begin
		x[3] <= 16'd0;
		y[3] <= 16'd0;
		z[3] <= 16'd0;
	end
	else
	begin
		if(z[2][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[3] <= x[2] + (y[2] >>> 2);
			y[3] <= y[2] - (x[2] >>> 2);
			z[3] <= z[2] + arctan_2;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[3] <= x[2] - (y[2] >>> 2);
			y[3] <= y[2] + (x[2] >>> 2);
			z[3] <= z[2] - arctan_2;
		end
	end
end

always@(posedge clk or negedge rstn) // i=3
begin
	if(!rstn)
	begin
		x[4] <= 16'd0;
		y[4] <= 16'd0;
		z[4] <= 16'd0;
	end
	else
	begin
		if(z[3][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[4] <= x[3] + (y[3] >>> 3);
			y[4] <= y[3] - (x[3] >>> 3);
			z[4] <= z[3] + arctan_3;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[4] <= x[3] - (y[3] >>> 3);
			y[4] <= y[3] + (x[3] >>> 3);
			z[4] <= z[3] - arctan_3;
		end
	end
end


always@(posedge clk or negedge rstn) // i=4
begin
	if(!rstn)
	begin
		x[5] <= 16'd0;
		y[5] <= 16'd0;
		z[5] <= 16'd0;
	end
	else
	begin
		if(z[4][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[5] <= x[4] + (y[4] >>> 4);
			y[5] <= y[4] - (x[4] >>> 4);
			z[5] <= z[4] + arctan_4;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[5] <= x[4] - (y[4] >>> 4);
			y[5] <= y[4] + (x[4] >>> 4);
			z[5] <= z[4] - arctan_4;
		end
	end
end

always@(posedge clk or negedge rstn) // i=5
begin
	if(!rstn)
	begin
		x[6] <= 16'd0;
		y[6] <= 16'd0;
		z[6] <= 16'd0;
	end
	else
	begin
		if(z[5][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[6] <= x[5] + (y[5] >>> 5);
			y[6] <= y[5] - (x[5] >>> 5);
			z[6] <= z[5] + arctan_5;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[6] <= x[5] - (y[5] >>> 5);
			y[6] <= y[5] + (x[5] >>> 5);
			z[6] <= z[5] - arctan_5;
		end
	end
end

always@(posedge clk or negedge rstn) // i=6
begin
	if(!rstn)
	begin
		x[7] <= 16'd0;
		y[7] <= 16'd0;
		z[7] <= 16'd0;
	end
	else
	begin
		if(z[6][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[7] <= x[6] + (y[6] >>> 6);
			y[7] <= y[6] - (x[6] >>> 6);
			z[7] <= z[6] + arctan_6;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[7] <= x[6] - (y[6] >>> 6);
			y[7] <= y[6] + (x[6] >>> 6);
			z[7] <= z[6] - arctan_6;
		end
	end
end


always@(posedge clk or negedge rstn) // i=7
begin
	if(!rstn)
	begin
		x[8] <= 16'd0;
		y[8] <= 16'd0;
		z[8] <= 16'd0;
	end
	else
	begin
		if(z[7][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[8] <= x[7] + (y[7] >>> 7);
			y[8] <= y[7] - (x[7] >>> 7);
			z[8] <= z[7] + arctan_7;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[8] <= x[7] - (y[7] >>> 7);
			y[8] <= y[7] + (x[7] >>> 7);
			z[8] <= z[7] - arctan_7;
		end
	end
end

always@(posedge clk or negedge rstn) // i=8
begin
	if(!rstn)
	begin
		x[9] <= 16'd0;
		y[9] <= 16'd0;
		z[9] <= 16'd0;
	end
	else
	begin
		if(z[8][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[9] <= x[8] + (y[8] >>> 8);
			y[9] <= y[8] - (x[8] >>> 8);
			z[9] <= z[8] + arctan_8;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[9] <= x[8] - (y[8] >>> 8);
			y[9] <= y[8] + (x[8] >>> 8);
			z[9] <= z[8] - arctan_8;
		end
	end
end

always@(posedge clk or negedge rstn) // i=9
begin
	if(!rstn)
	begin
		x[10] <= 16'd0;
		y[10] <= 16'd0;
		z[10] <= 16'd0;
	end
	else
	begin
		if(z[9][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[10] <= x[9] + (y[9] >>> 9);
			y[10] <= y[9] - (x[9] >>> 9);
			z[10] <= z[9] + arctan_9;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[10] <= x[9] - (y[9] >>> 9);
			y[10] <= y[9] + (x[9] >>> 9);
			z[10] <= z[9] - arctan_9;
		end
	end
end

always@(posedge clk or negedge rstn) // i=10
begin
	if(!rstn)
	begin
		x[11] <= 16'd0;
		y[11] <= 16'd0;
		z[11] <= 16'd0;
	end
	else
	begin
		if(z[10][15]) // 剩余角度为负数，顺时针旋转，d=-1
		begin
			x[11] <= x[10] + (y[10] >>> 10);
			y[11] <= y[10] - (x[10] >>> 10);
			z[11] <= z[10] + arctan_10;
		end          // 剩余角度为正数，逆时针旋转，d=+1
		else
		begin
			x[11] <= x[10] - (y[10] >>> 10);
			y[11] <= y[10] + (x[10] >>> 10);
			z[11] <= z[10] - arctan_10;
		end
	end
end

// 溢出判断
assign x_tmp = x[11][15]==1 ? 16'h7FFF : x[11];
assign y_tmp = y[11][15]==1 ? 16'h7FFF : y[11];
//assign x_tmp = x[11];
//assign y_tmp = y[11];

always@(posedge clk or negedge rstn) // i=11
begin
	if(!rstn)
	begin
		sin_theta <= 16'd0;
		cos_theta <= 16'd0;
	end
	else
	begin
		if(Quadrant == 3'd1)
		begin
			sin_theta <= y_tmp;
			cos_theta <= x_tmp;
		end
		else if(Quadrant == 3'd2)
		begin
			sin_theta <= y_tmp;
			cos_theta <= -x_tmp;
		end
		else if(Quadrant == 3'd3)
		begin
			sin_theta <= -y_tmp;
			cos_theta <= -x_tmp;
		end
		else if(Quadrant == 3'd4)
		begin
			sin_theta <= -y_tmp;
			cos_theta <= x_tmp;
		end
		else
		begin
			sin_theta <= sin_theta;
			cos_theta <= cos_theta;
		end
	end
end
endmodule
