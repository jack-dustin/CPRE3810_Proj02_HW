-- Isaiah Pridie
-- CprE 3810 Lab2 Part 3.e
-- Start Date: 2.17.2026,   1:14 PM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.mux_32t1_package.all; -- import package from word folder


entity tb_reg_file is
    generic(gCLK_HPER   : time := 50 ns);
end entity;

architecture reg_file of tb_reg_file is
    -- Calculate the clock period as twice the half-period
    constant cCLK_PER  : time := gCLK_HPER * 2;

    -- declare signals to show up on questa sim
        -- Also initialize bus/bit/signal values
    signal is_rs1   : std_logic_vector(4 downto 0)  := (others => '0'); -- Input to select a register
    signal is_rs2   : std_logic_vector(4 downto 0)  := (others => '0'); -- Input to select a register
    signal os_rs1   : std_logic_vector(31 downto 0) := (others => '0'); -- Values output by first Bus Mux
    signal os_rs2   : std_logic_vector(31 downto 0) := (others => '0'); -- Values output by second Bus MUX
    signal is_rd    : std_logic_vector(4 downto 0)  := (others => '0'); -- Input to select a register to write to
    
    signal is_dEN   : std_logic;    -- Enable bit for decoder
    signal is_RST   : std_logic;    -- Show reset
    signal is_CLK   : std_logic;    -- Show clock
    signal is_Data  : std_logic_vector(31 downto 0); -- Values to load into a register

    component reg_file is
        port(i_RS1   : in std_logic_vector(4 downto 0);   -- 5 bit bus    -- [19:15]
             i_RS2   : in std_logic_vector(4 downto 0);   -- 5 bit bus    -- [24:20]
             o_rs1   : out std_logic_vector(31 downto 0);    -- Result of RS1 input
             o_rs2   : out std_logic_vector(31 downto 0);    -- Result of RS2 input;
             i_rd    : in std_logic_vector(4 downto 0);   -- 5 but bus    -- [11:7]
             i_dEN   : in std_logic;     -- Decoder EN bit
             i_RST   : in std_logic;     -- RESET bit
             i_CLK   : in std_logic;     -- Clock Signal for register
             i_DATA  : in std_logic_vector(31 downto 0));  -- 32 bit bus   -- Register Data Input
    end component;

    begin
    DUT: reg_file
        -- left is component => right is signal
        port map(i_RS1   => is_rs1,
                 i_RS2   => is_rs2,
                 o_rs1   => os_rs1,
                 o_rs2   => os_rs2,
                 i_rd    => is_rd,

                 i_dEN   => is_dEN,
                 i_RST   => is_RST,
                 i_CLK   => is_CLK,
                 i_DATA  => is_Data );

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

    -- Remember only thing that depends on the clock are the registers
    is_dEN <= '0';  -- Enable Decoder - Don't write anything.
    is_RST <= '0';  -- Don't Reset registers
    
    ------ Test Case 1: ------
    -- Load Registers with a value and show it with os_rs1/2
    is_rd   <= "00000";   -- x0
    is_dEN   <= '1';   -- Enable decoder for writing

    is_rd   <= "00000";     -- x0
    is_Data  <= x"0FFFFFFF"; -- Try writing 0x0FFFFFFF to x0
    is_rs1  <= "00000";     -- Try to read x0
    is_rs2  <= "00000";     -- Try to read x0
    wait for cCLK_PER;

    is_rd   <= "00001";     -- x1
    is_Data  <= x"11111111"; -- Try writing 0x11111111 to x1
    is_rs1  <= "00001";     -- Try to read x1
    wait for cCLK_PER;

    is_rd   <= "01000";     -- x8
    is_Data  <= x"88888888"; -- Try writing 0x88888888 to x8
    is_rs2  <= "01000";     -- Try to read x8
    wait for cCLK_PER;

    is_rd   <= "11111";     -- x31
    is_Data  <= x"31313131"; -- Try writing 0x31313131 to x31
    is_rs1  <= "11111";     -- x31
    wait for cCLK_PER;
    -- Expect: A lot of red, but then in os_rsN 'i_Data'
    -- x0 = 0   x1 = 11111111   x8 = 88888888   x31 = 31313131


    ------ Test Case 2: ------
    -- Try resetting registers 
    is_dEN <= '0';      -- disable decoder. Don't w to reg on accident
    is_RST <= '1';      -- Reset Registers
    wait for cCLK_PER;

    is_rs1  <= "00000"; -- read x0
    is_rs2  <= "00001"; -- read x1
    wait for cCLK_PER;

    is_rs1  <= "00000"; -- read x0
    is_rs2  <= "00001"; -- read x1
    wait for cCLK_PER;
    -- Expect: Registers to output 0


    ------ Test Case 3: ------
    -- Try writing to registers while Decoder Enable = 0.
    -- Then try it with no Clock Signal but Decoder Enable = 1
    is_RST <= '0';
    is_dEN <= '0';      -- disable decoder. Don't w to reg on accident
    wait for cCLK_PER;
    
    is_rd   <= "01100";     -- Save to register x12
    is_rs1  <= "01100";     -- Read register x12   
    is_rs2  <= "01100";     -- Read register x12
    is_Data  <= x"12345678";
    wait for cCLK_PER;
    wait until rising_edge(is_CLK);    -- (try to) skip 1 full clock cycle so we know where we are; We know exactly when dEN is turned on

    is_dEN  <= '1';     
    wait for cCLK_PER;
    -- Expect: No updated output will occur; register x12 will say 0 from being reset. 
    -- Output present from o_RS1 and o_RS2
        -- Then after 100ns, it will update with the correct value because register value updated

    wait for 100 ns;    -- Wait for register to update contents. Need this to output x"12345678"

    ------ Test Case 4: ------
    -- Try writing to a register like normal, but with NO Clock Signal
    is_rd   <= "01110";     -- Save to register x14
    is_rs1  <= "01110";     -- Read register x12   
    is_rs2  <= "01110";     -- Read register x12
    is_Data  <= x"87654321";    
    wait until rising_edge(is_CLK); -- Skip 1 full clock cycle again so we know where we are
    wait for cCLK_PER;
    -- Expected: Nothing will happen UNTIL the first positive edge AFTER 100 ns has passed
        -- So apparently I can't stop the clock unless I STOP it. Too much work. Sorry Warren. 

    ------ Test Case 5: ------

    -- Expected:

    ------ Test Case 6: ------
    -- Expected:

    ------ Test Case 7: ------
    -- Expected:

    ------ Test Case 8: ------
    -- Expected:

    ------ Test Case 9: ------
    -- Expected:

        wait;   -- stop signals
    end process;
end architecture;
