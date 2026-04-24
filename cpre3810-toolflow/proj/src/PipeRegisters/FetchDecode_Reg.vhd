-- Isaiah Pridie
-- CprE 3810 Proj02 - Decode to Execute Pipeline Register
-- Start Date: 4.10.2026,   3:26 PM

-- Needs 64-Bit Register:
    -- PC + 4 Value     --> 32 bits     31 --> 95, 30 --> 94, ..., 0 --> 64
    -- PC Reg Value     --> 32 bits     31 --> 63, 30 --> 62, ..., 0 --> 32    
    -- Instruction      --> 32 bits     31 --> 31, 30 --> 30, ..., 0 --> 0
    -- Total: 96 bits

-- ^^^ This is depreciated; Current register uses 97 bits

library IEEE;
use IEEE.std_logic_1164.all;

entity FetchDecode_Reg is
    generic (N : integer := 96);
    port (
        i_CLK   : in  std_logic;
        i_RST   : in  std_logic;
        i_FLUSH : in  std_logic;
        i_WE    : in  std_logic;
        i_D     : in  std_logic_vector(N-1 downto 0);
        o_Q     : out std_logic_vector(N-1 downto 0)
    );
end FetchDecode_Reg;

architecture structural of FetchDecode_Reg is

    component dffg is
        port(
            i_CLK   : in  std_logic;
            i_RST   : in  std_logic;
            i_WE    : in  std_logic;
            i_D     : in  std_logic;
            o_Q     : out std_logic
        );
    end component;

    signal s_D : std_logic_vector(N-1 downto 0);

begin

    G_FlushMux : for i in 0 to N-1 generate
        s_D(i) <= '0' when i_FLUSH = '1' else i_D(i);
    end generate;

    G_nBit_Reg : for i in 0 to N-1 generate
        RegI : dffg
            port map(
                i_CLK => i_CLK,
                i_RST => i_RST,
                i_WE  => i_WE,
                i_D   => s_D(i),
                o_Q   => o_Q(i)
            );
    end generate;

end structural;
