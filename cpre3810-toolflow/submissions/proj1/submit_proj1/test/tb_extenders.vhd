-- Isaiah Pridie
-- CprE 3810 Lab2 Part 4(d)
-- Start Date: 2.22.2026,   7:36PM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


entity tb_extenders is
end entity;

architecture structural of tb_extenders is
    -- Wire/Signal declarations:

    signal is_imm   : std_logic_vector(11 downto 0);
    signal is_ctrl  : std_logic;    -- 0 for Zero Ext.  1 for Sign Ext.
    signal os_OUT   : std_logic_vector(31 downto 0) := (others => '0');

    component extenders is
        port(i_imm  : in  std_logic_vector(11 downto 0);    -- input 12 bit immediate value
             i_ZoS  : in  std_logic;                        -- Bit to choose between 
             o_out  : out std_logic_vector(31 downto 0));   -- Output (32-bit) vector);
    end component;

    begin
    DUT: extenders
    -- Left is component => Right is signal

    port map(i_imm  => is_imm,
             i_ZoS  => is_ctrl,
             o_out  => os_OUT);


    Test_Cases: process
    begin

    --------------------------------
    -------- Test Case 1: ----------
        -- Let MSB = 1, Try to sign extend
        is_ctrl  <= '1';
        is_imm  <= x"800";  -- 12 bits, MSB is a 1 
        wait for 10 ns;

        -- expect: Output will show F for the first 5 hex characters
    

    --------------------------------
    -------- Test Case 2: ----------
        -- Let MSB = 0, Try to sign extend
        is_ctrl  <= '1';     -- (same as last test)
        is_imm  <= x"000";  -- 12 bits, MSB is a 0
        wait for 10 ns;
        -- expect: output will show 0 for the first 5 hex characters

      ------ Test Case 2.1: --------
        -- Let MSB = 0, the rest = 1, Try to sign extend
        is_ctrl  <= '1';     -- (same as last test)
        is_imm  <= x"7FF";  -- 12 bits, MSB is a 0, the rest are 1's
        wait for 10 ns;
        -- exepct: output will show 0 for the first 5 hex characters


    ------------------------------
    -------- Test Case 3: --------
        -- Let MSB = 0, Try to zero extend
        is_ctrl  <= '0';     -- zero extend
        is_imm  <= x"000";
        wait for 10 ns;
        -- expect: output will show 0 for the first 5 hex characters


    ------------------------------
    -------- Test Case 4: --------
        -- Let MSB = 1, Try to zero extend
        is_ctrl  <= '0';     -- zero extend
        is_imm  <= x"FFF";  -- ALL 1's
        wait for 10 ns;
        -- expect: output will show 0 for the first 5 hex characters 
        
        wait;
    end process;

end architecture;