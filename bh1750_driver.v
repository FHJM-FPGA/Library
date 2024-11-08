//测重传感器
module	bh1750_driver
#(
		parameter				TIME_1S			=	480_000_000	,
		parameter				TIME_180MS		=	864_0000	,
		parameter				TIME_120MS		=	576_0000	,
		parameter				CLOCK_DIV		=	480			,
		parameter				SEND_FIRST_BYTE	=	8'b01000110	,
		parameter				SEND_SECOND_BYTE=	8'b00010000	,
		parameter				SEND_THIRD_BYTE	=	8'b01000111	
)
(
		input					clk								,
		input					reset							,
		output	wire			scl								,
		inout	wire			sda								,
		output	reg		[15:0]	lux_data						,
		output	wire			lux_data_vld					
);					
			
		localparam				INIT			=	5'b00001	;
        localparam				SEND_COMMAND	=	5'b00010	;
        localparam				WAIT_RESULT_1	=	5'b00100	;
        localparam				READ_RESULT		=	5'b01000	;
        localparam				WAIT_RESULT_2	=	5'b10000	;
		localparam				CLOCK_DIV_HALF	=	CLOCK_DIV/2 ;
        localparam				CLOCK_DIV_QUAT	=	CLOCK_DIV/4	;
		
		localparam				SEND_INIT		=	3'd0		;
		localparam				LOAD_SECOND_BYTE=	3'd2		;
		localparam				SEND_START		=	3'd3		;
		localparam				SEND_BYTE		=	3'd4		;
		localparam				RECIVE_ACK		=	3'd5		;
		localparam				LOAD_FIRST_BYTE	=	3'd1		;
		localparam				CHECK_ACK		=	3'd6		;
		localparam				SEND_END		=	3'd7		;
		
		localparam				READ_INIT		=	4'd0		;
		localparam				LOAD_SEND_BYTE	=	4'd1		;
		localparam				READ_START		=	4'd2		;
		localparam				READ_SEND_BYTE	=	4'd3		;
		localparam				READ_ACK		=	4'd4		;
		localparam				CHECK_READ_ACK	=	4'd5		;
		localparam				READ_HIGH_BYTE	=	4'd6		;
		localparam				SEND_FIRST_ACK	=	4'd7		;
		localparam				SEND_ACK_READ	=	4'd8		;
		localparam				READ_LOW_BYTE	=	4'd9		;
		localparam				SEND_SECOND_ACK	=	4'd10		;
		localparam				SEND_ACK_END	=	4'd11		;
        localparam				READ_END		=	4'd12		;

		reg				[ 4:0]	state_c_global					;
		reg				[ 4:0]	state_n_global					;
		wire					init_end						;
		wire					send_command_end				;
		wire					wait_result_1_end				;
		wire					read_result_end					;
		wire					wait_result_2_end				;
		reg				[25:0]	cnt								;
		
		wire					scl_en							;
		wire					scl_cnt_end						;
		wire					scl_low_middle					;
		wire					scl_high_middle					;
		reg				[ 8:0]	scl_cnt							;
		reg						scl_reg							;
		wire					scl_neg							;
		
		reg				[ 2:0]	state_send						;
		reg				[ 7:0]	send_byte						;
		wire			[ 7:0]	send_third_byte					;
		reg						sda_send_reg					;
		reg						sda_fpga_ctrl					;
		reg				[ 3:0]	send_bit_cnt					;
		reg				[ 3:0]	send_jump_state					;
		reg						ack_received					;
		reg				[ 3:0]	state_read						;
		reg				[ 2:0]	read_bit_cnt					;
		
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				state_c_global	<=	INIT	;
			else
				state_c_global	<=	state_n_global	;
		end
		
		always @(*)begin
			case(state_c_global)
				INIT:begin
					if(init_end)
						state_n_global	=	SEND_COMMAND	;
					else
						state_n_global	=	state_c_global	;
				end
				SEND_COMMAND:begin
					if(send_command_end)
						state_n_global	=	WAIT_RESULT_1	;
					else
						state_n_global	=	state_c_global	;
				end
				WAIT_RESULT_1:begin
					if(wait_result_1_end)
						state_n_global	=	READ_RESULT		;
					else
						state_n_global	=	state_c_global	;
				end
				READ_RESULT:begin
					if(read_result_end)
						state_n_global	=	WAIT_RESULT_2	;
					else
						state_n_global	=	state_c_global	;
				end
				WAIT_RESULT_2:begin
					if(wait_result_2_end)
						state_n_global	=	READ_RESULT		;
					else
						state_n_global	=	state_c_global	;
				end
				default:
					state_n_global		=	INIT			;
			endcase
		end
		
		assign	init_end			=	state_c_global==INIT			&&	cnt==0			;
		assign	send_command_end	=	state_send==SEND_END			&&	scl_high_middle	;
		assign	wait_result_1_end	=	state_c_global==WAIT_RESULT_1	&&	cnt==0			;
		assign	read_result_end		=	state_read==READ_END			&&	scl_high_middle	;
		assign	wait_result_2_end	=	state_c_global==WAIT_RESULT_2	&&	cnt==0			;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				cnt	<=	TIME_1S	-1	;
			else if(send_command_end)
				cnt	<=	TIME_180MS	-1	;
			else if(read_result_end)
				cnt	<=	TIME_120MS	-1	;
			else if(cnt!=0)
				cnt	<=	cnt-1		;
		end
		
		assign	scl_en				=	state_c_global==SEND_COMMAND	||	state_c_global==READ_RESULT	;
		assign	scl_cnt_end			=	scl_en	&&	scl_cnt==CLOCK_DIV-1	;
		assign	scl_high_middle		=	scl_en	&&	scl_cnt==CLOCK_DIV_QUAT -1	;
		assign	scl_low_middle		=	scl_en	&&	scl_cnt==CLOCK_DIV_HALF + CLOCK_DIV_QUAT	-1	;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				scl_cnt	<=	0	;
			else if(scl_en)begin
				if(scl_cnt_end)
					scl_cnt	<=	0	;
				else	
					scl_cnt	<=	scl_cnt	+1	;
			end
			else 
				scl_cnt	<=	0	;
		end
				
		assign	scl		=	scl_en	?	((scl_cnt	<	CLOCK_DIV_HALF	)?	1'b1	:	1'b0	)	:	1'b1	;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)
				scl_reg	<=	1	;
			else 
				scl_reg	<=	scl	;
		end
		
		assign	scl_neg	=	scl==0	&&	scl_reg==1	;
		assign	send_third_byte		=	SEND_THIRD_BYTE			;
		
		always @(posedge clk or negedge reset)begin
			if(reset==0)begin
				sda_fpga_ctrl	<=	1	;
				sda_send_reg	<=	1	;
				send_bit_cnt	<=	0	;
				send_jump_state	<=	0	;	
				ack_received	<=	0	;
				read_bit_cnt	<=	0	;
				state_read		<=	READ_INIT	;
				state_send		<=	SEND_INIT	;
				lux_data		<=	16'd0		;
			end
			else if(state_c_global==SEND_COMMAND)begin
				case(state_send)
					SEND_INIT:begin
						sda_fpga_ctrl	<=	1	;
						sda_send_reg	<=	1	;
						send_bit_cnt	<=	0	;
						send_jump_state	<=	0	;
						ack_received	<=	0	;
						state_send		<=	LOAD_FIRST_BYTE	;
					end
					LOAD_FIRST_BYTE:begin
						send_byte		<=	SEND_FIRST_BYTE	;
						state_send		<=	SEND_START		;
						send_jump_state	<=	LOAD_SECOND_BYTE;
					end
					LOAD_SECOND_BYTE:begin	
						send_byte		<=	SEND_SECOND_BYTE;
						state_send		<=	SEND_BYTE		;
						send_jump_state	<=	SEND_END		;
					end
					SEND_START:begin
						if(scl_high_middle)begin
							sda_send_reg	<=	0			;
							state_send		<=	SEND_BYTE	;
						end
						else
							state_send		<=	state_send	;
					end
					SEND_BYTE:begin
						if(scl_low_middle)begin
							if(send_bit_cnt==8)begin
								send_bit_cnt	<=	0		;
								state_send		<=	RECIVE_ACK	;
							end
							else begin
								sda_send_reg	<=	send_byte[7-send_bit_cnt]		;	
								send_bit_cnt	<=	send_bit_cnt	+1				;
							end
						end
						else 
							state_send	<=	state_send	;
					end
					RECIVE_ACK:begin
						sda_fpga_ctrl	<=	0	;
						if(scl_high_middle)begin
							ack_received	<=	sda			;
							state_send		<=	CHECK_ACK	;
						end
						else 
							state_send		<=	state_send	;
					end
					CHECK_ACK:begin
						if(ack_received==1'b0)begin
							if(scl_neg)begin
								state_send	<=	send_jump_state	;
								sda_fpga_ctrl	<=	1		;
								sda_send_reg	<=	0		;
							end
							else 
								state_send	<=	state_send	;
						end
						else 
							state_send		<=	SEND_INIT	;
					end
					SEND_END:begin
						sda_fpga_ctrl	<=	1	;
						if(scl_high_middle)begin
							sda_send_reg	<=	1	;
							state_send		<=	SEND_INIT	;
						end
						else 
							state_send		<=	state_send	;
					end
					default:begin
						state_send		<=	SEND_INIT	;
						ack_received	<=	0			;
						sda_fpga_ctrl	<=	1			;
						sda_send_reg	<=	1			;
						send_bit_cnt	<=	0			;
						send_jump_state	<=	0			;
					end
				endcase
			end
			else if(state_c_global==READ_RESULT)begin
				case(state_read)
					READ_INIT:begin
						sda_fpga_ctrl	<=	1	;
						sda_send_reg	<=	1	;
						ack_received	<=	0	;
						read_bit_cnt	<=	0	;
						send_bit_cnt	<=	0	;
						state_read		<=	READ_START	;
					end
					READ_START:begin
						if(scl_high_middle)begin
							sda_send_reg	<=	0	;
							state_read		<=	READ_SEND_BYTE	;
						end
						else
							state_read		<=	state_read		;
					end
					READ_SEND_BYTE:begin
						if(scl_low_middle)begin
							if(send_bit_cnt==8)begin
								send_bit_cnt	<=	0	;
								state_read		<=	READ_ACK	;
							end
							else begin
								sda_send_reg	<=	send_third_byte[7-send_bit_cnt]	;
								send_bit_cnt	<=	send_bit_cnt	+1	;
							end
						end
						else 
							state_read	<=	state_read	;
					end
					READ_ACK:begin
						sda_fpga_ctrl	<=		0	;
						if(scl_high_middle)begin
							ack_received	<=	sda	;
							state_read		<=	CHECK_READ_ACK	;
						end
						else
							state_read		<=	state_read		;
					end
					CHECK_READ_ACK:begin
						if(ack_received==1'b0)
							state_read		<=	READ_HIGH_BYTE	;
						else
							state_read		<=	READ_INIT		;
					end
					READ_HIGH_BYTE:begin
						if(scl_high_middle)begin
							if(read_bit_cnt==7)begin
								read_bit_cnt	<=		0		;
								lux_data[8]		<=		sda		;
								state_read		<=		SEND_FIRST_ACK	;
							end
							else begin
								lux_data[15-read_bit_cnt]	<=	sda		;
								read_bit_cnt	<=		read_bit_cnt	+1	;
							end
						end
						else
							state_read		<=	state_read		;
					end
					SEND_FIRST_ACK:begin
						if(scl_neg)begin
							sda_fpga_ctrl	<=	1	;
							sda_send_reg	<=	0	;
							state_read		<=	SEND_ACK_READ	;
						end
						else
							state_read		<=	state_read		;
					end
					SEND_ACK_READ:begin
						if(scl_neg)begin
							sda_fpga_ctrl	<=	0	;
							sda_send_reg	<=	1	;
							state_read		<=	READ_LOW_BYTE	;
						end
						else
							state_read		<=	state_read		;
					end
					READ_LOW_BYTE:begin
						if(scl_high_middle)begin
							if(read_bit_cnt==7)begin
								read_bit_cnt	<=		0		;
								lux_data[0]		<=		sda		;
								state_read		<=		SEND_SECOND_ACK	;
							end
							else begin
								lux_data[7-read_bit_cnt]	<=	sda		;
								read_bit_cnt	<=		read_bit_cnt	+1	;
							end
						end
						else
							state_read	<=	state_read		;
					end
					SEND_SECOND_ACK:begin
						if(scl_neg)begin
							sda_fpga_ctrl	<=	1	;
							sda_send_reg	<=	1	;
							state_read		<=	SEND_ACK_END	;
						end
						else
							state_read		<=	state_read	;
					end
					SEND_ACK_END:begin
						if(scl_neg)begin
							state_read	<=	READ_END		;
							sda_send_reg<=	0				;
						end
						else
							state_read	<=	state_read		;
					end
					READ_END:begin
						if(scl_high_middle)begin
							sda_send_reg	<=	1			;
							state_read		<=	READ_INIT	;
						end
						else
							state_read		<=	state_read	;
					end
					default:begin
						sda_fpga_ctrl	<=	1	;
						sda_send_reg	<=	1	;	
						ack_received	<=	0	;	
						read_bit_cnt	<=	0	;
						send_bit_cnt	<=	0	;		
						state_read		<=	READ_INIT	;	
					end
				endcase
			end
			else begin
				sda_fpga_ctrl	<=	1	;
			    sda_send_reg	<=	1	;
				send_bit_cnt	<=	0	;			
				send_jump_state	<=	0	;			
				ack_received	<=	0	;		
				read_bit_cnt	<=	0	;				
				state_read		<=	READ_INIT	;		
				state_send		<=	SEND_INIT	;	
			end
		end
		
		assign	lux_data_vld	=	read_result_end	;
		assign	sda		=		sda_fpga_ctrl	?	sda_send_reg	:	1'bz		;
		
endmodule


