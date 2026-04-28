-- Isaiah Pridie
-- CprE 3810 proj01 tb_ALU
-- Start Date: 3.19.2026,    5:31 PM

-- Forgot naming conventions for a hot minute
-- Make a large 32 bit and tree for BEQ and BNE instructions
-- Trying to use generate statements turned out a lot more complicated than I thought...
    -- Get result. Output as vector. Split vector into two smaller vectors
    -- Pass smaller vectors to and gate ports. 
    -- Do this until we get to 1 bit output
       
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- A, B --> XNOR --> AND tree

-- XNOR truth table:
-- A B | XOR | XNOR
-- 0 0 |  0  |  1
-- 0 1 |  1  |  0
-- 1 0 |  1  |  0
-- 1 1 |  0  |  1
-- XNOR is a 1 when A and B are equal. Do this for every bit and AND them

entity proj01_BEQ is
    generic (N: natural := 32);  
    port(i_Da   : in  std_logic_vector(31 downto 0);
         i_Db   : in  std_logic_vector(31 downto 0);
         o_out  : out std_logic);
end entity;

architecture structural of proj01_BEQ is

    signal xor_to_not     : std_logic_vector(31 downto 0);
    signal not_to_and16   : std_logic_vector(31 downto 0);  -- 16 AND gates
        signal and16_A    : std_logic_vector(15 downto 0);
        signal and16_B    : std_logic_vector(15 downto 0);
    signal and16_to_and8  : std_logic_vector(15 downto 0);  -- 8 AND gates
        signal and8_A     : std_logic_vector(7  downto 0);
        signal and8_B     : std_logic_vector(7  downto 0);
    signal and8_to_and4   : std_logic_vector(7  downto 0);  -- 4 AND gates
        signal and4_A     : std_logic_vector(3  downto 0);
        signal and4_B     : std_logic_vector(3  downto 0);
    signal and4_to_and2   : std_logic_vector(3  downto 0);  -- 2 AND gates
        signal and2_A     : std_logic_vector(1  downto 0);
        signal and2_B     : std_logic_vector(1  downto 0);
    signal and2_to_and1   : std_logic_vector(1  downto 0);  -- 1 AND gate
        signal and1_A     : std_logic;  
        signal and1_B     : std_logic; 

    component xor_ALU is
        generic(N : natural := 32); -- Make this file flexible because why not
        port(i_xDA  : in  std_logic_vector(N-1 downto 0);
             i_xDB  : in  std_logic_vector(N-1 downto 0);
             o_xDo  : out std_logic_Vector(N-1 downto 0));
    end component;

    component ones_comp_N is
        generic (N : natural := 32);
        port(i_OC    : in std_logic_vector(N-1 downto 0);
             o_O     : out std_logic_vector(N-1 downto 0));
    end component;

    component and_N is
        generic (N : natural := 32);
        port(i_A    : in std_logic_vector(N-1 downto 0);
             i_B    : in std_logic_vector(N-1 downto 0);
             o_F    : out std_logic_vector(N-1 downto 0) );
    end component;

    component andg2 is
        port(i_A        : in std_logic;
             i_B        : in std_logic;
             o_F        : out std_logic);
end component;

