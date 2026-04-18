-- Isaiah Pridie
-- CprE 381 project01 - OR Logic for ALU
-- 3.8.2026,    1:25 AM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity proj01_ALU is
    port(i_A        : in  std_logic_vector(31 downto 0);    -- RS1
         i_B        : in  std_logic_Vector(31 downto 0);    -- RS2 or IMM
         i_ALUctl   : in  std_logic_vector(3 downto 0);     -- All control signals we are supposed to need
            -- LeftMost bit of o_alu_op from Excel is (3)
            -- i_ALUctl(3) = funct3(1)      -- Used for mux, 
            -- i_ALUctl(2) = funct3(2)      -- Used for mux, Shift direction
            -- i_ALUctl(1) = funct3(0)      -- Used for mux
            -- i_ALUctl(0) = funct7(5)      -- Used for nAddSub*, Shift s_sex
         o_ALUout   : out std_logic_Vector(31 downto 0);
         o_branchOut: out std_logic
            );
end entity;

architecture structural of proj01_ALU is

    -- Establish Signals/Wires/Constants
    signal s_funct3_fix : std_logic_vector(2  downto 0);

    signal s_andOUT     : std_logic_vector(31 downto 0);
    signal s_xorOUT     : std_logic_vector(31 downto 0);
    signal s_orOUT      : std_logic_vector(31 downto 0);
    signal s_shiftOUT   : std_logic_vector(31 downto 0);    -- Used for SHIFT Left and Right
    signal s_AddSubOUT  : std_logic_vector(31 downto 0);
    signal s_sltOUT     : std_logic_vector(31 downto 0);
    signal s_sltuOUT    : std_logic_vector(31 downto 0);

    signal s_NOR_t_mux  : std_logic_vector(31 downto 0);
    signal s_ORm_t_Fm   : std_logic_vector(31 downto 0);    -- OR/NOR mux to Final mux

    signal s_nAddSub_nTa: std_logic;    -- From NOT gate to AND gate
    signal s_nAddSub_aTo1: std_logic;   -- From AND gate to OR gate 1
    signal s_nAddSub_aTo2: std_logic;   -- From OR gate1 to OR gate2
    signal sc_nAddSub   : std_logic;    -- Used to drive nAddSub control
    signal s_MSB_Cin    : std_logic;    -- Carries carry-in to MSB
    signal s_MSB_Cout   : std_logic;    -- Carries carry-out of MSB

    signal s_Mux_0t2    : std_logic_vector(31 downto 0);
    signal s_Mux_1t2    : std_logic_vector(31 downto 0);

    -- Components:
    component invg is
        port(i_A          : in  std_logic;
             o_F          : out std_logic);
    end component;

    component andg2 is
        port(i_A          : in  std_logic;
             i_B          : in  std_logic;
             o_F          : out std_logic);
    end component;

    component org2 is
        port(i_A          : in  std_logic;
             i_B          : in  std_logic;
             o_F          : out std_logic);
    end component;

    component and_ALU is
        generic(N : natural := 32); -- Make this file flexible because why not
        port(i_aDA  : in  std_logic_vector(N-1 downto 0);
             i_aDB  : in  std_logic_vector(N-1 downto 0);
             o_aDo  : out std_logic_Vector(N-1 downto 0));
    end component;
    
    component xor_ALU is
        generic(N : natural := 32); -- Make this file flexible because why not
        port(i_xDA  : in  std_logic_vector(N-1 downto 0);
             i_xDB  : in  std_logic_vector(N-1 downto 0);
             o_xDo  : out std_logic_Vector(N-1 downto 0));
    end component;

    component or_ALU is
        generic(N : natural := 32); -- Make this file flexible because why not
        port(i_oDA  : in  std_logic_vector(N-1 downto 0);
             i_oDB  : in  std_logic_vector(N-1 downto 0);
             o_oDo  : out std_logic_Vector(N-1 downto 0));
    end component;

    component shifter is
        port(i_vect_A   : in  std_logic_vector(31 downto 0);     -- Input A (RS1)
             i_vect_B   : in  std_logic_vector(31 downto 0);     -- Input B (RS2 or Imm)
             c_extend   : in  std_logic;     -- Controls Zero or Sign extending | funct7(5)
             c_Shift    : in  std_logic;     -- Controls shifting Left or Right | funct3(2)
             o_vect_Out : out std_logic_vector(31 downto 0) );
    end component;

    component addSub_BRANCH is
        generic (N : integer := 32);        -- use 32 for now. Value not specified in Lab Doc
        port(i_Da       : in  std_logic_vector(N-1 downto 0);
             i_Db       : in  std_logic_vector(N-1 downto 0);
             nAdd_Sub   : in  std_logic;    -- used as control/carry
             o_Sum      : out std_logic_vector(N-1 downto 0);
             o_MSB_Cin  : out std_logic;
             o_Car      : out std_logic);   -- used for last carry output
    end component;

    component proj01_SLT is
        port(i_MSB      : in  std_logic;
             i_MSB_Cin  : in  std_logic;
             i_MSB_Cout : in  std_logic;
             o_slt      : out std_logic_vector(31 downto 0);    -- SLT output
             o_sltu     : out std_logic_vector(31 downto 0));    -- SLTu output
    end component;

    component ones_comp_N is        -- Used for NOR
        generic (N : natural := 32);
        port(i_OC    : in std_logic_vector(N-1 downto 0);
             o_O     : out std_logic_vector(N-1 downto 0));
    end component;

    component busMux_2t1 is
        port(i_dZero  : in std_logic_vector(31 downto 0);
             i_dOne   : in std_logic_vector(31 downto 0);
             ALUSrc   : in std_logic; -- select line
             o_dOUT   : out std_logic_vector(31 downto 0));
    end component;

    component busMux_8t1 is
        port(i_D0   : in  std_logic_vector(31 downto 0);
             i_D1   : in  std_logic_vector(31 downto 0);
             i_D2   : in  std_logic_vector(31 downto 0);
             i_D3   : in  std_logic_vector(31 downto 0);
             i_D4   : in  std_logic_vector(31 downto 0);
             i_D5   : in  std_logic_vector(31 downto 0);
             i_D6   : in  std_logic_vector(31 downto 0);
             i_D7   : in  std_logic_vector(31 downto 0);
             c_sel0 : in  std_logic;
             c_sel1 : in  std_logic;
             c_sel2 : in  std_logic;
             o_Dout : out std_logic_vector(31 downto 0));
    end component;
    
    component proj01_branchWrap is
        port(i_Da       : in  std_logic_vector(31 downto 0);    -- For BEQ
             i_Db       : in  std_logic_vector(31 downto 0);    -- For BEQ
             i_slt      : in  std_logic_vector(31 downto 0);    -- Needs vector because slt/sltu is 32 bit vector signal in ALU
             i_sltu     : in  std_logic_vector(31 downto 0);
             c_funct3   : in  std_logic_vector(2  downto 0);
             o_out      : out std_logic);
    end component;

