-- Jack Dustin
-- Control Hazard Logic
-- Branches resolve in ID
-- Jumps resolve in EX

library IEEE;
use IEEE.std_logic_1164.all;

entity ctrlHaz is
    port(
        -- ID-stage branch info
        i_IDBranch      : in  std_logic;  -- 1 when instruction in ID is a branch
        i_IDBranchTaken : in  std_logic;  -- 1 when that branch is taken

        -- EX-stage jump info
        i_EXJump        : in  std_logic;  -- 1 when instruction in EX causes non-sequential PC update (jal/jalr)

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
    signal s_JumpHaz   : std_logic;

begin

    -- A control hazard exists if:
    -- 1) a branch in ID is taken
    -- 2) a jump in EX redirects the PC
    s_BranchHaz <= i_IDBranch and i_IDBranchTaken;
    s_JumpHaz   <= i_EXJump;

    o_CtrlHaz <= s_BranchHaz or s_JumpHaz;

    -- Flush wrong-path younger instructions
    -- Taken branch in ID kills the instruction currently behind it in IF/ID
    -- Jump in EX kills the younger instructions in both IF/ID and ID/EX
    o_IFIDFlush <= s_BranchHaz or s_JumpHaz;
    o_IDEXFlush <= s_JumpHaz;

    -- No stalls required for this baseline control-hazard unit
    -- Keep these outputs so the unit is easy to integrate with your existing pipeline control style
    o_PCStall   <= '0';
    o_IFIDStall <= '0';

end architecture;