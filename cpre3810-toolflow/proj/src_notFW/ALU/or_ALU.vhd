-- Isaiah Pridie
-- CprE 381 project01 - OR Logic for ALU
-- 3.8.2026,    12:36 AM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity or_ALU is
    generic(N : natural := 32); -- Make this file flexible because why not
    port(i_oDA  : in std_logic_vector(N-1 downto 0);
         i_oDB  : in std_logic_vector(N-1 downto 0);
         o_oDo  : out std_logic_Vector(N-1 downto 0) );
end or_ALU;

architecture structural of or_ALU is 

    component or_N is
        generic(N : natural := 32); -- want 32 or gates. But this # could be anything
        port(i_A    : in std_logic_vector(N-1 downto 0);
             i_B    : in std_logic_vector(N-1 downto 0);
             o_F    : out std_logic_vector(N-1 downto 0) );
    end component;

begin
        -- Component port => signal/wire/ENTITY port
        -- Instantiate N-bit vector of or gates
        INST_OR_N: or_N 
            generic map(N => N)
            port map(
            i_A   => i_oDA,
            i_B   => i_oDB,
            o_F   => o_oDo );

end architecture;
