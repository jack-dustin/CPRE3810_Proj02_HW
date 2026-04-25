-- Isaiah Pridie
-- 
-- Start Date: 3.28.2026,   8:06 PM

-- Originally made to AND OpCode(4) bit with funct3(0,1,2) bits individually
    -- Thus why it is 6 to 3

library IEEE;
use IEEE.std_logic_1164.all;

entity andg_6t3 is
    port(i_A    : in  std_logic_vector(2 downto 0);
         i_B    : in  std_logic_vector(2 downto 0);
         o_O    : out std_logic_vector(2 downto 0));
end entity;

architecture structural of andg_6t3 is

    -- signal declarations

    component andg2 is
        port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
    end component;

begin

    INST_AND_1: andg2 port map(
        i_A =>  i_A(0),
        i_B =>  i_B(0),
        o_F =>  o_O(0));

    INST_AND_2: andg2 port map(
        i_A =>  i_A(1),
        i_B =>  i_B(1),
        o_F =>  o_O(1));

    INST_AND_3: andg2 port map(
        i_A =>  i_A(2),
        i_B =>  i_B(2),
        o_F =>  o_O(2));

end architecture;
