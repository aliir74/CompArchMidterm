
module Clock;
  reg clock;
initial
   begin
      clock = 1'b0;
      #300 $finish; 
   end

always
   #10 clock = ~clock;
   
endmodule