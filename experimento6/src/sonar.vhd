LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY sonar IS
	PORT (
		clock : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		ligar : IN STD_LOGIC;
		echo : IN STD_LOGIC;
		selmux : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		pronto_tx_sonar : OUT STD_LOGIC;
		saida_serial : OUT STD_LOGIC;
		pwm : OUT STD_LOGIC;
		trigger : OUT STD_LOGIC;
		proximidade : OUT STD_LOGIC;
		depuracao : OUT STD_LOGIC_VECTOR(23 DOWNTO 0)
	);
END ENTITY;

ARCHITECTURE sonar_arch OF sonar IS

	COMPONENT tx_dados_sonar
		PORT (
			clock : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			transmitir : IN STD_LOGIC;
			angulo2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			angulo1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			angulo0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			distancia2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			distancia1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			distancia0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			saida_serial : OUT STD_LOGIC;
			pronto : OUT STD_LOGIC;
			db_transmitir : OUT STD_LOGIC;
			db_transmite_dado : OUT STD_LOGIC;
			db_saida_serial : OUT STD_LOGIC;
			db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			db_estado_uc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
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

	COMPONENT mux_4x1_n
		GENERIC (
			CONSTANT BITS : INTEGER
		);
		PORT (
			D0 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
			D1 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
			D2 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
			D3 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
			SEL : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
			MUX_OUT : OUT STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT dec_pos_ang
		PORT (
			posicao : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
			angulo0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			angulo1 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			angulo2 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
		);
	END COMPONENT;

	COMPONENT alerta_proximidade
		PORT (
			medida : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
			proximo : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT edge_detector IS
		PORT (
			clk : IN STD_LOGIC;
			signal_in : IN STD_LOGIC;
			output : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL s_angulo0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_angulo1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_angulo2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_distancia0 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_distancia1 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_distancia2 : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_pronto_interface : STD_LOGIC;
	SIGNAL s_transmitir : STD_LOGIC;
	SIGNAL s_pronto_transmissao : STD_LOGIC;
	SIGNAL s_medida : STD_LOGIC_VECTOR(11 DOWNTO 0);
	SIGNAL s_posicao : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_proximo : STD_LOGIC;
	SIGNAL sinais00 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL sinais01 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL sinais10 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL sinais11 : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL s_depuracao : STD_LOGIC_VECTOR(23 DOWNTO 0);
	SIGNAL db_estado_interface : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_db_estado_tx_sonar : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_tick : STD_LOGIC;
BEGIN

	-- sinais reset e partida mapeados na GPIO (ativos em alto)

	TRANSMISSAO : tx_dados_sonar PORT MAP(
		clock,
		reset,
		s_transmitir,
		s_angulo0,
		s_angulo1,
		s_angulo2,
		s_distancia0,
		s_distancia1,
		s_distancia2,
		saida_serial,
		s_pronto_transmissao,
		OPEN,
		OPEN,
		OPEN,
		s_db_estado_tx_sonar,
		OPEN
	);

	CONTROLE_SERVO : controle_sweep PORT MAP(
		clock,
		reset,
		ligar,
		s_tick,
		s_posicao,
		OPEN,
		pwm,
		OPEN
	);

	INTERFACE : interface_hcsr04 PORT MAP(
		clock,
		reset,
		echo,
		s_tick,
		s_pronto_interface,
		trigger,
		s_medida,
		db_estado_interface
	);

	MUX4 : mux_4x1_n GENERIC MAP(
		BITS => 24
	)
	PORT MAP(
		sinais00,
		sinais01,
		sinais10,
		sinais11,
		selmux,
		s_depuracao
	);
	ED : edge_detector PORT MAP(
		clk => clock,
		signal_in => s_pronto_interface,
		output => s_transmitir
	);

	DECODIFICADOR : dec_pos_ang PORT MAP(
		s_posicao,
		s_angulo0,
		s_angulo1,
		s_angulo2
	);

	ALERTA : alerta_proximidade PORT MAP(
		s_medida,
		s_proximo
	);

	proximidade <= s_proximo;
	s_distancia2 <= s_medida(11 DOWNTO 8);
	s_distancia1 <= s_medida(7 DOWNTO 4);
	s_distancia0 <= s_medida(3 DOWNTO 0);
	pronto_tx_sonar <= s_pronto_transmissao;
	depuracao <= s_depuracao;

	sinais00 <= s_posicao & db_estado_interface & "00000" & s_distancia2 & s_distancia1 & s_distancia2;
	sinais01 <= "0000" & "0000" & "0000" & "0000" & "0000" & "0000";
	sinais10 <= s_db_estado_tx_sonar & "0000" & "0000" & "0000" & "0000" & "0000";
	sinais11 <= "0000" & "0000" & "0000" & s_angulo2 & s_angulo1 & s_angulo0;

END ARCHITECTURE;