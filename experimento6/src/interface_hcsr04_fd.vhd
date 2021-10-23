
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY interface_hcsr04_fd IS
	PORT (
		clock, conta, zera, registra, gera : IN STD_LOGIC;
		distancia : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
		trigger, fim : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE arch OF interface_hcsr04_fd IS
	COMPONENT medidor_largura
		PORT (
			clock, zera, echo : IN STD_LOGIC;
			dig3, dig2, dig1, dig0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			fim : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT registrador_n
		GENERIC (
			CONSTANT N : INTEGER
		);
		PORT (
			clock : IN STD_LOGIC;
			clear : IN STD_LOGIC;
			enable : IN STD_LOGIC;
			D : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
			Q : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT gerador_pulso
		PORT (
			clock : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			gera : IN STD_LOGIC;
			para : IN STD_LOGIC;
			pulso : OUT STD_LOGIC;
			pronto : OUT STD_LOGIC
		);
	END COMPONENT;
	SIGNAL s_dig2, s_dig1, s_dig0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_distancia : STD_LOGIC_VECTOR(11 DOWNTO 0);

BEGIN

	CONTAGEM : medidor_largura
	PORT MAP(
		clock,
		zera,
		conta,
		OPEN,
		s_dig2,
		s_dig1,
		s_dig0,
		fim
	);

	REGISTRADOR : registrador_n GENERIC MAP(
		N => 12) PORT MAP(
		clock,
		zera,
		registra,
		s_distancia,
		distancia
	);

	GERADOR_TRIGGER : gerador_pulso
	PORT MAP(
		clock,
		zera,
		gera,
		'0',
		trigger,
		OPEN
	);

	s_distancia <= s_dig2 & s_dig1 & s_dig0;
END ARCHITECTURE;