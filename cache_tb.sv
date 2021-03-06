
module Cache_tb;
 
 reg random; 
 reg en;
 reg clk;
 reg [12:0] address;
 reg comp, write;
 reg [4:0] t_in;
 reg [15:0] d_in; 
 reg valid_in, rst;
 wire hit, dirt, valid;
 wire [4:0] t_out;
 wire [15:0] d_out;
 integer i,j,k, m, n;
 

 direct_Cache newCache(en, clk, address, comp, write, t_in, d_in, valid_in, rst, hit, dirt, t_out, d_out, valid);
                        
 initial
 begin
   
   for(k=0; k<256; k++)
   begin
      newCache.cache[k][0] = 1'b0;
     // $display("%b", newCache.cache[k][0]);
   end  
   
   clk = 0'b0;
   random = $random(5); 
   en = 1'b1;
   rst = 1'b0;
            
   for(i=0;i<8192;i=i+1)
   begin
     for(j=0;j<16;j=j+1)
     begin
       random = $random;
       //$display("random + %b ", random);
       newCache.mymemory.mem[i][j]= random;
       //$display("mem = %b", newCache.mymemory.mem[i][j]);
       
     end
   end
   
   
 forever
   #20 clk = ~clk;
   
 end
 
 
 initial
 begin
     address = 13'b0000000001111;
     comp = 1'b1;
     write = 1'b0;
     t_in = 4'b0000;
     d_in = 16'hz;
     valid_in = 1'b1;
     newCache.word = newCache.findword(address);
     newCache.index = newCache.cacheindex(address);
     
     if(rst == 1'b1)@(posedge clk)
     begin  
       for(m=0; m<256; m++)
       begin
         newCache.cache[j][0] = 1'b0; 
         for(n=1;n<71;n++)
         begin
            newCache.cache[m][n] = 1'hz;
         end  
       end 
     end
         
     $display("comp = %b write = %b en = %b  address = %b" , comp , write, en, address); 
     $monitor("add = %b tagin = %b hit = %b dirt = %b t_out = %b  d_out = %b", address, t_in, hit, dirt, t_out, d_out);
     $display(" valid = %b mem = %b word = %d index = %d cache = %b",
     valid, newCache.mymemory.mem[address][15:0], newCache.word, newCache.cacheindex(address), newCache.cache[newCache.index][70:7]);
 
  // turn = 4;
  // repeat(5)
  // begin
    // address = addlist[turn][12:0];
    // comp = complist[turn];
    // write = writelist[turn];
    // t_in = tlist[turn];
    // d_in = dlist[turn];
    // valid_in = vlist[turn]; 
     
    // if(hit == 1'b0 && write== 1'b0 && comp==1'b1)
    // begin
      // #40
      // write = 1'b0;
      // comp = 1'b0;
    // end  
     
    // if(write== 1'b0 && comp==1'b0)
    // begin
      // #40
      // write = 1'b1;
      // comp = 1'b0;
   //  end  
     
     //turn = turn -1;
   //end
 end
 

  
 endmodule
