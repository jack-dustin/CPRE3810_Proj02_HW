-- Isaiah Pridie
-- CprE 381 project01 - XOR Logic for ALU
-- 3.7.2026,    9:47 PM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity xor_ALU is
    generic(N : natural := 32); -- Make this file flexible because why not
    port(i_xDA  : in std_logic_vector(N-1 downto 0);
         i_xDB  : in std_logic_vector(N-1 downto 0);
         o_xDo  : out std_logic_Vector(N-1 downto 0) );
end xor_ALU;

architecture structural of xor_ALU is 

    component xor_N is
        generic(N : natural := 32); -- want 32 xor gates. But this # could be anything
        port(i_A    : in std_logic_vector(N-1 downto 0);
             i_B    : in std_logic_vector(N-1 downto 0);
             o_F    : out std_logic_vector(N-1 downto 0) );
    end component;

begin
        -- Component port => signal/wire/ENTITY port
        -- Instantiate N-bit vector of xor gates
        INST_XOR_N: xor_N 
            generic map(N => N)
            port map(
            i_A   => i_xDA,
            i_B   => i_xDB,
            o_F   => o_xDo );

end architecture;
