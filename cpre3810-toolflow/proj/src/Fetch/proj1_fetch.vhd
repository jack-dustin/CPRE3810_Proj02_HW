-- Isaiah Pridie
-- CprE 381 project01 Fetcher component thing
    -- This file contains:
        -- PC Register
        -- PC Register Update Logic
        -- All the necessary ports for clocks, resets, controls, and I/O
-- Start Date: 3.2.2026,    5:43 PM

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity proj1_fetch is 
    port(i_CLK      : in std_logic;
         i_RST_PC   : in std_logic;     -- Need different reset* (this one); We need to reset register to 0x0040.0000 not 0x0000.0000
         i_WE       : in std_logic;
         i_imm      : in std_logic_vector(31 downto 0);     -- imm AFTER SIGN-EXTENDING AND MUXING
         i_alu      : in std_logic_vector(31 downto 0); -- jal target address from ALU (for jalr)
         --c_PC_add   : in std_logic;                         -- Control bit for choosing between "+4" and "+imm"
         c_PC_sel   : in std_logic_vector(1 downto 0); -- Control bits for choosing between "+4", "+imm", and "jalr target address" 00 = +4, 01 = +imm, 10 = jalr target address
         o_PC       : out std_logic_vector(31 downto 0);  -- Output from PC register to Instruction memory
         o_PC4      : out std_logic_vector(31 downto 0) );  -- Output of "PC + 4" for use in jal instructions (to be stored in rd)
end proj1_fetch;

architecture structural of proj1_fetch is 
    
    -- Wire/Signal/constant declarations. Component declarations afterwards
    constant N : natural := 32;
    signal is_PC          : std_logic_vector(31 downto 0);    -- Carries PC contents to adders
    --signal os_busMux1     : std_logic_vector(31 downto 0);    -- Signal carries from busMux_1 to busMux_2
    signal os_busMux2     : std_logic_vector(31 downto 0);    -- Signal carries from busMux_2 to PC register
    signal os_busMux3     : std_logic_vector(31 downto 0);    -- Signal carries from busMux_3 to busMux_1 (for jalr)
    signal s_PC_4_mux     : std_logic_vector(31 downto 0);    -- Signal carries "PC + 4" result to busMux(0)
    --signal s_PC_imm_mux   : std_logic_vector(31 downto 0);    -- Signal carries "PC + imm" result to busMux(1)
    --signal s_CLK_n : std_logic;

        -- 3-way select signals: first pick between PC+imm and ALU, then between PC+4 and the result of the first mux
    --signal s_jalr_or_branch : std_logic_vector(31 downto 0);  -- result of inner mux
    --signal s_next_pc        : std_logic_vector(31 downto 0);  -- result of outer mux (pre-reset)
    --signal s_next_pc_rst    : std_logic_vector(31 downto 0);  -- after reset override
 

    component basic_adder_n is 
        generic (N: integer := 4);      -- Defined 4 by default in basic_adder_n folder
        port(i_aB0   : in std_logic_vector(N-1 downto 0);   -- Data in 0
             i_aB1   : in std_logic_vector(N-1 downto 0);   -- Data in 1
             o_S     : out std_logic_vector(N-1 downto 0);  -- Output Sum
             i_C     : in std_logic;    -- Not Bus. Used for a control*
             o_C     : out std_logic ); -- Not Bus. Final Carry Output)
    end component;

    component busMux_2t1 is
        port(i_dZero    : in std_logic_vector(31 downto 0); 
             i_dOne     : in std_logic_vector(31 downto 0);
             ALUSrc     : in std_logic; -- select line
             o_dOUT     : out std_logic_vector(31 downto 0));
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

    component reg_n is
        generic (N : integer := 32);
        port(i_CLK   : in std_logic;                          -- Clock input
             i_RST   : in std_logic;                          -- Reset input
             i_WE    : in std_logic;                          -- Write enable input
             i_D     : in std_logic_vector(N-1 downto 0);     -- (Bus) Data value input
             o_Q     : out std_logic_vector(N-1 downto 0));   -- (Bus) Data value output
    end component; 

    -- starting structuring the structural circuit with structural methods
    -- (instantiate components)
    -- Component => Entity Ports/Signals
    begin   
        --s_CLK_n <= not i_CLK;
        o_PC  <= is_PC;
        o_PC4 <= s_PC_4_mux; -- Output "PC + 4" for use in jal instructions (to be stored in rd)

                -- First mux: choose between PC+4 and PC+imm
        -- INST_BUSMUX_1: busMux_2t1
        -- port map(i_dZero    => s_PC_4_mux,
        --          i_dOne     => i_imm,
        --          ALUSrc     => c_PC_sel(0),
        --          o_dOUT     => os_busMux1);
                 
        -- -- Second mux: choose between previous result and jalr target
        -- -- Note: c_PC_sel(1) should only be 1 for jalr instructions, 
        -- -- so this mux will only select the ALU output for jalr, 
        -- -- and will select between PC+4 and PC+imm for all other instructions (including branches)
        -- INST_BUSMUX_2: busMux_2t1
        -- port map(i_dZero    => os_busMux1,
        --          i_dOne     => i_alu,
        --          ALUSrc     => c_PC_sel(1),
        --          o_dOUT     => os_busMux2);

        INST_BUSMUX_1: busMux_4t1
        port map(
            i_Da => s_PC_4_mux,
            i_Db => i_imm,
            i_Dc => i_alu,
            i_Dd => i_alu,
            C_S0 => c_PC_sel(0),
            C_S1 => c_PC_sel(1),
            O_Do => os_busMux2
        );
                 
        -- Reset override: force 0x00400000 on reset
        INST_BUSMUX_3: busMux_2t1
        port map(i_dZero    => os_busMux2,
                 i_dOne     => x"00400000",
                 ALUSrc     => i_RST_PC,
                 o_dOUT     => os_busMux3);

        INST_REG_N: reg_n
        port map(i_CLK  => i_CLK,
                 i_RST  => '0',             -- Prevent register from going to 0x0000.0000 
                 i_WE   => i_WE,             -- Should always be 1, except for when instructions hit wfi
                 i_D    => os_busMux3,      -- Input from busMux
                 o_Q    => is_PC);          -- Output of PC register (address going to instruction memory)

        o_PC    <= is_PC;   -- Assign output with the output signal

        -- PC + 4 into (0)
        INST_ADDER_N_4: basic_adder_n     
        generic map (N => N)
        port map(i_aB0  => is_PC,
                 i_aB1  => x"00000004",    -- d'4' 
                 o_S    => s_PC_4_mux,     -- Signal carries to busMux(0)
                 i_C    => '0',            -- Hardcode carry in bit to 0
                 o_C    =>  open);         -- "open" is used in VHDL to indicate an output not connected to anything

        -- -- PC + imm into (1)
        -- INST_ADDER_N_IMM: basic_adder_n     
        -- generic map (N => N)
        -- port map(i_aB0  => is_PC,
        --          i_aB1  => i_imm,
        --          o_S    => s_PC_imm_mux,    -- Signal carries to busMux(1)
        --          i_C    => '0',             -- Hardcode carry in bit to 0
        --          o_C    => open);           -- "open" is used in VHDL to indicate an output not connected to anything

end structural;
