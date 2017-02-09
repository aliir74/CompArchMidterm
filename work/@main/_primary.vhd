library verilog;
use verilog.vl_types.all;
entity Main is
    port(
        en              : in     vl_logic;
        address         : in     vl_logic_vector(12 downto 0);
        rst             : in     vl_logic
    );
end Main;
