module sobel(
   input    clk             ,
   input    rstn            ,
   input    per_frame_vsync ,
   input    per_frame_href  ,
   input    per_frame_clken ,
   input    per_img_Bit     ,
   output   post_frame_vsync,
   output   post_frame_href ,
   output   post_frame_clken,
   output   post_img_Bit    
);
wire  matrix_frame_vsync;
wire  matrix_frame_href ;
wire  matrix_frame_clken;
wire  matrix_p11,matrix_p12,matrix_p13;
wire  matrix_p21,matrix_p22,matrix_p23;
wire  matrix_p31,matrix_p32,matrix_p33;
VIP_Matrix_Generate_3x3_8Bit 
#(
   .IMG_HDISP(10'd480),
   .IMG_VDISP(10'd272)
)
VIP_Matrix_Generate_3x3_1Bit_u
(
   .clk                             (clk                             ) ,//       clk                             
   .rstn                            (rstn                            ) ,//       rstn                                                                
   .per_frame_vsync                 (per_frame_vsync                 ) ,//       per_frame_vsync                 
   .per_frame_href                  (per_frame_href                  ) ,//       per_frame_href                  
   .per_frame_clken                 (per_frame_clken                 ) ,//       per_frame_clken                 
   .per_img_Y                       (per_img_Bit                     ) ,// [7:0] per_img_Y                                                                     
   .matrix_frame_vsync              (matrix_frame_vsync              ) ,//       matrix_frame_vsync              
   .matrix_frame_href               (matrix_frame_href               ) ,//       matrix_frame_href               
   .matrix_frame_clken              (matrix_frame_clken              ) ,//       matrix_frame_clken              
   .matrix_p11(matrix_p11), .matrix_p12(matrix_p12), .matrix_p13(matrix_p13) ,// [7:0] matrix_p11,matrix_p12,matrix_p13
   .matrix_p21(matrix_p21), .matrix_p22(matrix_p22), .matrix_p23(matrix_p23) ,// [7:0] matrix_p21,matrix_p22,matrix_p23
   .matrix_p31(matrix_p31), .matrix_p32(matrix_p32), .matrix_p33(matrix_p33)  // [7:0] matrix_p31,matrix_p32,matrix_p33
);
reg post_img_bit1,post_img_bit2,post_img_bit3;
always@(posedge clk or negedge rstn)
   begin
      if(!rstn)begin
         post_img_bit1 <= 0;
         post_img_bit2 <= 0;
         post_img_bit3 <= 0;
      end else begin
         post_img_bit1 <= matrix_p11 & matrix_p12 & matrix_p13;
         post_img_bit2 <= matrix_p21 & matrix_p22 & matrix_p23;
         post_img_bit3 <= matrix_p31 & matrix_p32 & matrix_p33;         
      end
   end

reg post_img_bit4;
always@(posedge clk or negedge rstn)
   begin
      if(!rstn)begin
         post_img_bit4 <= 0;
      end else begin
         post_img_bit4 <= post_img_bit1 & post_img_bit2 & post_img_bit3;
      end
   end

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
         per_frame_vsync_r <= {per_frame_vsync_r[0],per_frame_vsync};
         per_frame_href_r  <= {per_frame_href_r [0],per_frame_href };
         per_frame_clken_r <= {per_frame_clken_r[0],per_frame_clken};
      end
   end

assign post_frame_vsync = per_frame_vsync_r[1];
assign post_frame_href  = per_frame_href_r [1]; 
assign post_frame_clken = per_frame_clken_r[1];
assign post_img_Bit     = per_frame_href_r ? post_img_bit4:0;

endmodule 
