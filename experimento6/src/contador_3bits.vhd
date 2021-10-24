LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY contador_3bits IS
	PORT (
		clock : IN STD_LOGIC;
		enable : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		tick : OUT STD_LOGIC;
		dado : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
	);

END contador_3bits;

ARCHITECTURE arch_contador_3bits OF contador_3bits IS

	CONSTANT TEMPO_BASE : INTEGER := 2000000;
	CONSTANT TEMPO_BASE_2 : INTEGER := TEMPO_BASE / 2;
	CONSTANT CONTAGEM_MAXIMA : INTEGER := TEMPO_BASE * 7;
	SIGNAL subindo : STD_LOGIC;
	SIGNAL contagem : INTEGER RANGE 0 TO CONTAGEM_MAXIMA;
	SIGNAL s_dado : STD_LOGIC_VECTOR (2 DOWNTO 0);

BEGIN

	PROCESS (clock, reset, enable)
	BEGIN
		-- inicia contagem e posicao
		IF (reset = '1') THEN
			contagem <= 0;
			subindo <= '1';
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

	PROCESS (contagem, reset, subindo)
	BEGIN
		IF (reset = '1') THEN
			s_dado <= "000";
		ELSIF (contagem < TEMPO_BASE * 1 AND subindo = '1') THEN
			s_dado <= "000";
		ELSIF (TEMPO_BASE * 1 <= contagem AND contagem < TEMPO_BASE * 2 AND subindo = '1') THEN
			s_dado <= "001";
		ELSIF (TEMPO_BASE * 2 <= contagem AND contagem < TEMPO_BASE * 3 AND subindo = '1') THEN
			s_dado <= "010";
		ELSIF (TEMPO_BASE * 3 <= contagem AND contagem < TEMPO_BASE * 4 AND subindo = '1') THEN
			s_dado <= "011";
		ELSIF (TEMPO_BASE * 4 <= contagem AND contagem < TEMPO_BASE * 5 AND subindo = '1') THEN
			s_dado <= "100";
		ELSIF (TEMPO_BASE * 5 <= contagem AND contagem < TEMPO_BASE * 6 AND subindo = '1') THEN
			s_dado <= "101";
		ELSIF (TEMPO_BASE * 6 <= contagem AND contagem < TEMPO_BASE * 7 AND subindo = '1') THEN
			s_dado <= "110";
		ELSIF (TEMPO_BASE * 6 <= contagem AND contagem < TEMPO_BASE * 7 AND subindo = '0') THEN
			s_dado <= "111";
		ELSIF (TEMPO_BASE * 5 <= contagem AND contagem < TEMPO_BASE * 6 AND subindo = '0') THEN
			s_dado <= "110";
		ELSIF (TEMPO_BASE * 4 <= contagem AND contagem < TEMPO_BASE * 5 AND subindo = '0') THEN
			s_dado <= "101";
		ELSIF (TEMPO_BASE * 3 <= contagem AND contagem < TEMPO_BASE * 4 AND subindo = '0') THEN
			s_dado <= "100";
		ELSIF (TEMPO_BASE * 2 <= contagem AND contagem < TEMPO_BASE * 3 AND subindo = '0') THEN
			s_dado <= "011";
		ELSIF (TEMPO_BASE * 1 <= contagem AND contagem < TEMPO_BASE * 2 AND subindo = '0') THEN
			s_dado <= "010";
		ELSIF (TEMPO_BASE * contagem < TEMPO_BASE * 1 AND subindo = '0') THEN
			s_dado <= "001";
		END IF;

		IF (contagem = TEMPO_BASE_2 OR contagem = TEMPO_BASE_2 + TEMPO_BASE * 1 OR
			contagem = TEMPO_BASE_2 + TEMPO_BASE * 2 OR contagem = TEMPO_BASE_2 + TEMPO_BASE * 3 OR
			contagem = TEMPO_BASE_2 + TEMPO_BASE * 4 OR contagem = TEMPO_BASE_2 + TEMPO_BASE * 5 OR
			contagem = TEMPO_BASE_2 + TEMPO_BASE * 6) THEN
			tick <= '1';
		ELSE
			tick <= '0';
		END IF;

	END PROCESS;

	dado <= s_dado;

END arch_contador_3bits;