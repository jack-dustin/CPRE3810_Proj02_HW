-- Isaiah Pridie
-- CprE 381 project01 - Load file for lw, lhw, lb
-- 3.13.2026,    10:24

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity proj01_LOAD is
    port(i_memVal       : in  std_logic_vector(31 downto 0);
         c_addr_2bit    : in  std_logic_vector(1  downto 0);    -- Lower 2 bits of DMEM addr
         c_funct3       : in  std_logic_vector(2  downto 0);    
         o_LoadOut      : out std_logic_vector(31 downto 0));
end entity;

architecture structural of proj01_LOAD is
    -- Given: i_memVal = 0x12345678

    -- Sign Extend by storing and using first bit of every byte
    signal s_ex             : std_logic_vector(3  downto 0);        

    -- Byte Signals     -- s_mux_byte_out uses busMux_4t1
    signal s_byte_00        : std_logic_vector(31 downto 0);        -- 0x78 
    signal s_byte_01        : std_logic_vector(31 downto 0);        -- 0x56
    signal s_byte_10        : std_logic_vector(31 downto 0);        -- 0x34
    signal s_byte_11        : std_logic_vector(31 downto 0);        -- 0x12
    signal s_mux_byte_out   : std_logic_vector(31 downto 0);        -- Signal for selected byte           
    
    -- Half-Word Signals
    signal s_hw_0           : std_logic_vector(31 downto 0);        -- 0x5678
    signal s_hw_1           : std_logic_vector(31 downto 0);        -- 0x1234
    signal s_mux_hw_out     : std_logic_vector(31 downto 0);        -- Signal for selected half-word

    -- Using buxMux_2t1, choose between byte_out and hw_out signal
    signal s_mux_b_hw_out   : std_logic_vector(31 downto 0);

    component busMux_2t1 is
        port(i_dZero    : in  std_logic_vector(31 downto 0);
             i_dOne     : in  std_logic_vector(31 downto 0);
             ALUSrc     : in  std_logic; -- select line
             o_dOUT     : out std_logic_vector(31 downto 0));
    end component;

    component busMux_4t1 is
        port(i_Da       : in  std_logic_vector(31 downto 0);    -- Input 1
             i_Db       : in  std_logic_vector(31 downto 0);    -- Input 2
             i_Dc       : in  std_logic_vector(31 downto 0);    -- Input 3
             i_Dd       : in  std_logic_vector(31 downto 0);    -- Input 4
             C_S0       : in  std_logic;                        -- Sel line 0
             C_S1       : in  std_logic;                        -- Sel line 1
             o_Do       : out std_logic_vector(31 downto 0) );  -- Output
    end component;

begin

    -- Sign Extension bits for each byte
    -- If c_funct3(2) = 1 {zero extend},    else {sign extend}
    s_ex(3)     <= i_memVal(31) AND (NOT c_funct3(2));
    s_ex(2)     <= i_memVal(23) AND (NOT c_funct3(2));
    s_ex(1)     <= i_memVal(15) AND (NOT c_funct3(2));
    s_ex(0)     <= i_memVal(7)  AND (NOT c_funct3(2));

    -- Extracting byte from word + sign extension 
    s_byte_00   <= (31 downto 8 => s_ex(0)) & i_memVal(7 downto 0);     -- 0x------78
    s_byte_01   <= (31 downto 8 => s_ex(1)) & i_memVal(15 downto 8);    -- 0x------56
    s_byte_10   <= (31 downto 8 => s_ex(2)) & i_memVal(23 downto 16);   -- 0x------34
    s_byte_11   <= (31 downto 8 => s_ex(3)) & i_memVal(31 downto 24);   -- 0x------12

    -- Extracting half-word from word + sign extension
    s_hw_0      <= (31 downto 16 => s_ex(1)) & i_memVal(15 downto 0);   -- 0x----5678
    s_hw_1      <= (31 downto 16 => s_ex(3)) & i_memVal(31 downto 16);  -- 0x----1234

    -- Select which byte
    INST_BYTE_BUSMUX_4t1: busMux_4t1 port map(
        i_Da        => s_byte_00,       -- 0x78
        i_Db        => s_byte_01,       -- 0x56
        i_Dc        => s_byte_10,       -- 0x34
        i_Dd        => s_byte_11,       -- 0x12
        C_S0        => c_addr_2bit(0),      -- Picks (0 vs 1), (2 vs 3)
        C_S1        => c_addr_2bit(1),      -- Picks (0,1) vs (2,3)
        o_Do        => s_mux_byte_out);     -- Select byte

    -- Select which half-word
    INST_BUSMUX_HW_1or2: busMux_2t1 port map(   -- Choose between two half-word inputs
        i_dZero     => s_hw_0,      -- 0x5678
        i_dOne      => s_hw_1,      -- 0x1234
        ALUSrc      => c_addr_2bit(1),      -- i_addr(1)
        o_dOUT      => s_mux_hw_out);       -- Selected half-word  

    -- Select Byte result or Half-Word result
    INST_BUSMUX_B_or_HW: busMux_2t1 port map(   -- Choose between byte and half-word
        i_dZero     => s_mux_byte_out,      -- Byte Mux Result
        i_dOne      => s_mux_hw_out,        -- Half-Word Mux Result
        ALUSrc      => c_funct3(0),
        o_dOUT      => s_mux_b_hw_out);     -- Selected byte or half-word output

    -- Select Word or previous result
    INST_BUSMUX_FINAL: busMux_2t1 port map(     -- Choose between prior result and word
        i_dZero     => s_mux_b_hw_out,  -- Result of Half-Word vs Byte
        i_dOne      => i_memVal,        -- Original Word
        ALUSrc      => c_funct3(1),
        o_dOUT      => o_LoadOut);      -- Final output

end architecture;
