module mul_8(
   input             clk     ,
   input             rstn    ,
   input      [7:0]  mul_a   ,
   input      [4:0]  b       ,
   output reg [15:0] mul_out 
);

   always@(posedge clk or negedge rstn)
      begin
         if(!rstn)begin
            mul_out <= 0;
         end else begin
            case(mul_b)
                0:mul_out <= 0;
                1:mul_out <= mul_a;
                2:mul_out <= mul_a << 1;
                3:mul_out <= (mul_a << 1) + mul_a;
                4:mul_out <= mul_a << 2;
                5:mul_out <= (mul_a << 2) + mul_a;
                6:mul_out <= (mul_a << 2) + (mul_a << 1);
                7:mul_out <= (mul_a << 2) + (mul_a << 1) + mul_a;
                8:mul_out <= mul_a << 3;
                9:mul_out <= (mul_a << 3) + mul_a;
               10:mul_out <= (mul_a << 3) + (mul_a << 1);
               11:mul_out <= (mul_a << 3) + (mul_a << 1) + mul_a;
               12:mul_out <= (mul_a << 3) + (mul_a << 2);
               13:mul_out <= (mul_a << 3) + (mul_a << 2) + mul_a;
               14:mul_out <= (mul_a << 3) + (mul_a << 2) + (mul_a << 1);
               15:mul_out <= (mul_a << 3) + (mul_a << 2) + (mul_a << 1) + mul_a;
               default:;
            endcase
         end
      end 

endmodule
