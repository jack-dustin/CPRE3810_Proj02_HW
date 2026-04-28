-- Isaiah Pridie
-- CprE 3810 proj01 and_N gate file.
-- 3.8.2026,   12:19 AM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity and_ALU is
    generic(N : natural := 32); -- Make this file flexible because why not
    port(i_aDA  : in std_logic_vector(N-1 downto 0);
         i_aDB  : in std_logic_vector(N-1 downto 0);
         o_aDo  : out std_logic_Vector(N-1 downto 0) );
end and_ALU;

architecture structural of and_ALU is 

    component and_N is
        generic(N : natural := 32); -- want 32 and gates. But this # could be anything
        port(i_A    : in std_logic_vector(N-1 downto 0);
             i_B    : in std_logic_vector(N-1 downto 0);
             o_F    : out std_logic_vector(N-1 downto 0) );
    end component;

begin
        -- Component port => signal/wire/ENTITY port
        -- Instantiate N-bit vector of and gates
        INST_AND_N: and_N 
            generic map(N => N)
            port map(
            i_A   => i_aDA,
            i_B   => i_aDB,
            o_F   => o_aDo );

end architecture;