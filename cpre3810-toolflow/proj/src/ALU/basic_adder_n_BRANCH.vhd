-- Isaiah Pridie
-- CprE 3810 proj01 
-- Start Date 3.18.2026,    4:07 PM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- (some) Branch inst. need c_in & c_out of MSB
    -- Need an adder that has those as ports
-- This is almost a direct copy + paste from original basic_adder_n.vhd

entity basic_adder_n_BRANCH is
    generic (N : integer := 32); -- Default is 32
    port (  i_aB0       : in std_logic_vector(N-1 downto 0);
            i_aB1       : in std_logic_vector(N-1 downto 0);
            o_S         : out std_logic_vector(N-1 downto 0);   -- Sum
            o_MSB_Cin   : out std_logic;    -- Carry in. Later used for subtraction (2's comp)
            i_C         : in std_logic;     -- I am not supply a bus of inputs to this
            o_C         : out std_logic);   -- Final carry out
end entity;

architecture structural of basic_adder_n_BRANCH is

    signal c_in  : std_logic_vector(N downto 0);    -- Send C_out(N) to C_in(N+1)
    
    component basic_adder is
        port(i_aB0   : in std_logic;     -- adder Bit 0
             i_aB1   : in std_logic;     -- adder Bit 1
             i_C     : in std_logic;
             o_C     : out std_logic;
             o_S     : out std_logic );
    end component;
        
    begin
        c_in(0)     <= i_C;         -- first carry is input. This is the first part of the carry bus
        o_C         <= c_in(N);     -- last carry is the last carry of the bus (OVERFLOW)
        o_MSB_Cin   <= c_in(N-1);   -- MSB carry in
        -- Instantiate N basic_adder instances
        G_NBit_Basic_Adder: for i in 0 to N-1 generate
            ADDERI: basic_adder port map (
                i_aB0   =>  i_aB0(i),
                i_aB1   =>  i_aB1(i),
                i_C     =>  c_in(i),    -- Carry in
                o_C     =>  c_in(i+1),  -- Last carry
                o_S     =>  o_S(i)       );
        end generate G_NBit_Basic_Adder;

end structural;