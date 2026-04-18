-- Isaiah Pridie
-- CprE 3810 buxMux_4t1  
-- Start Date: 3.8.2026,    1:33 PM

-- Takes in 4 32 bit inputs and outputs one of those inputs

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity busMux_4t1 is
    port(i_Da   : in  std_logic_vector(31 downto 0);    -- Input 1
         i_Db   : in  std_logic_vector(31 downto 0);    -- Input 2
         i_Dc   : in  std_logic_vector(31 downto 0);    -- Input 3
         i_Dd   : in  std_logic_vector(31 downto 0);    -- Input 4
         C_S0   : in  std_logic;                        -- Sel line 0
         C_S1   : in  std_logic;                        -- Sel line 1
         o_Do   : out std_logic_vector(31 downto 0) );  -- Output
end busMux_4t1;

architecture structural of busMux_4t1 is

    -- Signals/Wires/Constants:
    signal mux00_t_mux10    : std_logic_vector(31 downto 0);
    signal mux01_t_mux10    : std_logic_vector(31 downto 0);

    -- Components:
    component busMux_2t1 is     -- Used to control rev bit order + Zero/Sign extending
        port(i_dZero  : in std_logic_vector(31 downto 0);
             i_dOne   : in std_logic_vector(31 downto 0);
             ALUSrc   : in std_logic; -- select line. It's named poorly. I wasn't thinking ahead
             o_dOUT   : out std_logic_vector(31 downto 0));
    end component;

begin
    -- INST_BUSMUX_*layer**Number*
    INST_BUSMUX_00: busMux_2t1 port map(
        i_dZero   => i_Da,
        i_dOne    => i_Db,
        ALUSrc    => C_S0,
        o_dOUT    => mux00_t_mux10);

    INST_BUSMUX_01: busMux_2t1 port map(
        i_dZero   => i_Dc,
        i_dOne    => i_Dd,
        ALUSrc    => C_S0,
        o_dOUT    => mux01_t_mux10);

    INST_BUSMUX_10: busMux_2t1 port map(
        i_dZero   => mux00_t_mux10,
        i_dOne    => mux01_t_mux10,
        ALUSrc    => C_S1,
        o_dOUT    => o_Do);
         
end architecture;
