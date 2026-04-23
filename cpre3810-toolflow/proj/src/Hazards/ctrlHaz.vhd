-- Jack Dustin
-- Control Hazard Logic
-- Branches + jal resolve in ID
-- Jalr resolve in EX

library IEEE;
use IEEE.std_logic_1164.all;

library IEEE;
use IEEE.std_logic_1164.all;

entity ctrlHaz is
    port(
        -- ID-stage control-flow info
        i_IDBranch      : in  std_logic;
        i_IDBranchTaken : in  std_logic;
        i_IDJal         : in  std_logic;

        -- EX-stage control-flow info
        i_EXJalr        : in  std_logic;

        -- Hazard outputs
        o_CtrlHaz       : out std_logic;
        o_IFIDFlush     : out std_logic;
        o_IDEXFlush     : out std_logic;
        o_PCStall       : out std_logic;
        o_IFIDStall     : out std_logic
    );
end entity;

architecture dataflow of ctrlHaz is

    signal s_BranchHaz : std_logic;
    signal s_JalHaz    : std_logic;
    signal s_JalrHaz   : std_logic;

begin

    -- ID-stage hazards
    s_BranchHaz <= i_IDBranch and i_IDBranchTaken;
    s_JalHaz    <= i_IDJal;

    -- EX-stage hazard
    s_JalrHaz   <= i_EXJalr;

    o_CtrlHaz <= s_BranchHaz or s_JalHaz or s_JalrHaz;

    -- Any redirect kills the younger IF/ID instruction
    o_IFIDFlush <= s_BranchHaz or s_JalHaz or s_JalrHaz;

    -- Only EX-stage jalr needs to kill the current ID/EX contents
    o_IDEXFlush <= s_JalrHaz;

    -- No stalls in this baseline unit
    o_PCStall   <= '0';
    o_IFIDStall <= '0';

end architecture;