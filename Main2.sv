 module Main(en, address, rst);
  
input en, rst;
input [12:0] address;
reg [7:0] index; 
reg [1:0] word;
reg comp, write, hit, dirt, valid; //???
reg [4:0] t_out;
reg [4:0] t_in; //calculate
reg [15:0] d_in; 
reg [15:0] d_out;
reg v_in;
reg clock;
integer i,j,k, deciadd;

reg [255:0] cache [0:70];
reg [8191:0] MM [0:63];

initial
begin       //all valid=0
  for(i=0; i<256; i++)
    cache[i][0] = 1'b0;
end

MainMem mymemory(MM);
direct_Cache mycache(cache, en, index, word, comp, write, t_in, d_in, valid_in, clock, rst, hit, dirt, t_out, d_out, valid);

initial
   begin
      clock = 1'b0;
      #300 $finish; 
   end
  
always
   begin
     
    #10 clock = ~clock;
    
    deciadd = address[10]*1024 + address[9]* 512 + address[8]*256 + address[7]* 128 + address[6]*64 +
              address[5]*32 + address[4]*16 + address[3]*8 + address[2]*4 + address[1]*2 + address[0];
              
    mycache.word = address[1:0];
    mycache.index = address[9:2];
    mycache.t_in = {0'b0,0'b0,0'b0,0'b0,address[10]};
        
    if(comp == 1'b1 && write == 1'b1 && mycache.hit == 1'b0)
    begin
      MM[deciadd] = mycache.d_in;
    end
    if(comp == 1'b0 && write == 1'b1 && mycache.hit == 1'b0)
    begin
      mycache.d_in = MM[deciadd];
      t_in = mycache.findTag(index, word);
      
        
      
end
    

    end
     

   


 
 




endmodule
