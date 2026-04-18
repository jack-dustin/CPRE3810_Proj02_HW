-------------------------------------------------------------------------
-- Henry Duwe
-- Jack Dustin
-- Isaiah Pridie
-- Department of Electrical and Computer Engineering
-- Iowa State University of Science and Technology
-------------------------------------------------------------------------

-- RISCV_Processor.vhd
-------------------------------------------------------------------------
-- DESCRIPTION: This file contains a skeleton of a RISCV_Processor  
-- implementation.

-- 01/29/2019 by H3::Design created.
-- 04/10/2025 by AP::Coverted to RISC-V.
-- 02/19/2026 by H3::Renamed PC and handled OVFL
-------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.RISCV_types.all;

entity RISCV_Processor is
  generic(N : integer := DATA_WIDTH);
  port(iCLK            : in std_logic;
       iRST            : in std_logic;
       iInstLd         : in std_logic;
       iInstAddr       : in std_logic_vector(N-1 downto 0);
       iInstExt        : in std_logic_vector(N-1 downto 0);
       oALUOut         : out std_logic_vector(N-1 downto 0));

end  RISCV_Processor;


architecture structure of RISCV_Processor is

  -- Required data memory signals
  signal s_DMemWr       : std_logic;
  signal s_DMemAddr     : std_logic_vector(N-1 downto 0);
  signal s_DMemData     : std_logic_vector(N-1 downto 0);
  signal s_DMemOut      : std_logic_vector(N-1 downto 0);
 
  -- Required register file signals 
  signal s_RegWr        : std_logic;
  signal s_RegWrAddr    : std_logic_vector(4 downto 0);
  signal s_RegWrData    : std_logic_vector(N-1 downto 0);

  -- Required instruction memory signals
  signal s_IMemAddr     : std_logic_vector(N-1 downto 0);
  signal s_PC           : std_logic_vector(N-1 downto 0);
  signal s_Inst         : std_logic_vector(N-1 downto 0);

  -- Required halt signal -- for simulation
  signal s_Halt         : std_logic;

  -- Required overflow signal -- for overflow exception detection
  signal s_Ovfl         : std_logic;

  -- ALU source mux select (0=rs2, 1=imm)
  signal s_ALUsrc       : std_logic;

  -- Final 4-bit ALU control word from ctrl_decoder.
  signal s_ALUctl       : std_logic_vector(3 downto 0);

  -- Write-back select
  signal s_WBsel        : wb_sel_t;

  -- Branch / jump control flags
  signal s_Branch       : std_logic;
  signal s_jal          : std_logic;
  signal s_jalr         : std_logic;

  -- Memory sign extension control
  signal s_MemSign      : std_logic;

  -- Register file outputs
  signal s_Ors1         : std_logic_vector(N-1 downto 0);
  signal s_Ors2         : std_logic_vector(N-1 downto 0);

  -- Immediate generator output
  signal s_Oext         : std_logic_vector(N-1 downto 0);

  -- Data memory read enable
  signal s_DMemRD       : std_logic;

  -- ALU signals
  signal s_ALUOut       : std_logic_vector(N-1 downto 0);
  signal s_ALUIn2       : std_logic_vector(N-1 downto 0);

  -- LUI / AUIPC bypass flags
  signal s_isLUI        : std_logic;
  signal s_isAUIPC      : std_logic;
  signal s_AUIPCOut     : std_logic_vector(N-1 downto 0);
  signal s_RS1orPC      : std_logic_vector(N-1 downto 0);   -- 32 bits hopefully


  -- Load post-processor output
  signal s_LoadOut      : std_logic_vector(31 downto 0);

  -- Branch taken flag and fetch source select
  signal s_brTaken      : std_logic;
  signal s_Fetchsrc     : std_logic_vector(1 downto 0);
  signal s_PC4          : std_logic_vector(N-1 downto 0);

  -- JALR target (ALU result with LSB cleared)
  signal s_JalrTarget   : std_logic_vector(N-1 downto 0);


  component mem is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          clk          : in std_logic;
          addr         : in std_logic_vector((ADDR_WIDTH-1) downto 0);
          data         : in std_logic_vector((DATA_WIDTH-1) downto 0);
          we           : in std_logic := '1';
          q            : out std_logic_vector((DATA_WIDTH -1) downto 0));
    end component;

  component proj1_fetch is 
  port(
    i_CLK    : in  std_logic;
    i_RST_PC : in  std_logic;
    i_imm    : in  std_logic_vector(31 downto 0);
    i_alu    : in  std_logic_vector(31 downto 0);
    c_PC_sel : in  std_logic_vector(1 downto 0);
    o_PC4    : out std_logic_vector(31 downto 0);
    o_PC     : out std_logic_vector(31 downto 0)
  );
  end component;

  component ctrl_decoder is
    generic(ADDR_WIDTH : integer;
            DATA_WIDTH : integer);
    port(
          instr     : in  std_logic_vector((DATA_WIDTH - 1) downto 0);
          reg_we    : out std_logic;
          alu_src   : out std_logic;
          mem_we    : out std_logic;
          mem_re    : out std_logic;
          wb_sel    : out wb_sel_t;
          is_branch : out std_logic;
          is_jal    : out std_logic;
          is_jalr   : out std_logic;
          is_lui    : out std_logic;
          is_auipc  : out std_logic;
          alu_ctl   : out std_logic_vector(3 downto 0)
    );
  end component;

  component addSub is
    generic (N : integer := 32);
    port (  i_Da        :   in std_logic_vector(N-1 downto 0);
            i_Db        :   in std_logic_vector(N-1 downto 0);
            nAdd_Sub    :   in std_logic;
            o_Sum       :   out std_logic_vector(N-1 downto 0);
            o_Car       :   out std_logic);
  end component;

  component reg_file is
    port(
          i_RS1   : in std_logic_vector(4 downto 0);
          i_RS2   : in std_logic_vector(4 downto 0);
          o_rs1   : out std_logic_vector(31 downto 0);
          o_rs2   : out std_logic_vector(31 downto 0);
          i_rd    : in std_logic_vector(4 downto 0);
          i_dEN   : in std_logic;
          i_RST   : in std_logic;
          i_CLK   : in std_logic;
          i_DATA  : in std_logic_vector(31 downto 0));
  end component;

  component imm_gen is
    port(
      i_instr : in  std_logic_vector(31 downto 0);
      o_imm   : out std_logic_vector(31 downto 0)
    );
  end component;

  component mux2t1_N is
    generic (N : integer);
    port(
          i_D0   : in std_logic_vector(31 downto 0);
          i_D1   : in std_logic_vector(31 downto 0);
          i_S    : in std_logic;
          o_O    : out std_logic_vector(31 downto 0));
  end component;

  component proj01_ALU is
    port(
          i_A        : in std_logic_vector((DATA_WIDTH - 1) downto 0);
          i_B        : in std_logic_vector((DATA_WIDTH - 1) downto 0);
          i_ALUctl   : in std_logic_vector(3 downto 0);
          o_ALUout   : out std_logic_vector((DATA_WIDTH - 1) downto 0);
          o_branchOut: out std_logic
    ); 
  end component;

  component andg2 is
    port(i_A : in std_logic;
         i_B : in std_logic;
         o_F : out std_logic);
  end component;

  component proj01_LOAD is
    port(
         i_memVal       : in  std_logic_vector(31 downto 0);
         c_addr_2bit    : in  std_logic_vector(1  downto 0);
         c_funct3       : in  std_logic_vector(2  downto 0);
         o_LoadOut      : out std_logic_vector(31 downto 0));
  end component;
  

