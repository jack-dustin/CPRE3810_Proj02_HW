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

    i_CLK       : in  std_logic;
    i_RST       : in  std_logic;

    o_DataHaz   : out std_logic;
    o_DataBubble: out std_logic);
end entity;

architecture mixed of dataHaz is

    -- Checking Execute
    signal s_Ex_RS1_Dep     : std_logic_vector(4 downto 0);
    signal s_Ex_RS2_Dep     : std_logic_vector(4 downto 0);

    signal s_ExRS1And_0     : std_logic;
    signal s_ExRS1And_1     : std_logic;
    signal s_ExRS1And_2     : std_logic;
    signal s_ExRS1And_3     : std_logic;    -- This = 1 if EX(rd) = DEC(rs1)


    signal s_ExRS2And_0     : std_logic;
    signal s_ExRS2And_1     : std_logic;
    signal s_ExRS2And_2     : std_logic;
    signal s_ExRS2And_3     : std_logic;    -- This = 1 if EX(rd) = DEC(rs2)

    signal s_ExRS_res       : std_logic;    -- This = 1 if Ex(rd) = DEC(rs1 or rs2)
    signal s_ExRS_DataDep   : std_logic;    -- This = 1 if there is a data hazard

    -- Checking Memory
    signal s_Mem_RS1_Dep    : std_logic_vector(4 downto 0);
    signal s_Mem_RS2_Dep    : std_logic_vector(4 downto 0);

    signal s_MemRS1And_0    : std_logic;
    signal s_MemRS1And_1    : std_logic;
    signal s_MemRS1And_2    : std_logic;
    signal s_MemRS1And_3    : std_logic;    -- This = 1 if EX(rd) = DEC(rs1)


    signal s_MemRS2And_0    : std_logic;
    signal s_MemRS2And_1    : std_logic;
    signal s_MemRS2And_2    : std_logic;
    signal s_MemRS2And_3    : std_logic;    -- This = 1 if EX(rd) = DEC(rs2)

    signal s_MemRS_res      : std_logic;    -- This = 1 if Ex(rd) = DEC(rs1 or rs2)
    signal s_MemRS_DataDep  : std_logic;    -- This = 1 if there is a data hazard

    signal os_DataHaz       : std_logic;    -- Internal Signal for final data hazard signal
    signal os_DataBuble     : std_logic;    -- Internal signal for data flush signal

component dffg is
  port(i_CLK        : in std_logic;     -- Clock input
       i_RST        : in std_logic;     -- Reset input
       i_WE         : in std_logic;     -- Write enable input
       i_D          : in std_logic;     -- Data value input
       o_Q          : out std_logic);   -- Data value output
end component;

