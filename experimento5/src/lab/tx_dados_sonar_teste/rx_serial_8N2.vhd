------------------------------------------------------------------
-- Arquivo   : rx_serial_8N2.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 3 
--             > implementa configuracao 8N2
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     24/09/2021  1.0     Gabriel Kishida   versao inicial
------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY rx_serial_8N2 IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        dado_serial : IN STD_LOGIC;
        recebe_dado : IN STD_LOGIC;
        dado_recebido : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        tem_dado : OUT STD_LOGIC;
        pronto_rx : OUT STD_LOGIC;
        db_recebe_dado : OUT STD_LOGIC;
        db_dado_serial : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rx_serial_8N2_arch OF rx_serial_8N2 IS

    COMPONENT rx_serial_tick_uc PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        sinal : IN STD_LOGIC;
        tick : IN STD_LOGIC;
        fim_sinal : IN STD_LOGIC;
        recebe_dado : IN STD_LOGIC;
        zera : OUT STD_LOGIC;
        conta : OUT STD_LOGIC;
        carrega : OUT STD_LOGIC;
        pronto : OUT STD_LOGIC;
        tem_dado : OUT STD_LOGIC;
        registra : OUT STD_LOGIC;
        limpa : OUT STD_LOGIC;
        desloca : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT rx_serial_8N2_fd PORT (
        clock, reset : IN STD_LOGIC;
        zera, conta, carrega, desloca : IN STD_LOGIC;
        limpa, registra : IN STD_LOGIC;
        entrada_serial : IN STD_LOGIC;
        tick, fim_sinal : OUT STD_LOGIC;
        dados_ascii : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        db_deslocador : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL s_zera, s_conta, s_carrega, s_desloca, s_tick, s_conta_baud : STD_LOGIC;
    SIGNAL s_fim_sinal, s_registra, s_limpa : STD_LOGIC;

    SIGNAL s_dados_ascii : STD_LOGIC_VECTOR(7 DOWNTO 0);

BEGIN
    -- unidade de controle
    U1_UC : rx_serial_tick_uc PORT MAP(
        clock,
        reset,
        dado_serial,
        s_tick,
        s_fim_sinal,
        recebe_dado,
        s_zera,
        s_conta,
        s_carrega,
        pronto_rx,
        tem_dado,
        s_registra,
        s_limpa,
        s_desloca,
        db_estado
    );

    -- fluxo de dados
    U2_FD : rx_serial_8N2_fd PORT MAP(
        clock,
        reset,
        s_zera,
        s_conta,
        s_carrega,
        s_desloca,
        s_limpa,
        s_registra,
        dado_serial,
        s_tick,
        s_fim_sinal,
        s_dados_ascii,
        OPEN
    );

    db_dado_serial <= dado_serial;
    db_recebe_dado <= recebe_dado;
    dado_recebido <= s_dados_ascii;

END ARCHITECTURE;