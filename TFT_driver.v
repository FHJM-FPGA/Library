//**************************************************************************
// *** ���� : TFT_driver.v
// *** ���� : xianyu_FPGA
// *** ���� : https://www.cnblogs.com/xianyufpga/
// *** ���� : 2019-08-10
// *** ���� : TFT��ʾ�����������ֱ���480x272
//**************************************************************************
module TFT_driver
//========================< �˿� >==========================================
(
//system --------------------------------------------
input   wire                clk                     ,   //ʱ�ӣ�10Mhz
input   wire                rst_n                   ,   //��λ���͵�ƽ��Ч
//input ---------------------------------------------
output  wire                TFT_req                 ,   //�����������
input   wire    [15:0]      TFT_din                 ,   //�õ�ͼ������
//output --------------------------------------------
output  wire                TFT_clk                 ,   //TFT����ʱ��
output  wire                TFT_rst                 ,   //TFT��λ�ź�
output  wire                TFT_blank               ,   //TFT�������
output  wire                TFT_hsync               ,   //TFT��ͬ��
output  wire                TFT_vsync               ,   //TFT��ͬ��
output  wire    [15:0]      TFT_data                ,   //TFT�������
output  reg                 TFT_de                      //TFT����ʹ��
);
//========================< ���� >==========================================
//480x272 @60 10Mhz ---------------------------------
parameter H_SYNC            = 16'd41                ;   //��ͬ���ź�
parameter H_BACK            = 16'd2                 ;   //����ʾ����
parameter H_DISP            = 16'd480               ;   //����Ч����
parameter H_FRONT           = 16'd2                 ;   //����ʾǰ��
parameter H_TOTAL           = 16'd525               ;   //��ɨ������
//---------------------------------------------------
parameter V_SYNC            = 16'd10                ;   //��ͬ���ź�
parameter V_BACK            = 16'd2                 ;   //����ʾ����
parameter V_DISP            = 16'd272               ;   //����Ч����
parameter V_FRONT           = 16'd2                 ;   //����ʾǰ��
parameter V_TOTAL           = 16'd286               ;   //��ɨ������
//========================< �ź� >==========================================
reg     [15:0]              cnt_h                   ;
wire                        add_cnt_h               ;
wire                        end_cnt_h               ;
reg     [15:0]              cnt_v                   ;
wire                        add_cnt_v               ;
wire                        end_cnt_v               ;
//==========================================================================
//==    �С�������
//==========================================================================
always @(posedge clk or negedge rst_n) begin
    if(!rst_n)
        cnt_h <= 'd0;
    else if(add_cnt_h) begin
        if(end_cnt_h)
            cnt_h <= 'd0;
        else
            cnt_h <= cnt_h + 1'b1;
    end
end

assign add_cnt_h = 'd1;
assign end_cnt_h = add_cnt_h && cnt_h==H_TOTAL-1;

always @(posedge clk or negedge rst_n) begin 
    if(!rst_n)
        cnt_v <= 'd0;
    else if(add_cnt_v) begin
        if(end_cnt_v)
            cnt_v <= 'd0;
        else
            cnt_v <= cnt_v + 1'b1;
    end
end

assign add_cnt_v = end_cnt_h;
assign end_cnt_v = add_cnt_v && cnt_v==V_TOTAL-1;
//==========================================================================
//==    TFT display
//==========================================================================
//TFT������ǰһ�ķ���
assign TFT_req = (cnt_h >= H_SYNC + H_BACK - 1) && (cnt_h < H_SYNC + H_BACK + H_DISP - 1) &&
                 (cnt_v >= V_SYNC + V_BACK    ) && (cnt_v < V_SYNC + V_BACK + V_DISP    )
                 ? 1'b1 : 1'b0;

//TFTʱ��
assign TFT_clk = clk;

//TFT��λ
assign TFT_rst = rst_n;

//TFT�������
assign TFT_blank = rst_n;

//TFT��ͬ��
assign TFT_hsync = (cnt_h < H_SYNC) ? 1'b0 : 1'b1;

//TFT��ͬ��
assign TFT_vsync = (cnt_v < V_SYNC) ? 1'b0 : 1'b1;

//TFT�������
assign TFT_data = TFT_de ? TFT_din : 16'b0;

//TFT����ʹ�ܣ������ݶ���
always @(posedge clk) begin
    TFT_de <= TFT_req;
end

endmodule