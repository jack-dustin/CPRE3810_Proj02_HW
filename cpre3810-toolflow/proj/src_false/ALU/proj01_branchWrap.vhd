-- Isaiah Pridie
-- CprE 3810    wrapper/component for branching logic
-- Start Date:  3.19.2026,  8:50 PM

-- Need to implement:
    -- BEQ
    -- BNE  (~BEQ)
    -- BLT / BLTU   ( )
    -- BGE / BGEU   (~SLT / ~SLTU)

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity proj01_branchWrap is
    port(i_Da       : in  std_logic_vector(31 downto 0);    -- For BEQ
         i_Db       : in  std_logic_vector(31 downto 0);    -- For BEQ
         i_slt      : in  std_logic_vector(31 downto 0);    -- Needs vector because slt/sltu is 32 bit vector signal in ALU
         i_sltu     : in  std_logic_vector(31 downto 0);
         c_funct3   : in  std_logic_vector(2  downto 0);
         o_out      : out std_logic);
end entity;

architecture structural of proj01_branchWrap is

    signal s_slt_res    : std_logic;
    signal s_sltu_res   : std_logic;
    signal s_bge_res    : std_Logic;
    signal s_bgeu_res   : std_logic;

    signal s_beq_t_mux  : std_logic;
    signal s_bne_t_mux  : std_logic;
    signal s_blt_t_mux  : std_logic;
    signal s_bge_t_mux  : std_logic;
    
    signal s_mux_0t2    : std_logic;
    signal s_mux_1t2    : std_logic;

    component proj01_BEQ is
        port(i_Da   : in  std_logic_vector(31 downto 0);
             i_Db   : in  std_logic_vector(31 downto 0);
             o_out  : out std_logic);
    end component;

    component invg is       -- For BNE, BGE, and BGEU
        port(i_A          : in std_logic;
             o_F          : out std_logic);
    end component;

    component mux2t1 is 
        port(i_D0   : in std_logic;
             i_D1   : in std_logic;
             i_S    : in std_logic;
             o_O    : out std_logic);
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

begin

    -- Grab the actual result(s) or slt and sltu
    s_slt_res   <= i_slt(0);
    s_sltu_res  <= i_sltu(0);

    INST_BEQ: proj01_BEQ port map(
        i_Da    => i_Da,
        i_Db    => i_Db,
        o_out   => s_beq_t_mux);

    INST_BNE: invg port map(
        i_A   => s_beq_t_mux,
        o_F   => s_bne_t_mux);

    INST_BGE: invg port map(
        i_A   => s_slt_res,
        o_F   => s_bge_res);

    INST_BGEU: invg port map(
        i_A   => s_sltu_res,
        o_F   => s_bgeu_res);

    INST_MUX_BLT_U: mux2t1 port map(
        i_D0    => s_slt_res,
        i_D1    => s_sltu_res,
        i_S     => c_funct3(1),
        o_O     => s_blt_t_mux);

    INST_MUX_BGE_U: mux2t1 port map(
        i_D0    => s_bge_res,
        i_D1    => s_bgeu_res,
        i_S     => c_funct3(1),
        o_O     => s_bge_t_mux);

    INST_MUX_4t1: mux4t1 port map(
        i_Da    => s_beq_t_mux,
        i_Db    => s_bne_t_mux,
        i_Dc    => s_blt_t_mux,
        i_Dd    => s_bge_t_mux,
        c_sel1  => c_funct3(0),
        c_sel2  => c_funct3(2),
        o_out   => o_out);

end architecture;