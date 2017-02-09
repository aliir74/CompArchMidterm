module MainMemory(mem, d);
output d;  
input reg [2047:0] mem [0:7];
integer i,j;
reg random;

initial
begin
random = $random(5); 


for(i=0;i<2048;i=i+1)
begin
  for(j=0;j<8;j=j+1)
  begin
    random = $random;
    mem[i][j]= random;
  end
end
end
    
endmodule
