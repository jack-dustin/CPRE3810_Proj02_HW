library ieee;
use ieee.std_logic_1164.all;
use work.RISCV_types.all;

entity ctrl_decoder is
  generic(
    ADDR_WIDTH : integer;
    DATA_WIDTH : integer
  );
  port(
    instr     : in  std_logic_vector(31 downto 0);

    reg_we    : out std_logic;
    alu_src   : out std_logic;   -- 0=rs2, 1=imm
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
end entity;

architecture dataflow of ctrl_decoder is

  signal opcode : std_logic_vector(6 downto 0);
  signal funct3 : std_logic_vector(2 downto 0);
  signal funct7 : std_logic_vector(6 downto 0);

  -- Opcodes
  signal is_rtype, is_itype, is_lui_op, is_load, is_store,
         is_b, is_auipc_op, is_jal_op, is_jalr_op : std_logic;

  -- control bits prior to gatting with opcodes
  signal alu_raw   : std_logic_vector(3 downto 0);
  -- used to determine when to use funct3 directly or force to '0' for forced ADD operations
  signal use_funct3 : std_logic;

begin

  opcode <= instr(6 downto 0);
  funct3 <= instr(14 downto 12);
  funct7 <= instr(31 downto 25);

  -- Opcode classification
  is_rtype    <= '1' when opcode = OP_RTYPE  else '0';
  is_itype    <= '1' when opcode = OP_ITYPE  else '0';
  is_load     <= '1' when opcode = OP_LOAD   else '0';
  is_store    <= '1' when opcode = OP_STORE  else '0';
  is_b        <= '1' when opcode = OP_BRANCH else '0';
  is_jal_op   <= '1' when opcode = OP_JAL    else '0';
  is_jalr_op  <= '1' when opcode = OP_JALR   else '0';
  is_lui_op   <= '1' when opcode = OP_LUI    else '0';
  is_auipc_op <= '1' when opcode = OP_AUIPC  else '0';

  -- Output flag assignments
  is_branch <= is_b;
  is_jal    <= is_jal_op;
  is_jalr   <= is_jalr_op;
  is_lui    <= is_lui_op;
  is_auipc  <= is_auipc_op;

  -- Register write enable
  reg_we <= '1' when (is_rtype='1' or is_itype='1' or is_lui_op='1' or is_load='1'
                      or is_auipc_op='1' or is_jal_op='1' or is_jalr_op='1')
            else '0';

  -- ALU source mux select
  alu_src <= '1' when (is_itype='1' or is_load='1' or is_store='1'
                       or is_auipc_op='1' or is_jalr_op='1')
             else '0';

  mem_we   <= '1' when is_store='1' else '0';
  mem_re   <= '1' when is_load='1'  else '0';

  -- Writeback select
  wb_sel <= WB_MEM when is_load='1'                        else
            WB_PC4 when (is_jal_op='1' or is_jalr_op='1') else
            WB_ALU;

  -- ALU Control generation
  -- values before gating with opcode class
  alu_raw(3) <= instr(13);   -- funct3[1]
  alu_raw(2) <= instr(14);   -- funct3[2]
  alu_raw(1) <= instr(12);   -- funct3[0]
  alu_raw(0) <= instr(30) when (is_rtype='1') or -- R-type: ADD vs SUB, SRL vs SRA
                               (is_itype='1' and funct3="101")  -- SRAI only
                else '0'; -- treat as '0' for all other instructions

  -- use funct3 values directly for R, I arithmetic, and branch instructions, but force to '0' for everything else
  use_funct3 <= is_b or instr(4);  -- instr(4) is '1' for R-type and I-type only and is '0' for all other types, including branches
  -- if use_funct3='0', alu_ctl will be "000x" (ADD); if use_funct3='1', alu_ctl[3:1] = funct3
  alu_ctl(3) <= alu_raw(3) and use_funct3;
  alu_ctl(2) <= alu_raw(2) and use_funct3;
  alu_ctl(1) <= alu_raw(1) and use_funct3;

  -- determine bit 0
  -- pass funct7[5] (instr[30]) through for R-type and SRAI, but force to '1' (SUB) for branches
  alu_ctl(0) <= (alu_raw(0) and instr(4)) or is_b;

end architecture;