begin
  s_Ovfl  <= '0';
  oALUOut <= s_ALUOut;

  s_DMemAddr <= s_ALUOut;
  s_DMemData <= s_Ors2;

  -- WFI halt detection
  -- TODO: ensure signal doesnt go high till WB stage
  s_Halt <= '1' when (iRST='0' and iInstLd='0' and
                      s_Inst(6 downto 0)  = "1110011" and
                      s_Inst(14 downto 12) = "000"    and
                      s_Inst(31 downto 20) = x"105")
            else '0';

  s_RegWrAddr <= s_Inst(11 downto 7);

  s_RegWrData <= s_Oext     when s_isLUI='1'      else
                 s_AUIPCOut when s_isAUIPC='1'     else
                 s_PC4      when s_WBsel = WB_PC4  else
                 s_LoadOut  when s_WBsel = WB_MEM  else
                 s_ALUOut;

  -- JALR target: rs1 + imm_I with with LSB cleared
  s_JalrTarget <= s_ALUOut(31 downto 1) & '0';

  -- PC source select for fetch unit: TODO: may need to move into control decoder
  --   bit 1: JALR (register-indirect target via ALU)
  --   bit 0: any non-sequential update (JAL, JALR, or taken branch)
  -- claculated outside of control decoder since it depends on branch taken flag from ALU
  s_Fetchsrc(1) <= s_jalr;
  s_Fetchsrc(0) <= s_jal or s_jalr or (s_Branch and s_brTaken);

  with iInstLd select
    s_IMemAddr <= s_PC      when '0',
                  iInstAddr when others;


  IMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_IMemAddr(11 downto 2),
             data => iInstExt,
             we   => iInstLd,
             q    => s_Inst);
  
  DMem: mem
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(clk  => iCLK,
             addr => s_DMemAddr(11 downto 2),
             data => s_DMemData,
             we   => s_DMemWr,
             q    => s_DMemOut);

  IFetch: proj1_fetch
  port map(
    i_CLK    => iCLK,
    i_RST_PC => iRST,
    i_imm    => s_Oext,
    i_alu    => s_JalrTarget,
    c_PC_sel => s_Fetchsrc,
    o_PC     => s_PC,
    o_PC4    => s_PC4);

  CDec: ctrl_decoder
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(
              instr     => s_Inst,
              reg_we    => s_RegWr,
              alu_src   => s_ALUsrc,
              mem_we    => s_DMemWr,
              mem_re    => s_DMemRD,
              wb_sel    => s_WBsel,
              is_branch => s_Branch,
              is_jal    => s_jal,
              is_jalr   => s_jalr,
              is_lui    => s_isLUI,
              is_auipc  => s_isAUIPC,
              alu_ctl   => s_ALUctl
             );

  Rfile: reg_file
    port map(
              i_RS1   => s_Inst(19 downto 15),
              i_RS2   => s_Inst(24 downto 20),
              o_rs1   => s_Ors1,
              o_rs2   => s_Ors2,
              i_rd    => s_RegWrAddr,
              i_dEN   => s_RegWr,
              i_RST   => iRST,
              i_CLK   => iCLK,
              i_DATA  => s_RegWrData
             );
  
  Imm0: imm_gen
  port map(
    i_instr => s_Inst,
    o_imm   => s_Oext
  );

  AUIPC_ADD: addSub
  port map(
    i_Da     => s_PC,
    i_Db     => s_Oext,
    nAdd_Sub => '0',
    o_Sum    => s_AUIPCOut,
    o_Car    => open
  );

  Mux_ALUSrc: mux2t1_N
  generic map(N => N)
  port map(
    i_D0 => s_Ors2,
    i_D1 => s_Oext,
    i_S  => s_ALUsrc,
    o_O  => s_ALUIn2
  );

  Mux_PC_or_RS1: mux2t1_N
  generic map(N => N)
  port map(
    i_D0 => s_Ors1,         -- Default of using RS1
    i_D1 => s_PC,           -- Othewise use PC Output val
    i_S  => s_isAUIPC,      -- Flag for auipc
    o_O  => s_RS1orPC);     -- Output to Input A of ALU

  ALU0: proj01_ALU
  port map(
    i_A         => s_RS1orPC,
    i_B         => s_ALUIn2,
    i_ALUctl    => s_ALUctl,
    o_ALUout    => s_ALUOut,
    o_branchOut => s_brTaken);

  LOAD0: proj01_LOAD
    port map(
      i_memVal    => s_DMemOut,
      c_addr_2bit => s_ALUOut(1 downto 0),
      c_funct3    => s_Inst(14 downto 12),
      o_LoadOut   => s_LoadOut
    );

end structure;