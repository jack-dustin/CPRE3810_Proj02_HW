-- Isaiah Pridie
-- n-bit comparator for proj2_blt
-- Start Date: 4.12.2026,   4:08 PM

library IEEE;
use IEEE.std_logic_1164.all;

entity blt_combine_n is
    generic (N : integer := 32); 
    port(i_EQ0  : in  std_logic_vector(N-1 downto 0);
         i_EQ1  : in  std_logic_vector(N-1 downto 0);
         i_LT0  : in  std_logic_vector(N-1 downto 0);
         i_LT1  : in  std_logic_vector(N-1 downto 0);
         i_GT0  : in  std_logic_vector(N-1 downto 0);
         i_GT1  : in  std_logic_vector(N-1 downto 0);

         o_EQ   : out std_logic_vector(N-1 downto 0);
         o_LT   : out std_logic_vector(N-1 downto 0);
         o_GT   : out std_logic_vector(N-1 downto 0));
end blt_combine_n;

architecture structural of blt_combine_n is

component blt_combine is 
    port(i_EQ0  : in  std_logic;
         i_EQ1  : in  std_logic;
         i_LT0  : in  std_logic;
         i_LT1  : in  std_logic;
         i_GT0  : in  std_logic;
         i_GT1  : in  std_logic;

         o_EQ   : out std_logic;
         o_LT   : out std_logic;
         o_GT   : out std_logic);
end component;

begin

    G_nBit_Combine: for i in 0 to N-1 generate
    CombineI: blt_combine port map(
        i_EQ0 => i_EQ0(i),
        i_EQ1 => i_EQ1(i),
        i_LT0 => i_LT0(i),
        i_LT1 => i_LT1(i),
        i_GT0 => i_GT0(i),
        i_GT1 => i_GT1(i),
        o_EQ  => o_EQ(i),
        o_LT  => o_LT(i),
        o_GT  => o_GT(i));
    end generate G_nBit_Combine;

end architecture;