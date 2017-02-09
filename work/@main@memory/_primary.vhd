library verilog;
use verilog.vl_types.all;
entity MainMemory is
    port(
        mem             : in     vl_logic;
        d               : out    vl_logic
    );
end MainMemory;
