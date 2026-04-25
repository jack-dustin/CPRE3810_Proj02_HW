-- Isaiah Pridie
-- CprE 3810 proj01 32-bit 8 to 1 mux
-- Start Date: 3.18.2026,   6:58 PM

library IEEE;
use IEEE.std_logic_1164.all;

entity busMux_8t1 is
    port(i_D0   : in  std_logic_vector(31 downto 0);
         i_D1   : in  std_logic_vector(31 downto 0);
         i_D2   : in  std_logic_vector(31 downto 0);
         i_D3   : in  std_logic_vector(31 downto 0);
         i_D4   : in  std_logic_vector(31 downto 0);
         i_D5   : in  std_logic_vector(31 downto 0);
         i_D6   : in  std_logic_vector(31 downto 0);
         i_D7   : in  std_logic_vector(31 downto 0);
         c_sel0 : in  std_logic;
         c_sel1 : in  std_logic;
         c_sel2 : in  std_logic;
         o_Dout : out std_logic_vector(31 downto 0));
end entity;

architecture structural of busMux_8t1 is
    
    signal s_mux4t1_0   : std_logic_vector(31 downto 0);
    signal s_mux4t1_1   : std_logic_vector(31 downto 0);

    component busMux_2t1 is
        port(i_dZero  : in  std_logic_vector(31 downto 0);
             i_dOne   : in  std_logic_vector(31 downto 0);
             ALUSrc   : in  std_logic; -- select line. It's named poorly. I wasn't thinking ahead
             o_dOUT   : out std_logic_vector(31 downto 0));
    end component;

    component busMux_4t1 is 
        port(i_Da   : in  std_logic_vector(31 downto 0);    -- Input 1
             i_Db   : in  std_logic_vector(31 downto 0);    -- Input 2
             i_Dc   : in  std_logic_vector(31 downto 0);    -- Input 3
             i_Dd   : in  std_logic_vector(31 downto 0);    -- Input 4
             C_S0   : in  std_logic;                        -- Sel line 0
             C_S1   : in  std_logic;                        -- Sel line 1
             o_Do   : out std_logic_vector(31 downto 0) );  -- Output
    end component;

begin

    INST_BUSMUX_4t1_0: busMux_4t1 port map(
        i_Da    => i_D0,     
        i_Db    => i_D1,      
        i_Dc    => i_D2,     
        i_Dd    => i_D3,      
        C_S0    => c_sel0,     
        C_S1    => c_sel1,     
        o_Do    => s_mux4t1_0);      

    INST_BUSMUX_4t1_1: busMux_4t1 port map(
        i_Da    => i_D4,        
        i_Db    => i_D5,      
        i_Dc    => i_D6,         
        i_Dd    => i_D7,        
        C_S0    => c_sel0,     
        C_S1    => c_sel1,     
        o_Do    => s_mux4t1_1);      

    INST_BUSMUX_2t1_2: busMux_2t1 port map(
        i_dZero => s_mux4t1_0,       
        i_dOne  => s_mux4t1_1,       
        ALUSrc  => c_sel2,      
        o_dOUT  => o_Dout);       

end architecture;