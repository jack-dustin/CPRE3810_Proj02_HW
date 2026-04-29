-- Isaiah Pridie
-- CprE 3810 Lab2 Part 3.g
-- Start Date: 2.16.2026, 3:38 PM

library IEEE;
use IEEE.std_logic_1164.all;
-- 2d vector array wants to be a gay little greedy bitch
    -- it's gotta have it's OWN FILE because it's OH-SO speacial
    -- it's gotta waste 45 min. of your time trying to find a stupid syntax error
--use work.mux_32t1_package.all; -- import package from word folder
use work.RISCV_types.all;

entity mux_32t1 is
    port ( i_Sel  : in std_logic_vector(4 downto 0);    -- 5 total select bits
           i_R    : in i_reg_array; -- Map array port to actual port
           o_Reg  : out std_logic_vector(31 downto 0) );
end mux_32t1;

architecture dataflow of mux_32t1 is 

    begin
        with i_Sel select
        o_Reg <= i_R(0)  when "00000",
                 i_R(1)  when "00001",
                 i_R(2)  when "00010",
                 i_R(3)  when "00011",
                 i_R(4)  when "00100",
                 i_R(5)  when "00101",
                 i_R(6)  when "00110",
                 i_R(7)  when "00111",
                 i_R(8)  when "01000",
                 i_R(9)  when "01001",
                 i_R(10) when "01010",
                 i_R(11) when "01011",
                 i_R(12) when "01100",
                 i_R(13) when "01101",
                 i_R(14) when "01110",
                 i_R(15) when "01111",
                 i_R(16) when "10000",
                 i_R(17) when "10001",
                 i_R(18) when "10010",
                 i_R(19) when "10011",
                 i_R(20) when "10100",
                 i_R(21) when "10101",
                 i_R(22) when "10110",
                 i_R(23) when "10111",
                 i_R(24) when "11000",
                 i_R(25) when "11001",
                 i_R(26) when "11010",
                 i_R(27) when "11011",
                 i_R(28) when "11100",
                 i_R(29) when "11101",
                 i_R(30) when "11110",
                 i_R(31) when "11111",
                 x"00000000" when others;
end dataflow;
