-- -- Isaiah Pridie
-- -- BLT_output block for decode stage
--     -- 32 bit comparator to compare Vector A to Vector B. Takes outputs, combines them in a tree structure. Outputs final result
--     -- Max of 12 gate delays (bltu) as opposed to using a subtractor
--     -- I don't know how much of this actually needs to be based on generics... But the values make sense. Assume N = 32.
-- -- Start Date: 4.12.2026,   3:19 PM

-- library IEEE;
-- use IEEE.std_logic_1164.all;

-- entity proj2_blt is
--     generic(N : integer := 32); 
--     port(i_A        : in  std_logic_vector(N-1 downto 0);
--          i_B        : in  std_logic_vector(N-1 downto 0);
--          o_beqOut   : out std_logic;
--          o_bltuOut  : out std_logic;
--          o_bguOut   : out std_logic);
-- end entity;

-- architecture mixed of proj2_blt is

--     signal s_Comp_EQ    : std_logic_vector(N-1 downto 0);   -- 32 bit ouput
--         signal s_Comp_EQ_0  : std_logic_vector((N-1)/2 downto 0);   -- 16 bit input
--         signal s_Comp_EQ_1  : std_logic_vector((N-1)/2 downto 0);

--     signal s_Comp_LT    : std_logic_vector(N-1 downto 0);
--         signal s_Comp_LT_0  : std_logic_vector((N-1)/2 downto 0);
--         signal s_Comp_LT_1  : std_logic_vector((N-1)/2 downto 0);

--     signal s_Comp_GT    : std_logic_vector(N-1 downto 0);
--         signal s_Comp_GT_0  : std_logic_vector((N-1)/2 downto 0);
--         signal s_Comp_GT_1  : std_logic_vector((N-1)/2 downto 0);



--     signal s_Comb_EQ_16t8   : std_logic_vector((N-1)/2 downto 0);   -- 16 bit output
--         signal s_Comb_EQ_16t8_0 : std_logic_vector((N-1)/4 downto 0);   -- 8 bit input
--         signal s_Comb_EQ_16t8_1 : std_logic_vector((N-1)/4 downto 0);

--     signal s_Comb_LT_16t8   : std_logic_vector((N-1)/2 downto 0);
--         signal s_Comb_LT_16t8_0 : std_logic_vector((N-1)/4 downto 0);
--         signal s_Comb_LT_16t8_1 : std_logic_vector((N-1)/4 downto 0);

--     signal s_Comb_GT_16t8   : std_logic_vector((N-1)/2 downto 0);
--         signal s_Comb_GT_16t8_0 : std_logic_vector((N-1)/4 downto 0);
--         signal s_Comb_GT_16t8_1 : std_logic_vector((N-1)/4 downto 0);



--     signal s_Comb_EQ_8t4    : std_logic_vector((N-1)/4 downto 0);   -- 8 bit output
--         signal s_Comb_EQ_8t4_0 : std_logic_vector((N-1)/8 downto 0);   -- 4 bit input
--         signal s_Comb_EQ_8t4_1 : std_logic_vector((N-1)/8 downto 0);

--     signal s_Comb_LT_8t4    : std_logic_vector((N-1)/4 downto 0);   
--         signal s_Comb_LT_8t4_0 : std_logic_vector((N-1)/8 downto 0); 
--         signal s_Comb_LT_8t4_1 : std_logic_vector((N-1)/8 downto 0);
        
--     signal s_Comb_GT_8t4    : std_logic_vector((N-1)/4 downto 0);  
--         signal s_Comb_GT_8t4_0 : std_logic_vector((N-1)/8 downto 0);  
--         signal s_Comb_GT_8t4_1 : std_logic_vector((N-1)/8 downto 0);



--     signal s_Comb_EQ_4t2    : std_logic_vector((N-1)/8 downto 0);   -- 4 bit output
--         signal s_Comb_EQ_4t2_0  : std_logic_vector((N-1)/16 downto 0);  -- 2 bit input
--         signal s_Comb_EQ_4t2_1  : std_logic_vector((N-1)/16 downto 0);  

