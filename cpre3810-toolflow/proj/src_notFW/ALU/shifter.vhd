-- Isaiah Pridie
-- CprE 3810 Proj01 Barrel_Shifter
-- Start Date: 3.7.2026,    6:03 PM

-- Shifting Unit
-- NOTE: for future optimization
    -- I choose between shifted right or left result at the bottom of this file.
    -- The 8 to 1 mux already does this.
    -- So I a mux to choose between two signals. Split that signal into 2 and send both
        -- to shift right and shift left ports of the 8 to 1 ALU mux
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity shifter is
    port(i_vect_A   : in std_logic_vector(31 downto 0);     -- Input A (RS1)
         i_vect_B   : in std_logic_vector(31 downto 0);     -- Input B (RS2 or Imm)
         c_extend   : in std_logic;     -- Controls Zero or Sign extending | funct7(5)
         c_Shift    : in std_logic;     -- Controls shifting Left or Right | funct3(2)
         o_vect_Out : out std_logic_vector(31 downto 0) );
end shifter;

architecture structural of shifter is

    -- Constant/Wire/Signal declarations:
    signal  s_Rev       : std_logic_vector(31 downto 0);    -- Holds Reverse order of i_vect_A
    signal  s_Frwd      : std_logic_vector(31 downto 0);    -- Holders Reverse Reverse order post shifted
    signal  s_numShift  : std_logic_vector(4 downto 0);     -- 5 bits. Holds Shift amount
    signal  s_ex       : std_logic;

    signal  s_nRLt16    : std_logic_vector(31 downto 0);    -- Carries signal from Fwrd/Reverse to 16b Mux
    signal  s_sRLt16    : std_logic_vector(31 downto 0);
    
    signal  s_n16t8     : std_logic_vector(31 downto 0);    -- Carries signal from 16b Mux to 8b Mux
    signal  s_s16t8     : std_logic_vector(31 downto 0);

    signal  s_n8t4      : std_logic_vector(31 downto 0);    -- Carries signal from 8b Mux to 4b Mux
    signal  s_s8t4      : std_logic_vector(31 downto 0);

    signal  s_n4t2      : std_logic_vector(31 downto 0);    -- Carries signal from 4b Mux to 2b Mux
    signal  s_s4t2      : std_logic_vector(31 downto 0);

    signal  s_n2t1      : std_logic_vector(31 downto 0);    -- Carries signal from 2b Mux to 1b Mux
    signal  s_s2t1      : std_logic_vector(31 downto 0);

    signal  s_n1tout    : std_logic_vector(31 downto 0);    -- Carries signal from 1b Mux to Fwrd/Reverse

    component busMux_2t1 is     -- Used to control rev bit order + Zero/Sign extending
        port(i_dZero  : in std_logic_vector(31 downto 0);
             i_dOne   : in std_logic_vector(31 downto 0);
             ALUSrc   : in std_logic; -- select line. It's named poorly. I wasn't thinking ahead
             o_dOUT   : out std_logic_vector(31 downto 0));
    end component;

    begin
        -- s_ex represents the bit used to sign/zero extend when shifting
        -- Leaving very clear comments because I keep confusing myself with this part
            -- Need to AND 3 arguments:
            -- "Is this a logical or arithmetic shift?" --> c_extend
            -- "Am I shifting right?" --> c_Shift
            -- "Is the number being shifted actually negative?" --> i_vect_A(31) 
        s_ex       <= c_extend and c_Shift and i_vect_A(31);     -- Check this logic later 
        s_numShift  <= i_vect_B(4 downto 0);    -- Now holding shift amount

        -- Reverse the order of the input
        -- Shut Up Warren! It's beautiful!  (and works (hopefully))
        s_Rev(0)    <= i_vect_A(31);
        s_Rev(1)    <= i_vect_A(30);
        s_Rev(2)    <= i_vect_A(29);
        s_Rev(3)    <= i_vect_A(28);
        s_Rev(4)    <= i_vect_A(27);
        s_Rev(5)    <= i_vect_A(26);
        s_Rev(6)    <= i_vect_A(25);
        s_Rev(7)    <= i_vect_A(24);
        s_Rev(8)    <= i_vect_A(23);
        s_Rev(9)    <= i_vect_A(22);
        s_Rev(10)   <= i_vect_A(21);
        s_Rev(11)   <= i_vect_A(20);
        s_Rev(12)   <= i_vect_A(19);
        s_Rev(13)   <= i_vect_A(18);
        s_Rev(14)   <= i_vect_A(17);
        s_Rev(15)   <= i_vect_A(16);
        s_Rev(16)   <= i_vect_A(15);
        s_Rev(17)   <= i_vect_A(14);
        s_Rev(18)   <= i_vect_A(13);
        s_Rev(19)   <= i_vect_A(12);
        s_Rev(20)   <= i_vect_A(11);
        s_Rev(21)   <= i_vect_A(10);
        s_Rev(22)   <= i_vect_A(9);
        s_Rev(23)   <= i_vect_A(8);
        s_Rev(24)   <= i_vect_A(7);
        s_Rev(25)   <= i_vect_A(6);
        s_Rev(26)   <= i_vect_A(5);
        s_Rev(27)   <= i_vect_A(4);
        s_Rev(28)   <= i_vect_A(3);
        s_Rev(29)   <= i_vect_A(2);
        s_Rev(30)   <= i_vect_A(1);
        s_Rev(31)   <= i_vect_A(0);

        -- Passes the Normal or Reversed value
        INST_BUSMUX_RoL1: busMux_2t1
        port map(i_dZero    => s_Rev,       -- Reversed
                 i_dOne     => i_vect_A,    -- Normal
                 ALUSrc     => c_Shift,          
                 o_dOUT     => s_nRLt16);

            -- Logic to shift by 16 bits
            s_sRLt16    <= (31 downto 16 => s_ex) & s_nRLt16(31 downto 16);

        -- Passes 16-Shift or No-Shift value                 
        INST_BUSMUX_16_Shift: busMux_2t1
        port map(i_dZero    => s_nRLt16,       
                 i_dOne     => s_sRLt16,    
                 ALUSrc     => s_numShift(4),          
                 o_dOUT     => s_n16t8);
            
            -- Logic to shift by 8 bits     
            s_s16t8 <= (31 downto 24 => s_ex) & s_n16t8(31 downto 8);

        -- Passes 8-Shift or No-Shift value                 
        INST_BUSMUX_8_Shift: busMux_2t1
        port map(i_dZero    => s_n16t8,       
                 i_dOne     => s_s16t8,    
                 ALUSrc     => s_numShift(3),          
                 o_dOUT     => s_n8t4);

            -- Logic to shift by 4 bits
            s_s8t4 <= (31 downto 28 => s_ex) & s_n8t4(31 downto 4);

        -- Passes 4-Shift or No-Shift value                 
        INST_BUSMUX_4_Shift: busMux_2t1
        port map(i_dZero    => s_n8t4,       
                 i_dOne     => s_s8t4,    
                 ALUSrc     => s_numShift(2),          
                 o_dOUT     => s_n4t2);

            -- Logic to shift by 2 bits
            s_s4t2 <= (31 downto 30 => s_ex) & s_n4t2(31 downto 2);

        -- Passes 2-Shift or No-Shift value                 
        INST_BUSMUX_2_Shift: busMux_2t1
        port map(i_dZero    => s_n4t2,       
                 i_dOne     => s_s4t2,    
                 ALUSrc     => s_numShift(1),          
                 o_dOUT     => s_n2t1);
            -- Logic to shift by 1 bit
            s_s2t1 <= (31 => s_ex) & s_n2t1(31 downto 1);

        -- Passes 1-Shift or No-Shift value   
        INST_BUSMUX_1_Shift: busMux_2t1
        port map(i_dZero    => s_n2t1,       
                 i_dOne     => s_s2t1,    
                 ALUSrc     => s_numShift(0),          
                 o_dOUT     => s_n1tout);


        -- Reverse Reverse bits back by Reversing to Unreversed
        -- IT'S STILL BEAUTIFUL!
        s_Frwd(0)    <= s_n1tout(31);
        s_Frwd(1)    <= s_n1tout(30);
        s_Frwd(2)    <= s_n1tout(29);
        s_Frwd(3)    <= s_n1tout(28);
        s_Frwd(4)    <= s_n1tout(27);
        s_Frwd(5)    <= s_n1tout(26);
        s_Frwd(6)    <= s_n1tout(25);
        s_Frwd(7)    <= s_n1tout(24);
        s_Frwd(8)    <= s_n1tout(23);
        s_Frwd(9)    <= s_n1tout(22);
        s_Frwd(10)   <= s_n1tout(21);
        s_Frwd(11)   <= s_n1tout(20);
        s_Frwd(12)   <= s_n1tout(19);
        s_Frwd(13)   <= s_n1tout(18);
        s_Frwd(14)   <= s_n1tout(17);
        s_Frwd(15)   <= s_n1tout(16);
        s_Frwd(16)   <= s_n1tout(15);
        s_Frwd(17)   <= s_n1tout(14);
        s_Frwd(18)   <= s_n1tout(13);
        s_Frwd(19)   <= s_n1tout(12);
        s_Frwd(20)   <= s_n1tout(11);
        s_Frwd(21)   <= s_n1tout(10);
        s_Frwd(22)   <= s_n1tout(9);
        s_Frwd(23)   <= s_n1tout(8);
        s_Frwd(24)   <= s_n1tout(7);
        s_Frwd(25)   <= s_n1tout(6);
        s_Frwd(26)   <= s_n1tout(5);
        s_Frwd(27)   <= s_n1tout(4);
        s_Frwd(28)   <= s_n1tout(3);
        s_Frwd(29)   <= s_n1tout(2);
        s_Frwd(30)   <= s_n1tout(1);
        s_Frwd(31)   <= s_n1tout(0);

        -- Passes the Normal or Reverse Back To Normal value
        INST_BUSMUX_RoL2: busMux_2t1    
        port map(i_dZero    => s_Frwd,        
                 i_dOne     => s_n1tout,      
                 ALUSrc     => c_Shift,          
                 o_dOUT     => o_vect_Out);

end architecture;
