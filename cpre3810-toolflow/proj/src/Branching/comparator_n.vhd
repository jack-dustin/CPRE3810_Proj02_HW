-- Isaiah Pridie
-- n-bit comparator for proj2_blt
-- Start Date: 4.12.2026,   4:01 PM

library IEEE;
use IEEE.std_logic_1164.all;

entity comparator_n is
    generic (N : integer := 32); 
    port(i_A    : in  std_logic_vector(N-1 downto 0);
         i_B    : in  std_logic_vector(N-1 downto 0);
         o_EQ   : out std_logic_vector(N-1 downto 0);
         o_LT   : out std_logic_vector(N-1 downto 0);
         o_GT   : out std_logic_vector(N-1 downto 0));  
end entity;

architecture structural of comparator_n is

component comparator is
    port(i_A    : in  std_logic;
         i_B    : in  std_logic;
         o_EQ   : out std_logic;
         o_LT   : out std_logic;
         o_GT   : out std_logic);
end component;

begin

    G_nBit_Comparator: for i in 0 to N-1 generate
    CompI: comparator port map(
        i_A  => i_A(i),
        i_B  => i_B(i),
        o_EQ => o_EQ(i),
        o_LT => o_LT(i),
        o_GT => o_GT(i));
    end generate G_nBit_Comparator;

end architecture;