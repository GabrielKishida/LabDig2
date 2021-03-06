------------------------------------------------------------------
-- Arquivo   : uart_8N2.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
------------------------------------------------------------------
-- Descricao : Circuito principal da UART
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

ENTITY uart_8N2 IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        partida : IN STD_LOGIC;
        dados_ascii : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        recebe_dado : IN STD_LOGIC;
        dado_serial : IN STD_LOGIC;
        dado_recebido : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        pronto_rx : OUT STD_LOGIC;
        tem_dado : OUT STD_LOGIC;
        pronto_tx : OUT STD_LOGIC;
        saida_serial : OUT STD_LOGIC;
        db_dado_recebido_0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_dado_recebido_1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_tick_rx : OUT STD_LOGIC;
        db_tick_tx : OUT STD_LOGIC;
        db_estado_rx : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_estado_tx : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_deslocador_rx : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        db_deslocador_tx : OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE uart_8N2_arch OF uart_8N2 IS

    COMPONENT tx_serial_8N2 IS
        PORT (
            clock, reset, partida : IN STD_LOGIC;
            dados_ascii : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            saida_serial, pronto : OUT STD_LOGIC;
            db_deslocado : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
            db_deslocado_7seg_0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
            db_deslocado_7seg_1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
            db_deslocado_7seg_2 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
            db_tick : OUT STD_LOGIC;
            db_estado : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT rx_serial_8N2 IS
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
    END COMPONENT;

BEGIN
    TX : tx_serial_8n2 PORT MAP(
        clock => clock,
        reset => reset,
        partida => partida,
        dados_ascii => dados_ascii,
        saida_serial => saida_serial,
        pronto => pronto_tx,
        db_deslocado => db_deslocador_tx,
        db_deslocado_7seg_0 => OPEN,
        db_deslocado_7seg_1 => OPEN,
        db_deslocado_7seg_2 => OPEN,
        db_tick => db_tick_tx,
        db_estado => db_estado_tx
    );

    RX : rx_serial_8n2 PORT MAP(
        clock => clock,
        reset => reset,
        dado_serial => dado_serial,
        recebe_dado => recebe_dado,
        pronto_rx => pronto_rx,
        tem_dado => tem_dado,
        dado_recebido => dado_recebido,
        db_dado_recebido_0 => db_dado_recebido_0,
        db_dado_recebido_1 => db_dado_recebido_1,
        db_tick => db_tick_rx,
        db_estado => db_estado_rx,
        db_dado_serial => OPEN,
        db_deslocador => db_deslocador_rx
    );

END ARCHITECTURE;