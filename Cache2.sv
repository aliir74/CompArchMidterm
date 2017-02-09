module direct_Cache(en, clk, address, comp, write, t_in, d_in, valid_in, rst, hit, dirt, t_out, d_out, valid); 

input reg en;
input reg clk;
input reg [12:0] address;
input reg comp, write;
input reg [4:0] t_in;
input reg [15:0] d_in; 
input  reg valid_in, rst;
output reg  hit, dirt, valid;
output reg [4:0] t_out;
output reg [15:0] d_out;

reg [70:0] cache [0:255]; //how to number cols and rows?
reg [7:0] index; 
reg [1:0] word;
reg [15:0] mblock [0:4];

integer findplace, decimalindex, i, j, k, l;
MainMem mymemory();

function [12:2] memblock;
  input [12:0] address;
  begin
    memblock = address[12:2];
  end
endfunction

function findblockofmem;
  input [4:0] tag;
  input [7:0] index;
  begin
    findblockofmem = 256*tag + index;
  end
endfunction

function [1:0] findword;
  input [12:0] address;
  begin
  findword = address[1:0];
  end
endfunction 

function [7:0] cacheindex; 
  input [12:0] address;
  begin
  cacheindex = address[9:2];
  end
endfunction

function findValid;
  input [70:0] cache [0:255];
  input [7:0] index;
//  input decimalindex;
  begin
  findValid = cache[index][0];
  end
endfunction

function findDirt;
  input [70:0] cache [0:255];
  input [7:0] index;
  //input decimalindex;
  begin
  findDirt = cache[index][1];
  end
endfunction

function [4:0]findTag;
  input [70:0] cache [0:255];
  input [7:0] index;
  //input decimalindex;
  begin
  findTag = cache[index][6:2]; 
  end
endfunction

function findplacefunc;
  input word;
  begin
   case(word)
    2'b00: findplacefunc = 7;
    2'b01: findplacefunc = 23;
    2'b10: findplacefunc = 39;
    2'b11: findplacefunc = 55;
   endcase
  end
 endfunction 
 

function [15:0]findData;
  input[70:0] cache [0:255];
  input [7:0] index;
  input [1:0] word;
  //input decimalindex;
  begin
  case(word)
    2'b00: findData = cache[index][22:7];
    2'b01: findData = cache[index][38:23];
    2'b10: findData = cache[index][54:39];
    2'b11: findData = cache[index][70:55];
    //default: findData = {} //???
  endcase
  end
endfunction 

  always@(en)
    hit = en;
              //begin of cache process
initial
begin   
if(rst == 1'b0) 
begin
  if(en == 1'b0)    //disabled
  begin
   // hit <= en;
    dirt <= en;
    valid <= en;
    t_out = {1'b0,1'b0,1'b0,1'b0};
    d_out = {1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0};
  end // end of en = 0
  else
  if(en==1'b1)       //enabled 
  begin
   if(comp == 1'b1)
   begin
       if(write == 1'b0)  //load   1
       begin
         if(findValid(cache,index) == 1'b1 && t_in == findTag(cache, index)) //comparing vector???
         begin
          // hit = 1'b1;
           d_out = findData(cache, index, word); 
           t_out = findTag(cache, index);
           valid = 1'b1;
           dirt = findDirt(cache,index);
         end
         else                        
         begin
          // hit = 1'b0;
           d_out = 16'hz;
           valid = findValid(cache, index);
           dirt = findDirt(cache, index);
           t_out = findTag(cache, index);
         end 
       end  //end of write = 0
       else
       if(write == 1'b1)   // store  2
       begin
         if(findValid(cache,index) == 1'b1 && t_in == findTag(cache, index)) @(posedge clk) //hit(signale valid????)
         begin
          // hit = 1'b1; 
           dirt = 1'b0;
           valid = 1'b1;
           cache[index][findplacefunc(word)] = d_in;   //data=d_in
           cache[index][1] = 1'b1; //dirt=1 
           //data out tag out???
         end
         else  //miss
         begin
         //  hit = 1'b0; 
           valid = cache[index][0];
           dirt = cache[index][1];
           //dataout tagout???
           mymemory.mem[address][15:0] = d_in;
         end  
       end  //end of write = 1
   end  // end of comp = 1
   else 
   if(comp == 1'b0)
   begin
       if(write == 1'b0) //3
       begin
         if(findDirt(cache, index) == 1'b1)
         begin
           for(k=0; k<8192; k=k+4)
           begin
             if((k/4) == findblockofmem(findTag(cache,index), index)) //we should find block via cache not the wanted address
             begin
               mymemory.mem[k][15:0] = cache[index][22:7];
               mymemory.mem[k+1][15:0] = cache[index][38:23];
               mymemory.mem[k+2][15:0] = cache[index][54:39];
               mymemory.mem[k+3][15:0] = cache[index][70:55];
               break;
             end  //end of if
           end //end of for
         end  // end of dirt = 1
         for(l=0; l<8192; l=l+4)
         begin
            if(l/4 == memblock(address))
            begin
               mblock[0] = mymemory.mem[l/4][15:0];
               mblock[1] = mymemory.mem[l/4+1][15:0];
               mblock[2] = mymemory.mem[l/4+2][15:0];
               mblock[3] = mymemory.mem[l/4+3][15:0];
               break;
             end
          end   
       end // end of write = 0
       else
       if(write == 1'b1)@(posedge clk)
       begin
         for(k=0; k<4; k=k+1)
         begin
           d_in = mblock[k];
           valid_in = 1'b1;
           t_in = {1'b0, 1'b0, address[12:10]};
           word = 0'b0 + k;
           cache[index][0] = valid_in;
           cache[index][1] = 1'b0;
           cache[index][6:2] = t_in;
           cache[index][findplacefunc(word)] = d_in;  
         end  //end of for
        end  //end of write = 1 
       end  // end of comp = 0
    end    // end of en = 1 
 end //end of rst = 0 
end     //end of cache process
 
 
 
 endmodule    
     

