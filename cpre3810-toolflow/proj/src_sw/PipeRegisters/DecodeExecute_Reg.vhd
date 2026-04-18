-- Isaiah Pridie
-- CprE 3810 Proj02 - Decode to Execute Pipeline Register
-- Start Date: 4.10.2026,   3:19 PM

-- Needs 106-Bit Register:
    -- RS1_val          --> 32 bits
    -- RS2_val          --> 32 bits
    -- imm (auipc/lui)  --> 32 bits
    -- ALU_ctrl         --> 4 bits
    -- Mem_WE           --> 1 bit
    -- WriteBack Mux    --> 2 bits
    -- Load_ctrl        --> 3 bits
    -- Total: 106 bits

library IEEE;
use IEEE.std_logic_1164.all;

entity DecodeExecute_Reg is
    generic (N : integer := 106);   -- 106 bit register
    port (i_CLK   : in std_logic;                          -- Clock input
          i_RST   : in std_logic;                          -- Reset input
          i_WE    : in std_logic;                          -- Write enable input
          i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
          o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
end DecodeExecute_Reg;

architecture structural of DecodeExecute_Reg is

    component dffg is
        port(i_CLK   : in std_logic;    -- Clock input
             i_RST   : in std_logic;    -- Reset input
             i_WE    : in std_logic;    -- Write enable input
             i_D     : in std_logic;    -- Data value input
             o_Q     : out std_logic);  -- Output
    end component;

    begin
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
