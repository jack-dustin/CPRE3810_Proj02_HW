-- Isaiah Pridie
-- Data Hazard Logic for stalling register file
-- Start Date: 4.18.2026,   2:55 PM

-- This file compares the EX(rd) and MEM(rd) stage registers to the rs1 and rs2 of Decode stage reg
    -- If rd matches one of the source registers AND RegWr = 1, we have a data hazard

library IEEE;
use IEEE.std_logic_1164.all;

entity dataHaz is port(
    i_DecRS1    : in  std_logic_vector(4 downto 0);     -- 5 bits
    i_DecRS2    : in  std_logic_vector(4 downto 0);  
    i_ExRD      : in  std_logic_vector(4 downto 0);
    i_ExRegWr   : in  std_logic;
    i_MemRD     : in  std_logic_vector(4 downto 0);
    i_MemRegWr  : in  std_logic;
    i_DecUsesRS2: in  std_logic;
    i_CLK       : in  std_logic;
    i_RST       : in  std_logic;

    i_isLoad    : in  std_logic;    -- WB_sel --> 0 for Load, 1 for ALU
      -- This is needed from the Execute stage ONLY. Check for load instruction. If prdoucer then lw --> stall once

    i_isBranch  : in  std_logic;    -- Need to check for data dependency and if instruction is branch
      -- If producer then branch --> Stall once     Give time for execute to make it back to decode
      -- Checking Decode rs1/2 to EX rd

    o_DataHaz   : out std_logic;
    o_DataBubble: out std_logic);
end entity;

architecture mixed of dataHaz is

    -- Checking Execute
    signal s_Ex_RS1_Dep     : std_logic_vector(4 downto 0);
    signal s_Ex_RS2_Dep     : std_logic_vector(4 downto 0);

    signal s_EXrd_eq_rs1    : std_logic;    -- This = 1 if EX(rd) = DEC(rs1)
    signal s_EXrd_eq_rs2    : std_logic;    -- This = 1 if EX(rd) = DEC(rs2)

    signal s_ExRS_res       : std_logic;    -- This = 1 if Ex(rd) = DEC(rs1 or rs2)
    signal s_EX_Data_Haz    : std_logic;    -- This = 1 if there is a data hazard

    -- Checking Memory
    signal s_Mem_RS1_Dep    : std_logic_vector(4 downto 0);
    signal s_Mem_RS2_Dep    : std_logic_vector(4 downto 0);

    signal s_Mrd_eq_rs1     : std_logic;    -- This = 1 if EX(rd) = DEC(rs1)
    signal s_Mrd_eq_rs2     : std_logic;    -- This = 1 if EX(rd) = DEC(rs2)

    signal s_Erd_is_0       : std_logic;    -- This is 0 if rd = 0
    signal s_Mrd_is_0       : std_logic;    -- This is 0 if rd = 0

    signal s_MemRS_res      : std_logic;    -- This = 1 if Ex(rd) = DEC(rs1 or rs2)
    signal s_M_Data_Haz     : std_logic;    -- This = 1 if there is a data hazard

    signal os_DataHaz       : std_logic;    -- Internal Signal for final data hazard signal
    signal os_DataBubble    : std_logic;    -- Internal signal for data flush signal

component dffg is
  port(i_CLK        : in  std_logic;     -- Clock input
       i_RST        : in  std_logic;     -- Reset input
       i_WE         : in  std_logic;     -- Write enable input
       i_D          : in  std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
end component;

begin

-- Check for dependencies between EX(rd) and RSn:
    -- rs1
    s_Ex_RS1_Dep    <=  i_ExRD xnor i_DecRS1; -- [n,n] = 1, [n,m] = 0

    -- AND tree     -- [E] rd & rs1 equalivent flag
    s_EXrd_eq_rs1   <= and s_Ex_RS1_Dep;

    s_Ex_RS2_Dep    <=  i_ExRD xnor i_DecRS2; -- [n,n] = 1, [n,m] = 0

    -- AND tree     -- [E] rd & rs2 equalivent flag
    s_EXrd_eq_rs2   <= and s_Ex_RS2_Dep;
    
-- Check for dependencies betwen M(rd) and RSn:
    -- rs1
    s_Mem_RS1_Dep   <= i_MemRD xnor i_DecRS1;   -- [n,n] = 1, [n,m] = 0
 
    -- AND tree     -- [M] rd & rs1 equalivent flag
    s_Mrd_eq_rs1    <= and s_Mem_RS1_Dep;

    -- rs2
    s_Mem_RS2_Dep   <= i_MemRD xnor i_DecRS2;   -- [n,n] = 1, [n,m] = 0
  
    -- AND tree     -- [M] rd & rs2 equalivent flag
    s_Mrd_eq_rs2    <= and s_Mem_RS2_Dep;

-- These signals are 0 if rd = 0
    s_Erd_is_0  <= or i_ExRD;   -- OR trees
    s_Mrd_is_0  <= or i_MemRD;


-- Logic for Data Hazard Output signals
    s_ExRS_res  <= (s_EXrd_eq_rs2 and i_DecUsesRS2) or s_EXrd_eq_rs1;
    s_EX_Data_Haz  <= s_ExRS_res and i_ExRegWr and s_Erd_is_0;  -- If {RS Haz} and {RegWr Haz} and {rd != 0} --> A data Haz Exists

    s_MemRS_res     <= s_Mrd_eq_rs1 or s_Mrd_eq_rs2; 
    s_M_Data_Haz <= s_MemRS_res and i_MemRegWr and s_Mrd_is_0; -- If {RS Haz} and {RegWr Haz} and {rd != 0} --> A data Haz Exists

  -----------------------------------------------------------
  ---------------- Output Data Hazard Status ---------------- 
  
    -- If a Data Hazard is detected from Execute or Memory, this outputs* 1
    os_DataHaz    <= s_M_Data_Haz or s_EX_Data_Haz;
    o_DataBubble  <= os_DataHaz;    
    o_DataHaz     <= (s_EX_Data_Haz and (not i_isLoad)) or ( os_DataHaz and i_isBranch);  -- Required for stalling  
        -- If the hazard is between execute and decode, and the instruction is a load - stall
            -- lw  x28, _(x_)
            -- and x20, x28, x12
        -- If the hazard is between decode and execute or memory, and the instruction is a branch   - stall (once for EX_Haz, twice for Mem_Haz)
            -- addi x10, x10, 2   /   lw x10, _(x_)
            -- beq x7, x10, Label
            -- DO NOT FORWARD FROM WB TO DECODE - WB already writes to decode/RegFile

end architecture;