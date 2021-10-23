LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dec_pos_ang IS
	PORT (
		posicao: IN STD_LOGIC_VECTOR(2 downto 0);
		angulo0: STD_LOGIC_VECTOR(3 downto 0);
		angulo1: STD_LOGIC_VECTOR(3 downto 0);
		angulo2: STD_LOGIC_VECTOR(3 downto 0)
	);
END  dec_pos_ang;

ARCHITECTURE arch_ang of dec_pos_ang is

	with posicao select 
		angulo2 <= "0000" when "000", -- 20
			   "0000" when "001", -- 40
			   "0000" when "010", -- 60
			   "0000" when "011", -- 80
			   "0001" when "100", -- 100
			   "0001" when "101", -- 120
			   "0001" when "110", -- 140
			   "0001" when "111", -- 160
			   "0000" when others;
			   
	with posicao select 
		angulo1 <= "0010" when "000", -- 20
			   "0100" when "001", -- 40
			   "0110" when "010", -- 60
			   "1000" when "011", -- 80
			   "0000" when "100", -- 100
			   "0010" when "101", -- 120
			   "0100" when "110", -- 140
			   "0110" when "111", -- 160
			   "0000" when others;
			   
	angulo0 <= "0000";
			   

end arch_ang;
	