//-------------------------------------------------------------
`timescale 1ns/10ps

module Radix2_divider(remainder,quotient,divisor,dividend);

input [7:0]divisor,dividend;
output reg [7:0] quotient;
output reg [8:0] remainder;
reg [7:0] inA;
reg [7:0] inB;
reg [8:0] inB1;
reg [8:0] inP=9'b000000000;
reg [16:0] inPA;
reg [16:0] inB0;
reg flag=0,flag2=0;
reg [3:0] count=4'b0000;
reg [7:0]position_of_1bar=8'b00000000;
reg [7:0]position_of_1bar0=8'b00000000;
integer i,j;

always@(*)
begin
position_of_1bar=8'b00000000;
position_of_1bar0=8'b00000000;
flag=0;
flag2=0;
inP=9'b000000000;
inA = dividend;
inB = divisor;
inPA = {inP,inA};
count = 4'b0000;


// STEP 1  
//calculation of no. of leading zeroes and left shift B and PA  by number of leading zeros in divisor
//----------------------------------------------------------------
//while(inB[7]==0)
for(i=0;i<8;i=i+1)              
begin
if(inB[7]==0)
begin
count=count+1;
inB={inB[6:0],1'b0};         //left shift B once
inPA={inPA[15:0],1'b0};      //left shift PA once
end
end

//------------------------------------------------------------------------

inB0={1'b0,inB,8'b00000000};

// STEP 2
// Check top 3 bits of PA and decide
//-------------------------------------------------------------------------

for (i=0;i<8;i=i+1)                  //as 8 bit division therefore iterate 8 times

begin

//------------2.1 If top 3 bits are equal 
if (inPA[16]==inPA[15] && inPA[15]==inPA[14])        // if (inPA[16]==inPA[15]==inPA[14]==0)
        begin
        inPA={inPA[15:0],1'b0};           //left shift once and make LSB as 0
        end
        
//-----------2.2 If top 3 bits are unequal    
else
     begin
    //-------If P is (-ve)=>MSB is 1
        if (inPA[16] == 1'b1)
          begin 
          inPA={inPA[15:0],1'b0};         //left shift once and assign MSB as 0
          position_of_1bar[7-i] = 1'b1;   //to take care of (-1) at LSB
          flag = 1;      
          inPA = inPA + inB0;                 //add P to B
         
        end
        
  //-------if P is (+ve)=>MSB is(+ve)
        if (inPA[16] == 1'b0)
          begin  
          inPA={inPA[15:0],1'b1};       //left shift once and make MSB as 1
          inPA=inPA-inB0;               //P=P-B
          flag2 = 1;
          end
    end
    
end
  
inP[8:0] = inPA[16:8];         //Getting the values of P
inA[7:0] = inPA[7:0];          //Getting the values of A
if(inP[8] == 0)
   begin
   if (flag == 1'b1)
     begin                                           
     inA = inA - position_of_1bar;                 
     end 
     
   end

//---------step 3 If the final remiander is (-ve)
if (inP[8]==1) 
begin  
    // inB1 = {1'b0,inB};
    inP=inP+inB;     //correction of remainder by adding B to P 
    if (flag == 1'b1)
     begin
     position_of_1bar0 = position_of_1bar + 1'b1;     //adding to 2 subtractive terms
     inA = inA - position_of_1bar0;                  //correction of quotient
     end
    else
     inA = inA - 1;
     
end
  


//---step 4 Shift remainder "count" number of times
remainder = inP;
for(j=0;j<count;j=j+1)  
 begin
 remainder={1'b0,remainder[8:1]};   //Right shift "count" number of times
end
 
quotient = inA;

end
endmodule



module top_cell(input clk);
wire [7:0]dividend;
wire [7:0] divisor;
wire [7:0] quotient;
wire [8:0] remainder;

Radix2_divider sw(remainder,quotient,divisor,dividend);

vio_0 your_instance_name (
  .clk(clk),                // input wire clk
  .probe_in0(quotient),    // input wire [7 : 0] probe_in0
  .probe_in1(remainder),    // input wire [8 : 0] probe_in1
  .probe_out0(dividend),  // output wire [7 : 0] probe_out0
  .probe_out1(divisor)  // output wire [7 : 0] probe_out1
);
endmodule