begin

    INST_32_XOR: xor_ALU 
    generic map (N => 32)
    port map(i_xDA  => i_Da,
             i_xDB  => i_Db,
             o_xDo  => xor_to_not);

    INST_32_NOT: ones_comp_N
    generic map (N => 32)
    port map(i_OC   => xor_to_not,
             o_O    => not_to_and16);

    and16_A(0)    <= not_to_and16(0);     
    and16_B(0)    <= not_to_and16(1);     
    and16_A(1)    <= not_to_and16(2);     
    and16_B(1)    <= not_to_and16(3);     
    and16_A(2)    <= not_to_and16(4);     
    and16_B(2)    <= not_to_and16(5);     
    and16_A(3)    <= not_to_and16(6);     
    and16_B(3)    <= not_to_and16(7);   
    and16_A(4)    <= not_to_and16(8);     
    and16_B(4)    <= not_to_and16(9);     
    and16_A(5)    <= not_to_and16(10);     
    and16_B(5)    <= not_to_and16(11);     
    and16_A(6)    <= not_to_and16(12);     
    and16_B(6)    <= not_to_and16(13);     
    and16_A(7)    <= not_to_and16(14);     
    and16_B(7)    <= not_to_and16(15);     
    and16_A(8)    <= not_to_and16(16);     
    and16_B(8)    <= not_to_and16(17);     
    and16_A(9)    <= not_to_and16(18);     
    and16_B(9)    <= not_to_and16(19);     
    and16_A(10)   <= not_to_and16(20);     
    and16_B(10)   <= not_to_and16(21);     
    and16_A(11)   <= not_to_and16(22);     
    and16_B(11)   <= not_to_and16(23);   
    and16_A(12)   <= not_to_and16(24);     
    and16_B(12)   <= not_to_and16(25);     
    and16_A(13)   <= not_to_and16(26);     
    and16_B(13)   <= not_to_and16(27);     
    and16_A(14)   <= not_to_and16(28);     
    and16_B(14)   <= not_to_and16(29);     
    and16_A(15)   <= not_to_and16(30);     
    and16_B(15)   <= not_to_and16(31);  

    INST_AND_16: and_N
    generic map (N => 16)
    port map(i_A    => and16_A,        
             i_B    => and16_B,
             o_F    => and16_to_and8);

    and8_A(0)   <= and16_to_and8(0);     
    and8_B(0)   <= and16_to_and8(1);     
    and8_A(1)   <= and16_to_and8(2);     
    and8_B(1)   <= and16_to_and8(3);     
    and8_A(2)   <= and16_to_and8(4);     
    and8_B(2)   <= and16_to_and8(5);     
    and8_A(3)   <= and16_to_and8(6);     
    and8_B(3)   <= and16_to_and8(7);   
    and8_A(4)   <= and16_to_and8(8);     
    and8_B(4)   <= and16_to_and8(9);     
    and8_A(5)   <= and16_to_and8(10);     
    and8_B(5)   <= and16_to_and8(11);     
    and8_A(6)   <= and16_to_and8(12);     
    and8_B(6)   <= and16_to_and8(13);     
    and8_A(7)   <= and16_to_and8(14);     
    and8_B(7)   <= and16_to_and8(15);     

    INST_AND_8: and_N
    generic map (N => 8)
    port map(i_A    => and8_A,  
             i_B    => and8_B, 
             o_F    => and8_to_and4);

    and4_A(0)   <= and8_to_and4(0);     
    and4_B(0)   <= and8_to_and4(1);     
    and4_A(1)   <= and8_to_and4(2);     
    and4_B(1)   <= and8_to_and4(3);     
    and4_A(2)   <= and8_to_and4(4);     
    and4_B(2)   <= and8_to_and4(5);     
    and4_A(3)   <= and8_to_and4(6);     
    and4_B(3)   <= and8_to_and4(7);     

    INST_AND_4: and_N
    generic map (N => 4)
    port map(i_A    => and4_A, 
             i_B    => and4_B,
             o_F    => and4_to_and2);

    and2_A(0)   <= and4_to_and2(0);     -- 0
    and2_B(0)   <= and4_to_and2(1);     -- 1
    and2_A(1)   <= and4_to_and2(2);     -- 2
    and2_B(1)   <= and4_to_and2(3);     -- 3
    
    INST_AND_2: and_N
    generic map (N => 2)
    port map(i_A    => and2_A,
             i_B    => and2_B,
             o_F    => and2_to_and1);

    and1_A      <= and2_to_and1(0);     -- 0
    and1_B      <= and2_to_and1(1);     -- 1

    INST_AND_1: andg2   -- N => 1
    port map(i_A    => and1_A,
             i_B    => and1_B,
             o_F    => o_out);

end architecture;