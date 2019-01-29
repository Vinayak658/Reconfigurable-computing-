`timescale 1ns/10ps
module Float_divide_32bit(quotient,divisor,dividend);

output reg [31:0] quotient;
input wire [31:0] divisor,dividend;
reg        [23:0] mantissa_divisor,mantissa_dividend;
wire     [24:0] remainder1;
wire      [23:0] quotient1;
wire     [24:0] remainder2;
wire      [23:0] quotient2;
reg       [24:0] rem1;
reg       [23:0] quo1;
integer i,j,k;
integer count1,count2;

always@(*)
begin

		i=0;
		j=0;
		k=0;
		
		mantissa_divisor = {1'b1,divisor[22:0]};
		mantissa_dividend= {1'b1,dividend[22:0]};
		if (mantissa_divisor > mantissa_dividend)
           quotient[30:23] = 8'b01111110 +dividend[30:23] - divisor[30:23];
        else
           quotient[30:23] = 8'b01111111 +dividend[30:23] - divisor[30:23];
		rem1 = 25'd0;
		quo1 = 24'd0;

        quotient[31] = divisor[31]^dividend[31];   //sign bit
 
      
       
        
 
        for(i=0;i<=7;i=i+1) 
		begin
			
			    mantissa_divisor= {1'b0,mantissa_divisor[23:1]};		
	    end
		
end
		
        Radix2_divider div1(remainder1,quotient1,mantissa_divisor,mantissa_dividend);
        shifter s1(quotient2[22:0],quotient1);
        



always@(*) 
begin

quotient[22:0] = quotient2[22:0];

end
endmodule

module topcell(clk);
input clk;
wire [31:0]divisor;
wire [31:0]dividend,quotient;

Float_divide_32bit  f1(quotient,divisor,dividend);

vio_0 your_instance_name (
  .clk(clk),                // input wire clk
  .probe_in0(quotient),    // input wire [31 : 0] probe_in0
  .probe_out0(divisor),  // output wire [31 : 0] probe_out0
  .probe_out1(dividend)  // output wire [31 : 0] probe_out1
);


endmodule