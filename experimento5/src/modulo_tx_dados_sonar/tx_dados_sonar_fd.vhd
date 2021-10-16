
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY rx_serial_8N2_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        zera : IN STD_LOGIC;
        conta : IN STD_LOGIC;
        enviar_palavra : IN STD_LOGIC;
        saida_serial : OUT STD_LOGIC;
        pronto_tx : OUT STD_LOGIC;
        db_estado_tx : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)

    );
END ENTITY;

ARCHITECTURE rx_serial_8N2_fd_arch OF rx_serial_8N2_fd IS
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

BEGIN

    MULTIPLEXADOR : mux_8x1_n GENERIC MAP(
        BITS =>) PORT MAP(
        D0 :
    );

    CONTADOR_SINAL : contador_m GENERIC MAP(
        M => 10) PORT MAP (
        clock,
        reset,
        zera,
        conta,
        OPEN,
        fim_sinal,
        OPEN
    );

    CONTADOR_TICK : contador_m GENERIC MAP(
        M => 5208) PORT MAP (
        clock,
        reset,
        zera, -- s_reset_cont_final, 
        '1', -- clock, 
        OPEN,
        OPEN, -- s_reset_cont,
        tick
    );
    REGISTRADOR : registrador_n GENERIC MAP(
        N => 8) PORT MAP(
        clock,
        limpa,
        registra,
        s_dados,
        dados_ascii
    );

    db_deslocador <= s_dados;
    s_reset_cont_final <= s_reset_cont OR zera;

END ARCHITECTURE;