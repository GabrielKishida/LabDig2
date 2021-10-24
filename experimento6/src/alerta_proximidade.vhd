LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY alerta_proximidade IS
	PORT (
		medida : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		proximo : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE behav OF alerta_proximidade IS
BEGIN
	PROCESS (medida)
	BEGIN
		IF (medida(11 DOWNTO 8) = "0000" AND
			medida(7 DOWNTO 4) = "0001") THEN
			proximo <= '1';
		ELSIF (medida(11 DOWNTO 8) = "0000" AND
			medida(7 DOWNTO 4) = "0010" AND
			medida(3 DOWNTO 0) = "0000") THEN
			proximo <= '1';
		ELSIF (medida(11 DOWNTO 8) = "0000" AND
			medida(7 DOWNTO 4) = "0000" THEN
			proximo <= '1';
		ELSE
			proximo <= '0';
		END IF;
	END PROCESS;

END behav;