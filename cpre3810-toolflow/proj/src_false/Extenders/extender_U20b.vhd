-- Isaiah Pridie
-- CprE 3810 Proj01 Barrel_Shifter
-- Start Date: 3.7.2026, 8:05

-- For Core Instruction U and UJ Formats
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity extender_20b is
    port(i_imm  : in std_logic_vector(31 downto 0);
         o_out  : out std_logic_vector(31 downto 0) );
end extender_20b;

architecture dataflow of extender_20b is
    signal s_Z     : std_logic_Vector(11 downto 0);  
begin 
    s_Z     <= (others => '0'); -- Set all to 0

    o_out   <= i_imm(31 downto 12) & s_Z;
end architecture;
