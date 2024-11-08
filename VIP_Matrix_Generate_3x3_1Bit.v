`timescale 1ns / 1ps
module VIP_Matrix_Generate_3x3_8Bit
#(
   parameter [9:0] IMG_HDISP = 10'd480,
   parameter [9:0] IMG_VDISP = 10'd272
)
(
   input       clk                              ,
   input       rstn                             ,
           
   input       per_frame_vsync                  ,
   input       per_frame_href                   ,
   input       per_frame_clken                  ,
   input       per_img_Y                        ,

   output      matrix_frame_vsync               ,
   output      matrix_frame_href                ,
   output      matrix_frame_clken               ,
   output reg  matrix_p11,matrix_p12,matrix_p13 ,
   output reg  matrix_p21,matrix_p22,matrix_p23 ,
   output reg  matrix_p31,matrix_p32,matrix_p33 
);

wire row1_data;
wire row2_data;
reg  row3_data;

always@(posedge clk or negedge rstn)
   begin
      if(!rstn)begin
         row3_data <= 0;
      end else begin
         if(per_frame_clken)begin
            row3_data <= per_img_Y;
         end else begin
            row3_data <= row3_data;
         end
      end
   end 

wire shift_clk_en = per_frame_clken;
shift shift_u 
//#(
//   .RAM_Length (IMG_HDISP)
//);
(
	.clock    (clk  ),
   .clken    (shift_clk_en),
	.shiftin  (row3_data  ),
	.taps0x   (row2_data  ),
	.taps1x   (row1_data  ),
	.shiftout (      ),
);

reg [1:0] per_frame_vsync_r;
reg [1:0] per_frame_href_r ;
reg [1:0] per_frame_clken_r;
always@(posedge clk or negedge rstn)
   begin
      if(!rstn)begin
         per_frame_vsync_r <= 0;
         per_frame_href_r  <= 0;
         per_frame_clken_r <= 0;
      end else begin
         per_frame_vsync_r <= {per_frame_vsync_r[0],per_frame_vsync_r};
         per_frame_href_r  <= {per_frame_href_r [0],per_frame_href_r };
         per_frame_clken_r <= {per_frame_clken_r[0],per_frame_clken_r};
      end
   end

wire read_frame_href  = per_frame_href_r [0];
wire resd_frame_clken = per_frame_clken_r[0];

assign matrix_frame_vsync = per_frame_vsync_r[1];
assign matrix_frame_href  = per_frame_href_r [1];
assign matrix_frame_clken = per_frame_clken_r[1];

always@(posedge clk or negedge rstn)
		begin
			if(!rstn)begin
				{matrix_p11,matrix_p12,matrix_p13} <= 3'd0;
				{matrix_p21,matrix_p22,matrix_p23} <= 3'd0;
				{matrix_p31,matrix_p32,matrix_p33} <= 3'd0;
			end else if(read_frame_href)begin
            if(resd_frame_clken)begin
               {matrix_p11,matrix_p12,matrix_p13} <= {matrix_p12,matrix_p13,row1_data};
               {matrix_p21,matrix_p22,matrix_p23} <= {matrix_p22,matrix_p23,row2_data};
               {matrix_p31,matrix_p32,matrix_p33} <= {matrix_p32,matrix_p33,row3_data};
            end else begin
               {matrix_p11,matrix_p12,matrix_p13} <= {matrix_p11,matrix_p12,matrix_p13};
               {matrix_p21,matrix_p22,matrix_p23} <= {matrix_p21,matrix_p22,matrix_p23};
               {matrix_p31,matrix_p32,matrix_p33} <= {matrix_p31,matrix_p32,matrix_p33};
            end
			end else begin
				{matrix_p11,matrix_p12,matrix_p13} <= 3'd0;
				{matrix_p21,matrix_p22,matrix_p23} <= 3'd0;
				{matrix_p31,matrix_p32,matrix_p33} <= 3'd0;
			end
		end

endmodule