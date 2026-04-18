-- Isaiah Pridie
-- Combine Block
    -- Combines outputs of two comparator blocks into 1. Passes it on. Do this to make a comparator* tree*
-- Start Date: 4.12.2026,   3:19 PM

library IEEE;
use IEEE.std_logic_1164.all;

-- Let Val1 be the more Signficant bit, and Val0 be the less Significant bit
entity blt_combine is 
    port(i_EQ0  : in  std_logic;
         i_EQ1  : in  std_logic;
         i_LT0  : in  std_logic;
         i_LT1  : in  std_logic;
         i_GT0  : in  std_logic;
         i_GT1  : in  std_logic;

         o_EQ   : out std_logic;
         o_LT   : out std_logic;
         o_GT   : out std_logic);
end blt_combine;

architecture structural of blt_combine is

    signal s_EQ1_AND_LT0    : std_logic;
    signal s_EQ1_AND_GT0    : std_logic;

    component andg2 is port(
        i_A          : in std_logic;
        i_B          : in std_logic;
        o_F          : out std_logic);
    end component;

    component org2 is port(
        i_A          : in std_logic;
        i_B          : in std_logic;
        o_F          : out std_logic);
    end component;

begin

    INST_EQ1_AND_EQ0: andg2 port map(
        i_A => i_EQ0,
        i_B => i_EQ1,
        o_F => o_EQ);

    INST_EQ1_AND_LT0: andg2 port map(
        i_A => i_LT0,
        i_B => i_EQ1,
        o_F => s_EQ1_AND_LT0);

    INST_EQ1_AND_GT0: andg2 port map(
        i_A => i_GT0,
        i_B => i_EQ1,
        o_F => s_EQ1_AND_GT0);

    INST_LT1_OR_EQ1LT0: org2 port map(
        i_A => s_EQ1_AND_LT0,
        i_B => i_LT1,
        o_F => o_LT);

    INST_GT1_OR_EQ1GT0: org2 port map(
        i_A => s_EQ1_AND_GT0,
        i_B => i_GT1,
        o_F => o_GT);
    
end architecture;    
