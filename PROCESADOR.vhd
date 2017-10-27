----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:13:11 10/22/2017 
-- Design Name: 
-- Module Name:    PROCESADOR - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PROCESADOR is
    Port ( CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           RESULT : out  STD_LOGIC_VECTOR (31 downto 0));
end PROCESADOR;

architecture Behavioral of PROCESADOR is
	--PC AND NPC
	COMPONENT PC_MODULE
	PORT(
		CLK : IN std_logic;
		RST : IN std_logic;
		INSTR : IN std_logic_vector(31 downto 0);          
		PC : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	--PC + SEU(DISP22)
	COMPONENT ALU_BR_MODULE
	PORT(
		SDISP22 : IN std_logic_vector(31 downto 0);
		PC : IN std_logic_vector(31 downto 0);          
		BRANCHS : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	--PC + SEU(DISP30)
	COMPONENT ALU_CALL_MODULE
	PORT(
		SDISP30 : IN std_logic_vector(31 downto 0);
		PC : IN std_logic_vector(31 downto 0);          
		CALL : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	--ALU
	COMPONENT ALU_MODULE
	PORT(
		ALUOP : IN std_logic_vector(5 downto 0);
		CRS1 : IN std_logic_vector(31 downto 0);
		OP2 : IN std_logic_vector(31 downto 0);
		C : IN std_logic_vector(0 to 0);          
		ALU_RESULT : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	--PC + 1
	COMPONENT ALU_PC_MODULE
	PORT(
		NPC : IN std_logic_vector(31 downto 0);
		STATIC : IN std_logic_vector(31 downto 0);          
		PC : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	--CONTROL UNIT
	COMPONENT CONTROL_UNIT_MODULE
	PORT(
		OP : IN std_logic_vector(1 downto 0);
		OP3 : IN std_logic_vector(5 downto 0);
		ICC : IN std_logic_vector(3 downto 0);
		COND : IN std_logic_vector(3 downto 0);          
		PCSOURCE : OUT std_logic_vector(1 downto 0);
		ALUOP : OUT std_logic_vector(5 downto 0);
		WRDENMEM : OUT std_logic;
		RFSOURCE : OUT std_logic_vector(1 downto 0);
		RFDEST : OUT std_logic;
		WE : OUT std_logic
		);
	END COMPONENT;
	--DATA MEMORY
	COMPONENT DATA_MEMORY_MODULE
	PORT(
		RST : IN std_logic;
		CLK : IN STD_LOGIC;
		ALU_RESULT : IN std_logic_vector(4 downto 0);
		cRD : IN std_logic_vector(31 downto 0);
		WRDENMEM : IN std_logic;          
		DATATOMEM : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	--IM
	COMPONENT INSTRUCTION_MEMORY_MODULE
	PORT(
		PC : IN std_logic_vector(5 downto 0);
		RST : IN std_logic;          
		INSTRUCTION : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- MUX BRANCHS
	COMPONENT MUX_BR_MODULE
	PORT(
		PCSOURCE : IN std_logic_vector(1 downto 0);
		CALL : IN std_logic_vector(31 downto 0);
		BRANCHS : IN std_logic_vector(31 downto 0);
		PC : IN std_logic_vector(31 downto 0);
		ALU_RESULT : IN std_logic_vector(31 downto 0);          
		DATATONPC : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- MUX RESULT
	COMPONENT MUX_DM_MODULE
	PORT(
		RFSOURCE : IN std_logic_vector(1 downto 0);
		DATATOMEM : IN std_logic_vector(31 downto 0);
		ALU_RESULT : IN std_logic_vector(31 downto 0);
		PC : IN std_logic_vector(31 downto 0);          
		DATATOREG : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- MUX CRS1 OR IMM
	COMPONENT MUX_RF_MODULE
	PORT(
		I : IN std_logic;
		CRS2 : IN std_logic_vector(31 downto 0);
		SIMM : IN std_logic_vector(31 downto 0);          
		OP2 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- MUX RD OR 15
	COMPONENT MUX_WM_MODULE
	PORT(
		RFDEST : IN std_logic;
		RD : IN std_logic_vector(5 downto 0);          
		NRD : OUT std_logic_vector(5 downto 0)
		);
	END COMPONENT;
	-- PSR MODIFIER
	COMPONENT PSR_MODIFIER_MODULE
	PORT(
		CRS1 : IN std_logic_vector(31 downto 0);
		OP2 : IN std_logic_vector(31 downto 0);
		ALUOP : IN std_logic_vector(5 downto 0);
		ALU_RESULT : IN std_logic_vector(31 downto 0);          
		NZVC : OUT std_logic_vector(3 downto 0)
		);
	END COMPONENT;
	-- PSR
	COMPONENT PSR_MODULE
	PORT(
		CLK : IN std_logic;
		NZVC : IN std_logic_vector(3 downto 0);
		RST : IN std_logic;
		NCWP : IN std_logic_vector(0 to 0);          
		ICC : OUT std_logic_vector(3 downto 0);
		CWP : OUT std_logic_vector(0 to 0);
		C : OUT std_logic_vector(0 to 0)
		);
	END COMPONENT;
	-- REGISTER FILE
	COMPONENT REGITER_FILE_MODULE
	PORT(
		NRS1 : IN std_logic_vector(5 downto 0);
		NRS2 : IN std_logic_vector(5 downto 0);
		NRD : IN std_logic_vector(5 downto 0);
		RST : IN std_logic;
		WE : IN std_logic;
		DATATOREG : IN std_logic_vector(31 downto 0);          
		CRS1 : OUT std_logic_vector(31 downto 0);
		CRD : OUT std_logic_vector(31 downto 0);
		CRS2 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- SEU DISP22
	COMPONENT SEU_BR_MODULE
	PORT(
		DISP22 : IN std_logic_vector(21 downto 0);          
		SDISP22 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- SEU DISP30
	COMPONENT SEU_CALL_MODULE
	PORT(
		DISP30 : IN std_logic_vector(29 downto 0);          
		SDISP30 : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- SEU IMM
	COMPONENT SEU_IMM_MODULE
	PORT(
		IMM : IN std_logic_vector(12 downto 0);          
		SIMM : OUT std_logic_vector(31 downto 0)
		);
	END COMPONENT;
	-- WINDOWS MANAGER
	COMPONENT WINDOWS_MANAGER_MODULE
	PORT(
		CWP : IN std_logic_vector(0 to 0);
		OP : IN std_logic_vector(1 downto 0);
		OP3 : IN std_logic_vector(5 downto 0);
		RS1 : IN std_logic_vector(4 downto 0);
		RS2 : IN std_logic_vector(4 downto 0);
		RD : IN std_logic_vector(4 downto 0);          
		NCWP : OUT std_logic_vector(0 to 0);
		NRS1 : OUT std_logic_vector(5 downto 0);
		NRS2 : OUT std_logic_vector(5 downto 0);
		NRD : OUT std_logic_vector(5 downto 0)
		);
	END COMPONENT;
	
	SIGNAL AUX_NPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_DATATONPC : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_PC : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_PC_PLUS_ONE: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_INSTRUCTION: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_SDISP22: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_SDISP30: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_BRANCHS: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_CALL: STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_ALUOP: STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL AUX_CWP:STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL AUX_NCWP:STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL AUX_NRS1:STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL AUX_NRS2:STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL AUX_NRD:STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL AUX_RD:STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL AUX_CRS1:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_CRS2:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_CRD:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_SIMM:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_OP2:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_C:STD_LOGIC_VECTOR(0 DOWNTO 0);
	SIGNAL AUX_ALU_RESULT:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_NZVC:STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL AUX_ICC:STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL AUX_PCSOURCE:STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL AUX_WRDENMEM:STD_LOGIC;
	SIGNAL AUX_RFSOURCE:STD_LOGIC_VECTOR(1 DOWNTO 0);
	SIGNAL AUX_RFDEST:STD_LOGIC;
	SIGNAL AUX_WE:STD_LOGIC;
	SIGNAL AUX_DATATOMEM:STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL AUX_DATATOREG:STD_LOGIC_VECTOR(31 DOWNTO 0);
	
BEGIN

	Inst_NPC_MODULE: PC_MODULE PORT MAP(
		PC => AUX_NPC,
		CLK => CLK,
		RST => RST,
		INSTR => AUX_DATATONPC
	);
	
	Inst_PC_MODULE: PC_MODULE PORT MAP(
		PC => AUX_PC,
		CLK => CLK,
		RST => RST,
		INSTR => AUX_NPC 
	);
	
	Inst_ALU_BR_MODULE: ALU_BR_MODULE PORT MAP(
		SDISP22 => AUX_SDISP22,
		PC => AUX_PC,
		BRANCHS => AUX_BRANCHS
	);
	
	Inst_ALU_CALL_MODULE: ALU_CALL_MODULE PORT MAP(
		SDISP30 => AUX_SDISP30,
		PC => AUX_PC,
		CALL => AUX_CALL
	);
	
	Inst_ALU_MODULE: ALU_MODULE PORT MAP(
		ALUOP => AUX_ALUOP,
		CRS1 => AUX_CRS1,
		OP2 => AUX_OP2,
		C => AUX_C,
		ALU_RESULT => AUX_ALU_RESULT
	);
	Inst_ALU_PC_MODULE: ALU_PC_MODULE PORT MAP(
		NPC => AUX_NPC,
		STATIC => X"00000001",
		PC => AUX_PC_PLUS_ONE 
	);
	Inst_CONTROL_UNIT_MODULE: CONTROL_UNIT_MODULE PORT MAP(
		OP => AUX_INSTRUCTION(31 DOWNTO 30),
		OP3 => AUX_INSTRUCTION(24 DOWNTO 19),
		ICC => AUX_ICC,
		COND => AUX_INSTRUCTION(28 DOWNTO 25),
		PCSOURCE => AUX_PCSOURCE,
		ALUOP => AUX_ALUOP,
		WRDENMEM => AUX_WRDENMEM,
		RFSOURCE => AUX_RFSOURCE,
		RFDEST => AUX_RFDEST,
		WE => AUX_WE
	);
	Inst_DATA_MEMORY_MODULE: DATA_MEMORY_MODULE PORT MAP(
		RST => RST,
		CLK => CLK,
		ALU_RESULT => AUX_ALU_RESULT(4 DOWNTO 0),
		cRD => AUX_CRD,
		WRDENMEM => AUX_WRDENMEM,
		DATATOMEM => AUX_DATATOMEM
	);
	Inst_INSTRUCTION_MEMORY_MODULE: INSTRUCTION_MEMORY_MODULE PORT MAP(
		PC => AUX_PC(5 DOWNTO 0),
		RST => RST,
		INSTRUCTION => AUX_INSTRUCTION
	);
	Inst_MUX_BR_MODULE: MUX_BR_MODULE PORT MAP(
		PCSOURCE => AUX_PCSOURCE,
		CALL => AUX_CALL,
		BRANCHS => AUX_BRANCHS,
		PC => AUX_PC_PLUS_ONE,
		ALU_RESULT => AUX_ALU_RESULT,
		DATATONPC => AUX_DATATONPC
	);
	Inst_MUX_DM_MODULE: MUX_DM_MODULE PORT MAP(
		RFSOURCE => AUX_RFSOURCE,
		DATATOMEM => AUX_DATATOMEM,
		ALU_RESULT => AUX_ALU_RESULT,
		PC => AUX_PC,
		DATATOREG => AUX_DATATOREG
	);
	Inst_MUX_RF_MODULE: MUX_RF_MODULE PORT MAP(
		I => AUX_INSTRUCTION(13),
		CRS2 => AUX_CRS2,
		SIMM => AUX_SIMM,
		OP2 => AUX_OP2
	);
	Inst_MUX_WM_MODULE: MUX_WM_MODULE PORT MAP(
		RFDEST => AUX_RFDEST,
		RD => AUX_RD,
		NRD => AUX_NRD
	);
	Inst_PSR_MODIFIER_MODULE: PSR_MODIFIER_MODULE PORT MAP(
		CRS1 => AUX_CRS1,
		OP2 => AUX_OP2,
		ALUOP => AUX_ALUOP,
		ALU_RESULT => AUX_ALU_RESULT,
		NZVC => AUX_NZVC
	);
	Inst_PSR_MODULE: PSR_MODULE PORT MAP(
		CLK => CLK,
		NZVC => AUX_NZVC,
		RST => RST,
		NCWP => AUX_NCWP,
		ICC => AUX_ICC,
		CWP => AUX_CWP,
		C => AUX_C
	);
	Inst_REGITER_FILE_MODULE: REGITER_FILE_MODULE PORT MAP(
		NRS1 => AUX_NRS1,
		NRS2 => AUX_NRS2,
		NRD => AUX_NRD,
		RST => RST,
		WE => AUX_WE,
		DATATOREG => AUX_DATATOREG,
		CRS1 => AUX_CRS1,
		CRD => AUX_CRD,
		CRS2 => AUX_CRS2
	);
	Inst_SEU_BR_MODULE: SEU_BR_MODULE PORT MAP(
		DISP22 => AUX_INSTRUCTION(21 DOWNTO 0),
		SDISP22 => AUX_SDISP22
	);
	Inst_SEU_CALL_MODULE: SEU_CALL_MODULE PORT MAP(
		DISP30 => AUX_INSTRUCTION(29 DOWNTO 0),
		SDISP30 => AUX_SDISP30
	);
	Inst_SEU_IMM_MODULE: SEU_IMM_MODULE PORT MAP(
		IMM => AUX_INSTRUCTION(12 DOWNTO 0),
		SIMM => AUX_SIMM
	);
	Inst_WINDOWS_MANAGER_MODULE: WINDOWS_MANAGER_MODULE PORT MAP(
		CWP => AUX_CWP,
		OP => AUX_INSTRUCTION(31 DOWNTO 30),
		OP3 => AUX_INSTRUCTION(24 DOWNTO 19),
		RS1 => AUX_INSTRUCTION(18 DOWNTO 14),
		RS2 => AUX_INSTRUCTION(4 DOWNTO 0),
		RD => AUX_INSTRUCTION(29 DOWNTO 25),
		NCWP => AUX_NCWP,
		NRS1 => AUX_NRS1,
		NRS2 => AUX_NRS2,
		NRD => AUX_RD
	);
	
	RESULT <= AUX_DATATOREG;
	
end Behavioral;

