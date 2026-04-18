-- Isaiah Pridie
-- CprE 3810 Lab2 Part 3.e
-- Start Date: 2.13.2026    10:23 PM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_decoder_5t32 is
end entity;

architecture decoder_5t32 of tb_decoder_5t32 is

    -- declare signals to show up on questa sim
    -- initiallize bus/data values as 0
    signal is_D    : std_logic_vector(4 downto 0)  := (others => '0');
    signal os_D    : std_logic_vector(31 downto 0) := (others => '0');
    signal is_EN   : std_logic := '0';  -- only 1 enable bit

    component decoder_5t32 is
        port ( i_D  : in std_logic_vector(4 downto 0 ); -- 5 total bits
               i_EN : in std_logic; -- EN
               o_D  : out std_logic_vector(31 downto 0)); -- 32 total bits
    end component;

    begin 
    DUT: decoder_5t32
        -- Left is component => Right is signal
        port map ( i_D  => is_D,
                   i_EN => is_EN,
                   o_D  => os_D
        );

        process     -- Test Bench Process
        -- variable var0 : std_logic_vector(5-1 downto 0);
        begin 

        ------ Test Case 1: ------
        -- Iterate through every visible combination. 
        -- Output should display 1 hot bit rippling through
        --var0 := (others => '0');    -- Set all (5) bits to 0
        is_EN <= '0';   -- make sure it is set to 0
        for k in 0 to 32-1 loop
            -- Start with assigning is_D with 0. 
            -- After each iteration, increase by 1.
            -- Need to cast k to unsigned and 5 bit value
            is_D <= std_logic_vector(to_unsigned(k, 5));
            wait for 10 ns;
        end loop;


        ------ Test Case 2: ------
        is_D <= (others => '0');    -- Reset input to 0 before turning on EN
        is_EN <= '1';   -- Make sure it is set to 1
        for k in 0 to 32-1 loop
            -- Start with assigning is_D with 0. 
            -- After each iteration, increase by 1.
            -- Need to cast k to unsigned and 5 bit value
            is_D <= std_logic_vector(to_unsigned(k, 5));
            wait for 10 ns;
        end loop;

        wait;
    end process;
end architecture;
                
                
        

    










