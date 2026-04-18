-- Isaiah Pridie
-- CprE 3810 Lab1 Part 3.6b
-- Start Date: 2.4.2026 3:59 AM


library IEEE;
use IEEE.std_logic_1164.all;


entity basic_adder is
    port (
        i_aB0   : in std_logic;     -- adder Bit 0
        i_aB1   : in std_logic;     -- adder Bit 1
        i_C     : in std_logic;
        o_C     : out std_logic;
        o_S     : out std_logic );
end basic_adder;

architecture structural of basic_adder is
    
    -- wires
    signal w0   : std_logic;
    signal w1   : std_logic;
    signal w2   : std_logic;
    signal w3   : std_logic;
    -- Note to self: May need more or less wires

    -- component: "I plan to use a circuit shaped like this"
    -- Does NOT create working hardware by itself

    -- AND gate
    component andg2 is
        port (  i_A     : in std_logic;
                i_B     : in std_logic;
                o_F     : out std_logic );
    end component;

    -- OR gate
    component org2 is
        port (  i_A     : in std_logic;
                i_B     : in std_logic;
                o_F     : out std_logic );
    end component;

    -- XOR gate
    component xorg2 is
        port(   i_A     : in std_logic;
                i_B     : in std_logic;
                o_F     : out std_logic );
    end component;

-- Start building actual circuit
begin
    -- component port => signal/wire or port

    -- A and B
    g_and0 : andg2
    port map (  i_A     =>  i_aB0,
                i_B     =>  i_aB1,
                o_F     =>  w0  );  -- w0 holds A * B

    -- A ⊕ B    (xor)
    g_xor0 : xorg2
    port map (  i_A     =>  i_aB0,
                i_B     =>  i_aB1,
                o_F     =>  w1  );  -- w1 holds A ⊕ B

    -- (A ⊕ B) * C
    g_and1 : andg2
    port map (  i_A     =>  w1,  -- A ⊕ B
                i_B     =>  i_C,  -- input Carry
                o_F     =>  w2  );  -- w2 holds (A ⊕ B) * C

    -- CARRY BIT
    -- [A * B] + [(A ⊕ B) * C]
    g_or0 : org2
    port map (  i_A     =>  w0, -- A * B
                i_B     =>  w2, -- (A ⊕ B) * C
                o_F     =>  o_C );  -- Carry Out Bit

    -- SUM BIT
    -- (A ⊕ B) ⊕ C
    g_xor1 : xorg2
    port map (  i_A     => w1,  -- A ⊕ B
                i_B     => i_C, -- Input Carry bit
                o_F     => o_S  );  -- Output Sum But

end structural;