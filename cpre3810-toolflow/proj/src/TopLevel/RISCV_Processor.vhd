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
  signal s_ALUctl_OverRide  : std_logic_vector(3 downto 0); -- actually gets passed to the ALU

  -- Write-back select
  signal s_WBsel        : std_logic;

  -- Branch / jump control flags
  signal s_Branch       : std_logic;
  signal s_jal          : std_logic;
  signal s_jalr         : std_logic;

  -- Memory sign extension control
  --signal s_MemSign      : std_logic;

  -- Register file outputs
  signal s_Ors1         : std_logic_vector(N-1 downto 0);
  signal s_Ors2         : std_logic_vector(N-1 downto 0);

  -- Immediate generator output
  signal s_Oext         : std_logic_vector(N-1 downto 0);
  signal s_Oext_Dec_to_Fetch  : std_logic_vector(N-1 downto 0);   -- Need this because the immediate needs to be added to the stage's PC value, not the new PC value

  -- Data memory read enable
  signal s_DMemRD       : std_logic;

  -- ALU signals
  signal s_ALUOut       : std_logic_vector(N-1 downto 0);
  signal s_ALUIn2       : std_logic_vector(N-1 downto 0);
  signal s_RS1orPC      : std_logic_vector(N-1 downto 0);

  -- LUI / AUIPC bypass flags
  signal s_isLUI        : std_logic;
  signal s_isAUIPC      : std_logic;
  --signal s_AUIPCOut     : std_logic_vector(N-1 downto 0);  -- Load post-processor output
  signal s_LoadOut      : std_logic_vector(31 downto 0);

  -- Branch taken flag and fetch source select
  --signal s_brTaken      : std_logic;
  signal s_Fetchsrc     : std_logic_vector(1 downto 0);
  signal s_PC4          : std_logic_vector(N-1 downto 0);

  -- JALR target (ALU result with LSB cleared)
  signal s_JalrTarget   : std_logic_vector(N-1 downto 0);

  signal s_all_but_halt_decode : std_logic_vector(95 downto 0);
  signal s_all_but_halt_execute : std_logic_vector(179 downto 0);
  signal s_HaltDecoded : std_logic;



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
    i_WE     : in  std_logic;
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
          wb_sel    : out std_logic;
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

  component busMux_4t1 is 
        port(i_Da   : in  std_logic_vector(31 downto 0);    -- Input 1
             i_Db   : in  std_logic_vector(31 downto 0);    -- Input 2
             i_Dc   : in  std_logic_vector(31 downto 0);    -- Input 3
             i_Dd   : in  std_logic_vector(31 downto 0);    -- Input 4
             C_S0   : in  std_logic;                        -- Sel line 0
             C_S1   : in  std_logic;                        -- Sel line 1
             o_Do   : out std_logic_vector(31 downto 0) );  -- Output
    end component;

  component proj02_ALU is
    port(
          i_A        : in std_logic_vector((DATA_WIDTH - 1) downto 0);
          i_B        : in std_logic_vector((DATA_WIDTH - 1) downto 0);
          i_ALUctl   : in std_logic_vector(3 downto 0);
          o_ALUout   : out std_logic_vector((DATA_WIDTH - 1) downto 0)
          -- o_branchOut: out std_logic
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


  -- Control Hazards
  component ctrlHaz is
    port(
      -- ID-stage branch info
        i_IDBranch      : in  std_logic;  -- 1 when instruction in ID is a branch
        i_IDBranchTaken : in  std_logic;  -- 1 when that branch is taken

        -- EX-stage jump info
        i_EXJump        : in  std_logic;  -- 1 when instruction in EX causes non-sequential PC update (jal/jalr)

        -- Hazard outputs
        o_CtrlHaz       : out std_logic;
        o_IFIDFlush     : out std_logic;
        o_IDEXFlush     : out std_logic;
        o_PCStall       : out std_logic;
        o_IFIDStall     : out std_logic
    );
  end component;
  
  signal s_CtrlHaz    : std_logic;
  signal s_IFIDFlush  : std_logic;
  signal s_IDEXFlush  : std_logic;
  signal s_PCStall    : std_logic;
  signal s_IFIDStall  : std_logic;

    signal s_FtD_Reg_In : std_logic_vector(96 downto 0);
  signal s_DtE_Reg_In : std_logic_vector(180 downto 0);
    
  component proj2_branch is 
  port( 
    i_A         : in  std_logic_vector(31 downto 0);
    i_B         : in  std_logic_vector(31 downto 0);
    c_funct3    : in  std_logic_vector(2  downto 0);
    o_out       : out std_logic);
  end component;

  -- Pipeline Register Signals
  component FetchDecode_Reg is
    generic (N : integer := 96);   -- 96 bit register
    port (i_CLK   : in std_logic;                          -- Clock input
          i_RST   : in std_logic;                          -- Reset input
          i_FLUSH : in std_logic;
          i_WE    : in std_logic;                          -- Write enable input
          i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
          o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
  end component;

  signal s_FtD_Reg      : std_logic_vector(96 downto 0);  -- 96 bit output
  signal s_branch_from_decode : std_logic;


  component DecodeExecute_Reg is
    generic (N : integer := 180);   -- 180 bit register
    port (i_CLK   : in std_logic;                          -- Clock input
          i_RST   : in std_logic;                          -- Reset input
          i_FLUSH : in std_logic;
          i_WE    : in std_logic;                          -- Write enable input
          i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
          o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
  end component;

  signal s_DtE_Reg      : std_logic_vector(180 downto 0); -- 181 bit output
  signal s_ForceAddSub  : std_logic;  -- Signal to pass through processor to ALU - Forces Add/Sub output from ALU
  --signal s_Ex_WB        : std_logic;  -- For now use this instead of s_WBsel
  signal s_jump         : std_logic;
  signal s_funct3       : std_logic_vector(2 downto 0);   -- 3 bit vector

  signal s_RegWrAddr_Dec  : std_logic_vector(4 downto 0); -- 5 bit vector for passing rd past decode
  signal s_RegWr_Dec      : std_logic;  -- RegWrite EN for decode stage

  signal s_DMemWr_Dec     : std_logic;    -- Dmem Write EN for decode stage

  component ExecuteMemory_Reg is
    generic (N : integer := 101);   -- 101 bit register
    port (i_CLK   : in std_logic;                          -- Clock input
          i_RST   : in std_logic;                          -- Reset input
          i_WE    : in std_logic;                          -- Write enable input
          i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
          o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
  end component;

  signal s_EtM_Reg      : std_logic_vector(76 downto 0);  -- 77 bit output
  signal s_EXout        : std_logic_vector(31 downto 0);  -- Final ALU out to EtM_Reg


  component MemoryWriteback_Reg is
    generic (N : integer := 71);   -- 71 bit register
    port (i_CLK   : in std_logic;                          -- Clock input
          i_RST   : in std_logic;                          -- Reset input
          i_WE    : in std_logic;                          -- Write enable input
          i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
          o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
  end component;

  signal s_MtWB_Reg     : std_logic_vector(71 downto 0); -- 72 bit output
  --signal s_MemFunct3    : std_logic_vector(2 downto 0); -- 3 bits

  component dataHaz is 
  port (
    i_DecRS1    : in  std_logic_vector(4 downto 0);     -- 5 bits
    i_DecRS2    : in  std_logic_vector(4 downto 0);  
    i_ExRD      : in  std_logic_vector(4 downto 0);
    i_ExRegWr   : in  std_logic;
    i_MemRD     : in  std_logic_vector(4 downto 0);
    i_MemRegWr  : in  std_logic;
    i_DecUsesRS2: in  std_logic;
    i_CLK       : in  std_logic;
    i_RST       : in  std_logic;
    o_DataHaz   : out std_logic;
    o_DataBubble: out std_logic);
  end component;
  signal s_DecUsesRS2 : std_logic;
  signal s_DataHazStall : std_logic;
  signal s_DataHazFlush : std_logic;  -- Resets Decode/Execute Register on Positive Edge of Clock
begin

---------------------------------------------
---------------- FETCH STAGE ----------------

  s_Ovfl  <= '0';
  oALUOut <= s_ALUOut;

  
-- R-type and B-type (store uses rs2 but is a source not destination — still relevant)
-- S-type also uses rs2 as the data to write
s_DecUsesRS2 <= '1' when (s_FtD_Reg(6 downto 0) = "0110011"   -- R-type
                        or s_FtD_Reg(6 downto 0) = "1100011"   -- B-type
                        or s_FtD_Reg(6 downto 0) = "0100011")  -- S-type
                else '0';

  -- WFI halt detection
  -- TODO: ensure signal doesnt go high till WB stage
  -- s_Halt <= 
  s_HaltDecoded <= '1' when (iRST='0' and iInstLd='0' and
                      s_FtD_Reg(6 downto 0)  = "1110011" and
                      s_FtD_Reg(14 downto 12) = "000"    and
                      s_FtD_Reg(31 downto 20) = x"105")
            else '0';
 s_Halt <= s_MtWB_Reg(71);

  -- s_jump <= s_jal or s_DtE_Reg(132); 
  -- --s_jump <= s_jal or s_jalr;
  -- -- PC source select for fetch unit: TODO: may need to move into control decoder
  -- --   bit 1: JALR (register-indirect target via ALU)
  -- --   bit 0: any non-sequential update (JAL, JALR, or taken branch)
  -- -- claculated outside of control decoder since it depends on branch taken flag from ALU
  -- s_Fetchsrc(1) <= s_DtE_Reg(132);  -- s_jalr from Execute Stage
  -- s_Fetchsrc(0) <= s_jump or (s_Branch and s_branch_from_decode);

    -- Keep all jump redirection in EX so PC redirect timing matches ctrlHaz timing
  -- s_jump <= s_DtE_Reg(133);

  -- PC source select for fetch unit
  --   bit 1: JALR target from EX
  --   bit 0: any non-sequential PC update
  s_Fetchsrc(1) <= s_DtE_Reg(132);  -- jalr from EX
  s_Fetchsrc(0) <= s_jal or (s_Branch and s_branch_from_decode) or s_DtE_Reg(132);

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

  IFetch: proj1_fetch
  port map(
    i_CLK    => iCLK,
    i_RST_PC => iRST,
    i_WE     => ((not s_Halt) and (not s_PCStall) and (not s_DataHazStall)),
    i_imm    => s_Oext_Dec_to_Fetch,
    i_alu    => s_JalrTarget,
    c_PC_sel => s_Fetchsrc,
    o_PC     => s_PC,
    o_PC4    => s_PC4);

----------------------------------------------
---------------- DECODE STAGE ----------------

s_all_but_halt_decode <=(others => '0') when s_IFIDFlush = '1' else
                  (  s_PC4     -- PC+4 Value     -- [95:64]
                   & s_PC      -- PC Value       -- [63:32]
                   & s_Inst);  -- Instructions   -- [31:0]

s_FtD_Reg_In <= s_HaltDecoded & s_all_but_halt_decode;

  Fetch_To_Decode_Reg: FetchDecode_Reg
    generic map(N => 97)      -- 97 bit register
    port map(i_CLK  => iCLK,
             i_RST  => iRST,
             i_FLUSH => s_IFIDFlush,
             i_WE   => ((not s_FtD_Reg(96)) and (not s_IFIDStall) and (not s_DataHazStall)),   -- Used to stop on wfi or for stalling
             i_D    => s_FtD_Reg_In,  -- Input is now muxed for flush and stall
             o_Q    => s_FtD_Reg);

  s_RegWrAddr_Dec <= s_FtD_Reg(11 downto 7);      -- s_Inst(11 downto 7);
  s_ForceAddSub <= s_FtD_Reg(2);              -- 2nd bit of OpCode
  s_funct3  <= s_FtD_Reg(14 downto 12);

  CDec: ctrl_decoder
    generic map(ADDR_WIDTH => ADDR_WIDTH,
                DATA_WIDTH => N)
    port map(
              instr     => s_FtD_Reg(31 downto 0),
              reg_we    => s_RegWr_Dec,
              alu_src   => s_ALUsrc,
              mem_we    => s_DMemWr_Dec,
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
              i_RS1   => s_FtD_Reg(19 downto 15),
              i_RS2   => s_FtD_Reg(24 downto 20),
              o_rs1   => s_Ors1,
              o_rs2   => s_Ors2,
              i_rd    => s_RegWrAddr,  -- From Write Back Stage      
              i_dEN   => s_RegWr,      -- From Write Back Stage 
              i_RST   => iRST,
              i_CLK   => iCLK,
              i_DATA  => s_RegWrData   -- From Write Back Stage
             );

  Imm0: imm_gen
  port map(
    i_instr => s_FtD_Reg(31 downto 0),
    o_imm   => s_Oext
  );

  -- Choose RS2 or Immediate
  Mux_ALUSrc: mux2t1_N    -- In parallel with Branch Logic & RS1_OR_PC mux
  generic map(N => N)
  port map(
    i_D0 => s_Ors2,
    i_D1 => s_Oext,
    i_S  => s_ALUsrc,
    o_O  => s_ALUIn2
  );

    -- TODO: (later) Inputs will have to change for forwarding
    INST_BRANCHING: proj2_branch port map(
    i_A      => s_Ors1,     -- Output RS1
    i_B      => s_Ors2,     -- Branches compare RS1 vs RS2
    c_funct3 => s_FtD_Reg(14 downto 12),  -- funct3(2:0)
    o_out    => s_branch_from_decode);


  DtoF_pcPLUSimm: addSub      -- In parallel with Register File
  port map(
    i_Da     => s_FtD_Reg(63 downto 32),  -- Stage PC val
    i_Db     => s_Oext,                   -- Immediate output from immediate generator
    nAdd_Sub => '0',                      -- Force addition
    o_Sum    => s_Oext_Dec_to_Fetch,      -- Output to immediate input of fetch
    o_Car    => open                      -- Throw out overflow 
  );

  -- Choose RS1 or PC Value
  Mux_PC_or_RS1: mux2t1_N     -- In parallel with Branch Logic & RS2_OR_IMM mux
  generic map(N => N)
  port map(
    i_D0 => s_Ors1,         -- Default of using RS1
    i_D1 => s_FtD_Reg(63 downto 32),           -- Othewise use PCs_ALUctl_OverRideval  |   OG PC value
    i_S  => s_isAUIPC,      -- Flag for auipc
    o_O  => s_RS1orPC);     -- Output to Input A of ALU

-----------------------------------------------
---------------- EXECUTE STAGE ----------------

 s_all_but_halt_execute <=  (others => '0') when (s_IDEXFlush = '1' or s_DataHazFlush = '1') else
                  (  s_funct3                 -- RawFunct3_fr_Load  -- [179:177]
                   & s_Oext                   -- Immediate          -- [176:145]
                   & s_isLUI                  -- Inst is lui        -- [144] 
                   & s_ForceAddSub            -- Force AddSub_o     -- [143]
                   & s_RegWr_Dec              -- RegFile Write EN   -- [142]
                   & s_RegWrAddr_Dec          -- [rd]               -- [141:137]
                   & s_DMemWr_Dec             -- DMem Write EN      -- [136]
                   & s_DMemRD                 -- DMem Read EN       -- [135]
                   & s_WBsel                  -- Write Back Sel     -- [134]
                   & (s_jal or s_jalr)        --                    -- [133]
                   & s_jalr                   -- jalr               -- [132]
                   & s_ALUctl                 -- ALU Control        -- [131:128]
                   & s_FtD_Reg(95 downto 64)  -- PC + 4             -- [127:96]
                   & s_RS1orPC                -- RS1 Or PC          -- [95:64]
                   & s_Ors2                   -- RS2 for Stores     -- [63:32]
                   & s_ALUIn2);               -- RS2 Or IMM         -- [31:0]

s_DtE_Reg_In <= s_FtD_Reg(96) & s_all_but_halt_execute;

  Decode_To_Execute_Reg: DecodeExecute_Reg
    generic map(N => 181)
    port map(i_CLK => iCLK,
            i_RST => iRST,
            i_FLUSH => s_IDEXFlush or s_DataHazFlush,
            i_WE  => (not s_DtE_Reg(180)),
            i_D   => s_DtE_Reg_In,
            o_Q   => s_DtE_Reg);
  -- s_Inst(2) = OpCode(2) = s_DtE_Reg(143)
    -- This bit is 1 for ONLY aupic, lui, jal, jalr, (and fence).   Use this to force the ALU output to Add/Sub
  s_ALUctl_OverRide(0)  <= s_DtE_Reg(128);                                -- s_ALUctl(0)
  s_ALUctl_OverRide(1)  <= ((not s_DtE_Reg(143)) and s_DtE_Reg(129));     -- not OpCode(2) and s_ALUctl(1) <<< (ORIGINAL CODE)
  s_ALUctl_OverRide(2)  <= ((not s_DtE_Reg(143)) and s_DtE_Reg(130));     -- not OpCode(2) and s_ALUctl(2)
  s_ALUctl_OverRide(3)  <= ((not s_DtE_Reg(143)) and s_DtE_Reg(131));     -- not OpCode(2) and s_ALUctl(3)

  ALU0: proj02_ALU
  port map(
    i_A         => s_DtE_Reg(95 downto 64),   -- s_RS1orPC and ~s_isLUI. If s_isLUI is 0 --> 1, allows normal operation, else 0
    i_B         => s_DtE_Reg(31 downto 0),    -- s_ALUIn2
    i_ALUctl    => s_ALUctl_OverRide, 
    o_ALUout    => s_ALUOut);                 -- o_branchOut => s_brTaken);

  --   -- include PC+4
  --   LUI_MUX: mux2t1_N   
  -- generic map(N => N)
  -- port map(
  --   i_D0 => s_ALUout,
  --   i_D1 => s_DtE_Reg(176 downto 145),  -- immediate
  --   i_S  => s_DtE_REG(144),
  --   o_O  => s_EXout
  -- );

  INST_BUSMUX_4t1_0: busMux_4t1 port map(
        i_Da    => s_ALUout, -- ALUoutput 00     
        i_Db    => s_DtE_Reg(176 downto 145),  -- immediate 01      
        i_Dc    => s_DtE_Reg(127 downto 96),  -- PC + 4 1X    
        i_Dd    => s_DtE_Reg(127 downto 96), -- PC + 4 1X      
        C_S0    => s_DtE_REG(144), -- is lui     
        C_S1    => s_DtE_REG(133), -- is jal or jalr PC + 4 WB   
        o_Do    => s_EXout); 


  -- JALR target: rs1 + imm_I with with LSB cleared
  s_JalrTarget <= s_ALUOut(31 downto 1) & '0';

----------------------------------------------
---------------- MEMORY STAGE ----------------

  Execute_To_Memory_Reg: ExecuteMemory_Reg
    generic map(N => 77)      -- 77 bit register
    port map(i_CLK => iCLK,
             i_RST => iRST,
             i_WE  => not s_EtM_Reg(76),
             i_D   =>   s_DtE_Reg(180)            -- Halt           -- [76]
                      & s_DtE_Reg(179 downto 177) -- Funct3 bits    -- [75:73]
                      & s_DtE_Reg(142)            -- RegWrite EN    -- [72]
                      & s_DtE_Reg(141 downto 137) -- rd             -- [71:67]
                      & s_DtE_Reg(136)            -- DMem Write EN  -- [66]
                      & s_DtE_Reg(135)            -- DMem Read EN   -- [65]
                      & s_DtE_Reg(134)            -- Write Back Sel -- [64]
                      & s_EXout                   -- ALU_out        -- [63:32]  -- For addressing and Write Back
                      & s_DtE_Reg(63 downto 32),  -- RS2            -- [31:0]
             o_Q   => s_EtM_Reg);

  s_DMemAddr <= s_EtM_Reg(63 downto 32);
  s_DMemData <= s_EtM_Reg(31 downto 0);
  s_DMemWr   <= s_EtM_Reg(66);

  DMem: mem
  generic map(ADDR_WIDTH => ADDR_WIDTH, 
              DATA_WIDTH => N)
  port map(clk  => iCLK,
           addr => s_DMemAddr(11 downto 2), -- ALU_out      -- s_DMemAddr(11 downto 2)      
           data => s_DMemData,  -- RS2        
           we   => s_DMemWr,           -- Write EN     -- s_DMemWr
           q    => s_DMemOut);

  LOAD0: proj01_LOAD
    port map(
      i_memVal    => s_DMemOut,
      c_addr_2bit => s_EtM_Reg(33 downto 32),    -- s_ALUOut(1 downto 0)
      c_funct3    => s_EtM_Reg(75 downto 73),    -- Function 3 bits
      o_LoadOut   => s_LoadOut
    );

--------------------------------------------------
---------------- WRITE BACK STAGE ----------------    

Memory_To_WriteBack_Reg: MemoryWriteback_Reg 
  generic map(N => 72)    -- 72 bit register
  port map(i_CLK => iCLK,
           i_RST => iRST,
           i_WE  => not s_MtWB_Reg(71),
           i_D   => s_EtM_Reg(76)             -- Halt       -- [71]
                  & s_EtM_Reg(72)             -- RegWrite   -- [70]
                  & s_EtM_Reg(71 downto 67)   -- [rd]       -- [69:65]
                  & s_EtM_Reg(64)             -- WB_Sel     -- [64]
                  & s_LoadOut                 -- O_Load     -- [63:32]
                  & s_EtM_Reg(63 downto 32),  -- O_ALU      -- [31:0]   -- Actually s_EXout
           o_Q   => s_MtWB_Reg);

  s_RegWrAddr <= s_MtWB_Reg(69 downto 65);  -- rd
  s_RegWr     <= s_MtWB_Reg(70);            -- RegWrite EN

  Mux_WriteBack: mux2t1_N
    generic map(N => N)
    port map(
      i_D0 => s_MtWB_Reg(63 downto 32),   -- s_LoadOut
      i_D1 => s_MtWB_Reg(31 downto 0),    -- ALU out
      i_S  => s_MtWB_Reg(64),             -- s_WBsel
      o_O  => s_RegWrData
    );

-------------------------------------------------------
---------------- Data Hazard Dectection ---------------
    Data_Hazard_Detection: dataHaz port map(
    i_DecRS1      => s_FtD_Reg(19 downto 15),   -- Fetch/Dec i_RS1
    i_DecRS2      => s_FtD_Reg(24 downto 20),   -- Fetch/Dec i_RS2
    i_ExRD        => s_DtE_Reg(141 downto 137), -- Dec/Ex rd
    i_ExRegWr     => s_DtE_Reg(142),            -- Dec/Ex RegWr EN
    i_MemRD       => s_EtM_Reg(71 downto 67),   -- Ex/Mem rd
    i_MemRegWr    => s_EtM_Reg(72),             -- Ex/Mem RegWr EN
    i_DecUsesRS2  => s_DecUsesRS2,
    i_CLK         => iCLK,
    i_RST         => iRST,
    o_DataHaz     => s_DataHazStall,
    o_DataBubble  => s_DataHazFlush);
    
----------------------------------------------------------
---------------- Control Hazard Dectection ---------------
Ctrl_Hazard_Detection: ctrlHaz
  port map(
    i_IDBranch      => s_Branch or s_jal,  
    i_IDBranchTaken => s_branch_from_decode or s_jal,
    i_EXJump        => s_DtE_Reg(132),
    o_CtrlHaz       => s_CtrlHaz,
    o_IFIDFlush     => s_IFIDFlush,
    o_IDEXFlush     => s_IDEXFlush,
    o_PCStall       => s_PCStall,
    o_IFIDStall     => s_IFIDStall
  );

end structure;