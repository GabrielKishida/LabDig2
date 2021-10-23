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
		pronto: OUT STD_LOGIC;
		saida_serial: OUT STD_LOGIC;
		pwm: OUT STD_LOGIC;
		trigger: OUT STD_LOGIC;
		
        
    );
END ENTITY;

ARCHITECTURE sonar_fd_arch OF sonar_fd IS

    ENTITY tx_dados_sonar IS
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
END ENTITY;
	
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
	
	ENTITY dec_pos_ang
	PORT (
		posicao: IN STD_LOGIC_VECTOR(2 downto 0);
		angulo0: STD_LOGIC_VECTOR(3 downto 0);
		angulo1: STD_LOGIC_VECTOR(3 downto 0);
		angulo2: STD_LOGIC_VECTOR(3 downto 0)
	);
	END  COMPONENT;
	
	

    SIGNAL s_reset : STD_LOGIC;
    SIGNAL s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim : STD_LOGIC;
    SIGNAL s_saida_serial : STD_LOGIC;

    SIGNAL s_db_deslocado : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL s_db_estado_hex_in : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset <= reset;

    -- unidade de controle
    U1_UC : tx_serial_tick_uc PORT MAP(
        clock, s_reset, partida, s_tick, s_fim,
        s_zera, s_conta, s_carrega, s_desloca, pronto_tx, db_estado);

    -- fluxo de dados
    U2_FD : tx_serial_8N2_fd PORT MAP(
        clock, s_reset, s_zera, s_conta, s_carrega, s_desloca,
        dados_ascii, s_saida_serial, s_fim, s_db_deslocado);

    -- gerador de tick
    -- fator de divisao 50MHz para 9600 bauds (5208=50M/9600)
    U3_TICK : contador_m GENERIC MAP(M => 5208) PORT MAP(clock, s_zera, '0', '1', OPEN, s_tick, OPEN);

    saida_serial <= s_saida_serial;
    db_saida_serial <= s_saida_serial;
    db_partida <= partida;
END ARCHITECTURE;