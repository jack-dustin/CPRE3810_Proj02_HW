-- Isaiah Pridie
-- Data Hazard Logic for stalling register file
-- Start Date: 4.18.2026,   2:55 PM

library IEEE;
use IEEE.std_logic_1164.all;

entity dataHaz is(
    i_DecRS1    : in  std_logic_vector(4 downto 0);     -- 5 bits
    i_DecRS2    : in  std_logic_vector(4 downto 0);  
    i_ExRD      : in  std_logic_vector(4 downto 0);
    i_ExRegWr   : in  std_logic;
    i_MemRD     : in  std_logic_vector(4 downto 0);
    i_MemRegWr  : in  std_logic

    o_Hazard    : out std_logic);
end entity;

architecture mixed of dataHaz is

    signal s_Ex_RS1_Dep     : std_logic_vector(4 downto 0);
    signal s_Ex_RS2_Dep     : std_logic_vector(4 downto 0);

    signal s_ExRS1And       : 


begin

    -- Check for Execute Dependencies:
    s_Ex_RS1_Dep(0) <=  i_ExRD(0) xnor i_DecRS1(0);
    s_Ex_RS1_Dep(1) <=  i_ExRD(1) xnor i_DecRS1(1);
    s_Ex_RS1_Dep(2) <=  i_ExRD(2) xnor i_DecRS1(2);
    s_Ex_RS1_Dep(3) <=  i_ExRD(3) xnor i_DecRS1(3);
    s_Ex_RS1_Dep(4) <=  i_ExRD(4) xnor i_DecRS1(4);






end architecture;