-- Isaiah Pridie
-- CprE 3810 Lab1 Part 3.6b
-- Start Date: 2.4.2026 6:21 PM

library IEEE;
use IEEE.std_logic_1164.all;

entity addSub is
    generic (N : integer := 32);    -- use 32 for now. Value not specified in Lab Doc
    port (  i_Da        :   in std_logic_vector(N-1 downto 0);
            i_Db        :   in std_logic_vector(N-1 downto 0);
            nAdd_Sub    :   in std_logic;   -- used as control/carry
            o_Sum       :   out std_logic_vector(N-1 downto 0);
            o_Car       :   out std_logic);  -- used for last carry output
end addSub;

architecture structural of addSub is

    -- wires    -- Need them to connect different components
    signal inv_Db   : std_logic_vector(N-1 downto 0);
    signal Mux_t_Add : std_logic_vector(N-1 downto 0);   -- Wire moving i_Db from Mux -> Full Adder


    component basic_adder_n is
        generic (N : natural := 4);     -- 4 by default, but allowed to change
        port (  i_aB0   : in std_logic_vector(N-1 downto 0);
                i_aB1   : in std_logic_vector(N-1 downto 0);
                o_S     : out std_logic_vector(N-1 downto 0);
                i_C     : in std_logic;  -- Not Bus. Used for a control*
                o_C     : out std_logic   ); -- Not Bus. Final Carry Output
    end component;

    component mux2t1_N is   -- from THE Duwe. Yes, Duwe himself!!
        generic (N : natural := 16);
        port (  i_S     : in std_logic;
                i_D0    : in std_logic_vector(N-1 downto 0);
                i_D1    : in std_logic_vector(N-1 downto 0);
                o_O     : out std_logic_vector(N-1 downto 0));
    end component;

    component ones_comp_N is
        generic (N : natural := 32);
        port (  i_OC    : in std_logic_vector(N-1 downto 0);
                o_O     : out std_logic_vector(N-1 downto 0));
    end component;


    -- start building circuit
    begin   

        -- instantiate One's Compliment first
        -- Left is Component's ports. Assigned to signals on Right side
        INST_ONES_COMP: ones_comp_N
            generic map (N => N)
            port map (  i_OC => i_Db,
                        o_O  => inv_Db);
        
        INST_2t1_MUX: mux2t1_N
            generic map (N => N)
            port map (  i_S  => nAdd_Sub,
                        i_D0 => i_Db,
                        i_D1 => inv_Db,
                        o_O  => Mux_t_Add);

        INST_ADDER: basic_adder_n
            generic map (N => N)
            port map (  i_aB0 => i_Da,
                        i_aB1 => Mux_t_Add,
                        o_S   => o_Sum,
                        i_C   => nAdd_Sub,
                        o_C   => o_Car);
end architecture;



    