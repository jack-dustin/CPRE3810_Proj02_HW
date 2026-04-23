-- Isaiah Pridie
-- CprE 3810 Lab1 Part 3.3
-- Start Date: 1.30.2026


library ieee;
use IEEE.std_logic_1164.all;

-- Think entity as pin out of the chip
-- Names here MUST match what other files connect to
entity mux2t1 is 
port (  i_D0    : in std_logic;
        i_D1    : in std_logic;
        i_S     : in std_logic;
        o_O     : out std_logic
     );
end mux2t1;


-- What is actually inside the 'chip'
-- Allowed to have multiple architectures for the same entity
    -- only 1 is active at a time
architecture structural of mux2t1 is 
    
    -- wires:
    signal wire0        : std_logic;
    signal wire1        : std_logic;
    signal wire2        : std_logic;

    -- component: "I plan to use a circuit shaped like this"
    -- Does NOT create working hardware by itself
    -- and gate
    component andg2 is 
        port ( i_A      : in std_logic;
               i_B      : in std_logic;
               o_F      : out std_logic
             );
    end component;

    -- or gate
    component org2 is
        port ( i_A      : in std_logic;
               i_B      : in std_logic;
               o_F      : out std_logic
             );
    end component;

    -- not gate
    component invg is
        port ( i_A      : in std_logic;
               o_F      : out std_logic 
             );
    end component;


-- Start building the circuit
begin
    -- component port => signal or port

    -- notW = ~W
    g_not : invg
    port map (
               i_A    => i_S,
               o_F    => wire0
             );
             
    -- i_A & i_D0 = o_F (Wire 1)
    -- !i_S & i_D0 = wire 1
    g_and0 : andg2
    port map (
               i_A    => i_D0,
               i_B    => wire0, -- wire 0 is !i_S
               o_F    => wire1  -- wire 1 is the and for i_D0
             );

    -- i_S & i_D1
    g_and1 : andg2
    port map (
               i_A    => i_D1,
               i_B    => i_S,
               o_F    => wire2 
             );


    -- Is signal i_D0 or i_D1 getting through?
    g_or : org2
    port map (
               i_A    => wire2,
               i_B    => wire1,
               o_F    => o_O
             );

end structural;
