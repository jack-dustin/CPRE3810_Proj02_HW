library ieee;
use ieee.std_logic_1164.all;
use work.RISCV_types.all;

entity imm_gen is
  port(
    i_instr : in  std_logic_vector(31 downto 0);
    o_imm   : out std_logic_vector(31 downto 0)
  );
end entity;

architecture dataflow of imm_gen is
  signal opcode : std_logic_vector(6 downto 0);

  signal imm_i  : std_logic_vector(31 downto 0);
  signal imm_s  : std_logic_vector(31 downto 0);
  signal imm_u  : std_logic_vector(31 downto 0);
  signal imm_b  : std_logic_vector(31 downto 0);
  signal imm_j  : std_logic_vector(31 downto 0);
begin
  opcode <= i_instr(6 downto 0);

  -- I-type immediate: instr[31:20], sign-extend bit 31 to 31:20 then concatenate with instr[31:20]
  imm_i <= (31 downto 12 => i_instr(31)) & i_instr(31 downto 20);

  -- S-type immediate: instr[31:25] & instr[11:7], sign-extend and concatenate with correct bit positions
  imm_s <= (31 downto 12 => i_instr(31)) & i_instr(31 downto 25) & i_instr(11 downto 7);

  -- U-type immediate: instr[31:12] << 12, value already aligned, just concatenate with 12 zeros
  imm_u <= i_instr(31 downto 12) & x"000";

  -- B-type immediate: {instr[31], instr[7], instr[30:25], instr[11:8], 0} << 1, sign-extend
  -- align bits to correct positions and concatenate with sign bit and 0 at the end
  imm_b <= (31 downto 13 => i_instr(31)) &
           i_instr(31) & i_instr(7) & i_instr(30 downto 25) & i_instr(11 downto 8) & '0';

  -- J-type immediate: {instr[31], instr[19:12], instr[20], instr[30:21], 0} << 1, sign-extend
  -- align bits to correct positions and concatenate with sign bit and 0 at the end
  imm_j <= (31 downto 21 => i_instr(31)) &
           i_instr(31) & i_instr(19 downto 12) & i_instr(20) & i_instr(30 downto 21) & '0';

  -- Choose immediate by opcode (no extra control signal needed)
  o_imm <= imm_i when (opcode = OP_ITYPE or opcode = OP_LOAD or opcode = OP_JALR) else
           imm_s when (opcode = OP_STORE) else
           imm_u when (opcode = OP_LUI or opcode = OP_AUIPC) else
           imm_b when (opcode = OP_BRANCH) else
           imm_j when (opcode = OP_JAL) else
           imm_i; -- safe default
end architecture;