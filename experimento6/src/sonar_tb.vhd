LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY sonar_tb IS
END ENTITY;

ARCHITECTURE tb OF sonar_tb IS

    -- Componente a ser testado (Device Under Test -- DUT)
    COMPONENT sonar IS
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            ligar : IN STD_LOGIC;
            echo : IN STD_LOGIC;
            selmux : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            entrada_serial : IN STD_LOGIC;
            recebe_dado : IN STD_LOGIC;
            pronto_tx_sonar : OUT STD_LOGIC;
            saida_serial : OUT STD_LOGIC;
            pwm : OUT STD_LOGIC;
            trigger : OUT STD_LOGIC;
            proximidade : OUT STD_LOGIC;
            hex0 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            hex1 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            hex2 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            hex3 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            hex4 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            hex5 : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            db_dado_recebido : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            db_pwm : OUT STD_LOGIC;
            db_saida_serial : OUT STD_LOGIC

        );
    END COMPONENT;

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

    -- Declaração de sinais para conectar o componente a ser testado (DUT)
    --   valores iniciais para fins de simulacao (ModelSim)
    SIGNAL clock_in : STD_LOGIC := '0';
    SIGNAL reset_in : STD_LOGIC := '0';
    SIGNAL ligar_in : STD_LOGIC := '0';
    SIGNAL echo_in : STD_LOGIC := '0';
    SIGNAL entrada_serial_in : STD_LOGIC := '1';
    SIGNAL recebe_dado_in : STD_LOGIC := '0';
    SIGNAL selmux_in : STD_LOGIC_VECTOR(1 DOWNTO 0) := "01";
    SIGNAL pronto_tx_sonar_out : STD_LOGIC;
    SIGNAL saida_serial_out : STD_LOGIC;
    SIGNAL pwm_out : STD_LOGIC;
    SIGNAL proximidade_out : STD_LOGIC;
    SIGNAL hex0_out, hex1_out, hex2_out, hex3_out, hex4_out, hex5_out : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL trigger_out : STD_LOGIC := '0';

    SIGNAL s_tem_dado : STD_LOGIC;
    SIGNAL s_dado_recebido : STD_LOGIC_VECTOR(7 DOWNTO 0);

    -- Configurações do clock
    SIGNAL keep_simulating : STD_LOGIC := '0'; -- delimita o tempo de geração do clock
    CONSTANT clockPeriod : TIME := 20 ns; -- clock de 50MHz
    CONSTANT one_cm_time : TIME := 2950 * clockPeriod;

BEGIN
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
    -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
    -- simulação de eventos
    clock_in <= (NOT clock_in) AND keep_simulating AFTER clockPeriod/2;

    -- Conecta DUT (Device Under Test)
    dut : sonar PORT MAP(
        clock => clock_in,
        reset => reset_in,
        ligar => ligar_in,
        echo => echo_in,
        selmux => selmux_in,
        entrada_serial => entrada_serial_in,
        recebe_dado => recebe_dado_in,
        pronto_tx_sonar => pronto_tx_sonar_out,
        saida_serial => saida_serial_out,
        pwm => pwm_out,
        trigger => trigger_out,
        proximidade => proximidade_out,
        hex0 => hex0_out,
        hex1 => hex1_out,
        hex2 => hex2_out,
        hex3 => hex3_out,
        hex4 => hex4_out,
        hex5 => hex5_out
    );

    uart : uart_8n2 PORT MAP(
        clock => clock_in,
        reset => reset_in,
        transmite_dado => '0',
        dados_ascii => "00000000",
        dado_serial => saida_serial_out,
        recebe_dado => s_tem_dado,
        saida_serial => OPEN,
        pronto_tx => OPEN,
        dado_recebido_rx => s_dado_recebido,
        tem_dado => s_tem_dado,
        pronto_rx => OPEN,
        db_transmite_dado => OPEN,
        db_saida_serial => OPEN,
        db_estado_tx => OPEN,
        db_partida => OPEN,
        db_recebe_dado => OPEN,
        db_dado_serial => OPEN,
        db_estado_rx => OPEN
    );

    -- geracao dos sinais de entrada (estimulos)
    stimulus : PROCESS IS
    BEGIN

        ASSERT false REPORT "Inicio da simulacao" SEVERITY note;
        keep_simulating <= '1';

        ---- inicio da simulacao: reset ----------------
        reset_in <= '1';
        WAIT FOR 20 * clockPeriod; -- pulso com 20 periodos de clock
        reset_in <= '0';
        WAIT UNTIL falling_edge(clock_in);
        WAIT FOR 50 * clockPeriod;

        ligar_in <= '1';

        ---- acionamento da partida (inicio da transmissao)
        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 10; -- Distância de 10 cm
        echo_in <= '0';

        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 20; -- Distância de 20 cm
        echo_in <= '0';

        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 25; -- Distância de 25 cm
        echo_in <= '0';

        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 121; -- Distância de 121 cm
        echo_in <= '0';

        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 87; -- Distância de 87 cm
        echo_in <= '0';

        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 132; -- Distância de 219 cm
        echo_in <= '0';

        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 18; -- Distância de 37 cm
        echo_in <= '0';

        WAIT UNTIL trigger_out = '1';
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR one_cm_time * 21; -- Distância de 21 cm
        echo_in <= '0';

        WAIT FOR 10000 * clockPeriod;
        WAIT UNTIL pronto_tx_sonar_out = '1';
        WAIT FOR 10000 * clockPeriod;

        ---- final dos casos de teste da simulacao
        ASSERT false REPORT "Fim da simulacao" SEVERITY note;
        keep_simulating <= '0';

        WAIT; -- fim da simulação: aguarda indefinidamente
    END PROCESS;
END ARCHITECTURE;