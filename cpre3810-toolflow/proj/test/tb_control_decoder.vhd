library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.RISCV_types.all;

entity tb_ctrl_decoder is
end entity;

architecture sim of tb_ctrl_decoder is
  constant ADDR_WIDTH_C : integer := 32;
  constant DATA_WIDTH_C : integer := 32;

  signal instr     : std_logic_vector(31 downto 0) := (others => '0');
  signal reg_we    : std_logic;
  signal alu_src   : std_logic;
  signal mem_we    : std_logic;
  signal mem_re    : std_logic;
  signal wb_sel    : wb_sel_t;
  signal is_branch : std_logic;
  signal is_jal    : std_logic;
  signal is_jalr   : std_logic;
  signal is_lui    : std_logic;
  signal is_auipc  : std_logic;
  signal alu_ctl   : std_logic_vector(3 downto 0);

begin

  uut: entity work.ctrl_decoder
    generic map (
      ADDR_WIDTH => ADDR_WIDTH_C,
      DATA_WIDTH => DATA_WIDTH_C
    )
    port map (
      instr     => instr,
      reg_we    => reg_we,
      alu_src   => alu_src,
      mem_we    => mem_we,
      mem_re    => mem_re,
      wb_sel    => wb_sel,
      is_branch => is_branch,
      is_jal    => is_jal,
      is_jalr   => is_jalr,
      is_lui    => is_lui,
      is_auipc  => is_auipc,
      alu_ctl   => alu_ctl
    );

  stim: process
  begin
    instr <= x"003100B3"; -- add x1,x2,x3
    wait for 10 ns;
    assert reg_we = '1' report "R-type reg_we failed" severity error;
    assert alu_src = '0' report "R-type alu_src failed" severity error;
    assert mem_we = '0' report "R-type mem_we failed" severity error;
    assert mem_re = '0' report "R-type mem_re failed" severity error;
    assert wb_sel = WB_ALU report "R-type wb_sel failed" severity error;
    assert is_branch = '0' report "R-type is_branch failed" severity error;
    assert is_jal = '0' report "R-type is_jal failed" severity error;
    assert is_jalr = '0' report "R-type is_jalr failed" severity error;
    assert is_lui = '0' report "R-type is_lui failed" severity error;
    assert is_auipc = '0' report "R-type is_auipc failed" severity error;
    assert alu_ctl = "0000" report "ADD alu_ctl failed" severity error;

    instr <= x"403100B3"; -- sub x1,x2,x3
    wait for 10 ns;
    assert alu_ctl = "0001" report "SUB alu_ctl failed" severity error;

    instr <= x"00510093"; -- addi x1,x2,5
    wait for 10 ns;
    assert reg_we = '1' report "I-type reg_we failed" severity error;
    assert alu_src = '1' report "I-type alu_src failed" severity error;
    assert mem_we = '0' report "I-type mem_we failed" severity error;
    assert mem_re = '0' report "I-type mem_re failed" severity error;
    assert wb_sel = WB_ALU report "I-type wb_sel failed" severity error;
    assert alu_ctl = "0000" report "ADDI alu_ctl failed" severity error;

    instr <= x"00012083"; -- lw x1,0(x2)
    wait for 10 ns;
    assert reg_we = '1' report "LW reg_we failed" severity error;
    assert alu_src = '1' report "LW alu_src failed" severity error;
    assert mem_we = '0' report "LW mem_we failed" severity error;
    assert mem_re = '1' report "LW mem_re failed" severity error;
    assert wb_sel = WB_MEM report "LW wb_sel failed" severity error;
    assert alu_ctl = "0000" report "LW alu_ctl failed" severity error;

    instr <= x"00112023"; -- sw x1,0(x2)
    wait for 10 ns;
    assert reg_we = '0' report "SW reg_we failed" severity error;
    assert alu_src = '1' report "SW alu_src failed" severity error;
    assert mem_we = '1' report "SW mem_we failed" severity error;
    assert mem_re = '0' report "SW mem_re failed" severity error;
    assert wb_sel = WB_ALU report "SW wb_sel failed" severity error;
    assert alu_ctl = "0000" report "SW alu_ctl failed" severity error;

    instr <= x"00208463"; -- beq x1,x2,8
    wait for 10 ns;
    assert reg_we = '0' report "BEQ reg_we failed" severity error;
    assert alu_src = '0' report "BEQ alu_src failed" severity error;
    assert mem_we = '0' report "BEQ mem_we failed" severity error;
    assert mem_re = '0' report "BEQ mem_re failed" severity error;
    assert is_branch = '1' report "BEQ is_branch failed" severity error;
    assert is_jal = '0' report "BEQ is_jal failed" severity error;
    assert is_jalr = '0' report "BEQ is_jalr failed" severity error;
    assert alu_ctl = "0001" report "BEQ alu_ctl failed" severity error;

    instr <= x"008000EF"; -- jal x1,8
    wait for 10 ns;
    assert reg_we = '1' report "JAL reg_we failed" severity error;
    assert alu_src = '0' report "JAL alu_src failed" severity error;
    assert mem_we = '0' report "JAL mem_we failed" severity error;
    assert mem_re = '0' report "JAL mem_re failed" severity error;
    assert wb_sel = WB_PC4 report "JAL wb_sel failed" severity error;
    assert is_jal = '1' report "JAL is_jal failed" severity error;
    assert is_jalr = '0' report "JAL is_jalr failed" severity error;
    assert alu_ctl = "0000" report "JAL alu_ctl failed" severity error;

    instr <= x"000100E7"; -- jalr x1,0(x2)
    wait for 10 ns;
    assert reg_we = '1' report "JALR reg_we failed" severity error;
    assert alu_src = '1' report "JALR alu_src failed" severity error;
    assert mem_we = '0' report "JALR mem_we failed" severity error;
    assert mem_re = '0' report "JALR mem_re failed" severity error;
    assert wb_sel = WB_PC4 report "JALR wb_sel failed" severity error;
    assert is_jal = '0' report "JALR is_jal failed" severity error;
    assert is_jalr = '1' report "JALR is_jalr failed" severity error;
    assert alu_ctl = "0000" report "JALR alu_ctl failed" severity error;

    instr <= x"123450B7"; -- lui x1,0x12345
    wait for 10 ns;
    assert reg_we = '1' report "LUI reg_we failed" severity error;
    assert alu_src = '0' report "LUI alu_src failed" severity error;
    assert mem_we = '0' report "LUI mem_we failed" severity error;
    assert mem_re = '0' report "LUI mem_re failed" severity error;
    assert wb_sel = WB_ALU report "LUI wb_sel failed" severity error;
    assert is_lui = '1' report "LUI is_lui failed" severity error;
    assert is_auipc = '0' report "LUI is_auipc failed" severity error;
    assert alu_ctl = "0000" report "LUI alu_ctl failed" severity error;

    instr <= x"12345097"; -- auipc x1,0x12345
    wait for 10 ns;
    assert reg_we = '1' report "AUIPC reg_we failed" severity error;
    assert alu_src = '1' report "AUIPC alu_src failed" severity error;
    assert mem_we = '0' report "AUIPC mem_we failed" severity error;
    assert mem_re = '0' report "AUIPC mem_re failed" severity error;
    assert wb_sel = WB_ALU report "AUIPC wb_sel failed" severity error;
    assert is_lui = '0' report "AUIPC is_lui failed" severity error;
    assert is_auipc = '1' report "AUIPC is_auipc failed" severity error;
    assert alu_ctl = "0000" report "AUIPC alu_ctl failed" severity error;

    report "tb_ctrl_decoder completed" severity note;
    wait;
  end process;

end architecture;