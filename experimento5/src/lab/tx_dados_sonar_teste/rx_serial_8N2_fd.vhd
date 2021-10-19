
------------------------------------------------------------------
-- Arquivo   : rx_serial_8N2_fd.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 3 
--             > implementa configuracao 8N2
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     24/09/2021  1.0     Gabriel Kishida   versao inicial
------------------------------------------------------------------
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY rx_serial_8N2_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        zera, conta, carrega, desloca : IN STD_LOGIC;
        limpa, registra : IN STD_LOGIC;
        entrada_serial : IN STD_LOGIC;
        tick, fim_sinal : OUT STD_LOGIC;
        dados_ascii : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        db_deslocador : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rx_serial_8N2_fd_arch OF rx_serial_8N2_fd IS

    COMPONENT deslocador_n
        GENERIC (
            CONSTANT N : INTEGER
        );
        PORT (
            clock, reset : IN STD_LOGIC;
            carrega, desloca, entrada_serial : IN STD_LOGIC;
            dados : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0)
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

    COMPONENT registrador_n
        GENERIC (
            CONSTANT N : INTEGER
        );
        PORT (
            clock : IN STD_LOGIC;
            clear : IN STD_LOGIC;
            enable : IN STD_LOGIC;
            D : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
            Q : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL s_reset_cont : STD_LOGIC;
    SIGNAL s_reset_cont_final : STD_LOGIC;
    SIGNAL s_dados : STD_LOGIC_VECTOR(9 DOWNTO 0);

BEGIN

    DESLOCADOR : deslocador_n GENERIC MAP(
        N => 10) PORT MAP (
        clock,
        reset,
        '0',
        desloca,
        entrada_serial,
        "0000000000",
        s_dados
    );

    CONTADOR_SINAL : contador_m GENERIC MAP(
        M => 12) PORT MAP (
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
        s_dados (7 DOWNTO 0),
        dados_ascii
    );

    db_deslocador <= s_dados(7 DOWNTO 0);
    s_reset_cont_final <= s_reset_cont OR zera;

END ARCHITECTURE;