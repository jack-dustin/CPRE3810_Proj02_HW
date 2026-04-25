-- Isaiah Pridie
-- CprE 3810 Lab2 Part 3.b
-- Start Date: 2.9.2026, 2:28 PM

-- Comments so I don't confuse myself:
    -- 2 wires/signals: s_D, s_Q
    -- when Write EN is '1', s_D <= inputData
        -- On rising clock, s_D goes to output
    -- when Write EN is NOT '1', s_D <= s_Q  (NO INPUT IS READ)
-- AKA:
    -- EITHER WAY, s_Q <= s_D, output <= s_Q
        -- when Write EN is '1', s_D represents input
        -- when Write EN is not 1, s_D represents current data

library IEEE;
use IEEE.std_logic_1164.all;

entity reg_n is
    generic (N : integer := 32); -- We can change 8 to something else later
    port (i_CLK   : in std_logic;                          -- Clock input
          i_RST   : in std_logic;                          -- Reset input
          i_WE    : in std_logic;                          -- Write enable input
          i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
          o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
end reg_n;

architecture structural of reg_n is

    component dffg is
        port(i_CLK   : in std_logic;    -- Clock input
             i_RST   : in std_logic;    -- Reset input
             i_WE    : in std_logic;    -- Write enable input
             i_D     : in std_logic;    -- Data value input
             o_Q     : out std_logic);
    end component;

    begin
        -- signal flow:
        -- second_part <= first_part
        -- output <= input

        -- instantiate N flip-flop instances:
        G_nBit_Reg: for i in 0 to N-1 generate
            -- component port => signal/wire/entity port
            RegI: dffg port map (
                i_CLK   => i_CLK,
                i_RST   => i_RST,
                i_WE    => i_WE, 
                i_D     => i_D(i),
                o_Q     => o_Q(i));
        end generate G_nBit_Reg;
end structural;
