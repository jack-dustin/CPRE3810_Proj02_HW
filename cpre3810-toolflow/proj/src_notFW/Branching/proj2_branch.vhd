-- Isaiah Pridie
-- Proj02_Branching unit.   PUT THIS IN DECODE STAGE
-- Start Date: 4.12.2026,   6:45 PM

library IEEE;
use IEEE.std_logic_1164.all;

entity proj2_branch is port(
    i_A         : in  std_logic_vector(31 downto 0);
    i_B         : in  std_logic_vector(31 downto 0);
    c_funct3    : in  std_logic_vector(2  downto 0);
    o_out       : out std_logic);
end entity;

architecture mixed of proj2_branch is

    signal s_bltu       : std_logic;
    signal s_beq        : std_logic;
    signal s_bgu        : std_logic;

    signal s_bgeu       : std_logic;
    signal s_bne        : std_logic;

    signal s_blt        : std_logic;    -- signed
    signal s_bge        : std_logic;    -- signed

    signal s_bge_Fout   : std_logic;    -- Signed or Unsigned - Final Output
    signal s_blt_Fout   : std_logic;    -- Signed or Unsigned - Final Output

    component proj2_blt is
        generic(N : integer := 32);
        port(i_A        : in  std_logic_vector(N-1 downto 0);
             i_B        : in  std_logic_vector(N-1 downto 0);
             o_beqOut   : out std_logic;
             o_bltuOut  : out std_logic;
             o_bguOut   : out std_logic);
    end component;

    component mux2t1 is 
    port (  i_D0    : in std_logic;
            i_D1    : in std_logic;
            i_S     : in std_logic;
            o_O     : out std_logic);
    end component;

    component mux4t1 is
        port(i_Da   : in  std_logic;
             i_Db   : in  std_logic;
             i_Dc   : in  std_logic;
             i_Dd   : in  std_logic;
             c_sel1 : in  std_logic;
             c_sel2 : in  std_logic;
             o_out  : out std_logic);
    end component;

    component org2 is
        port(i_A          : in std_logic;
             i_B          : in std_logic;
             o_F          : out std_logic);
    end component;

    component invg is
        port(i_A          : in std_logic;
             o_F          : out std_logic);
    end component;

begin

    INST_BLT: proj2_blt 
    generic map (N => 32)
    port map(i_A       => i_A,
             i_B       => i_B,
             o_beqOut  => s_beq,
             o_bltuOut => s_bltu,
             o_bguOut  => s_bgu);

    INST_BGEU_OR: org2 port map(
        i_A => s_bgu,
        i_B => s_beq,
        o_F => s_bgeu);

    INST_BNE_INV: invg port map(
        i_A => s_beq,
        o_F => s_bne);

    -- Getting blt:
      -- -A < +B  --> True   |   +A < -B  --> False
      -- Both have the same sign, then bltu = blt
        -- [A * not(B)] or [not(A xor B)]
    s_blt   <= (i_A(31) and (not i_B(31))) or ((not (i_A(31) xor i_B(31))) and s_bltu);
    s_bge   <= not s_blt;
    

    INST_BLT_Sine_Unsine: mux2t1 port map(
        i_D0 => s_blt,
        i_D1 => s_bltu,
        i_S  => c_funct3(1),
        o_O  => s_blt_Fout);

    INST_BGE_Sine_Unsine: mux2t1 port map(
        i_D0 => s_bge,
        i_D1 => s_bgeu,
        i_S  => c_funct3(1),
        o_O  => s_bge_Fout);

    ISNT_OUTPUT_MUX: mux4t1 port map(
        i_Da   => s_beq,
        i_Db   => s_bne,
        i_Dc   => s_blt_Fout,
        i_Dd   => s_bge_Fout,
        c_sel1 => c_funct3(0),
        c_sel2 => c_funct3(2),
        o_out  => o_out);

end architecture;