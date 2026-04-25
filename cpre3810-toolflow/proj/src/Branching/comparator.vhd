-- Isaiah Pridie
-- 1 bit comparator
    -- Input two input bits, output an IS_EQ, IS_LessThan, and IS_GreaterThan flags
-- Start Date: 4.12.2026,   2:47 PM

library IEEE;
use IEEE.std_logic_1164.all;

entity comparator is
    port(i_A    : in  std_logic;
         i_B    : in  std_logic;
         o_EQ   : out std_logic;
         o_LT   : out std_logic;
         o_GT   : out std_logic);
end comparator;

architecture structural of comparator is

    signal s_notA       : std_logic;
    signal s_notB       : std_logic;
    signal s_AxorB      : std_logic;

    component invg is
      port(i_A          : in std_logic;
           o_F          : out std_logic);
    end component;

    component andg2 is
      port(i_A          : in std_logic;
           i_B          : in std_logic;
           o_F          : out std_logic);

    end component;

    component xorg2 is
      port(i_A          : in std_logic;
           i_B          : in std_logic;
           o_F          : out std_logic);
    end component;

begin

    INST_notA: invg port map(
        i_A => i_A,
        o_F => s_notA);

    INST_notB:  invg port map(
        i_A => i_B,
        o_F => s_notB);

    INST_notA_B: andg2 port map(     -- A < B
        i_A => s_notA,
        i_B => i_B,
        o_F => o_LT);

    INST_notB_A: andg2 port map(     -- A > B
        i_A => s_notB,
        i_B => i_A,
        o_F => o_GT);

    INST_AxorB: xorg2 port map(     -- 1 if A != B
        i_A => i_A,
        i_B => i_B,
        o_F => s_AxorB);

    INST_not_AxorB: invg port map(  -- 1 if A == B
        i_A => s_AxorB,
        o_F => o_EQ);

end architecture;