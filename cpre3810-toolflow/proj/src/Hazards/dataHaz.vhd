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

    i_E_isLoad  : in  std_logic;    -- MemRead      from the Execute stage      -- if producer then lw --> stall once
    i_M_isLoad  : in  std_logic;    -- MemRead      From the Memory  stage

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

    signal s_Erd_isnt_0     : std_logic;    -- This is 0 if rd = 0
    signal s_Mrd_isnt_0     : std_logic;    -- This is 0 if rd = 0

    signal s_MemRS_res      : std_logic;    -- This = 1 if Ex(rd) = DEC(rs1 or rs2)
    signal s_M_Data_Haz     : std_logic;    -- This = 1 if there is a data hazard

    signal s_LoadUseHaz     : std_logic;      
    signal s_BranchExHaz    : std_logic;    
    signal s_BranchMemHaz   : std_logic;
    signal s_Stall          : std_logic;    

    signal os_DataHaz       : std_logic;    -- Internal Signal for final data hazard signal
    signal os_DataBubble    : std_logic;    -- Internal signal for data flush signal


begin

-- Check for dependencies between EX(rd) and RSn:
    -- rs1
    s_Ex_RS1_Dep    <=  i_ExRD xnor i_DecRS1; -- [n,n] = 1, [n,m] = 0

    -- AND tree     -- [E] rd & rs1 equalivent flag
    -- NOTE: These trees were in the form of "v1 <= and v2". The toolflow ran no problem, but the synthesizer did not. It flags it as a VHDL syntax error
    s_EXrd_eq_rs1   <= s_Ex_RS1_Dep(0) and s_Ex_RS1_Dep(1) and s_Ex_RS1_Dep(2) and s_Ex_RS1_Dep(3) and s_Ex_RS1_Dep(4);

    s_Ex_RS2_Dep    <=  i_ExRD xnor i_DecRS2; -- [n,n] = 1, [n,m] = 0

    -- AND tree     -- [E] rd & rs2 equalivent flag
    s_EXrd_eq_rs2   <= s_Ex_RS2_Dep(0) and s_Ex_RS2_Dep(1) and s_Ex_RS2_Dep(2) and s_Ex_RS2_Dep(3) and s_Ex_RS2_Dep(4);
    
-- Check for dependencies betwen M(rd) and RSn:
    -- rs1
    s_Mem_RS1_Dep   <= i_MemRD xnor i_DecRS1;   -- [n,n] = 1, [n,m] = 0
 
    -- AND tree     -- [M] rd & rs1 equalivent flag
    s_Mrd_eq_rs1    <= s_Mem_RS1_Dep(0) and s_Mem_RS1_Dep(1) and s_Mem_RS1_Dep(2) and s_Mem_RS1_Dep(3) and s_Mem_RS1_Dep(4);

    -- rs2
    s_Mem_RS2_Dep   <= i_MemRD xnor i_DecRS2;   -- [n,n] = 1, [n,m] = 0
  
    -- AND tree     -- [M] rd & rs2 equalivent flag
    s_Mrd_eq_rs2    <= s_Mem_RS2_Dep(0) and s_Mem_RS2_Dep(1) and s_Mem_RS2_Dep(2) and s_Mem_RS2_Dep(3) and s_Mem_RS2_Dep(4);

-- These signals are 0 if rd = 0
    s_Erd_isnt_0  <= i_ExRD(0) or i_ExRD(1) or i_ExRD(2) or i_ExRD(3) or i_ExRD(4);   -- OR trees
    s_Mrd_isnt_0  <= i_MemRD(0) or i_MemRD(1) or i_MemRD(2) or i_MemRD(3) or i_MemRD(4);


-- Logic for Data Hazard Output signals
    s_ExRS_res    <= (s_EXrd_eq_rs2 and i_DecUsesRS2) or s_EXrd_eq_rs1;
    s_EX_Data_Haz <= s_ExRS_res and i_ExRegWr and s_Erd_isnt_0;  -- If {RS Haz} and {RegWr Haz} and {rd != 0} --> A data Haz Exists

    s_MemRS_res   <= s_Mrd_eq_rs1 or (s_Mrd_eq_rs2 and i_DecUsesRS2); 
    s_M_Data_Haz  <= s_MemRS_res and i_MemRegWr and s_Mrd_isnt_0; -- If {RS Haz} and {RegWr Haz} and {rd != 0} --> A data Haz Exists

  -----------------------------------------------------------
  ---------------- Output Data Hazard Status ---------------- 
      
    -- If a Data Hazard is detected, these signals go high
    -- Using these signals here for more clarity on waveform
    s_LoaduseHaz    <= s_EX_Data_Haz and i_E_isLoad;
    -- s_BranchExHaz   <= (s_EX_Data_Haz or (s_M_Data_Haz and i_E_isLoad)) and i_isBranch;   -- stall when producer is Ex or load in Mem
    s_BranchExHaz   <= s_EX_Data_Haz and i_isBranch;
    s_BranchMemHaz  <= i_isBranch and s_M_Data_Haz and i_M_isLoad;

    s_Stall         <= s_LoadUseHaz or s_BranchExHaz or s_BranchMemHaz;   -- final stall signal

    o_DataBubble    <= s_Stall;
    o_DataHaz       <= s_Stall;

    -- If the hazard is between execute and decode, and the instruction is a load - stall
            -- lw  x28, _(x_)
            -- and x20, x28, x12
        -- If the hazard is between decode and execute or memory, and the instruction is a branch   - stall (once for EX_Haz, twice for Mem_Haz)
            -- addi x10, x10, 2   /   lw x10, _(x_)
            -- beq x7, x10, Label
            -- DO NOT FORWARD FROM WB TO DECODE - WB already writes to decode/RegFile

end architecture;