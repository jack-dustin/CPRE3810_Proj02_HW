-------------------------------------------------------------------------
-- Author: Braedon Giblin
-- Date: 2022.02.12
-- Files: RISCV_types.vhd
-------------------------------------------------------------------------
-- Description: This file contains a skeleton for some types that 381 students
-- may want to use. This file is guarenteed to compile first, so if any types,
-- constants, functions, etc., etc., are wanted, students should declare them
-- here.
-------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package RISCV_types is

  -- ---- Datapath widths ----
  constant DATA_WIDTH : integer := 32;
  constant ADDR_WIDTH : integer := 10;

  -- Op codes
  constant OP_RTYPE  : std_logic_vector(6 downto 0) := "0110011";
  constant OP_ITYPE  : std_logic_vector(6 downto 0) := "0010011";
  constant OP_LOAD   : std_logic_vector(6 downto 0) := "0000011";
  constant OP_STORE  : std_logic_vector(6 downto 0) := "0100011";
  constant OP_BRANCH : std_logic_vector(6 downto 0) := "1100011";
  constant OP_JAL    : std_logic_vector(6 downto 0) := "1101111";
  constant OP_JALR   : std_logic_vector(6 downto 0) := "1100111";
  constant OP_LUI    : std_logic_vector(6 downto 0) := "0110111";
  constant OP_AUIPC  : std_logic_vector(6 downto 0) := "0010111";

  -- REGFile mux
  type i_reg_array is array (31 downto 0) of std_logic_vector(31 downto 0);

  -- WB types
  --   WB_ALU : rd <- ALU result        (R-type, I-type arithmetic)
  --   WB_MEM : rd <- DMEM load data    (load instructions)
  --   WB_PC4 : rd <- PC+4              (JAL, JALR return address)
  type wb_sel_t is (WB_ALU, WB_MEM, WB_PC4);

end package RISCV_types;