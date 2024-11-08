genvar i;
generate 
for(i=0;i<16;i=i+1)
    begin:gfor
        shake_u shake_u(        
            .clk    (clk     ),  //input      clk   ,
            .rstn   (rstn    ),  //input      rstn  ,
            .key    (key[i]  ),  //input      key   ,
            .shape  (key_pulse[i])   //output reg shape  
        );
    end
endgenerate


//快时钟到慢时钟跨时钟域处理
xpm_cdc_array_single #(
  //Common module parameters
  .DEST_SYNC_FF   (2), // integer; range: 2-10
  .INIT_SYNC_FF   (0), // integer; 0=disable simulation init values, 1=enable simulation init values
  .SIM_ASSERT_CHK (0), // integer; 0=disable simulation messages, 1=enable simulation messages
  .SRC_INPUT_REG  (1), // integer; 0=do not register input, 1=register input
  .WIDTH          (26)  // integer; range: 1-1024
) xpm_cdc_h_phase_shift (
  .src_clk  (gmii_rx_clk),  // optional; required when SRC_INPUT_REG = 1
  .src_in   (h_phase_shift),
  .dest_clk (clk),
  .dest_out (h_phase_shift_reg)
);


//IBUFDS 差分转单端、OBUFDS 单端转差分
IBUFDS #(
   .DIFF_TERM("TRUE"),       // Differential Termination
   .IBUF_LOW_PWR("FALSE"),     // Low power="TRUE", Highest performance="FALSE" 
   .IOSTANDARD("LVDS")     // Specify the input I/O standard
) IBUFDS_inst (
   .O(ad1_clk_s),  // Buffer output
   .I(ad1_clkoutp),  // Diff_p buffer input (connect directly to top-level port)
   .IB(ad1_clkoutn) // Diff_n buffer input (connect directly to top-level port)
);


//参数重定义，代码中参数太大，需要减少参数大小，加快仿真
defparam qiangdaqi.CNT_MAX=100;