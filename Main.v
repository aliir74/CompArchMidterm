module Main;
  
input en;
input [7:0] index; 
input [1:0] word;
input comp, write;
input [4:0] t_in;
input [15:0] d_in; 
input v_in, clk, rst;
output hit, dirt, valid;
output [4:0] t_out;
output [15:0] d_out;

reg [255:0] cache [0:70];
reg [2047:0] MM [0:7];

Clock new_clock;
Cache new_cache();
MainMemory new_memory;  



endmodule