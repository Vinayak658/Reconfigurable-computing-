//-------------------------------------------------------------
`timescale 1ns/10ps

module srt_16bit(remainder,quotient,divisor,dividend);

input [15:0]divisor,dividend;
output reg [15:0] quotient;
output reg [16:0] remainder;
reg [15:0] inA;
reg [15:0] inB;
reg [16:0] inB1;
reg [16:0] inP=17'b00000000000000000;
reg [32:0] inPA;
reg [32:0] inB0;
reg flag=0,flag2=0;
reg [4:0] count=5'b00000;
reg [15:0]position_of_1bar=16'b0000000000000000;
reg [15:0]position_of_1bar0=16'b0000000000000000;
integer i,j;

always@(*)
begin
position_of_1bar=16'b0000000000000000;
position_of_1bar0=16'b0000000000000000;
flag=0;
flag2=0;
inP=17'b00000000000000000;
inA = dividend;
inB = divisor;
inPA = {inP,inA};
count =5'b00000;


// STEP 1  
//calculation of no. of leading zeroes and left shift B and PA  by number of leading zeros in divisor
//----------------------------------------------------------------
//while(inB[7]==0)
for(i=0;i<16;i=i+1)              
begin
if(inB[15]==0)
begin
count=count+1;
inB={inB[14:0],1'b0};         //left shift B once
inPA={inPA[31:0],1'b0};      //left shift PA once
end
end

//------------------------------------------------------------------------

inB0={1'b0,inB,16'b0000000000000000};

// STEP 2
// Check top 3 bits of PA and decide
//-------------------------------------------------------------------------

for (i=0;i<16;i=i+1)                 

begin

//------------2.1 If top 3 bits are equal 
if (inPA[32]==inPA[31] && inPA[31]==inPA[30])        
        begin
        inPA={inPA[31:0],1'b0};           
        end
        
//-----------2.2 If top 3 bits are unequal    
else
     begin
    //-------If P is (-ve)=>MSB is 1
        if (inPA[32] == 1'b1)
          begin 
          inPA={inPA[31:0],1'b0};         
          position_of_1bar[15-i] = 1'b1;  
          flag = 1;      
          inPA = inPA + inB0;                 
         
        end
        
  //-------if P is (+ve)=>MSB is(+ve)
        //if (inPA[32] == 1'b0)
        else
          begin  
          inPA={inPA[31:0],1'b1};      
          inPA=inPA-inB0;             
          flag2 = 1;
          end
    end
    
end
  
inP[16:0] = inPA[32:16];        
inA[15:0] = inPA[15:0];         
if(inP[16] == 0)
   begin
   if (flag == 1'b1)
     begin                                           
     inA = inA - position_of_1bar;                 
     end 
     
   end

//---------step 3 If the final remiander is (-ve)
if (inP[16]==1) 
begin  
    
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
 remainder={1'b0,remainder[16:1]};   //Right shift "count" number of times
end
 
quotient = inA;

end
endmodule



module top_cell(input clk);
wire [15:0]dividend;
wire [15:0] divisor;
wire [15:0] quotient;
wire [16:0] remainder;

srt_16bit sw(remainder,quotient,divisor,dividend);


vio_0 your_instance_name (
  .clk(clk),                // input wire clk
  .probe_in0(quotient),    // input wire [15 : 0] probe_in0
  .probe_in1(remainder),    // input wire [16 : 0] probe_in1
  .probe_out0(dividend),  // output wire [15 : 0] probe_out0
  .probe_out1(divisor)  // output wire [15 : 0] probe_out1
);
endmodule
