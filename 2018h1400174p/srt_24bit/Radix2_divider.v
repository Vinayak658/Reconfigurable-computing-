

module Radix2_divider(remainder,quotient,divisor,dividend);

input [23:0]divisor,dividend;
output reg [23:0] quotient;
output reg [24:0] remainder;
reg [23:0] inA;
reg [23:0] inB;
reg [24:0] inB1;
reg [24:0] inP=25'd000000000;
reg [48:0] inPA;
reg [48:0] inB0;
reg flag=0,flag2=0;
reg [5:0] count=6'b000000;
reg [23:0]position_of_1bar=24'd00000000;
reg [23:0]position_of_1bar0=24'd00000000;
integer i,j;

always@(*)
begin
position_of_1bar=24'd00000000;
position_of_1bar0=24'd00000000;
flag=0;
flag2=0;
inP=25'b000000000;
inA = dividend;
inB = divisor;
inPA = {inP,inA};
count = 6'b000000;


// STEP 1  
//calculation of no. of leading zeroes and left shift B and PA  by number of leading zeros in divisor
//----------------------------------------------------------------
for(i=0;i<24;i=i+1)    
begin  
if(inB[23]==0)         
begin
count=count+1;
inB={inB[22:0],1'b0};         //left shift B once
inPA={inPA[47:0],1'b0};      //left shift PA once
end
end

//------------------------------------------------------------------------

inB0={1'b0,inB,24'd00000000};

// STEP 2
// Check top 3 bits of PA and decide
//-------------------------------------------------------------------------

for (i=0;i<24;i=i+1)                  

begin

//------------2.1 If top 3 bits are equal 
if (inPA[48]==inPA[47] && inPA[47]==inPA[46])        
        begin
        inPA={inPA[47:0],1'b0};           
        end
        
//-----------2.2 If top 3 bits are unequal    
else
     begin
    //-------If P is (-ve)=>MSB is 1
        if (inPA[48] == 1'b1)
          begin 
          inPA={inPA[47:0],1'b0};         
          position_of_1bar[23-i] = 1'b1;  
          flag = 1;      
          inPA = inPA + inB0;             
         
        end
        
  //-------if P is (+ve)=>MSB is(+ve)
//         if (inPA[16] == 1'b0)
        else
          begin  
          inPA={inPA[47:0],1'b1};       
          inPA=inPA-inB0;               
          flag2 = 1;
          end
    end
    
end
  
inP[24:0] = inPA[48:24];         //Getting the values of P
inA[23:0] = inPA[23:0];          //Getting the values of A
if(inP[24] == 0)
   begin
   if (flag == 1'b1)
     begin                                           
     inA = inA - position_of_1bar;                 
     end 
     
   end

//---------step 3 If the final remiander is (-ve)
if (inP[24]==1) 
begin  
    inP=inP+inB;      
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
 remainder={1'b0,remainder[24:1]};   //Right shift "count" number of times
end
 
quotient = inA;

end
endmodule