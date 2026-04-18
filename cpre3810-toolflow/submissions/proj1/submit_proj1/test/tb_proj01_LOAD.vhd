-- Isaiah Pridie
-- CprE 381 project01 - Load file for lw, lhw, lb
-- 3.13.2026,    10:24

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Testbench for masking and outputting the correct memory value


entity tb_proj01_LOAD is
end entity;


architecture proj01_LOAD of tb_proj01_LOAD is

    -- signals:
    signal si_memVal        : std_logic_vector(31 downto 0);
    signal sc_addr_2bit     : std_logic_vector(1  downto 0);
    signal sc_funct3        : std_logic_vector(2  downto 0);
    signal so_Out           : std_logic_vector(31 downto 0);


    component proj01_LOAD is
    port(i_memVal       : in  std_logic_vector(31 downto 0);
         c_addr_2bit    : in  std_logic_vector(1  downto 0);    -- Lower 2 bits of DMEM addr
         c_funct3       : in  std_logic_vector(2  downto 0);    
         o_LoadOut      : out std_logic_vector(31 downto 0));
    end component;

begin
DUT: proj01_LOAD
    -- component => signal
    port map(i_memVal       => si_memVal,
             c_addr_2bit    => sc_addr_2bit,
             c_funct3       => sc_funct3,
             o_LoadOut      => so_Out);

Test_Cases: process
begin
-- given i_memVal = 0x12345678
-- sc_funct3(2)    --> 1 for unsigned results
-- sc_funct3(1)    --> 1 for entire word, 0 for eveything else
-- sc_funct3(0)    --> 1 for halfword, 0 for byte

-- sc_addr_2bit(1) --> 1 for 0x78/56. 0 for ox34/12
    -- 1 for 
-- sc_addr_2bit(0) --> 0 for (0x78 or 0x25) / (0x34 or 0x12)
    -- b"00" = 0x12
    -- b"01" = 0x34
    -- b"10" = 0x56
    -- b"11" = 0x78

    ------------------------------------
    ------ TEST CASE 1.0:  ------
        -- Test getting each byte
    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"00";       -- 0x12
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0x00000012

    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"01";       -- 0x34
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0x00000034

    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"10";       -- 0x56
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0x00000056

    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"11";       -- 0x78
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0x00000078

    ------ TEST CASE: 1.1: ------
        -- Test getting each byte unsigned (expecting no difference in results)
    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"00";       -- 0x12
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x00000012

    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"01";       -- 0x34
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x00000034

    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"10";       -- 0x56
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x00000056

    si_memVal       <= x"12345678";
    sc_addr_2bit    <= b"11";       -- 0x78
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x00000078


    ------ TEST CASE 1.2: ------
        -- Test with bytes that should sign extend
    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"00";       -- 0xF1
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0xFFFFFFF1

    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"01";       -- 0x71
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0x00000071

    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"10";       -- 0xF2
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0xFFFFFFF2

    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"11";       -- 0x72
    sc_funct3       <= b"000";      -- Geting a byte
    wait for 3 ns;
    -- Expected: 0x00000072

    ------ TEST CASE 1.3: ------
        -- Test getting unsigned bits (forced to 0 extend)
    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"00";       -- 0xF1
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x000000F1

    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"01";       -- 0x71
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x00000071

    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"10";       -- 0xF2
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x000000F2

    si_memVal       <= x"F171F272";
    sc_addr_2bit    <= b"11";       -- 0x72
    sc_funct3       <= b"100";      -- Geting an unsigned byte
    wait for 3 ns;
    -- Expected: 0x00000072


    ----------------------------
    ------ TEST CASE 2.0: ------
        -- Test getting each half-word
    si_memVal       <= x"11223344";
    sc_addr_2bit    <= b"00";       -- 0x1122
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0x00001122
    
    si_memVal       <= x"11223344";
    sc_addr_2bit    <= b"10";       -- 0x3344
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0x00003344

    ------ TEST CASE 2.1: ------
        -- 0th bit of last 2 addr bits shouldn't affect half-word
    si_memVal       <= x"11223344";
    sc_addr_2bit    <= b"01";       -- 0x1122
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0x00001122

    si_memVal       <= x"11223344";
    sc_addr_2bit    <= b"11";       -- 0x3344
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0x00003344

    ------ TEST CASE 2.2: ------
        -- Try with half-words that will sign extend
    si_memVal       <= x"1234CDEF"; 
    sc_addr_2bit    <= b"00";       -- 0x1234
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0x00001234

    si_memVal       <= x"1234CDEF"; 
    sc_addr_2bit    <= b"10";       -- 0xCDEF
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0xFFFFCDEF

    ------ TEST CASE 2.3: ------
        -- Try sign extending using [1:0] bits of addr
    si_memVal       <= x"1234CDEF"; 
    sc_addr_2bit    <= b"01";       -- 0x1234
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0x00001234

    si_memVal       <= x"1234CDEF"; 
    sc_addr_2bit    <= b"11";       -- 0xCDEF
    sc_funct3       <= b"001";      -- Geting a half-word
    wait for 3 ns;
    -- Expected: 0xFFFFCDEF


    ----------------------------
    ------ TEST CASE 3.0: ------    Test getting entire word
        -- Test with all combinations of bits [1:0] of addr
        -- Also, funct3(0) = 0 = byte
    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"00";       -- 0x55667788
    sc_funct3       <= b"010";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"01";       -- 0x55667788
    sc_funct3       <= b"010";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"10";       -- 0x55667788
    sc_funct3       <= b"010";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"11";       -- 0x55667788
    sc_funct3       <= b"010";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    ------ TEST CASE 3.1: ------
        -- Test with all combinations of addr [1:0] bits
        -- and funct3(0) = 1 = half-word
    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"00";       -- 0x55667788
    sc_funct3       <= b"011";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"01";       -- 0x55667788
    sc_funct3       <= b"011";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"10";       -- 0x55667788
    sc_funct3       <= b"011";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    si_memVal       <= x"55667788"; 
    sc_addr_2bit    <= b"11";       -- 0x55667788
    sc_funct3       <= b"011";      -- Geting a word
    wait for 3 ns;
    -- Expected: 0x55667788

    wait;
    end process;
end architecture;
