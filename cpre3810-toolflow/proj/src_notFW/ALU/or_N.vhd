-- Isaiah Pridie
-- CprE 3810 proj01 or_N gate file.
-- 3.8.2026,   12:23 AM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- N-Bit OR
entity or_N is
    generic(N : natural := 32); -- Natural ~= Unsigned* Integer*
    port(i_A : in std_logic_vector(N-1 downto 0);
         i_B : in std_logic_vector(N-1 downto 0);
         o_F : out std_logic_vector(N-1 downto 0));
end or_N;

architecture structural of or_N is

    component org2 is
        port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
    end component;

begin
    G_nBit_OR : for i in 0 to N-1 generate
        GenerateOR : org2 port map(
            i_A => i_A(i),
            i_B => i_B(i),
            o_F => o_F(i) );
    end generate;

end architecture;