begin

    -- funct3(2), funct3(1), funct3(0);
    s_funct3_fix    <= i_ALUctl(2) & i_ALUctl(3) & i_ALUctl(1); 

    ------ INSTANTIATE LOGIC FOR nAddSub ------
    -- funct7(5) OR [~funct3(2) AND funct3(1)] or funct3(2)
    -- [~funct3(2) AND funct3(1)] is for slt
    -- funct3(2) is for branching (need slt result)
    INST_NOT_SUB_Ctrl: invg port map(
        i_A => i_ALUctl(2),
        o_F => s_nAddSub_nTa);

    INST_AND_SUB_Ctrl: andg2 port map(
        i_A => s_nAddSub_nTa,
        i_B => i_ALUctl(3),
        o_F => s_nAddSub_aTo1);

    INST_OR_SUB_Ctrl_1: org2 port map(
        i_A => s_nAddSub_aTo1,
        i_B => i_ALUctl(0),
        o_F => s_nAddSub_aTo2);

    INST_OR_SUB_Ctrl_2: org2 port map(
        i_A => s_nAddSub_aTo2,
        i_B => i_ALUctl(2),
        o_F => sc_nAddSub);
    -------------------------------------------

    -- Instantiate AND ALU fucntionality
    INST_AND: and_ALU port map(
        i_aDA   => i_A,
        i_aDB   => i_B,
        o_aDo   => s_andOUT);

    -- Instantiate XOR ALU functionality
    INST_XOR: xor_ALU port map(
        i_xDA   => i_A,
        i_xDB   => i_B,
        o_xDo   => s_xorOUT);

    -- Instantiate OR ALU functionality
    INST_OR: or_ALU port map(
        i_oDA   => i_A,
        i_oDB   => i_B,
        o_oDo   => s_orOUT);

    -- Instantiate NOR functionality
    INST_INV_OR: ones_comp_N port map(
        i_OC    => s_orOUT,
        o_O     => s_NOR_t_mux);
    
    INST_NOR_MUX: busMux_2t1 port map(
        i_dZero     => s_orOUT,
        i_dOne      => s_NOR_t_mux,
        ALUSrc      => i_ALUctl(0),
        o_dOUT      => s_ORm_t_Fm);

    -- Instantiate shifting ALU functionality
    INST_SHIFT: Shifter port map(
        i_vect_A    => i_A,
        i_vect_B    => i_B,
        c_extend    => i_ALUctl(0),     -- funct7(5)    When 1 sign extend, else zero extend
        c_Shift     => i_ALUctl(2),     -- funct3(2)    When 1 continue, else reverse bit order
        o_vect_Out  => s_shiftOUT);

    -- Instantiate Add/Sub ALU functionality
    INST_ADDSUB: addSub_BRANCH port map(
        i_Da        => i_A,
        i_Db        => i_B,
        nAdd_Sub    => sc_nAddSub,     -- funct7(5) OR [~funct3(2) AND funct3(1)]
        o_Sum       => s_AddSubOUT,     -- Sum is output vector
        o_MSB_Cin   => s_MSB_Cin,
        o_Car       => s_MSB_Cout);

    INST_SLT: proj01_SLT port map(
        i_MSB       => s_AddSubOUT(31), 
        i_MSB_Cin   => s_MSB_Cin, 
        i_MSB_Cout  => s_MSB_Cout,
        o_slt       => s_sltOUT, 
        o_sltu      => s_sltuOUT);

    -- 2x [4t1 Mux]  ->  1x [2t1 mux]  ->  output
        -- Da0  000  Add/Sub
        -- Db0  001  Shift (Left)
        -- Dc0  010  sltn
        -- Dd0  011  sltnu
        -- Da1  100  XORn
        -- Db1  101  Shift (Right)
        -- Dc1  110  ORn
        -- Dd1  111  ANDn

    -- LeftMost bit of o_alu_op from Excel is (3)
        -- i_ALUctl(3) = funct3(1)      -- Used for mux, 
        -- i_ALUctl(2) = funct3(2)      -- Used for mux, Shift direction
        -- i_ALUctl(1) = funct3(0)      -- Used for mux
        -- i_ALUctl(0) = funct7(5)      -- Used for nAddSub*, Shift s_ex
    
    INST_BUSMUX_8t1: busMux_8t1 port map(
        i_D0    => s_AddSubOUT,     -- AddSub 
        i_D1    => s_shiftOUT,      -- Left Shift 
        i_D2    => s_sltOUT,        -- SLT
        i_D3    => s_sltuOUT,       -- SLTU
        i_D4    => s_xorOUT,        -- XOR
        i_D5    => s_shiftOUT,      -- Right Shift
        i_D6    => s_ORm_t_Fm,      -- OR / NOR 
        i_D7    => s_andOUT,        -- AND
        c_sel0  => i_ALUctl(1),     -- funct3(0)
        c_sel1  => i_ALUctl(3),     -- funct3(1)
        c_sel2  => i_ALUctl(2),     -- fucnt3(2)
        o_Dout  => o_ALUout);       -- Final Mux Output

    -- BRANCHING
    INST_BRANCH_WRAPPER: proj01_branchWrap port map(
        i_Da        => i_A,
        i_Db        => i_B,
        i_slt       => s_sltOUT,
        i_sltu      => s_sltuOUT,
        c_funct3    => s_funct3_fix,
        o_out       => o_branchOut);

end architecture;
