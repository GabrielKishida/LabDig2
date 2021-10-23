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

ENTITY tx_serial_tb IS
END ENTITY;

ARCHITECTURE tb OF tx_serial_tb IS

  -- Componente a ser testado (Device Under Test -- DUT)
  COMPONENT tx_serial_8N2
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

  -- Declaração de sinais para conectar o componente a ser testado (DUT)
  --   valores iniciais para fins de simulacao (ModelSim)
  SIGNAL clock_in : STD_LOGIC := '0';
  SIGNAL reset_in : STD_LOGIC := '0';
  SIGNAL partida_in : STD_LOGIC := '0';
  SIGNAL dados_ascii_8_in : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";

  SIGNAL saida_serial_out : STD_LOGIC;
  SIGNAL pronto_tx_out : STD_LOGIC;

  SIGNAL db_partida_out : STD_LOGIC;
  SIGNAL db_saida_serial_out : STD_LOGIC;
  SIGNAL db_estado_out : STD_LOGIC_VECTOR (3 DOWNTO 0);

  -- Configurações do clock
  SIGNAL keep_simulating : STD_LOGIC := '0'; -- delimita o tempo de geração do clock
  CONSTANT clockPeriod : TIME := 20 ns; -- clock de 50MHz

BEGIN
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (NOT clock_in) AND keep_simulating AFTER clockPeriod/2;

  -- Conecta DUT (Device Under Test)
  dut : tx_serial_8N2
  PORT MAP
  (
    clock => clock_in,
    reset => reset_in,
    partida => partida_in,
    dados_ascii => dados_ascii_8_in,
    saida_serial => saida_serial_out,
    pronto_tx => pronto_tx_out,
    db_partida => db_partida_out,
    db_saida_serial => db_saida_serial_out,
    db_estado => db_estado_out
  );

  -- geracao dos sinais de entrada (estimulos)
  stimulus : PROCESS IS
  BEGIN

    ASSERT false REPORT "Inicio da simulacao" SEVERITY note;
    keep_simulating <= '1';

    ---- inicio da simulacao: reset ----------------
    partida_in <= '0';
    reset_in <= '1';
    WAIT FOR 20 * clockPeriod; -- pulso com 20 periodos de clock
    reset_in <= '0';
    WAIT UNTIL falling_edge(clock_in);
    WAIT FOR 50 * clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #1)
    dados_ascii_8_in <= "00110101"; -- x35 = '5'	
    WAIT FOR 20 * clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    WAIT UNTIL rising_edge(clock_in);
    WAIT FOR 5 * clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
    WAIT UNTIL pronto_tx_out = '1';

    ---- final do caso de teste 1

    -- intervalo entre casos de teste
    WAIT FOR 2000 * clockPeriod;

    ---- dado de entrada da simulacao (caso de teste #2)
    dados_ascii_8_in <= "00101001"; -- x29 = ')'	
    WAIT FOR 20 * clockPeriod;

    ---- acionamento da partida (inicio da transmissao)
    partida_in <= '1';
    WAIT UNTIL rising_edge(clock_in);
    WAIT FOR 5 * clockPeriod; -- pulso partida com 5 periodos de clock
    partida_in <= '0';

    ---- espera final da transmissao (pulso pronto em 1)
    WAIT UNTIL pronto_tx_out = '1';

    ---- final do caso de teste 2

    -- intervalo
    WAIT FOR 2000 * clockPeriod;

    ---- final dos casos de teste da simulacao
    ASSERT false REPORT "Fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT; -- fim da simulação: aguarda indefinidamente
  END PROCESS;
END ARCHITECTURE;