-- Isaiah Pridie
-- Test Bench for dataHaz
-- Start Date: 4.20.2026

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_dataHaz is
    generic(gCLK_HPER   : time := 20 ns);
end entity;

architecture dataHaz of tb_dataHaz is
    -- Calculate the clock period as twice the half-period
    constant cCLK_PER  : time := gCLK_HPER * 2;

    -- declare signals to show up on questa sim
        -- Also initialize bus/bit/signal values
    signal is_DecRS1      : std_logic_vector(4 downto 0)  := (others => '0');
    signal is_DecRS2      : std_logic_vector(4 downto 0)  := (others => '0');
    signal is_ExRD        : std_logic_vector(4 downto 0)  := (others => '0');
    signal is_MemRD       : std_logic_vector(4 downto 0)  := (others => '0');

    signal is_ExRegWr     : std_logic := '0';
    signal is_MemRegWr    : std_logic := '0';
    signal is_DecUsesRS2  : std_logic := '0';
    signal is_CLK         : std_logic := '0';
    signal is_RST         : std_logic := '0';

    signal os_DataHaz     : std_logic;
    signal os_DataBubble  : std_logic;

    component dataHaz is
        port(
            i_DecRS1     : in  std_logic_vector(4 downto 0);
            i_DecRS2     : in  std_logic_vector(4 downto 0);
            i_ExRD       : in  std_logic_vector(4 downto 0);
            i_ExRegWr    : in  std_logic;
            i_MemRD      : in  std_logic_vector(4 downto 0);
            i_MemRegWr   : in  std_logic;
            i_DecUsesRS2 : in  std_logic;
            i_CLK        : in  std_logic;
            i_RST        : in  std_logic;

            o_DataHaz    : out std_logic;
            o_DataBubble : out std_logic);
    end component;

begin
    DUT: dataHaz
        port map(
            i_DecRS1     => is_DecRS1,
            i_DecRS2     => is_DecRS2,
            i_ExRD       => is_ExRD,
            i_ExRegWr    => is_ExRegWr,
            i_MemRD      => is_MemRD,
            i_MemRegWr   => is_MemRegWr,
            i_DecUsesRS2 => is_DecUsesRS2,
            i_CLK        => is_CLK,
            i_RST        => is_RST,

            o_DataHaz    => os_DataHaz,
            o_DataBubble => os_DataBubble);

    -- This process sets the clock value (low for gCLK_HPER, then high
    -- for gCLK_HPER). Absent a "wait" command, processes restart
    -- at the beginning once they have reached the final statement.
    P_CLK: process
    begin
        is_CLK <= '0';
        wait for gCLK_HPER;
        is_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    TEST_CASES: process
    begin

    -- Default values
    is_DecRS1      <= "00000";
    is_DecRS2      <= "00000";
    is_ExRD        <= "00000";
    is_MemRD       <= "00000";
    is_ExRegWr     <= '0';
    is_MemRegWr    <= '0';
    is_DecUsesRS2  <= '0';
    is_RST         <= '0';

    ------ Test Case 1: ------
    -- No hazard anywhere
    is_DecRS1      <= "00001";
    is_DecRS2      <= "00010";
    is_ExRD        <= "00011";
    is_MemRD       <= "00100";
    is_ExRegWr     <= '0';
    is_MemRegWr    <= '0';
    is_DecUsesRS2  <= '1';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 0, o_DataBubble = 0


    ------ Test Case 2: ------
    -- EX hazard on RS1
    is_DecRS1      <= "00101";
    is_DecRS2      <= "00010";
    is_ExRD        <= "00101";
    is_MemRD       <= "00111";
    is_ExRegWr     <= '1';
    is_MemRegWr    <= '0';
    is_DecUsesRS2  <= '0';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 1, o_DataBubble = 1


    ------ Test Case 3: ------
    -- EX hazard on RS2
    is_DecRS1      <= "00001";
    is_DecRS2      <= "01010";
    is_ExRD        <= "01010";
    is_MemRD       <= "00111";
    is_ExRegWr     <= '1';
    is_MemRegWr    <= '0';
    is_DecUsesRS2  <= '1';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 1, o_DataBubble = 1


    ------ Test Case 4: ------
    -- EX rd matches RS2, but instruction does not use RS2
    is_DecRS1      <= "00001";
    is_DecRS2      <= "01010";
    is_ExRD        <= "01010";
    is_MemRD       <= "00111";
    is_ExRegWr     <= '1';
    is_MemRegWr    <= '0';
    is_DecUsesRS2  <= '0';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 0, o_DataBubble = 0


    ------ Test Case 5: ------
    -- MEM hazard on RS1
    is_DecRS1      <= "01100";
    is_DecRS2      <= "00010";
    is_ExRD        <= "00001";
    is_MemRD       <= "01100";
    is_ExRegWr     <= '0';
    is_MemRegWr    <= '1';
    is_DecUsesRS2  <= '0';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 1, o_DataBubble = 1


    ------ Test Case 6: ------
    -- MEM hazard on RS2
    is_DecRS1      <= "00001";
    is_DecRS2      <= "10101";
    is_ExRD        <= "00010";
    is_MemRD       <= "10101";
    is_ExRegWr     <= '0';
    is_MemRegWr    <= '1';
    is_DecUsesRS2  <= '1';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 1, o_DataBubble = 1


    ------ Test Case 7: ------
    -- rd = x0 in EX should not count as a hazard
    is_DecRS1      <= "00000";
    is_DecRS2      <= "00001";
    is_ExRD        <= "00000";
    is_MemRD       <= "00100";
    is_ExRegWr     <= '1';
    is_MemRegWr    <= '0';
    is_DecUsesRS2  <= '1';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 0, o_DataBubble = 0


    ------ Test Case 8: ------
    -- rd = x0 in MEM should not count as a hazard
    is_DecRS1      <= "00000";
    is_DecRS2      <= "00101";
    is_ExRD        <= "00110";
    is_MemRD       <= "00000";
    is_ExRegWr     <= '0';
    is_MemRegWr    <= '1';
    is_DecUsesRS2  <= '1';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 0, o_DataBubble = 0


    ------ Test Case 9: ------
    -- Both EX and MEM match at once
    is_DecRS1      <= "00111";
    is_DecRS2      <= "01000";
    is_ExRD        <= "00111";
    is_MemRD       <= "01000";
    is_ExRegWr     <= '1';
    is_MemRegWr    <= '1';
    is_DecUsesRS2  <= '1';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 1, o_DataBubble = 1


    ------ Test Case 10: ------
    -- Reset toggled just so it shows on waveform
    is_RST         <= '1';
    wait for cCLK_PER;

    is_RST         <= '0';
    is_DecRS1      <= "00010";
    is_DecRS2      <= "00011";
    is_ExRD        <= "00100";
    is_MemRD       <= "00101";
    is_ExRegWr     <= '0';
    is_MemRegWr    <= '0';
    is_DecUsesRS2  <= '1';
    wait for cCLK_PER;
    -- Expect: o_DataHaz = 0, o_DataBubble = 0

        wait;   -- stop signals
    end process;
end architecture;
