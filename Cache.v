module direct_Cache(en, address, comp, write, t_in, d_in, valid_in, rst, hit, dirt, t_out, d_out, valid); 

input en;
input [12:0] address;
input comp, write;
input [4:0] t_in;
input [15:0] d_in; 
input valid_in, rst;
output reg hit, dirt, valid;
output reg [4:0] t_out;
output reg [15:0] d_out;

reg [255:0] cache [0:70]; //how to number cols and rows?
reg [7:0] index; 
reg [1:0] word;
reg [4:0] mblock [0:16];
reg clk;
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
  input [255:0] cache [0:70];
  input [7:0] index;
//  input decimalindex;
  begin
    findValid = cache[decimalindex][0];
end
endfunction

function findDirt;
  input [255:0] cache [0:70];
  input [7:0] index;
  //input decimalindex;
  begin
    findDirt = cache[decimalindex][1];
end
endfunction

function [4:0]findTag;
  input [255:0] cache [0:70];
  input [7:0] index;
  //input decimalindex;
  begin
    findTag = cache[decimalindex][6:2]; //copy vector???
end
endfunction

function findplacefunc;
  input word;
  begin
   case(word)
    2'b00: findplace = 7;
    2'b01: findplace = 23;
    2'b10: findplace = 39;
    2'b11: findplace = 55;
   endcase
  end
 endfunction 

function [15:0]findData;
  input [255:0] cache [0:70];
  input [7:0] index;
  input [1:0] word;
  //input decimalindex;
  begin
  case(word)
    2'b00: findData = cache[decimalindex][22:7];
    2'b01: findData = cache[decimalindex][38:23];
    2'b10: findData = cache[decimalindex][54:39];
    2'b11: findData = cache[decimalindex][70:55];
    //default: findData = {} //???
  endcase
  end
endfunction 

initial
begin       //all valid=0
  for(i=0; i<256; i=i+1)
    cache[i][0] = 1'b0;
    
  clk = 1'b0;  
end


always
begin     //begin of cache process
   
   #30 clk = ~clk;
   
   word = findword(address);
   index = cacheindex(address);
   mymemory.MM[address] = 0'b1;//////??????????///???
     
   case(word)
    2'b00: findplace = 7;
    2'b01: findplace = 23;
    2'b10: findplace = 39;
    2'b11: findplace = 55;
   endcase

  index = address[9:2];
  decimalindex  = (index[7]*128)+(index[6]*64)+(index[5]*32)+(index[4]*16)+(index[3]*8)+(index[2]*4)
          +(index[1]*2)+index[0]; 
    
  
if(rst == 1'b1)@(posedge clk)
begin
    for(j=0; j<256; j=j+1)
    begin
      cache[j][0] = 1'b0; 
      for(i=1;i<71;i=i+1)
      begin
        cache[j][i] = 1'hz; 
      end  
    end 
end


if(en == 1'b0)    //disabled
begin
    hit = 1'b0;
    dirt = 1'b0;
    valid = 1'b0;
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
           hit = 1'b1;
           d_out = findData(cache, index, word); 
           t_out = findTag(cache, index);
           valid = 1'b1;
           dirt = finddirt(cache,index);
         end
         else                        
         begin
           hit = 1'b0;
           d_out = 8'hz;
           valid = findValid(cache, index);
           dirt = findDirt(cache, index);
           t_out = findTag(cache, index);
         end 
       end // end of write = 0
       else
       if(write == 1'b1)   // store  2
       begin
         if(findValid(cache,index) == 1'b1 && t_in == findTag(cache, index)) @(posedge clk) //hit(signale valid????)
         begin
           hit = 1'b1; 
           dirt = 1'b0;
           valid = 1'b1;
           cache[decimalindex][findplace] = d_in;   //data=d_in
           cache[decimalindex][1] = 1'b1; //dirt=1 
           //data out tag out???
         end
         else  //miss
         begin
           hit = 1'b0; 
           valid = cache[decimalindex][0];
           dirt = cache[decimalindex][1];
           //dataout tagout???
           mymemory.MM[address] = d_in;
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
               mymemory.MM[k] = cache[decimalindex][22:7];
               mymemory.MM[k+1] = cache[decimalindex][38:23];
               mymemory.MM[k+2] = cache[decimalindex][54:39];
               mymemory.MM[k+3] = cache[decimalindex][70:55];
               break;
             end  //end of if
           end //end of for
         end  // end of dirt = 1
         for(l=0; l<8192; l=l+4)
         begin
            if(l/4 == memblock(address))
            begin
               mblock[0] = mymemory.MM[l/4];
               mblock[1] = mymemory.MM[l/4+1];
               mblock[2] = mymemory.MM[l/4+2];
               mblock[3] = mymemory.MM[l/4+3];
               break;
             end
          end   
          write = 1'b1;
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
           cache[decimalindex][0] = valid_in;
           cache[decimalindex][1] = 1'b0;
           cache[decimalindex][6:2] = t_in;
           cache[decimalindex][findplacefunc(word)] = d_in;  
         end  //end of for
        end  //end of write = 1 
       end  // end of comp = 0
   end     // end of en = 1 
 
 
 end      //end of cache process
 
 
 
 endmodule    
     

