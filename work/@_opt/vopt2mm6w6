library verilog;
use verilog.vl_types.all;
entity direct_Cache is
    port(
        en              : in     vl_logic;
        clk             : in     vl_logic;
        address         : in     vl_logic_vector(12 downto 0);
        comp            : in     vl_logic;
        write           : in     vl_logic;
        t_in            : in     vl_logic_vector(4 downto 0);
        d_in            : in     vl_logic_vector(15 downto 0);
        valid_in        : in     vl_logic;
        rst             : in     vl_logic;
        hit             : out    vl_logic;
        dirt            : out    vl_logic;
        t_out           : out    vl_logic_vector(4 downto 0);
        d_out           : out    vl_logic_vector(15 downto 0);
        valid           : out    vl_logic
    );
end direct_Cache;
