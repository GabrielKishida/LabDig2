LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY interface_hcsr04 IS
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		echo : IN STD_LOGIC;
		medir : IN STD_LOGIC;
		pronto : OUT STD_LOGIC;
		trigger : OUT STD_LOGIC;
		medida : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
		db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE interface_hcsr04_arch OF interface_hcsr04 IS

	COMPONENT interface_hcsr04_uc
		PORT (
			clock : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			medir : IN STD_LOGIC;
			echo : IN STD_LOGIC;
			registra : OUT STD_LOGIC;
			gera : OUT STD_LOGIC;
			zera : OUT STD_LOGIC;
			pronto : OUT STD_LOGIC;
			db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;
	COMPONENT interface_hcsr04_fd
		PORT (
			clock, conta, zera, registra, gera : IN STD_LOGIC;
			distancia : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
			trigger, fim : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL s_pronto, s_zera, s_gera, s_registra : STD_LOGIC;
BEGIN
	-- unidade de controle
	U1_UC : interface_hcsr04_uc PORT MAP(
		clock,
		reset,
		medir,
		echo,
		s_registra,
		s_gera,
		s_zera,
		pronto,
		db_estado
	);

	-- fluxo de dados
	U2_FD : interface_hcsr04_fd PORT MAP(
		clock,
		echo,
		s_zera,
		s_registra,
		s_gera,
		medida,
		trigger,
		OPEN
	);
END ARCHITECTURE;