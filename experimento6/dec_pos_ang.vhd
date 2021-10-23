LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dec_pos_ang IS
	PORT (
		posicao: IN STD_LOGIC_VECTOR(3 downto 0);
		ang: STD_LOGIC_VECTOR(7 downto 0)
	);
END  dec_pos_ang;

ARCHITECTURE arch_ang of dec_pos_ang is

	with posicao select 
		ang <= "00010100" when "000",
			   "00101000" when "001",
			   "00111100" when "010",
			   "01010000" when "011",
			   "01100100" when "100",
			   "01111000" when "101",
			   "10001100" when "110",
			   "10100000" when "111",
			   "00000000" when others;

end arch_ang;
	