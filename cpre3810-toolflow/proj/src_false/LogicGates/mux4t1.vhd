-- Isaiah Pridie
-- CprE 3810    Creating a 1-but 4t1 mux to simplify code/make it easier to read
-- Start Date: 3.19.2026,   11:17 PM

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4t1 is
    port(i_Da   : in  std_logic;
         i_Db   : in  std_logic;
         i_Dc   : in  std_logic;
         i_Dd   : in  std_logic;
         c_sel1 : in  std_logic;
         c_sel2 : in  std_logic;
         o_out  : out std_logic);
end entity;

architecture structural of mux4t1 is

    signal s_mux_0t2    : std_logic;
    signal s_mux_1t2    : std_logic;

    component mux2t1 is 
        port(i_D0   : in std_logic;
             i_D1   : in std_logic;
             i_S    : in std_logic;
             o_O    : out std_logic);
    end component;

begin

    INST_MUX_0: mux2t1 port map(
        i_D0    => i_Da,
        i_D1    => i_Db,
        i_S     => c_sel1,
        o_O     => s_mux_0t2);

    INST_MUX_1: mux2t1 port map(
        i_D0    => i_Dc,
        i_D1    => i_Dd,
        i_S     => c_sel1,
        o_O     => s_mux_1t2);

    INST_MUX_2: mux2t1 port map(
        i_D0    => s_mux_0t2,
        i_D1    => s_mux_1t2,
        i_S     => c_sel2,
        o_O     => o_out);

end architecture;