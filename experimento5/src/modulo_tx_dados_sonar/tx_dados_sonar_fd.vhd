
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY tx_dados_sonar_fd IS
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
        fim_contagem : OUT STD_LOGIC;
        saida_serial : OUT STD_LOGIC;
        pronto_tx : OUT STD_LOGIC;
        db_transmite_dado : OUT STD_LOGIC;
        db_saida_serial : OUT STD_LOGIC;
        db_estado_tx : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)

    );
END ENTITY;

ARCHITECTURE tx_dados_sonar_fd_arch OF tx_dados_sonar_fd IS

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
        db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        db_partida : OUT STD_LOGIC;
        db_recebe_dado : OUT STD_LOGIC;
        db_dado_serial : OUT STD_LOGIC;
        db_estado_rx : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
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

    SIGNAL s_contagem : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL s_dado_a_transmitir : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL asc_angulo0, asc_angulo1, asc_angulo2 : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL asc_distancia0, asc_distancia1, asc_distancia2 : STD_LOGIC_VECTOR (7 DOWNTO 0);

BEGIN

    asc_angulo0 <= "0011" & angulo0;
    asc_angulo1 <= "0011" & angulo1;
    asc_angulo2 <= "0011" & angulo2;
    asc_distancia0 <= "0011" & distancia0;
    asc_distancia1 <= "0011" & distancia1;
    asc_distancia2 <= "0011" & distancia2;

    MULTIPLEXADOR : mux_8x1_n GENERIC MAP(
        BITS => 8) PORT MAP(
        D0 => asc_angulo0,
        D1 => asc_angulo1,
        D2 => asc_angulo2,
        D3 => "00101100", -- virgula
        D4 => asc_distancia0,
        D5 => asc_distancia1,
        D6 => asc_distancia2,
        D7 => "00101110", -- ponto
        SEL => s_contagem,
        MUX_OUT => s_dado_a_transmitir
    );

    UART : uart_8n2 PORT MAP(
        clock => clock,
        reset => reset,
        transmite_dado => enviar_palavra,
        dados_ascii => s_dado_a_transmitir,
        dado_serial => '0',
        recebe_dado => '0',
        saida_serial => saida_serial,
        pronto_tx => pronto_tx,
        dado_recebido_rx => OPEN,
        tem_dado => OPEN,
        pronto_rx => OPEN,
        db_transmite_dado => db_transmite_dado,
        db_saida_serial => db_saida_serial,
        db_estado_tx => db_estado_tx,
        db_partida => OPEN,
        db_recebe_dado => OPEN,
        db_dado_serial => OPEN,
        db_estado_rx => OPEN
    );

    CONTADOR : contador_m GENERIC MAP(
        m => 8) PORT MAP(
        clock => clock,
        zera_as => zera,
        zera_s => zera,
        conta => conta,
        Q => s_contagem,
        fim => fim_contagem,
        meio => OPEN
    );

END ARCHITECTURE;