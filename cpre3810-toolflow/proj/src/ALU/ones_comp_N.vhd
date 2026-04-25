-- Isaiah Pridie
-- CprE 3810 Lab1 Part 3.3
-- Start Date: 2.3.2026


library ieee;
use IEEE.std_logic_1164.all;

-- Think entity as pin out of the chip
-- Names here MUST match what other files connect to
entity ones_comp_N is 
        generic (N : integer := 32);    -- defualt 32 bits wide
        port (  i_OC    : in std_logic_vector(N-1 downto 0);
                o_O     : out std_logic_vector(N-1 downto 0));
end ones_comp_N;

architecture structural of ones_comp_N is

        -- not gate component
        component invg is
                port ( i_A      : in std_logic;
                       o_F      : out std_logic);
        end component;

-- start building circuit
begin
        -- component port => signal or entity port
        -- Generate loop
        G_NBit_OnesComp: for i in 0 to N-1 generate
                NOTI: invg port map (
                        i_A     => i_OC(i),
                        o_F     => o_O(i));
        end generate G_NBit_OnesComp;

end structural;