-- Isaiah Pridie
-- CprE 3810 Lab1 Part 3.6b
-- Start Date: 2.4.2026 5:09 AM

library IEEE;
use IEEE.std_logic_1164.all;

entity basic_adder_n is
    generic (N : integer := 4); -- Generic of type integer. N = 4
    port (  i_aB0   : in std_logic_vector(N-1 downto 0);
            i_aB1   : in std_logic_vector(N-1 downto 0);
            o_S     : out std_logic_vector(N-1 downto 0);   -- Sum
            -- Next two are not controlled through a bus. They are used
            -- inside of the adder. Thus, don't need "(N-1 downto 0)"
            i_C     : in std_logic;  -- I am not supply a bus of inputs to this
            o_C     : out std_logic); -- I am not supplying 
           

end basic_adder_n;

architecture structural of basic_adder_n is

    -- wires
    -- We need wires to transfer oC to iC
        -- Think about it: intuitive:
            -- If we need wires to connect gates/components, then
            -- we need wires to connect components here too
        -- "N" instead of "N-1" b/c we need space for initial iC
    signal c_in  : std_logic_vector(N downto 0);
    
    component basic_adder is
        port (  i_aB0   : in std_logic;     -- adder Bit 0
                i_aB1   : in std_logic;     -- adder Bit 1
                i_C     : in std_logic;
                o_C     : out std_logic;
                o_S     : out std_logic );
    end component;
        
    begin
        c_in(0) <= i_C; -- first carry is input. This is the first part of the carry bus
        o_C     <= c_in(N);    -- last carry is the last carry of the bus
    
        -- Instantiate N basic_adder instances
        G_NBit_Basic_Adder: for i in 0 to N-1 generate
            ADDERI: basic_adder port map (
                -- Component Port => signal/wire/entity port
                i_aB0   =>  i_aB0(i),
                i_aB1   =>  i_aB1(i),
                i_C     =>  c_in(i),   -- 
                o_C     =>  c_in(i+1),  -- Last carry
                o_S     =>  o_S(i)       );
        end generate G_NBit_Basic_Adder;

end structural;