--     signal s_Comb_LT_4t2    : std_logic_vector((N-1)/8 downto 0);   
--         signal s_Comb_LT_4t2_0  : std_logic_vector((N-1)/16 downto 0);
--         signal s_Comb_LT_4t2_1  : std_logic_vector((N-1)/16 downto 0);

--     signal s_Comb_GT_4t2    : std_logic_vector((N-1)/8 downto 0);   
--         signal s_Comb_GT_4t2_0  : std_logic_vector((N-1)/16 downto 0);
--         signal s_Comb_GT_4t2_1  : std_logic_vector((N-1)/16 downto 0);



--     signal s_Comb_EQ_2t1    : std_logic_vector((N-1)/16 downto 0);  -- 2 bit output
--         signal s_Comb_EQ_2t1_0  : std_logic_vector((N-1)/32 downto 0);  -- 1 bit input
--         signal s_Comb_EQ_2t1_1  : std_logic_vector((N-1)/32 downto 0);

--     signal s_Comb_LT_2t1    : std_logic_vector((N-1)/16 downto 0);
--         signal s_Comb_LT_2t1_0  : std_logic_vector((N-1)/32 downto 0);
--         signal s_Comb_LT_2t1_1  : std_logic_vector((N-1)/32 downto 0);

--     signal s_Comb_GT_2t1    : std_logic_vector((N-1)/16 downto 0);
--         signal s_Comb_GT_2t1_0  : std_logic_vector((N-1)/32 downto 0);
--         signal s_Comb_GT_2t1_1  : std_logic_vector((N-1)/32 downto 0);


--     signal so_beqOut    : std_logic_vector((N-1)/32 downto 0);
--     signal so_bltuOut   : std_logic_vector((N-1)/32 downto 0);
--     signal so_bguOut    : std_logic_vector((N-1)/32 downto 0);


-- component comparator_n is
--     generic (N : integer := 32); 
--     port(i_A    : in  std_logic_vector(N-1 downto 0);
--          i_B    : in  std_logic_vector(N-1 downto 0);
--          o_EQ   : out std_logic_vector(N-1 downto 0);
--          o_LT   : out std_logic_vector(N-1 downto 0);
--          o_GT   : out std_logic_vector(N-1 downto 0));  
-- end component;

-- component blt_combine_n is
--     generic (N : integer := 32); 
--     port(i_EQ0  : in  std_logic_vector(N-1 downto 0);
--          i_EQ1  : in  std_logic_vector(N-1 downto 0);
--          i_LT0  : in  std_logic_vector(N-1 downto 0);
--          i_LT1  : in  std_logic_vector(N-1 downto 0);
--          i_GT0  : in  std_logic_vector(N-1 downto 0);
--          i_GT1  : in  std_logic_vector(N-1 downto 0);

--          o_EQ   : out std_logic_vector(N-1 downto 0);
--          o_LT   : out std_logic_vector(N-1 downto 0);
--          o_GT   : out std_logic_vector(N-1 downto 0));
-- end component;

-- begin

--     INST_32_Compare: comparator_n 
--     generic map (N => N)
--     port map(i_A  => i_A,
--              i_B  => i_B,
--              o_EQ => s_Comp_EQ,
--              o_LT => s_Comp_LT,
--              o_GT => s_Comp_GT);

--     -- Doing process statements JUST for signal assignments. EVERYONE CALM DOWN!!!!
--         -- It is either this or proj01_BEQ.vhd times six.
--     Comb_32_t_16: process(all)  -- "Run this process whenever any signal that I read inside this process changes"
--     begin
--         for i in 0 to (N-1)/2 loop
--             s_Comp_EQ_0(i)  <= s_Comp_EQ(i * 2);        -- 0, 2, 4, 6, ..., 30
--             s_Comp_EQ_1(i)  <= s_Comp_EQ((i * 2) + 1);  -- 1, 3, 5, 7, ..., 31
--             s_Comp_LT_0(i)  <= s_Comp_LT(i * 2);
--             s_Comp_LT_1(i)  <= s_Comp_LT((i * 2) + 1);
--             s_Comp_GT_0(i)  <= s_Comp_GT(i * 2);
--             s_Comp_GT_1(i)  <= s_Comp_GT((i * 2) + 1);
--         end loop;
--     end process;

