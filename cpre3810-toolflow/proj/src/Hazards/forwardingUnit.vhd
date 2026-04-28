-- Jack Dustin
-- EX-stage forwarding unit
-- Handles EX/MEM -> EX and MEM/WB -> EX forwarding.

library IEEE;
use IEEE.std_logic_1164.all;

entity forwardingUnit is
  port(
    i_IFID_RS1      : in  std_logic_vector(4 downto 0);
    i_IFID_RS2      : in  std_logic_vector(4 downto 0);

    i_IDEX_RS1      : in  std_logic_vector(4 downto 0);
    i_IDEX_RS2      : in  std_logic_vector(4 downto 0);

    i_EXMEM_RD      : in  std_logic_vector(4 downto 0);
    i_EXMEM_RegWr   : in  std_logic;
    i_EXMEM_MemRead : in  std_logic;

    i_MEMWB_RD      : in  std_logic_vector(4 downto 0);
    i_MEMWB_RegWr   : in  std_logic;

    -- 00 = normal ID/EX value
    -- 10 = EX/MEM result
    -- 01 = MEM/WB final writeback value
    -- 11 = unused / not generated
    o_ForwardA      : out std_logic_vector(1 downto 0);
    o_ForwardB      : out std_logic_vector(1 downto 0);

    o_ForwardBranch : out std_logic_vector(1 downto 0)  -- [0, RS1]   [1, RS2]    Forward from Execute to Branching Decode
  );
end entity;

architecture dataflow of forwardingUnit is
  signal s_EXHazA : std_logic;
  signal s_EXHazB : std_logic;
  signal s_WBHazA : std_logic;
  signal s_WBHazB : std_logic;

  signal s_rd_xnor_IFID_RS1   : std_logic_vector(4 downto 0); -- Contains i_EXMEM_RD xnor i_IFID_RS1
      signal s_rd_eq_IFID_RS1 : std_logic;  -- And tree of [i_EXMEM_RD xnor i_IFID_RS1]
  signal s_rd_xnor_IFID_RS2   : std_logic_vector(4 downto 0); -- And tree of [i_EXMEM_RD xnor i_IFID_RS2]
      signal s_rd_eq_IFID_RS2 : std_logic;  -- And tree of [i_EXMEM_RD xnor i_IFID_RS2]

  signal s_EXMEM_rd_isnt_0    : std_logic;  -- Holds result of "or i_EXMEM_RD"

begin

  -- EX/MEM has priority, but do not forward EX/MEM for loads. For loads in EX/MEM,
  -- s_EtM_Reg(63 downto 32) is the address, not the loaded value.
  s_EXHazA <= '1' when (i_EXMEM_RegWr = '1' and
                        i_EXMEM_MemRead = '0' and
                        i_EXMEM_RD /= "00000" and
                        i_EXMEM_RD = i_IDEX_RS1)
              else '0';

  s_EXHazB <= '1' when (i_EXMEM_RegWr = '1' and
                        i_EXMEM_MemRead = '0' and
                        i_EXMEM_RD /= "00000" and
                        i_EXMEM_RD = i_IDEX_RS2)
              else '0';

  -- MEM/WB forwarding only wins when EX/MEM does not already match the same source.
  s_WBHazA <= '1' when (s_EXHazA = '0' and
                        i_MEMWB_RegWr = '1' and
                        i_MEMWB_RD /= "00000" and
                        i_MEMWB_RD = i_IDEX_RS1)
              else '0';

  s_WBHazB <= '1' when (s_EXHazB = '0' and
                        i_MEMWB_RegWr = '1' and
                        i_MEMWB_RD /= "00000" and
                        i_MEMWB_RD = i_IDEX_RS2)
              else '0';

  o_ForwardA <= "10" when s_EXHazA = '1' else
                "01" when s_WBHazA = '1' else
                "00";

  o_ForwardB <= "10" when s_EXHazB = '1' else
                "01" when s_WBHazB = '1' else
                "00";

  ---------------- Forwarding for Branching ----------------    DO NOT CHANGE OR TRY TO SIMPLIFY ANY OF THIS
              -- Using "and v1" to make an and tree from v1 works fine for the toolflow, but is flagged as a VHDL syntax error by the synthesizer
    -- 1 when:
      -- Haz between MEM rd and DEC RSn     Checking Mem, not EX --> Values forwarded at the beginning of the NEXT stage
      -- MEM RegWrite = 1
      -- Mem is not a Load instruction      Note: [add/lw --> branch] cases look the same. lw shouldn't be forwarded; WB takes care of it already
      -- MEM rd != x0

  s_rd_xnor_IFID_RS1  <= i_EXMEM_RD xnor i_IFID_RS1;    -- Check for equality
      s_rd_eq_IFID_RS1    <= s_rd_xnor_IFID_RS1(0) and s_rd_xnor_IFID_RS1(1) and s_rd_xnor_IFID_RS1(2) and s_rd_xnor_IFID_RS1(3) and s_rd_xnor_IFID_RS1(4);   -- AND tree
  s_rd_xnor_IFID_RS2  <= i_EXMEM_RD xnor i_IFID_RS2;
      s_rd_eq_IFID_RS2    <= s_rd_xnor_IFID_RS2(0) and s_rd_xnor_IFID_RS2(1) and s_rd_xnor_IFID_RS2(2) and s_rd_xnor_IFID_RS2(3) and s_rd_xnor_IFID_RS2(4);

  s_EXMEM_rd_isnt_0   <= i_EXMEM_RD(0) or i_EXMEM_RD(1) or i_EXMEM_RD(2) or i_EXMEM_RD(3) or i_EXMEM_RD(4);

                         -- Check Equality    -- Check RegWr     -- Check if Load         -- Check for x0
  o_ForwardBranch(0)  <= s_rd_eq_IFID_RS1 and i_EXMEM_RegWr and (not i_EXMEM_MemRead) and s_EXMEM_rd_isnt_0;
              -- "and vector" creates an and tree inputting all bits of 'vector'. Same with "or vector"

                         -- Check Equality    -- Check RegWr     -- Check if Load         -- Check for x0
  o_ForwardBranch(1)  <= s_rd_eq_IFID_RS2 and i_EXMEM_RegWr and (not i_EXMEM_MemRead) and s_EXMEM_rd_isnt_0;
              -- "and vector" creates an and tree inputting all bits of 'vector'. Same with "or vector"
end architecture;