begin

  -- EX(rd) AND DEC(rs1)
    -- Check for dependencies between Ex rd and RS1:
    s_Ex_RS1_Dep(0) <=  i_ExRD(0) xnor i_DecRS1(0);
    s_Ex_RS1_Dep(1) <=  i_ExRD(1) xnor i_DecRS1(1);
    s_Ex_RS1_Dep(2) <=  i_ExRD(2) xnor i_DecRS1(2);
    s_Ex_RS1_Dep(3) <=  i_ExRD(3) xnor i_DecRS1(3);
    s_Ex_RS1_Dep(4) <=  i_ExRD(4) xnor i_DecRS1(4);

    -- AND tree
    s_ExRS1And_0    <= s_Ex_RS1_Dep(0) and s_Ex_RS1_Dep(1);
    s_ExRS1And_1    <= s_Ex_RS1_Dep(2) and s_Ex_RS1_Dep(3);
    s_ExRS1And_2    <= s_ExRS1And_0 and s_ExRS1And_1;
    s_ExRS1And_3    <= s_ExRS1And_2 and s_Ex_RS1_Dep(4);


  -- EX(rd) AND DEC(rs2)
    s_Ex_RS2_Dep(0) <=  i_ExRD(0) xnor i_DecRS2(0);
    s_Ex_RS2_Dep(1) <=  i_ExRD(1) xnor i_DecRS2(1);
    s_Ex_RS2_Dep(2) <=  i_ExRD(2) xnor i_DecRS2(2);
    s_Ex_RS2_Dep(3) <=  i_ExRD(3) xnor i_DecRS2(3);
    s_Ex_RS2_Dep(4) <=  i_ExRD(4) xnor i_DecRS2(4);

    -- AND tree
    s_ExRS2And_0    <= s_Ex_RS2_Dep(0) and s_Ex_RS2_Dep(1);
    s_ExRS2And_1    <= s_Ex_RS2_Dep(2) and s_Ex_RS2_Dep(3);
    s_ExRS2And_2    <= s_ExRS2And_0 and s_ExRS2And_1;
    s_ExRS2And_3    <= s_ExRS2And_2 and s_Ex_RS2_Dep(4);

    s_ExRS_res      <= s_ExRS2And_3 or s_ExRS1And_3;
    s_ExRS_DataDep  <= s_ExRS_res and i_ExRegWr;    -- If RS Haz and RegWr Haz --> A data Haz Exists


  -- MEM(rd) and DEC(rs1)
    -- Check for dependencies betwen Mem rd and RS1:
    s_Mem_RS1_Dep(0)    <= i_MemRD(0) xnor i_DecRS1(0);
    s_Mem_RS1_Dep(1)    <= i_MemRD(1) xnor i_DecRS1(1);
    s_Mem_RS1_Dep(2)    <= i_MemRD(2) xnor i_DecRS1(2);
    s_Mem_RS1_Dep(3)    <= i_MemRD(3) xnor i_DecRS1(3);
    s_Mem_RS1_Dep(4)    <= i_MemRD(4) xnor i_DecRS1(4);

    -- AND tree
    s_MemRS1And_0   <= s_Mem_RS1_Dep(0) and s_Mem_RS1_Dep(1);
    s_MemRS1And_1   <= s_Mem_RS1_Dep(2) and s_Mem_RS1_Dep(3);
    s_MemRS1And_2   <= s_MemRS1And_0 and s_MemRS1And_1;
    s_MemRS1And_3   <= s_MemRS1And_2 and s_Mem_RS1_Dep(4);

  -- MEM(rd) and DEC(rs2)
    s_Mem_RS2_Dep(0)    <= i_MemRD(0) xnor i_DecRS2(0);
    s_Mem_RS2_Dep(1)    <= i_MemRD(1) xnor i_DecRS2(1);
    s_Mem_RS2_Dep(2)    <= i_MemRD(2) xnor i_DecRS2(2);
    s_Mem_RS2_Dep(3)    <= i_MemRD(3) xnor i_DecRS2(3);
    s_Mem_RS2_Dep(4)    <= i_MemRD(4) xnor i_DecRS2(4);

    -- AND tree
    s_MemRS2And_0   <= s_Mem_RS2_Dep(0) and s_Mem_RS2_Dep(1);
    s_MemRS2And_1   <= s_Mem_RS2_Dep(2) and s_Mem_RS2_Dep(3);
    s_MemRS2And_2   <= s_MemRS2And_0 and s_MemRS2And_1;
    s_MemRS2And_3   <= s_MemRS2And_2 and s_Mem_RS2_Dep(4);

    s_MemRS_res     <= s_MemRS1And_3 or s_MemRS2And_3; 
    s_MemRS_DataDep <= s_MemRS_res and i_MemRegWr;  -- If RS Haz and RegWr Haz --> A data Hazard Exists

    -- If a Data Hazard is detected from Execute or Memory, this outputs 1
    o_DataHaz   <= os_DataHaz;
    os_DataHaz   <= s_MemRS_DataDep or s_ExRS_DataDep;

    -- Make sure DEC/EX register flush is synchronous with clock
    INST_DFFG: dffg port map(
    i_CLK   => i_CLK,
    i_RST   => i_RST,
    i_WE    => '1',
    i_D     => os_DataHaz,
    o_Q     => os_DataBubble);

    -- Ensures the reset is enabled at the clock edge, but also reset goes low to allow next instruction through
    o_DataBuble <= os_DataBubble and os_DataHaz;
end architecture;