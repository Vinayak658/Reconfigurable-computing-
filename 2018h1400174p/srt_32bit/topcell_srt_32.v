//-------------------------------------------------------------
`timescale 1ns/10ps

module srt_32bit(remainder,quotient,divisor,dividend);

input [31:0]divisor,dividend;
output reg [31:0] quotient;
output reg [32:0] remainder;
reg [31:0] inA;
reg [31:0] inB;
reg [32:0] inB1;
reg [32:0] inP=33'b000000000000000000000000000000000;
reg [64:0] inPA;
reg [64:0] inB0;
reg flag=0,flag2=0;
reg [5:0] count=6'b000000;
reg [31:0]position_of_1bar=32'b00000000000000000000000000000000;
reg [31:0]position_of_1bar0=32'b00000000000000000000000000000000;
integer i,j;

always@(*)
begin
position_of_1bar=32'b00000000000000000000000000000000;
position_of_1bar0=32'b00000000000000000000000000000000;
flag=0;
flag2=0;
inP=33'b000000000000000000000000000000000;
inA = dividend;
inB = divisor;
inPA = {inP,inA};
count =6'b000000;


// STEP 1  
//calculation of no. of leading zeroes and left shift B and PA  by number of leading zeros in divisor
//----------------------------------------------------------------
for(i=0;i<32;i=i+1)              
begin
if(inB[31]==0)
begin
count=count+1;
inB={inB[30:0],1'b0};         //left shift B once
inPA={inPA[63:0],1'b0};      //left shift PA once
end
end

//------------------------------------------------------------------------

inB0={1'b0,inB,32'b00000000000000000000000000000000};

// STEP 2
// Check top 3 bits of PA and decide
//-------------------------------------------------------------------------

for (i=0;i<32;i=i+1)                  

begin

//------------2.1 If top 3 bits are equal 
if (inPA[64]==inPA[63] && inPA[63]==inPA[62])       
        begin
        inPA={inPA[63:0],1'b0};          
        end
        
//-----------2.2 If top 3 bits are unequal    
else
     begin
    //-------If P is (-ve)=>MSB is 1
        if (inPA[64] == 1'b1)
          begin 
          inPA={inPA[63:0],1'b0};         
          position_of_1bar[31-i] = 1'b1;   
          flag = 1;      
          inPA = inPA + inB0;                 
         
        end
        
  //-------if P is (+ve)=>MSB is(+ve)
        //if (inPA[64] == 1'b0)
        else
          begin  
          inPA={inPA[63:0],1'b1};      
          inPA=inPA-inB0;               
          flag2 = 1;
          end
    end
    
end
  
inP[32:0] = inPA[64:32];         //Getting the values of P
inA[31:0] = inPA[31:0];          //Getting the values of A
if(inP[32] == 0)
   begin
   if (flag == 1'b1)
     begin                                           
     inA = inA - position_of_1bar;                 
     end 
     
   end

//---------step 3 If the final remiander is (-ve)
if (inP[32]==1) 
begin 
    inP=inP+inB;           //correction of remainder by adding B to P 
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
 remainder={1'b0,remainder[32:1]};   //Right shift "count" number of times
end
 
quotient = inA;

end
endmodule



module top_cell(input clk);
wire [31:0]dividend;
wire [31:0] divisor;
wire [31:0] quotient;
wire [32:0] remainder;

srt_32bit sw(remainder,quotient,divisor,dividend);

vio_0 your_instance_name (
  .clk(clk),                // input wire clk
  .probe_in0(quotient),    // input wire [31 : 0] probe_in0
  .probe_in1(remainder),    // input wire [32 : 0] probe_in1
  .probe_out0(dividend),  // output wire [31 : 0] probe_out0
  .probe_out1(divisor)  // output wire [31 : 0] probe_out1
);
endmodule
