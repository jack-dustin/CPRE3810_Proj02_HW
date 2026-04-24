-- Isaiah Pridie
-- CprE 3810 Lab2 Part i
-- 2.17.2026,   9:30 AM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.RISCV_types.all;
--use work.mux_32t1_package.all; -- import package from word folder

entity reg_file is 
  port(
    i_RS1   : in std_logic_vector(4 downto 0);   -- 5 bit bus    -- [19:15]
    i_RS2   : in std_logic_vector(4 downto 0);   -- 5 bit bus    -- [24:20]
    o_rs1   : out std_logic_vector(31 downto 0);    -- Result of RS1 input
    o_rs2   : out std_logic_vector(31 downto 0);    -- Result of RS2 input
    i_rd    : in std_logic_vector(4 downto 0);   -- 5 but bus    -- [11:7]
    i_dEN   : in std_logic;     -- Decoder EN bit
    i_RST   : in std_logic;     -- RESET bit
    i_CLK   : in std_logic;     -- Clock Signal for register
    i_DATA  : in std_logic_vector(31 downto 0));  -- 32 bit bus   -- Register Data Input
end reg_file;

architecture structural of reg_file is
    -- Wire/Signal declarations:
    signal wire_WE    : std_logic_vector(31 downto 0) := (others => '0');
    signal wire_iReg  : i_reg_array := (others => (others => '0'));
    -- i_Reg(0) = x0    i_Reg(31) = x31

    component decoder_5t32 is
        port(i_D    : in std_logic_vector(4 downto 0 ); -- 5 total bits
             i_EN   : in std_logic; -- EN
             o_D    : out std_logic_vector(31 downto 0)); -- 32 total bits
    end component;

    component reg_n is
        generic (N : natural := 32); -- expecting 32 instances of 32-bit registers
        port(i_CLK   : in std_logic;                          -- Clock input
             i_RST   : in std_logic;                          -- Reset input
             i_WE    : in std_logic;                          -- Write enable input
             i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
             o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
    end component;

    component mux_32t1 is
        port(i_Sel  : in std_logic_vector(4 downto 0);    -- 5 total select bits
             i_R    : in i_reg_array; -- Map array port to actual port
             o_Reg  : out std_logic_vector(31 downto 0) );
    end component;

    begin
        -- instantiate / connect components
        -- Left is component ports. Right is signals/entity ports

        INST_DECODER: decoder_5t32
        port map(i_D    => i_rd,
                 i_EN   => i_dEN,
                 o_D    => wire_WE);

        -- Every register has the same Clock and Reset* Signal  (* = x0 (maybe) always 1)
        -- Each register gets 1 Write EN bit from decoder: i_WE --> wire_WE(i)
        -- Every register gets the same DATA input
        -- Each register produces it's own output. Mux filters it i_Q--> wire_iReg(i) 

        -- Normal if statements not valid in generate for some reason. Have to do it this way.
            -- I like this way. It is cleaner. More efficient(?) than an OR gate at reset port of reg x0
        GEN_REGISTERS: for i in 0 to 31 generate

            INST_x0: if i = 0 generate
              INST_REGISTER: reg_n
              generic map (N => 32)
              port map(i_CLK  => not i_CLK,
                       i_RST  => i_RST,     -- force RESET of x0 to '1'
                       i_WE   => '0',    
                       i_D    => (others => '0'),    -- Register Input
                       o_Q    => wire_iReg(i));    -- Register Output (This needs to go to the MUXes)
            end generate;

            INST_x1_31: if i /= 0 generate
            INST_REGISTERS: reg_n
              port map(i_CLK  => not i_CLK,
                       i_RST  => i_RST,
                       i_WE   => wire_WE(i),    
                       i_D    => i_DATA,    -- Register Input
                       o_Q    => wire_iReg(i));    -- Register Output (This needs to go to the MUXes)
            end generate;

        end generate;

        INST_MUX_1: mux_32t1
        port map(i_Sel  => i_RS1,
                 i_R    => wire_iReg, 
                 o_Reg  => o_rs1 );

        INST_MUX_2: mux_32t1
        port map(i_Sel  => i_RS2,
                 i_R    => wire_iReg, 
                 o_Reg  => o_rs2 );

end architecture;