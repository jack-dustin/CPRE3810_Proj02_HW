-- -- Isaiah Pridie
-- -- CprE 3810 Proj02 - Decode to Execute Pipeline Register
-- -- Start Date: 4.10.2026,   3:19 PM

-- -- -- -- -- -- --Needs 106-Bit Register:
-- -- -- -- -- -- --    RS1_val          --> 32 bits
-- -- -- -- -- -- --    RS2_val          --> 32 bits
-- -- -- -- -- -- --    imm (auipc/lui)  --> 32 bits
-- -- -- -- -- -- --    ALU_ctrl         --> 4 bits
-- -- -- -- -- -- --    Mem_WE           --> 1 bit
-- -- -- -- -- -- --    WriteBack Mux    --> 2 bit
-- -- -- -- -- -- --    Load_ctrl        --> 3 bits
-- -- -- -- -- -- --    Total: 106 bits
--     -- Depreciated ^^^^^

--     -- Bit Mapping:
--     -- CONTROLS:
--         -- s_isLUI          --> 1 bit       [144]
--         -- ForceAddSub_out  --> 1 bit       [143]
--         -- RegWrite EN      --> 1 bit       [142]
--         -- RegWriteAddr (rd)--> 5 bits      [141:137]
--         -- D_Mem Write EN   --> 1 bit       [136]
--         -- D_Mem Read EN    --> 1 bit       [135]
--         -- Write Back Sel   --> 1 bit       [134]
--         -- Branch           --> 1 bit       [133]
--         -- jalr             --> 1 bit       [132]
--         -- ALU_CTRL         --> 4 bits      [131:128]

--     -- DATA:
--         -- PC + 4 Value     --> 32 bits     31 --> 127, 30 --> 126, ..., 0 --> 96       -- Need for jalr [rd]
--         -- RS1_OR_PC        --> 32 bits     31 --> 95,  30 --> 94,  ..., 0 --> 64
--         -- RS2              --> 32 bits     31 --> 63,  30 --> 62,  ..., 0 --> 32
--         -- RS2_OR_IMM       --> 32 bits     31 --> 31,  30 --> 30,  ..., 0 --> 0

-- library IEEE;
-- use IEEE.std_logic_1164.all;

-- entity DecodeExecute_Reg is
--     generic (N : integer := 145);   -- 145 bit register
--     port (i_CLK   : in std_logic;                          -- Clock input
--           i_RST   : in std_logic;                          -- Reset input
--           i_WE    : in std_logic;                          -- Write enable input
--           i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
--           o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
-- end DecodeExecute_Reg;

-- architecture structural of DecodeExecute_Reg is

--     component dffg is
--         port(i_CLK   : in std_logic;    -- Clock input
--              i_RST   : in std_logic;    -- Reset input
--              i_WE    : in std_logic;    -- Write enable input
--              i_D     : in std_logic;    -- Data value input
--              o_Q     : out std_logic);  -- Output
--     end component;

--     begin
--         -- instantiate N flip-flop instances:
--         G_nBit_Reg: for i in 0 to N-1 generate
--             -- component port => signal/wire/entity port
--             RegI: dffg port map (
--                 i_CLK   => i_CLK,
--                 i_RST   => i_RST,
--                 i_WE    => i_WE, 
--                 i_D     => i_D(i),
--                 o_Q     => o_Q(i));
--         end generate G_nBit_Reg;
-- end structural;
library IEEE;
use IEEE.std_logic_1164.all;

entity DecodeExecute_Reg is
    generic (N : integer := 145);
    port (
        i_CLK   : in  std_logic;
        i_RST   : in  std_logic;
        i_FLUSH : in  std_logic;
        i_WE    : in  std_logic;
        i_D     : in  std_logic_vector(N-1 downto 0);
        o_Q     : out std_logic_vector(N-1 downto 0)
    );
end DecodeExecute_Reg;

architecture structural of DecodeExecute_Reg is

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