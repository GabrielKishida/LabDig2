LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tx_dados_sonar_tb IS
END ENTITY;

ARCHITECTURE tb OF tx_dados_sonar_tb IS

  -- Componente a ser testado (Device Under Test -- DUT)
  COMPONENT tx_dados_sonar
    PORT (
      clock : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      transmitir : IN STD_LOGIC;
      angulo2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- digitos BCD
      angulo1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- de angulo
      angulo0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      distancia2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- digitos de distancia
      distancia1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      distancia0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
      saida_serial : OUT STD_LOGIC;
      pronto : OUT STD_LOGIC;
      db_transmitir : OUT STD_LOGIC;
      db_transmite_dado : OUT STD_LOGIC;
      db_saida_serial : OUT STD_LOGIC;
      db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
      db_estado_uc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
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

  SIGNAL transmitir_in : STD_LOGIC := '0';
  SIGNAL angulo2_in, angulo1_in, angulo0_in : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
  SIGNAL distancia2_in, distancia1_in, distancia0_in : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";

  SIGNAL saida_serial_out : STD_LOGIC;
  SIGNAL pronto_out : STD_LOGIC;
  SIGNAL db_transmite_dado_out : STD_LOGIC;
  SIGNAL db_estado_tx_out : STD_LOGIC_VECTOR(3 DOWNTO 0);
  SIGNAL db_estado_uc_out : STD_LOGIC_VECTOR(2 DOWNTO 0);

  SIGNAL s_dado_recebido : STD_LOGIC_VECTOR (7 DOWNTO 0);
  SIGNAL s_tem_dado : STD_LOGIC;

  -- Configurações do clock
  SIGNAL keep_simulating : STD_LOGIC := '0'; -- delimita o tempo de geração do clock
  CONSTANT clockPeriod : TIME := 20 ns; -- clock de 50MHz

BEGIN
  -- Gerador de clock: executa enquanto 'keep_simulating = 1', com o período
  -- especificado. Quando keep_simulating=0, clock é interrompido, bem como a 
  -- simulação de eventos
  clock_in <= (NOT clock_in) AND keep_simulating AFTER clockPeriod/2;

  -- Conecta DUT (Device Under Test)
  dut : tx_dados_sonar PORT MAP(
    clock => clock_in,
    reset => reset_in,
    transmitir => transmitir_in,
    angulo2 => angulo2_in,
    angulo1 => angulo1_in,
    angulo0 => angulo0_in,
    distancia2 => distancia2_in,
    distancia1 => distancia1_in,
    distancia0 => distancia0_in,
    saida_serial => saida_serial_out,
    pronto => pronto_out,
    db_transmitir => OPEN,
    db_transmite_dado => db_transmite_dado_out,
    db_saida_serial => OPEN,
    db_estado_tx => db_estado_tx_out,
    db_estado_uc => db_estado_uc_out
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
    transmitir_in <= '0';
    reset_in <= '1';
    WAIT FOR 20 * clockPeriod; -- pulso com 20 periodos de clock
    reset_in <= '0';
    WAIT UNTIL falling_edge(clock_in);
    WAIT FOR 20 * clockPeriod;

    ---- Envio de 153,017. (caso de teste 1)
    angulo0_in <= "0001";
    angulo1_in <= "0101";
    angulo2_in <= "0011";
    distancia0_in <= "0000";
    distancia1_in <= "0001";
    distancia2_in <= "0111";

    WAIT FOR 10 * clockPeriod;

    transmitir_in <= '1';

    WAIT FOR 20 * clockPeriod;

    transmitir_in <= '0';

    WAIT UNTIL pronto_out = '1';

    ---- Intervalo
    WAIT FOR 1000 * clockPeriod;

    ---- Envio de 089,205. (caso de teste 1)
    angulo0_in <= "0000";
    angulo1_in <= "1000";
    angulo2_in <= "1001";
    distancia0_in <= "0010";
    distancia1_in <= "0000";
    distancia2_in <= "0101";

    WAIT FOR 10 * clockPeriod;

    transmitir_in <= '1';

    WAIT FOR 20 * clockPeriod;

    transmitir_in <= '0';

    WAIT UNTIL pronto_out = '1';

    ---- Intervalo
    WAIT FOR 1000 * clockPeriod;

    ---- final dos casos de teste da simulacao
    ASSERT false REPORT "Fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT; -- fim da simulação: aguarda indefinidamente
  END PROCESS;
END ARCHITECTURE;