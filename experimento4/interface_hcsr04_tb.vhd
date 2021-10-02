    ------------------------------------------------------------------
-- Arquivo   : tx_serial_tb.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
--             > modelo de testbench para simulacao do circuito
--             > de transmissao serial assincrona
--             > 
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
------------------------------------------------------------------
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY interface_hcsr04_tb IS
END ENTITY;

ARCHITECTURE tb OF interface_hcsr04_tb IS

    -- Componente a ser testado (Device Under Test -- DUT)
    COMPONENT interface_hcsr04 IS
        PORT (
            clock : IN STD_LOGIC;
            reset : IN STD_LOGIC;
            echo : IN STD_LOGIC;
            medir : IN STD_LOGIC;
            pronto : OUT STD_LOGIC;
            trigger : OUT STD_LOGIC;
            medida : OUT STD_LOGIC_VECTOR(11 DOWNTO 0);
            db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
        );
    END COMPONENT;

    -- Declaração de sinais para conectar o componente a ser testado (DUT)
    --   valores iniciais para fins de simulacao (ModelSim)
    SIGNAL clock_in : STD_LOGIC := '0';
    SIGNAL reset_in : STD_LOGIC := '0';
    SIGNAL echo_in : STD_LOGIC := '0';
    SIGNAL medir_in : STD_LOGIC := '0';
    SIGNAL pronto_out : STD_LOGIC := '0';
    SIGNAL trigger_out : STD_LOGIC := '0';
    SIGNAL medida_out : STD_LOGIC_VECTOR (11 DOWNTO 0) := "000000000000";
    SIGNAL db_estado_out : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";

    -- Configurações do clock
    SIGNAL keep_simulating : STD_LOGIC := '0'; -- delimita o tempo de geração do clock
    CONSTANT clockPeriod : TIME := 20 ns; -- clock de 50MHz

BEGIN
    -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
    -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
    -- simulação de eventos
    clock_in <= (NOT clock_in) AND keep_simulating AFTER clockPeriod/2;

    -- Conecta DUT (Device Under Test)
    dut : interface_hcsr04
    PORT MAP
    (
        clock => clock_in,
        reset => reset_in,
        echo => echo_in,
        medir => medir_in,
        pronto => pronto_out,
        trigger => trigger_out,
        medida => medida_out,
        db_estado => db_estado_out
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

        ---- caso de teste #1
        medir_in <= '1';
        WAIT FOR 20 * clockPeriod;
        medir_in <= '0';

        ---- acionamento da partida (inicio da transmissao)
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR 12000 * clockPeriod; -- pulso partida com 5 periodos de clock
        echo_in <= '0';

        ---- espera final da transmissao (pulso pronto em 1)
        WAIT UNTIL pronto_out = '1';

        ---- final do caso de teste 1

        -- intervalo entre casos de teste
        WAIT FOR 10000 * clockPeriod;

        ---- caso de teste #2
        medir_in <= '1';
        WAIT FOR 20 * clockPeriod;
        medir_in <= '0';

        ---- acionamento da partida (inicio da transmissao)
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR 148000 * clockPeriod; -- pulso partida com 5 periodos de clock
        echo_in <= '0';

        ---- espera final da transmissao (pulso pronto em 1)
        WAIT UNTIL pronto_out = '1';

        ---- final do caso de teste 2

        -- intervalo entre casos de teste
        WAIT FOR 10000 * clockPeriod;

        ---- caso de teste #3
        medir_in <= '1';
        WAIT FOR 20 * clockPeriod;
        medir_in <= '0';

        ---- acionamento da partida (inicio da transmissao)
        WAIT FOR 10000 * clockPeriod;
        echo_in <= '1';
        WAIT UNTIL rising_edge(clock_in);
        WAIT FOR 945000 * clockPeriod; -- pulso partida com 5 periodos de clock
        echo_in <= '0';

        ---- espera final da transmissao (pulso pronto em 1)
        WAIT UNTIL pronto_out = '1';

        ---- final do caso de teste 3

        -- intervalo entre casos de teste
        WAIT FOR 10000 * clockPeriod;

        ---- final dos casos de teste da simulacao
        ASSERT false REPORT "Fim da simulacao" SEVERITY note;
        keep_simulating <= '0';

        WAIT; -- fim da simulação: aguarda indefinidamente
    END PROCESS;
END ARCHITECTURE;