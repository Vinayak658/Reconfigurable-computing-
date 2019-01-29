module shifter(quo,quo2);

input wire [23:0]quo2;
output reg [22:0] quo;
reg [23:0]q;
integer k;

always@(*)
begin       

q = quo2;
             for(k=23;k>=0;k=k-1)
                begin
                  if (q[23] == 1'b0)
                     q = {q[22:0],1'b0};
                end
             quo = q[22:0];
             
end
endmodule