--     INST_16_Combine: blt_combine_n
--     generic map (N => N/2)
--     port map(i_EQ0 => s_Comp_EQ_0,
--              i_EQ1 => s_Comp_EQ_1,
--              i_LT0 => s_Comp_LT_0,
--              i_LT1 => s_Comp_LT_1,
--              i_GT0 => s_Comp_GT_0,
--              i_GT1 => s_Comp_GT_1,
--              o_EQ  => s_Comb_EQ_16t8,
--              o_LT  => s_Comb_LT_16t8,
--              o_GT  => s_Comb_GT_16t8);

--     Comb_16_t_8: process(all) 
--     begin
--         for i in 0 to (N-1)/4 loop
--             s_Comb_EQ_16t8_0(i)  <= s_Comb_EQ_16t8(i * 2);        -- 0, 2, 4, 6, ..., 14
--             s_Comb_EQ_16t8_1(i)  <= s_Comb_EQ_16t8((i * 2) + 1);  -- 1, 3, 5, 7, ..., 15
--             s_Comb_LT_16t8_0(i)  <= s_Comb_LT_16t8(i * 2);
--             s_Comb_LT_16t8_1(i)  <= s_Comb_LT_16t8((i * 2) + 1);
--             s_Comb_GT_16t8_0(i)  <= s_Comb_GT_16t8(i * 2);
--             s_Comb_GT_16t8_1(i)  <= s_Comb_GT_16t8((i * 2) + 1);
--         end loop;
--     end process;

--     INST_8_Combine: blt_combine_n
--     generic map (N => N/4)
--     port map(i_EQ0 => s_Comb_EQ_16t8_0,
--              i_EQ1 => s_Comb_EQ_16t8_1,
--              i_LT0 => s_Comb_LT_16t8_0,
--              i_LT1 => s_Comb_LT_16t8_1,
--              i_GT0 => s_Comb_GT_16t8_0,
--              i_GT1 => s_Comb_GT_16t8_1,
--              o_EQ  => s_Comb_EQ_8t4,
--              o_LT  => s_Comb_LT_8t4,
--              o_GT  => s_Comb_GT_8t4);

--     Comb_8_t_4: process(all)
--     begin
--         for i in 0 to (N-1)/8 loop
--             s_Comb_EQ_8t4_0(i)  <= s_Comb_EQ_8t4(i * 2);        -- 0, 2, 4, 6
--             s_Comb_EQ_8t4_1(i)  <= s_Comb_EQ_8t4((i * 2) + 1);  -- 1, 3, 5, 7
--             s_Comb_LT_8t4_0(i)  <= s_Comb_LT_8t4(i * 2);
--             s_Comb_LT_8t4_1(i)  <= s_Comb_LT_8t4((i * 2) + 1);
--             s_Comb_GT_8t4_0(i)  <= s_Comb_GT_8t4(i * 2);
--             s_Comb_GT_8t4_1(i)  <= s_Comb_GT_8t4((i * 2) + 1);
--         end loop;
--     end process;

--     INST_4_Combine: blt_combine_n
--     generic map (N => N/8)
--     port map(i_EQ0 => s_Comb_EQ_8t4_0,
--              i_EQ1 => s_Comb_EQ_8t4_1,
--              i_LT0 => s_Comb_LT_8t4_0,
--              i_LT1 => s_Comb_LT_8t4_1,
--              i_GT0 => s_Comb_GT_8t4_0,
--              i_GT1 => s_Comb_GT_8t4_1,
--              o_EQ  => s_Comb_EQ_4t2,
--              o_LT  => s_Comb_LT_4t2,
--              o_GT  => s_Comb_GT_4t2);

