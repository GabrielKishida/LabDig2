LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY sonar_fd IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        ligar : IN STD_LOGIC;
		medir : IN STD_LOGIC;
		echo : IN STD_LOGIC;
		transmitir: IN STD_LOGIC;
		selmux: IN STD_LOGIC_VECTOR(1 downto 0);
		pronto: OUT STD_LOGIC;
		saida_serial: OUT STD_LOGIC;
		pwm: OUT STD_LOGIC;
		trigger: OUT STD_LOGIC;
		proximidade: OUT STD_LOGIC;
		
        
    );
END ENTITY;

ARCHITECTURE sonar_fd_arch OF sonar_fd IS

    component tx_dados_sonar
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
	END component;
	
	COMPONENT controle_sweep
	PORT (
		clock : IN STD_LOGIC; -- 50MHz
		reset : IN STD_LOGIC;
		liga : IN STD_LOGIC;
		db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		db_slider : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
		pwm : OUT STD_LOGIC;
		db_pwm : OUT STD_LOGIC);

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
	
	component mux_4x1_n
    generic (
        constant BITS: integer
    );
    port ( 
        D0 :     in  std_logic_vector (BITS-1 downto 0);
        D1 :     in  std_logic_vector (BITS-1 downto 0);
        D2 :     in  std_logic_vector (BITS-1 downto 0);
        D3 :     in  std_logic_vector (BITS-1 downto 0);
        SEL:     in  std_logic_vector (1 downto 0);
        MUX_OUT: out std_logic_vector (BITS-1 downto 0)
    );
	end component;
	
	COMPONENT dec_pos_ang
	PORT (
		posicao: IN STD_LOGIC_VECTOR(2 downto 0);
		angulo0: STD_LOGIC_VECTOR(3 downto 0);
		angulo1: STD_LOGIC_VECTOR(3 downto 0);
		angulo2: STD_LOGIC_VECTOR(3 downto 0)
	);
	END  COMPONENT;
	
	component alerta_proximidade
    port ( 
        medida : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
        proximo: out std_logic
    );
	end component;
	
	

    SIGNAL s_angulo0: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL s_angulo1: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL s_angulo2: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL s_distancia0: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL s_distancia1: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL s_distancia2: STD_LOGIC_VECTOR(3 downto 0);
	SIGNAL s_pronto_interface: STD_LOGIC;
	SIGNAL s_pronto_transmissao
	SIGNAL s_medir: STD_LOGIC;
	SIGNAL s_medida: STD_LOGIC_VECTOR(11 downto 0);
	SIGNAL s_posicao: STD_LOGIC_VECTOR(2 downto 0);
	SIGNAL s_proximo: STD_LOGIC;
	SIGNAL sinais00 : STD_LOGIC_VECTOR(23 downto 0);
	SIGNAL sinais01 : STD_LOGIC_VECTOR(23 downto 0);
	SIGNAL sinais10 : STD_LOGIC_VECTOR(23 downto 0);
	SIGNAL sinais11 : STD_LOGIC_VECTOR(23 downto 0);
	SIGNAL s_depuracao : STD_LOGIC_VECTOR(23 downto 0);
	SIGNAL db_estado_interface : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_db_estado_tx_sonar : STD_LOGIC_VECTOR(3 DOWNTO 0);
	

BEGIN

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset <= reset;

    TRANSMISSAO: tx_dados_sonar port map(
		clock,
		reset,
		transmitir,
		s_angulo0,
		s_angulo1,
		s_angulo2,
		s_distancia0,
		s_distancia1,
		s_distancia2,
		saida_serial,
		s_pronto_transmissao,
		open,
		open,
		open,
		s_db_estado_tx_sonar,
		open
	);
	
	CONTROLE_SERVO: controle_sweep port map(
		clock,
		reset,
		ligar,
		s_posicao,
		open,
		pwm,
		open
	);
	
	INTERFACE: interface_hcsr04 port map(
		clock,
		reset,
		echo,
		s_medir,
		s_pronto_interface,
		trigger,
		s_medida,
		db_estado_interface		
	);
	
	MUX4: mux_4x1_n generic map(
		BITS => 12
	)
	port map(
		sinais00,
		sinais01,
		sinais10,
		sinais11,
		selmux,
		s_depuracao		
	);
	
	DECODIFICADOR: dec_pos_ang port map(
		s_posicao,
		s_angulo0,
		s_angulo1,
		s_angulo2
	);
	
	PROXIMIDADE: alerta_proximidade port map(
		s_medida,
		s_proximo
	);
	
	proximidade <= s_proximo;
	
    sinais00 <= s_posicao & db_estado_interface & "0000" & s_distancia2 & s_distancia1 & s_distancia2;
	sinais01 <= "0000" & "0000" & "0000" & "0000" & "0000" & "0000";
	sinais10 <= s_db_estado_tx_sonar & "0000" & "0000" & "0000" & "0000" & "0000" & "0000";
	sinais11 <= "0000" & "0000" & "0000" & s_angulo2 & s_angulo1 & s_angulo0;
	
END ARCHITECTURE;