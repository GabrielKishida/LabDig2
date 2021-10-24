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
		entrada_serial : IN STD_LOGIC;
		recebe_dado : IN STD_LOGIC;
		pronto_tx_sonar : OUT STD_LOGIC;
		saida_serial : OUT STD_LOGIC;
		pwm : OUT STD_LOGIC;
		trigger : OUT STD_LOGIC;
		proximidade : OUT STD_LOGIC;
		hex0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hex1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hex2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hex3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hex4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		hex5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
		db_dado_recebido : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		db_pwm : OUT STD_LOGIC;
		db_saida_serial : OUT STD_LOGIC
	);
END ENTITY;

ARCHITECTURE sonar_arch OF sonar IS

	COMPONENT tx_dados_sonar
		PORT (
			clock : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			transmitir : IN STD_LOGIC;
			entrada_serial : IN STD_LOGIC;
			recebe_dado : IN STD_LOGIC;
			angulo2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			angulo1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			angulo0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			distancia2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			distancia1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			distancia0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			saida_serial : OUT STD_LOGIC;
			pronto : OUT STD_LOGIC;
			dado_recebido_rx : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			db_transmitir : OUT STD_LOGIC;
			db_transmite_dado : OUT STD_LOGIC;
			db_saida_serial : OUT STD_LOGIC;
			db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			db_estado_rx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			db_estado_uc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
			db_contagem_mux_transmissao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			db_dado_a_transmitir : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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
			medida_pronto : IN STD_LOGIC;
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

	COMPONENT hexa7seg IS
		PORT (
			hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
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
	SIGNAL s_db_estado_uc_sonar : STD_LOGIC_VECTOR(2 DOWNTO 0);
	SIGNAL s_tick : STD_LOGIC;
	SIGNAL s_db_contagem_mux_transmissao : STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL s_db_dado_a_transmitir : STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL s_db_estado_rx : STD_LOGIC_VECTOR (3 DOWNTO 0);
	SIGNAL s_dado_recebido_rx : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN

	-- sinais reset e partida mapeados na GPIO (ativos em alto)

	TRANSMISSAO : tx_dados_sonar PORT MAP(
		clock => clock,
		reset => reset,
		transmitir => s_transmitir,
		entrada_serial => entrada_serial,
		recebe_dado => recebe_dado,
		angulo2 => s_angulo2,
		angulo1 => s_angulo1,
		angulo0 => s_angulo0,
		distancia2 => s_distancia2,
		distancia1 => s_distancia1,
		distancia0 => s_distancia0,
		saida_serial => saida_serial,
		pronto => s_pronto_transmissao,
		dado_recebido_rx => s_dado_recebido_rx,
		db_transmitir => OPEN,
		db_transmite_dado => OPEN,
		db_saida_serial => db_saida_serial,
		db_estado_tx => s_db_estado_tx_sonar,
		db_estado_uc => s_db_estado_uc_sonar,
		db_contagem_mux_transmissao => s_db_contagem_mux_transmissao,
		db_dado_a_transmitir => s_db_dado_a_transmitir,
		db_estado_rx => s_db_estado_rx
	);

	CONTROLE_SERVO : controle_sweep PORT MAP(
		clock,
		reset,
		ligar,
		s_tick,
		s_posicao,
		OPEN,
		pwm,
		db_pwm
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

	C_HEX0 : hexa7seg PORT MAP(
		hexa => s_depuracao (3 DOWNTO 0),
		sseg => hex0
	);

	C_HEX1 : hexa7seg PORT MAP(
		hexa => s_depuracao (7 DOWNTO 4),
		sseg => hex1
	);

	C_HEX2 : hexa7seg PORT MAP(
		hexa => s_depuracao (11 DOWNTO 8),
		sseg => hex2
	);

	C_HEX3 : hexa7seg PORT MAP(
		hexa => s_depuracao (15 DOWNTO 12),
		sseg => hex3
	);

	C_HEX4 : hexa7seg PORT MAP(
		hexa => s_depuracao (19 DOWNTO 16),
		sseg => hex4
	);

	C_HEX5 : hexa7seg PORT MAP(
		hexa => s_depuracao (23 DOWNTO 20),
		sseg => hex5
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
		s_pronto_interface,
		s_proximo
	);

	proximidade <= s_proximo;
	s_distancia2 <= s_medida(11 DOWNTO 8);
	s_distancia1 <= s_medida(7 DOWNTO 4);
	s_distancia0 <= s_medida(3 DOWNTO 0);
	pronto_tx_sonar <= s_pronto_transmissao;

	db_dado_recebido <= s_dado_recebido_rx;

	-- Sinais 00 -> Angulação + Distância
	-- Sinais 01 -> Posicionamento + estado interface hcsr04
	-- Sinais 10 -> TX_dados_sonar
	-- Sinais 11 -> Saídas da UART

	sinais00 <= s_angulo2 & s_angulo1 & s_angulo0 & s_distancia2 & s_distancia1 & s_distancia0;
	sinais01 <= '0' & s_posicao & db_estado_interface & "0000" & "0000" & "0000" & "0000";
	sinais10 <= s_db_estado_tx_sonar & '0' & s_db_estado_uc_sonar & '0' & s_db_contagem_mux_transmissao & s_db_dado_a_transmitir & "0000";
	sinais11 <= s_db_estado_rx & s_dado_recebido_rx & s_db_estado_tx_sonar & s_db_dado_a_transmitir;

END ARCHITECTURE;