--     Comb_4_t_2: process(all) 
--     begin
--         for i in 0 to (N-1)/16 loop
--             s_Comb_EQ_4t2_0(i)  <= s_Comb_EQ_4t2(i * 2);        -- 0, 2
--             s_Comb_EQ_4t2_1(i)  <= s_Comb_EQ_4t2((i * 2) + 1);  -- 1, 3
--             s_Comb_LT_4t2_0(i)  <= s_Comb_LT_4t2(i * 2);
--             s_Comb_LT_4t2_1(i)  <= s_Comb_LT_4t2((i * 2) + 1);
--             s_Comb_GT_4t2_0(i)  <= s_Comb_GT_4t2(i * 2);
--             s_Comb_GT_4t2_1(i)  <= s_Comb_GT_4t2((i * 2) + 1);
--         end loop;
--     end process;

--     INST_2_Combine: blt_combine_n
--     generic map (N => N/16)
--     port map(i_EQ0 => s_Comb_EQ_4t2_0,
--              i_EQ1 => s_Comb_EQ_4t2_1,
--              i_LT0 => s_Comb_LT_4t2_0,
--              i_LT1 => s_Comb_LT_4t2_1,
--              i_GT0 => s_Comb_GT_4t2_0,
--              i_GT1 => s_Comb_GT_4t2_1,
--              o_EQ  => s_Comb_EQ_2t1,
--              o_LT  => s_Comb_LT_2t1,
--              o_GT  => s_Comb_GT_2t1);

--     s_Comb_EQ_2t1_0(0) <= s_Comb_EQ_2t1(0);
--     s_Comb_EQ_2t1_1(0) <= s_Comb_EQ_2t1(1);
--     s_Comb_LT_2t1_0(0) <= s_Comb_LT_2t1(0);
--     s_Comb_LT_2t1_1(0) <= s_Comb_LT_2t1(1);
--     s_Comb_GT_2t1_0(0) <= s_Comb_GT_2t1(0);
--     s_Comb_GT_2t1_1(0) <= s_Comb_GT_2t1(1);

--     INST_1_Combine: blt_combine_n
--     generic map (N => N/32)
--     port map(i_EQ0 => s_Comb_EQ_2t1_0,
--              i_EQ1 => s_Comb_EQ_2t1_1,
--              i_LT0 => s_Comb_LT_2t1_0,
--              i_LT1 => s_Comb_LT_2t1_1,
--              i_GT0 => s_Comb_GT_2t1_0,
--              i_GT1 => s_Comb_GT_2t1_1,
--              o_EQ  => so_beqOut,             -- Maybe use later
--              o_LT  => so_bltuOut,
--              o_GT  => so_bguOut);            -- Maybe use later

--     o_beqOut    <= so_beqOut(0);
--     o_bltuOut   <= so_bltuOut(0);
--     o_bguOut    <= so_bguOut(0);

-- end architecture;

library IEEE;
use IEEE.std_logic_1164.all;

entity proj2_blt is
    generic(N : integer := 32); 
    port(i_A        : in  std_logic_vector(N-1 downto 0);
         i_B        : in  std_logic_vector(N-1 downto 0);
         o_beqOut   : out std_logic;
         o_bltuOut  : out std_logic;
         o_bguOut   : out std_logic);
end entity;

