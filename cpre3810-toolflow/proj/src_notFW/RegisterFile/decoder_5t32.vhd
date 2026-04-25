-- Isaiah Pridie
-- CprE 3810 Lab2 Part 3.d
-- Start Date: 2.13.2026, 5:33 AM

-- FIRST OUTPUT PORT OF THIS DECODER IS ALWAYS 0
    -- DO NOT CHANGE!!
    -- Reg x0 CAN NEVER BE WRITTEN TO!!!

library IEEE;
use IEEE.std_logic_1164.all;


entity decoder_5t32 is
    port ( i_D  : in std_logic_vector(4 downto 0 ); -- 5 total bits
           i_EN : in std_logic; -- EN
           o_D  : out std_logic_vector(31 downto 0)); -- 32 total bits
end decoder_5t32;

architecture mixed of decoder_5t32 is

    signal dcdr_t_and : std_logic_vector(31 downto 0);  

    component andg2 is
        port (i_A   : in std_logic;
              i_B   : in std_logic;
              o_F   : out std_logic);
    end component;

    begin
        -- Note: Decoder values will still change when EN bit = 0
            -- Does not matter (allegedly) for our purposes
        -- Generate 5 AND gates to maybe force 5 sel bits to 0
        G_nBit_And: for i in 0 to 31 generate 
            -- component port => signal/wire/entity port
            AndI: andg2 port map (
                i_A  => i_EN,           -- EN 
                i_B  => dcdr_t_and(i),  -- input FROM decoder
                o_F  => o_D(i));        -- Final Output
        end generate G_nBit_And;
        
        with i_D select
 dcdr_t_and  <= x"00000000" when "00000",   -- register x0 can NEVER be written to
                x"00000002" when "00001",       
                x"00000004" when "00010",
                x"00000008" when "00011",
                x"00000010" when "00100",
                x"00000020" when "00101",
                x"00000040" when "00110",
                x"00000080" when "00111",
                x"00000100" when "01000",
                x"00000200" when "01001",
                x"00000400" when "01010",
                x"00000800" when "01011",
                x"00001000" when "01100",
                x"00002000" when "01101",
                x"00004000" when "01110",
                x"00008000" when "01111",
                x"00010000" when "10000",
                x"00020000" when "10001",
                x"00040000" when "10010",
                x"00080000" when "10011",
                x"00100000" when "10100",
                x"00200000" when "10101",
                x"00400000" when "10110",
                x"00800000" when "10111",
                x"01000000" when "11000",
                x"02000000" when "11001",
                x"04000000" when "11010",
                x"08000000" when "11011",
                x"10000000" when "11100",
                x"20000000" when "11101",
                x"40000000" when "11110",
                x"80000000" when "11111",
                x"00000000" when others;
end mixed;
