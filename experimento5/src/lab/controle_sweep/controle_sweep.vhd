LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY controle_sweep IS
	PORT (
		clock : IN STD_LOGIC; -- 50MHz
		reset : IN STD_LOGIC;
		liga : IN STD_LOGIC;
		db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		db_slider : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		pwm : OUT STD_LOGIC;
		db_pwm : OUT STD_LOGIC);

END controle_sweep;

ARCHITECTURE arch_controle_sweep OF controle_sweep IS

	COMPONENT controle_servo IS
		PORT (
			clock : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			posicao : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			pwm : OUT STD_LOGIC;
			db_pwm : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT contador_3bits IS
		PORT (
			clock : IN STD_LOGIC;
			enable : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			dado : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
		);
	END COMPONENT;

	SIGNAL s_posicao : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_db_posicao : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_pwm : STD_LOGIC;
	SIGNAL s_db_pwm : STD_LOGIC;

BEGIN
	contador : contador_3bits PORT MAP(
		clock => clock,
		enable => liga,
		reset => reset,
		dado => s_posicao);

	controle : controle_servo PORT MAP(
		clock => clock,
		reset => reset,
		posicao => s_posicao,
		pwm => s_pwm,
		db_pwm => s_db_pwm,
		db_posicao => s_db_posicao);

	db_posicao <= s_db_posicao;
	db_slider <= s_db_posicao;
	pwm <= s_pwm;
	db_pwm <= s_db_pwm;

END arch_controle_sweep;