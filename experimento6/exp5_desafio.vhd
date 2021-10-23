
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY exp5_desafio IS
	PORT (
		clock, reset, liga, echo: IN STD_LOGIC;
		trigger, pronto: OUT STD_LOGIC;
		pwm, db_pwm: OUT STD_LOGIC;
		db_slider: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
		posicao: OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		distancia0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		distancia1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		distancia2 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
		db_estado_hcsr04 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE arch OF exp5_desafio IS

	COMPONENT interface_hcsr04
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
	END COMPONENT;
	
	COMPONENT controle_sweep 
	PORT (
		clock : IN STD_LOGIC; -- 50MHz
		reset : IN STD_LOGIC;
		liga : IN STD_LOGIC;
		tick : OUT STD_LOGIC;
		db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		db_slider : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		pwm : OUT STD_LOGIC;
		db_pwm : OUT STD_LOGIC
		);
	END COMPONENT;
	
	COMPONENT hexa7seg 
   PORT (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
	END COMPONENT;
	
	SIGNAL s_medida : STD_LOGIC;
	SIGNAL s_posicao : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_distancia : STD_LOGIC_VECTOR(11 DOWNTO 0);


BEGIN

	INTERFACE: interface_hcsr04 PORT MAP(
		clock,
		reset,
		echo,
		s_medida,
		pronto,
		trigger,
		s_distancia,
		db_estado_hcsr04
		);
	
	CONTROLE_SERVO: controle_sweep PORT MAP (
		clock,
		reset,
		liga,
		s_medida,
		s_posicao,
		db_slider,
		pwm,
		db_pwm
	);
	
	POSICAO7SEG : hexa7seg PORT MAP (
		'0' & s_posicao,
		posicao
	);
	
	DISTANCIA07SEG : hexa7seg PORT MAP (
		s_distancia(3 DOWNTO 0),
		distancia0
	);
	
	DISTANCIA17SEG : hexa7seg PORT MAP (
		s_distancia(7 DOWNTO 4),
		distancia1
	);
	
	DISTANCIA27SEG : hexa7seg PORT MAP (
		s_distancia(11 DOWNTO 8),
		distancia2
	);

END ARCHITECTURE;