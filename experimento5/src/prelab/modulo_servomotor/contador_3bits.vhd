LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY contador_3bits IS
	PORT (
		clock : IN STD_LOGIC;
		enable : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		dado : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);

END contador_3bits;

ARCHITECTURE arch_contador_3bits OF contador_3bits IS

	CONSTANT CONTAGEM_MAXIMA : INTEGER := 250 * 8; --50000000*8
	SIGNAL subindo : STD_LOGIC;
	SIGNAL contagem : INTEGER RANGE 0 TO CONTAGEM_MAXIMA;

BEGIN

	PROCESS (clock, reset)
	BEGIN
		-- inicia contagem e posicao
		IF (reset = '1') THEN
			contagem <= 0;
		ELSIF (rising_edge(clock) AND enable = '1') THEN
			-- atualiza contagem e posicao
			IF (contagem = 1) THEN
				subindo <= '1';
			ELSIF (contagem = CONTAGEM_MAXIMA - 1) THEN
				subindo <= '0';
			END IF;

			IF (subindo = '0') THEN
				contagem <= contagem - 1;
			ELSE
				contagem <= contagem + 1;
			END IF;

		END IF;
	END PROCESS;

	PROCESS (contagem, reset)
	BEGIN
		--IF (reset = '1') THEN
		--	dado <= "000";
		--ELSIF (contagem < 50000000 * 1) THEN
		--	dado <= "001";
		--ELSIF (50000000 * 1 <= contagem AND contagem < 50000000 * 2) THEN
		--	dado <= "010";
		--ELSIF (50000000 * 2 <= contagem AND contagem < 50000000 * 3) THEN
		--	dado <= "011";
		--ELSIF (50000000 * 3 <= contagem AND contagem < 50000000 * 4) THEN
		--	dado <= "100";
		--ELSIF (50000000 * 4 <= contagem AND contagem < 50000000 * 5) THEN
		--	dado <= "101";
		--ELSIF (50000000 * 5 <= contagem AND contagem < 50000000 * 6) THEN
		--	dado <= "110";
		--ELSIF (50000000 * 6 <= contagem AND contagem < 50000000 * 7) THEN
		--	dado <= "111";
		--END IF;

		IF (reset = '1') THEN
			dado <= "000";
		ELSIF (contagem < 250 * 1) THEN
			dado <= "000";
		ELSIF (250 * 1 <= contagem AND contagem < 250 * 2) THEN
			dado <= "001";
		ELSIF (250 * 2 <= contagem AND contagem < 250 * 3) THEN
			dado <= "010";
		ELSIF (250 * 3 <= contagem AND contagem < 250 * 4) THEN
			dado <= "011";
		ELSIF (250 * 4 <= contagem AND contagem < 250 * 5) THEN
			dado <= "100";
		ELSIF (250 * 5 <= contagem AND contagem < 250 * 6) THEN
			dado <= "101";
		ELSIF (250 * 6 <= contagem AND contagem < 250 * 7) THEN
			dado <= "110";
		ELSIF (250 * 7 <= contagem AND contagem < 250 * 8) THEN
			dado <= "111";
		END IF;
	END PROCESS;

END arch_contador_3bits;