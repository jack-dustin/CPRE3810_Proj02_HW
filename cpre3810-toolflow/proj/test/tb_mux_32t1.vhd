-- Isaiah Pridie
-- CprE 3810 Lab2 Part 3.g
-- Start Date: 2.16.2026, 9:36 PM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.mux_32t1_package.all; -- import package from word folder

entity tb_mux_32t1 is
end entity;

architecture mux_32t1 of tb_mux_32t1 is 

-- declare signals to show up on questa sim
-- intialize bus/data values as 0
signal o_Reg  : std_logic_vector(31 downto 0) := (others => '0');
signal i_Sel  : std_logic_vector(4 downto 0)  := (others => '0');
signal i_R    : i_reg_array := (others => (others => '0')); -- signal as a 2d vector. Set all to 0. 

component mux_32t1 is
    port ( i_Sel  : in std_logic_vector(4 downto 0);    -- 5 total select bits
           i_R    : in i_reg_array; -- Map array port to actual port
           o_Reg  : out std_logic_vector(31 downto 0) );
end component;

begin
DUT: mux_32t1
    -- left is component => Right is signal
    port map ( i_Sel => i_Sel,
               i_R   => i_R,
               o_Reg => o_Reg );

    process     -- Test Bench Process
    begin

        ------  Test Case 1:  ------
        -- Load mock registers:
        i_R(0)  <= x"10000001";
        i_R(1)  <= x"20000002";
        i_R(2)  <= x"30000003";
        i_R(3)  <= x"40000004";
        i_R(4)  <= x"50000005";
        i_R(5)  <= x"60000006";
        i_R(6)  <= x"70000007";
        i_R(7)  <= x"80000008";
        i_R(8)  <= x"90000009";
        i_R(9)  <= x"10100010";
        i_R(10) <= x"11000011";
        i_R(11) <= x"12000012";
        i_R(12) <= x"13000013";
        i_R(13) <= x"14000014";
        i_R(14) <= x"15000015";
        i_R(15) <= x"16000016";
        i_R(16) <= x"17000017";
        i_R(17) <= x"18000018";
        i_R(18) <= x"19000019";
        i_R(19) <= x"20200020";
        i_R(20) <= x"21000021";
        i_R(21) <= x"22000022";
        i_R(22) <= x"23000023";
        i_R(23) <= x"24000024";
        i_R(24) <= x"25000025";
        i_R(25) <= x"26000026";
        i_R(26) <= x"27000027";
        i_R(27) <= x"28000028";
        i_R(28) <= x"29000029";
        i_R(29) <= x"30300030";
        i_R(30) <= x"31000031";
        i_R(31) <= x"32000032";

        -- Iterate through every MUX combination
        for k in 0 to (32-1) loop
            i_Sel <= std_logic_vector(to_unsigned(k,5));
            wait for 10 ns;
        end loop;

        wait;
    end process;
end architecture;

