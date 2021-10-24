LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

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
        dado_recebido_rx : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        db_transmitir : OUT STD_LOGIC;
        db_transmite_dado : OUT STD_LOGIC;
        db_saida_serial : OUT STD_LOGIC;
        db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        db_estado_rx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        db_estado_uc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
        db_contagem_mux_transmissao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        db_dado_a_transmitir : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE tx_dados_sonar_arch OF tx_dados_sonar IS

    SIGNAL s_zera, s_conta, s_enviar_palavra, s_fim_tx : STD_LOGIC;
    SIGNAL s_fim_contagem : STD_LOGIC;

    COMPONENT tx_dados_sonar_fd IS
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
            dado_recebido_rx : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            db_transmite_dado : OUT STD_LOGIC;
            db_saida_serial : OUT STD_LOGIC;
            db_estado_tx : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            db_estado_rx : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            db_contagem_mux_transmissao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            db_dado_a_transmitir : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT tx_dados_sonar_uc IS
        PORT (
            clock, reset : IN STD_LOGIC;
            transmitir : IN STD_LOGIC;
            fim_tx : IN STD_LOGIC;
            fim_contagem : IN STD_LOGIC;
            zera : OUT STD_LOGIC;
            enviar_palavra : OUT STD_LOGIC;
            pronto : OUT STD_LOGIC;
            conta : OUT STD_LOGIC;
            db_estado : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    END COMPONENT;

BEGIN

    FD : tx_dados_sonar_fd PORT MAP(
        clock => clock,
        reset => reset,
        zera => s_zera,
        conta => s_conta,
        enviar_palavra => s_enviar_palavra,
        angulo2 => angulo2,
        angulo1 => angulo1,
        angulo0 => angulo0,
        distancia2 => distancia2,
        distancia1 => distancia1,
        distancia0 => distancia0,
        fim_contagem => s_fim_contagem,
        saida_serial => saida_serial,
        pronto_tx => s_fim_tx,
        db_transmite_dado => db_transmite_dado,
        db_saida_serial => db_saida_serial,
        db_estado_tx => db_estado_tx,
        db_contagem_mux_transmissao => db_contagem_mux_transmissao,
        db_dado_a_transmitir => db_dado_a_transmitir,
        db_estado_rx => db_estado_rx,
        dado_recebido_rx => dado_recebido_rx

    );

    UC : tx_dados_sonar_uc PORT MAP(
        clock => clock,
        reset => reset,
        transmitir => transmitir,
        fim_tx => s_fim_tx,
        fim_contagem => s_fim_contagem,
        zera => s_zera,
        enviar_palavra => s_enviar_palavra,
        pronto => pronto,
        conta => s_conta,
        db_estado => db_estado_uc
    );

    db_transmitir <= transmitir;

END tx_dados_sonar_arch;