architecture mixed of proj2_blt is

    signal s_Comp_EQ    : std_logic_vector(N-1 downto 0);
    signal s_Comp_EQ_0  : std_logic_vector((N-1)/2 downto 0);
    signal s_Comp_EQ_1  : std_logic_vector((N-1)/2 downto 0);

    signal s_Comp_LT    : std_logic_vector(N-1 downto 0);
    signal s_Comp_LT_0  : std_logic_vector((N-1)/2 downto 0);
    signal s_Comp_LT_1  : std_logic_vector((N-1)/2 downto 0);

    signal s_Comp_GT    : std_logic_vector(N-1 downto 0);
    signal s_Comp_GT_0  : std_logic_vector((N-1)/2 downto 0);
    signal s_Comp_GT_1  : std_logic_vector((N-1)/2 downto 0);

    signal s_Comb_EQ_16t8   : std_logic_vector((N-1)/2 downto 0);
    signal s_Comb_EQ_16t8_0 : std_logic_vector((N-1)/4 downto 0);
    signal s_Comb_EQ_16t8_1 : std_logic_vector((N-1)/4 downto 0);

    signal s_Comb_LT_16t8   : std_logic_vector((N-1)/2 downto 0);
    signal s_Comb_LT_16t8_0 : std_logic_vector((N-1)/4 downto 0);
    signal s_Comb_LT_16t8_1 : std_logic_vector((N-1)/4 downto 0);

    signal s_Comb_GT_16t8   : std_logic_vector((N-1)/2 downto 0);
    signal s_Comb_GT_16t8_0 : std_logic_vector((N-1)/4 downto 0);
    signal s_Comb_GT_16t8_1 : std_logic_vector((N-1)/4 downto 0);

    signal s_Comb_EQ_8t4    : std_logic_vector((N-1)/4 downto 0);
    signal s_Comb_EQ_8t4_0  : std_logic_vector((N-1)/8 downto 0);
    signal s_Comb_EQ_8t4_1  : std_logic_vector((N-1)/8 downto 0);

    signal s_Comb_LT_8t4    : std_logic_vector((N-1)/4 downto 0);   
    signal s_Comb_LT_8t4_0  : std_logic_vector((N-1)/8 downto 0); 
    signal s_Comb_LT_8t4_1  : std_logic_vector((N-1)/8 downto 0);
        
    signal s_Comb_GT_8t4    : std_logic_vector((N-1)/4 downto 0);  
    signal s_Comb_GT_8t4_0  : std_logic_vector((N-1)/8 downto 0);  
    signal s_Comb_GT_8t4_1  : std_logic_vector((N-1)/8 downto 0);

    signal s_Comb_EQ_4t2    : std_logic_vector((N-1)/8 downto 0);
    signal s_Comb_EQ_4t2_0  : std_logic_vector((N-1)/16 downto 0);
    signal s_Comb_EQ_4t2_1  : std_logic_vector((N-1)/16 downto 0);

    signal s_Comb_LT_4t2    : std_logic_vector((N-1)/8 downto 0);   
    signal s_Comb_LT_4t2_0  : std_logic_vector((N-1)/16 downto 0);
    signal s_Comb_LT_4t2_1  : std_logic_vector((N-1)/16 downto 0);

    signal s_Comb_GT_4t2    : std_logic_vector((N-1)/8 downto 0);   
    signal s_Comb_GT_4t2_0  : std_logic_vector((N-1)/16 downto 0);
    signal s_Comb_GT_4t2_1  : std_logic_vector((N-1)/16 downto 0);

    signal s_Comb_EQ_2t1    : std_logic_vector((N-1)/16 downto 0);
    signal s_Comb_EQ_2t1_0  : std_logic_vector((N-1)/32 downto 0);
    signal s_Comb_EQ_2t1_1  : std_logic_vector((N-1)/32 downto 0);

    signal s_Comb_LT_2t1    : std_logic_vector((N-1)/16 downto 0);
    signal s_Comb_LT_2t1_0  : std_logic_vector((N-1)/32 downto 0);
    signal s_Comb_LT_2t1_1  : std_logic_vector((N-1)/32 downto 0);

    signal s_Comb_GT_2t1    : std_logic_vector((N-1)/16 downto 0);
    signal s_Comb_GT_2t1_0  : std_logic_vector((N-1)/32 downto 0);
    signal s_Comb_GT_2t1_1  : std_logic_vector((N-1)/32 downto 0);

    signal so_beqOut    : std_logic_vector((N-1)/32 downto 0);
    signal so_bltuOut   : std_logic_vector((N-1)/32 downto 0);
    signal so_bguOut    : std_logic_vector((N-1)/32 downto 0);

