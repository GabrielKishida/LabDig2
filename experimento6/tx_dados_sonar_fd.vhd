
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY tx_serial_8N2_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        zera : IN STD_LOGIC;
        conta : IN STD_LOGIC;
        enviar_palavra : IN STD_LOGIC;
		  angulo2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- digitos BCD
        angulo1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- de angulo
        angulo0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- digitos de distancia
        distancia1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        saida_serial : OUT STD_LOGIC;
        pronto_tx : OUT STD_LOGIC;
        db_estado_tx : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)

    );
END ENTITY;

ARCHITECTURE tx_serial_8N2_fd_arch OF tx_serial_8N2_fd IS
    COMPONENT uart_8n2 PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        transmite_dado : IN STD_LOGIC;
        dados_ascii : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        dado_serial : IN STD_LOGIC;
        recebe_dado : IN STD_LOGIC;
        saida_serial : OUT STD_LOGIC;
        pronto_tx : OUT STD_LOGIC;
        dado_recebido_rx : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        tem_dado : OUT STD_LOGIC;
        pronto_rx : OUT STD_LOGIC;
        db_transmite_dado : OUT STD_LOGIC;
        db_saida_serial : OUT STD_LOGIC;
        db_estado_tx : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
        db_recebe_dado : OUT STD_LOGIC;
        db_dado_serial : OUT STD_LOGIC;
        db_estado_rx : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT contador_m
        GENERIC (
            CONSTANT M : INTEGER
        );
        PORT (
            clock, zera_as, zera_s, conta : IN STD_LOGIC;
            Q : OUT STD_LOGIC_VECTOR (NATURAL(ceil(log2(real(M)))) - 1 DOWNTO 0);
            fim, meio : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT mux_8x1_n
        GENERIC (
            CONSTANT BITS : INTEGER := 4
        );
        PORT (
            D0 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            D1 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            D2 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            D3 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            D4 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            D5 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            D6 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            D7 : IN STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0);
            SEL : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
            MUX_OUT : OUT STD_LOGIC_VECTOR (BITS - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL s_reset_cont : STD_LOGIC;
    SIGNAL s_reset_cont_final : STD_LOGIC;
    SIGNAL s_dados : STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL s_angulo0_ascii: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL s_angulo1_ascii: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL s_angulo2_ascii: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL s_distancia0_ascii: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL s_distancia1_ascii: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL s_distancia2_ascii: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL virgula: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 SIGNAL ponto: STD_LOGIC_VECTOR(7 DOWNTO 0);
	 
	 

BEGIN

    MULTIPLEXADOR : mux_8x1_n GENERIC MAP(
        BITS =>) PORT MAP(
        D0 :
    );

    

    db_deslocador <= s_dados;
    s_reset_cont_final <= s_reset_cont OR zera;
	 s_angulo0_ascii <= "0000" & angulo0;
	 s_angulo1_ascii <= "0000" & angulo1;
	 s_angulo2_ascii <= "0000" & angulo2;
	 s_distancia0_ascii <= "0000" & angulo0;
	 s_distancia1_ascii <= "0000" & angulo1;
	 s_distancia2_ascii <= "0000" & angulo2;
	 virgula <= "00101100";
	 ponto <= "00101110";

	 

END ARCHITECTURE;