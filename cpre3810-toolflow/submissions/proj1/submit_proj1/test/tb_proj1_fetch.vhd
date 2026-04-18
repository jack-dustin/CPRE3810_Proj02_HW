-- Isaiah Pridie
-- CprE 381 Project01 Fetcher component thing TEST_BENCH
-- Start Date: 3.3.2026,    1:54 PM


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_proj1_fetch is
    generic(gCLK_HPER   : time := 10 ns);   -- Changed the time from 50 ns to 10 ns (can be adjusted more)
end tb_proj1_fetch;

architecture structural of tb_proj1_fetch is
    
    -- Declare signals/constants    (These will show up on QuestaSim)
    constant cCLK_PER  : time := gCLK_HPER * 2; -- Calculate the clock period as twice the half-period
    
    signal is_CLK       : std_logic;    
    signal is_RST_PC    : std_logic;
    signal is_imm       : std_logic_vector(31 downto 0);    -- Imm AFTER sign extending
    signal cs_PC_add     : std_logic;            -- Control bit for choosign between "+4" or "+Imm"
    signal os_PC_val     : std_logic_vector(31 downto 0);    -- Displays registers contents

    component proj1_fetch is
        port(i_CLK      : in std_logic;
             i_RST_PC   : in std_logic;     -- Need different reset* (this one); We need to reset register to 0x0040.0000 not 0x0000.0000
             i_imm      : in std_logic_vector(31 downto 0);     -- imm AFTER SIGN-EXTENDING AND MUXING
             c_PC_add   : in std_logic;                         -- Control bit for choosing between "+4" and "+imm"
             o_PC       : out std_logic_vector(31 downto 0) );  -- Output from PC register to Instruction memory
    end component;

    begin
    DUT: proj1_fetch
        -- Component Port => Signal
        port map(i_CLK      => is_CLK,
                 i_RST_PC   => is_RST_PC,
                 i_imm      => is_imm,
                 c_PC_add   => cs_PC_add,
                 o_PC       => os_PC_val);

    P_CLK: process
    begin
        is_CLK <= '0';
        wait for gCLK_HPER;
        is_CLK <= '1';
        wait for gCLK_HPER;
    end process;

    TEST_CASES: process
    begin

        ----------------------------
        ------ TEST CASE 1.0: ------
          -- Reset PC register
        is_RST_PC   <= '1'; -- Turn reset signal ON
        cs_PC_add   <= '0'; -- Set to a default value - Prevent unexepected behavior when RST goes low
        is_imm      <= x"00000000";     -- Same reason as above
        wait until rising_edge(is_clk);

        
        ------ TEST CASE 1.1: ------
          -- Set PC register to all 1
        is_RST_PC   <= '0';   -- Make sure reset signal goes low
        cs_PC_add   <= '1';  -- Set to adding immediate
        -- What + 0x0040.0000 = 0xFFFF.FFFF -> 0xFFBF.FFFF
        is_imm      <= x"FFBFFFFF"; -- Set to all 1
        wait until rising_edge(is_clk);
        -- Expected: o_PC = 0xFFFF.FFFF


        ------ TEST CASE 1.2: ------
          -- Add 1 to PC register of all F's
        is_RST_PC   <= '0';
        cs_PC_add   <= '1';  -- Set to adding immediate
        is_imm      <= x"00000001"; -- Set to 0x1
        wait until rising_edge(is_clk);
        -- Expected: o_PC = 0x0000.0000


        ------ TEST CASE 1.3: ------
          -- Reset PC register with is_RST_PC
        is_RST_PC   <= '1';
        cs_PC_add   <= '0';         -- Set to default of "+ 4"
        is_imm      <= x"00000000"; -- Set to default
        wait until rising_edge(is_clk);
        -- Expected: o_PC = 0x0040.0000


        ----------------------------
        ------ TEST CASE 2.0: ------
          -- Test +4 and +imm adders with loop
          -- Should be starting from a reset PC register
          is_RST_PC <= '0';         -- Turn Reset OFF
        is_imm      <= x"00001000"; -- Initialize the i_imm
        
        for k in 0 to 15 loop       -- Loop 16 times

            if (k mod 2) = 0 then   -- if even, add 4
                cs_PC_add    <= '0';
            else                    -- else, add is_imm
                cs_PC_add   <= '1';
            end if;

            wait until rising_edge(is_clk);
        end loop;
        -- Expected: 
            -- (0)  o_PC = 0x0040.0004   | (1)   o_PC = 0x0040.1004
            -- (2)  o_PC = 0x0040.1008   | (3)   o_PC = 0x0040.2008
            -- (4)  o_PC = 0x0040.200C   | (5)   o_PC = 0x0040.300C
            -- (6)  o_PC = 0x0040.3010   | (7)   o_PC = 0x0040.4010
            -- (8)  o_PC = 0x0040.4014   | (9)   o_PC = 0x0040.5014
            -- (10) o_PC = 0x0040.5018   | (11)  o_PC = 0x0040.6018
            -- (12) o_PC = 0x0040.601C   | (13)  o_PC = 0x0040.701C
            -- (14) o_PC = 0x0040.7020   | (15)  o_PC = 0x0040.8020


        ----------------------------
        ------ TEST CASE 3.0: ------
          -- Reset PC register one last time
        is_RST_PC   <= '1';         -- Reset signal ON
        cs_PC_add   <= '0';         -- Default value
        is_imm      <= x"00000000"; -- Default value
        wait until rising_edge(is_clk);
        -- Exepcted: o_PC = 0x0040.0000
        
        wait;
    end process;
end architecture;
