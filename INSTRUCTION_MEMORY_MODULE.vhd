----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:06:45 10/22/2017 
-- Design Name: 
-- Module Name:    INSTRUCTION_MEMORY_MODULE - Behavioral 
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
use ieee.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity INSTRUCTION_MEMORY_MODULE is
    Port ( PC : in  STD_LOGIC_VECTOR (5 downto 0);
           RST : in  STD_LOGIC;
           INSTRUCTION : out  STD_LOGIC_VECTOR (31 downto 0));
end INSTRUCTION_MEMORY_MODULE;

architecture IM of INSTRUCTION_MEMORY_MODULE is

	type ROM_TYPE is array (0 to 63) of std_logic_vector (31 downto 0);

	signal ROM: ROM_TYPE := (	"10000010000000000010000000000101",
										"10100000000000000011111111111000",
										"10100010000000000010000000000100",
										"10110001001010000110000000000010",
										"10110011001101000110000000000001",
										"10000001111010000010000000000000",
										"10100000000000000110000000000011",
										"10000001111000000010000000000000",
										"10000000101000000010000000000100",
										"10000100010000000000000000000001",
										"10010000000000000000000000010000",
									 others => "00000000000000000000000000000000");

begin
process(RST,ROM,PC)
	begin
		if(RST = '1') then
			INSTRUCTION<="00000000000000000000000000000000";
		else
			INSTRUCTION<=ROM(conv_integer(PC));
		end if;
end process;

end IM;