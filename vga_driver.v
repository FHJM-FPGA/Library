//VGA驱动
module vga_driver(
    input           clk       ,   //VGA驱动时钟
    input           rstn      ,   //复位信号
    output          vga_hs    ,   //行同步信号
    output          vga_vs    ,   //场同步信号
    output  [15:0]  vga_rgb   ,   //红绿蓝三原色输出
    input   [15:0]  pixel_data,   //像素点数据
    output          data_req  ,   //请求像素点颜色数据输入 
    output  [10:0]  pixel_xpos,   //像素点横坐标
    output  [10:0]  pixel_ypos    //像素点纵坐标    
);                             
reg vga_clk;
always@(posedge clk or negedge rstn)
    begin
        if(!rstn)begin
            vga_clk <= 0;
        end else begin
            vga_clk <= !vga_clk;
        end
    end
//parameter define  
//640*480 60FPS_25MHz
parameter  H_SYNC   =  10'd96;    //行同步
parameter  H_BACK   =  10'd48;    //行显示后沿
parameter  H_DISP   =  10'd640;   //行有效数据
parameter  H_FRONT  =  10'd16;    //行显示前沿
parameter  H_TOTAL  =  10'd800;   //行扫描周期

parameter  V_SYNC   =  10'd2;     //场同步
parameter  V_BACK   =  10'd33;    //场显示后沿
parameter  V_DISP   =  10'd480;   //场有效数据
parameter  V_FRONT  =  10'd10;    //场显示前沿
parameter  V_TOTAL  =  10'd525;   //场扫描周期


// //1024*768 60FPS_65MHz
// parameter  H_SYNC   =  11'd136;   //行同步     
// parameter  H_BACK   =  11'd160;   //行显示后沿
// parameter  H_DISP   =  11'd1024;  //行有效数据
// parameter  H_FRONT  =  11'd24;    //行显示前沿
// parameter  H_TOTAL  =  11'd1344;  //行扫描周期  注意位宽长度,需要11位的位宽

// parameter  V_SYNC   =  11'd6;     //场同步
// parameter  V_BACK   =  11'd29;    //场显示后沿
// parameter  V_DISP   =  11'd768;   //场有效数据
// parameter  V_FRONT  =  11'd3;     //场显示前沿
// parameter  V_TOTAL  =  11'd806;   //场扫描周期

//reg define                                     
reg  [10:0] cnt_h;               
reg  [10:0] cnt_v;

//wire define
wire       vga_en;

//*****************************************************
//**                    main code
//*****************************************************
//VGA行场同步信号
assign vga_hs  = (cnt_h <= H_SYNC - 1'b1) ? 1'b0 : 1'b1;
assign vga_vs  = (cnt_v <= V_SYNC - 1'b1) ? 1'b0 : 1'b1;

//使能RGB565数据输出
assign vga_en  = (((cnt_h >= H_SYNC+H_BACK) && (cnt_h < H_SYNC+H_BACK+H_DISP))
                 &&((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                 ?  1'b1 : 1'b0;
                 
//RGB565数据输出                 
assign vga_rgb = vga_en ? pixel_data : 16'd0;

//请求像素点颜色数据输入                
assign data_req = (((cnt_h >= H_SYNC+H_BACK-1'b1) && (cnt_h < H_SYNC+H_BACK+H_DISP-1'b1))
                  && ((cnt_v >= V_SYNC+V_BACK) && (cnt_v < V_SYNC+V_BACK+V_DISP)))
                  ?  1'b1 : 1'b0;

//像素点坐标                
assign pixel_xpos = data_req ? (cnt_h - (H_SYNC + H_BACK - 1'b1)) : 10'd0;
assign pixel_ypos = data_req ? (cnt_v - (V_SYNC + V_BACK - 1'b1)) : 10'd0;

//行计数器对像素时钟计数
always @(posedge vga_clk or negedge rstn) begin         
    if (!rstn)
        cnt_h <= 10'd0;                                  
    else begin
        if(cnt_h < H_TOTAL - 1'b1)                                               
            cnt_h <= cnt_h + 1'b1;                               
        else 
            cnt_h <= 10'd0;  
    end
end

//场计数器对行计数
always @(posedge vga_clk or negedge rstn) begin         
    if (!rstn)
        cnt_v <= 10'd0;                                  
    else if(cnt_h == H_TOTAL - 1'b1) begin
        if(cnt_v < V_TOTAL - 1'b1)                                               
            cnt_v <= cnt_v + 1'b1;                               
        else 
            cnt_v <= 10'd0;  
    end
end

endmodule 