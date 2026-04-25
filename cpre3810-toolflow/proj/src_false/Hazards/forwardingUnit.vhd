-- Jack Dustin
-- EX-stage forwarding unit
-- Handles EX/MEM -> EX and MEM/WB -> EX forwarding.

library IEEE;
use IEEE.std_logic_1164.all;

entity forwardingUnit is
  port(
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
    o_ForwardB      : out std_logic_vector(1 downto 0)
  );
end entity;

architecture dataflow of forwardingUnit is
  signal s_EXHazA : std_logic;
  signal s_EXHazB : std_logic;
  signal s_WBHazA : std_logic;
  signal s_WBHazB : std_logic;
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

end architecture;
