-- Isaiah Pridie
-- CprE 3810 Lab2 Part 4.d
-- Start Date: 2.16.2026, 3:37 AM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity busMux_2t1 is
    port(i_dZero  : in std_logic_vector(31 downto 0);
         i_dOne   : in std_logic_vector(31 downto 0);
         ALUSrc   : in std_logic; -- select line
         o_dOUT   : out std_logic_vector(31 downto 0));
end busMux_2t1;

architecture dataflow of busMux_2t1 is
    begin
    with ALUSrc select
    o_dOUT <= i_dZero when '0',
              i_dOne when '1',
              x"00000000" when others;
end dataflow;  