component comparator_n is
    generic (N : integer := 32); 
    port(i_A    : in  std_logic_vector(N-1 downto 0);
         i_B    : in  std_logic_vector(N-1 downto 0);
         o_EQ   : out std_logic_vector(N-1 downto 0);
         o_LT   : out std_logic_vector(N-1 downto 0);
         o_GT   : out std_logic_vector(N-1 downto 0));  
end component;

component blt_combine_n is
    generic (N : integer := 32); 
    port(i_EQ0  : in  std_logic_vector(N-1 downto 0);
         i_EQ1  : in  std_logic_vector(N-1 downto 0);
         i_LT0  : in  std_logic_vector(N-1 downto 0);
         i_LT1  : in  std_logic_vector(N-1 downto 0);
         i_GT0  : in  std_logic_vector(N-1 downto 0);
         i_GT1  : in  std_logic_vector(N-1 downto 0);
         o_EQ   : out std_logic_vector(N-1 downto 0);
         o_LT   : out std_logic_vector(N-1 downto 0);
         o_GT   : out std_logic_vector(N-1 downto 0));
end component;

begin

    INST_32_Compare: comparator_n 
    generic map (N => N)
    port map(i_A  => i_A,
             i_B  => i_B,
             o_EQ => s_Comp_EQ,
             o_LT => s_Comp_LT,
             o_GT => s_Comp_GT);

    GEN_32_TO_16 : for i in 0 to (N-1)/2 generate
    begin
        s_Comp_EQ_0(i) <= s_Comp_EQ(i * 2);
        s_Comp_EQ_1(i) <= s_Comp_EQ((i * 2) + 1);
        s_Comp_LT_0(i) <= s_Comp_LT(i * 2);
        s_Comp_LT_1(i) <= s_Comp_LT((i * 2) + 1);
        s_Comp_GT_0(i) <= s_Comp_GT(i * 2);
        s_Comp_GT_1(i) <= s_Comp_GT((i * 2) + 1);
    end generate;

    INST_16_Combine: blt_combine_n
    generic map (N => N/2)
    port map(i_EQ0 => s_Comp_EQ_0,
             i_EQ1 => s_Comp_EQ_1,
             i_LT0 => s_Comp_LT_0,
             i_LT1 => s_Comp_LT_1,
             i_GT0 => s_Comp_GT_0,
             i_GT1 => s_Comp_GT_1,
             o_EQ  => s_Comb_EQ_16t8,
             o_LT  => s_Comb_LT_16t8,
             o_GT  => s_Comb_GT_16t8);

    GEN_16_TO_8 : for i in 0 to (N-1)/4 generate
    begin
        s_Comb_EQ_16t8_0(i) <= s_Comb_EQ_16t8(i * 2);
        s_Comb_EQ_16t8_1(i) <= s_Comb_EQ_16t8((i * 2) + 1);
        s_Comb_LT_16t8_0(i) <= s_Comb_LT_16t8(i * 2);
        s_Comb_LT_16t8_1(i) <= s_Comb_LT_16t8((i * 2) + 1);
        s_Comb_GT_16t8_0(i) <= s_Comb_GT_16t8(i * 2);
        s_Comb_GT_16t8_1(i) <= s_Comb_GT_16t8((i * 2) + 1);
    end generate;

    INST_8_Combine: blt_combine_n
    generic map (N => N/4)
    port map(i_EQ0 => s_Comb_EQ_16t8_0,
             i_EQ1 => s_Comb_EQ_16t8_1,
             i_LT0 => s_Comb_LT_16t8_0,
             i_LT1 => s_Comb_LT_16t8_1,
             i_GT0 => s_Comb_GT_16t8_0,
             i_GT1 => s_Comb_GT_16t8_1,
             o_EQ  => s_Comb_EQ_8t4,
             o_LT  => s_Comb_LT_8t4,
             o_GT  => s_Comb_GT_8t4);

    GEN_8_TO_4 : for i in 0 to (N-1)/8 generate
    begin
        s_Comb_EQ_8t4_0(i) <= s_Comb_EQ_8t4(i * 2);
        s_Comb_EQ_8t4_1(i) <= s_Comb_EQ_8t4((i * 2) + 1);
        s_Comb_LT_8t4_0(i) <= s_Comb_LT_8t4(i * 2);
        s_Comb_LT_8t4_1(i) <= s_Comb_LT_8t4((i * 2) + 1);
        s_Comb_GT_8t4_0(i) <= s_Comb_GT_8t4(i * 2);
        s_Comb_GT_8t4_1(i) <= s_Comb_GT_8t4((i * 2) + 1);
    end generate;

    INST_4_Combine: blt_combine_n
    generic map (N => N/8)
    port map(i_EQ0 => s_Comb_EQ_8t4_0,
             i_EQ1 => s_Comb_EQ_8t4_1,
             i_LT0 => s_Comb_LT_8t4_0,
             i_LT1 => s_Comb_LT_8t4_1,
             i_GT0 => s_Comb_GT_8t4_0,
             i_GT1 => s_Comb_GT_8t4_1,
             o_EQ  => s_Comb_EQ_4t2,
             o_LT  => s_Comb_LT_4t2,
             o_GT  => s_Comb_GT_4t2);

    GEN_4_TO_2 : for i in 0 to (N-1)/16 generate
    begin
        s_Comb_EQ_4t2_0(i) <= s_Comb_EQ_4t2(i * 2);
        s_Comb_EQ_4t2_1(i) <= s_Comb_EQ_4t2((i * 2) + 1);
        s_Comb_LT_4t2_0(i) <= s_Comb_LT_4t2(i * 2);
        s_Comb_LT_4t2_1(i) <= s_Comb_LT_4t2((i * 2) + 1);
        s_Comb_GT_4t2_0(i) <= s_Comb_GT_4t2(i * 2);
        s_Comb_GT_4t2_1(i) <= s_Comb_GT_4t2((i * 2) + 1);
    end generate;

    INST_2_Combine: blt_combine_n
    generic map (N => N/16)
    port map(i_EQ0 => s_Comb_EQ_4t2_0,
             i_EQ1 => s_Comb_EQ_4t2_1,
             i_LT0 => s_Comb_LT_4t2_0,
             i_LT1 => s_Comb_LT_4t2_1,
             i_GT0 => s_Comb_GT_4t2_0,
             i_GT1 => s_Comb_GT_4t2_1,
             o_EQ  => s_Comb_EQ_2t1,
             o_LT  => s_Comb_LT_2t1,
             o_GT  => s_Comb_GT_2t1);

    s_Comb_EQ_2t1_0(0) <= s_Comb_EQ_2t1(0);
    s_Comb_EQ_2t1_1(0) <= s_Comb_EQ_2t1(1);
    s_Comb_LT_2t1_0(0) <= s_Comb_LT_2t1(0);
    s_Comb_LT_2t1_1(0) <= s_Comb_LT_2t1(1);
    s_Comb_GT_2t1_0(0) <= s_Comb_GT_2t1(0);
    s_Comb_GT_2t1_1(0) <= s_Comb_GT_2t1(1);

    INST_1_Combine: blt_combine_n
    generic map (N => N/32)
    port map(i_EQ0 => s_Comb_EQ_2t1_0,
             i_EQ1 => s_Comb_EQ_2t1_1,
             i_LT0 => s_Comb_LT_2t1_0,
             i_LT1 => s_Comb_LT_2t1_1,
             i_GT0 => s_Comb_GT_2t1_0,
             i_GT1 => s_Comb_GT_2t1_1,
             o_EQ  => so_beqOut,
             o_LT  => so_bltuOut,
             o_GT  => so_bguOut);

    o_beqOut  <= so_beqOut(0);
    o_bltuOut <= so_bltuOut(0);
    o_bguOut  <= so_bguOut(0);

end architecture;