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
END ENTITY;

ARCHITECTURE uart_8N2_arch OF uart_8N2 IS

    COMPONENT tx_serial_8N2 IS
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            partida : IN STD_LOGIC;
            dados_ascii : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            saida_serial : OUT STD_LOGIC;
            pronto_tx : OUT STD_LOGIC;
            db_partida : OUT STD_LOGIC;
            db_saida_serial : OUT STD_LOGIC;
            db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT rx_serial_8N2 IS
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
    END COMPONENT;

    SIGNAL s_saida_serial : STD_LOGIC;

BEGIN
    TX : tx_serial_8n2 PORT MAP(
        clock => clock,
        reset => reset,
        partida => transmite_dado,
        dados_ascii => dados_ascii,
        saida_serial => saida_serial,
        pronto_tx => pronto_tx,
        db_partida => db_partida,
        db_saida_serial => db_saida_serial,
        db_estado => db_estado_tx
    );
    RX : rx_serial_8n2 PORT MAP(
        clock => clock,
        reset => reset,
        dado_serial => dado_serial,
        recebe_dado => recebe_dado,
        pronto_rx => pronto_rx,
        tem_dado => tem_dado,
        dado_recebido => dado_recebido_rx,
        db_estado => db_estado_rx,
        db_dado_serial => db_dado_serial
    );
    db_transmite_dado <= transmite_dado;
    db_recebe_dado <= recebe_dado;
END ARCHITECTURE;