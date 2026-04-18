-- Isaiah Pridie
-- CprE 3810    slt component for proj01_ALU
-- Start Date: 3.18.2026,   4:35 PM

-- Should take in MSB, MSB Cin and Cout
-- Outputs 0x00000001 or 0x00000000

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity proj01_SLT is
    port(i_MSB      : in  std_logic;
         i_MSB_Cin  : in  std_logic;
         i_MSB_Cout : in  std_logic;
         o_slt      : out std_logic_vector(31 downto 0);    -- SLT output
         o_sltu     : out std_logic_vector(31 downto 0));    -- SLTu output
end entity;

architecture structural of proj01_SLT is
    
    signal s_signed_carries : std_logic;
    signal s_slt_0          : std_logic;
    signal s_sltu_0         : std_logic;


    component xorg2 is
    port(i_A          : in std_logic;
         i_B          : in std_logic;
         o_F          : out std_logic);
    end component;

    component invg is
    port(i_A          : in std_logic;
         o_F          : out std_logic);
    end component;
begin

    INST_XORg_1: xorg2
    port map(i_A    => i_MSB_Cin,
             i_B    => i_MSB_Cout,
             o_F    => s_signed_carries);

    INST_XORg_2: xorg2
    port map(i_A    => s_signed_carries,
             i_B    => i_MSB,
             o_F    => s_slt_0);

    INST_INVg: invg
    port map(i_A    => i_MSB_Cout,
             o_F    => s_sltu_0);

    -- Pass both results back into the ALU as internal signals
    o_slt   <= (31 downto 1 => '0') & s_slt_0;
    o_sltu  <= (31 downto 1 => '0') & s_sltu_0;

end architecture;