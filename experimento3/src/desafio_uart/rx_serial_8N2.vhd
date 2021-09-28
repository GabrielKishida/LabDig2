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
        pronto_rx : OUT STD_LOGIC;
        tem_dado : OUT STD_LOGIC;
        dado_recebido : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        db_dado_recebido_0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_dado_recebido_1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_tick : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_dado_serial : OUT STD_LOGIC;
        db_deslocador : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
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
    COMPONENT hex7seg PORT (
        hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL s_zera, s_conta, s_carrega, s_desloca, s_tick, s_conta_baud : STD_LOGIC;
    SIGNAL s_fim_sinal, s_registra, s_limpa, s_dado_serial : STD_LOGIC;

    SIGNAL s_dados_ascii : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL s_db_estado : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN
    -- unidade de controle
    U1_UC : rx_serial_tick_uc PORT MAP(
        clock,
        reset,
        s_dado_serial,
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
        s_db_estado
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
        s_dado_serial,
        s_tick,
        s_fim_sinal,
        s_dados_ascii,
        db_deslocador
    );

    DB_ESTADO_7SEG : hex7seg PORT MAP(
        hexa => s_db_estado(3 DOWNTO 0),
        sseg => db_estado
    );

    DB_DADO_7SEG_0 : hex7seg PORT MAP(
        hexa => s_dados_ascii(3 DOWNTO 0),
        sseg => db_dado_recebido_0
    );

    DB_DADO_7SEG_1 : hex7seg PORT MAP(
        hexa => s_dados_ascii(7 DOWNTO 4),
        sseg => db_dado_recebido_1
    );
    s_dado_serial <= dado_serial;
    db_dado_serial <= s_dado_serial;
    dado_recebido <= s_dados_ascii;
    db_tick <= s_tick;

END ARCHITECTURE;