module RAM #(
    parameter DATA_W = 8,
    parameter PTR_W  = 4
) (
    input                   clk    ,
    input                   rst_n  ,
    input                   wq     ,
    input                   rq     ,
    input      [DATA_W-1:0] wr_data,
    input      [DATA_W-1:0] fo_data,
    output                  error  
);
   reg flag;
   reg [0:(1<<(PTR_W))-1] cnt_wq;
   always@(posedge clk or negedge rst_n)
      begin
         if(!rst_n)begin
            cnt_wq <= 0;
         end else if(flag)begin
            cnt_wq <= 0;
         end else if(wq)begin
            cnt_wq <= cnt_wq+1;
         end else begin
            cnt_wq <= cnt_wq;
         end
      end
   reg [(1<<(PTR_W))-1:0] cnt_rq;
   always@(posedge clk or negedge rst_n)
      begin
         if(!rst_n)begin
            cnt_rq <= 0;
         end else if(flag)begin
            cnt_rq <= 0;
         end else if(rq)begin
            cnt_rq <= cnt_rq+1;
         end else begin
            cnt_rq <= cnt_rq;
         end
      end

   reg [DATA_W-1:0] mem [0:(1<<(PTR_W))-1];
   reg [0:(1<<(PTR_W))-1] i;
   always@(posedge clk or negedge rst_n)
      begin
         if(!rst_n)begin
            for(i=0;i<(1<<(PTR_W));i=i+1)
                mem[i] <= 0;
         end else if(flag)begin
             for(i=0;i<(1<<(PTR_W));i=i+1)
                mem[i] <= 0;
         end else if(wq)begin
                mem[cnt_wq] <= wr_data;
         end else begin
             mem[cnt_wq] <= mem[cnt_wq];
         end
      end
   reg rq_delay;
   always@(posedge clk)
        rq_delay <= rq;
   always@(posedge clk or negedge rst_n)
      begin
         if(!rst_n)begin
            flag <= 0;
         end else if(rq_delay)begin
            if(mem[cnt_rq-1] == fo_data)begin
               flag <= 0;
            end else begin
               flag <= 1;
            end
         end else begin
            flag <= 0;
         end
      end
     
     assign error = flag;

endmodule