--------------------------------------------------------------------
-- Arquivo   : rx_serial_tb.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
--------------------------------------------------------------------
-- Descricao : testbench para circuito de recepcao serial 
--             contem recursos adicionais que devem ser aprendidos
--             1) procedure em VHDL (UART_WRITE_BYTE)
--             2) array de casos de teste
-- 
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
--------------------------------------------------------------------
--
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY rx_serial_tb IS
END ENTITY;

ARCHITECTURE tb OF rx_serial_tb IS

  -- Declaracao de sinais para conectar o componente a ser testado (DUT)
  SIGNAL clock_in : STD_LOGIC := '0';
  SIGNAL reset_in : STD_LOGIC := '0';
  SIGNAL recebe_in : STD_LOGIC := '0';
  -- saidas
  SIGNAL dado_out : STD_LOGIC_VECTOR(7 DOWNTO 0);
  SIGNAL pronto_out : STD_LOGIC;
  SIGNAL tem_dado_out : STD_LOGIC;
  SIGNAL db_recebe_dado_out : STD_LOGIC;
  SIGNAL db_estado_out : STD_LOGIC_VECTOR(3 DOWNTO 0);

  -- para procedimento UART_WRITE_BYTE
  SIGNAL entrada_serial_in : STD_LOGIC := '1';
  SIGNAL serialData : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";

  -- Configura��es do clock
  CONSTANT clockPeriod : TIME := 20 ns; -- 50MHz
  CONSTANT bitPeriod : TIME := 5208 * clockPeriod; -- 5208 clocks por bit (9.600 bauds)
  -- constant bitPeriod : time := 454*clockPeriod; -- 454 clocks por bit (115.200 bauds)

  -- Procedimento para geracao da sequencia de comunicacao serial 8N2
  -- adaptacao de codigo acessado de:
  -- https://www.nandland.com/goboard/uart-go-board-project-part1.html
  PROCEDURE UART_WRITE_BYTE (
    Data_In : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL Serial_Out : OUT STD_LOGIC) IS
  BEGIN

    -- envia Start Bit
    Serial_Out <= '0';
    WAIT FOR bitPeriod;

    -- envia Dado de 8 bits
    FOR ii IN 0 TO 7 LOOP
      Serial_Out <= Data_In(ii);
      WAIT FOR bitPeriod;
    END LOOP; -- loop ii

    -- envia 2 Stop Bits
    Serial_Out <= '1';
    WAIT FOR 2 * bitPeriod;

  END UART_WRITE_BYTE;
  -- fim procedure

  ---- Array de casos de teste
  TYPE caso_teste_type IS RECORD
    id : NATURAL;
    data : STD_LOGIC_VECTOR(7 DOWNTO 0);
  END RECORD;

  TYPE casos_teste_array IS ARRAY (NATURAL RANGE <>) OF caso_teste_type;
  CONSTANT casos_teste : casos_teste_array :=
  (
  (1, "00110101"), -- 35H
  (2, "01010101"), -- 55H
  (3, "10101010"), -- AAH
  (4, "11111111"), -- FFH
  (5, "00000000") -- 00H
  -- inserir aqui outros casos de teste (inserir "," na linha anterior)
  );

  SIGNAL keep_simulating : STD_LOGIC := '0'; -- delimita o tempo de gera��o do clock

BEGIN

  ---- Gerador de Clock
  clock_in <= (NOT clock_in) AND keep_simulating AFTER clockPeriod/2;

  -- Instancia��o direta DUT (Device Under Test)
  DUT : ENTITY work.rx_serial_8N2
    PORT MAP(
      clock => clock_in,
      reset => reset_in,
      dado_serial => entrada_serial_in,
      recebe_dado => recebe_in,
      dado_recebido => dado_out,
      tem_dado => tem_dado_out,
      pronto_rx => pronto_out,
      db_recebe_dado => db_recebe_dado_out,
      db_estado => db_estado_out
    );

  ---- Geracao dos sinais de entrada (estimulo)
  stimulus : PROCESS IS
  BEGIN

    ---- inicio da simulacao
    ASSERT false REPORT "inicio da simulacao" SEVERITY note;
    keep_simulating <= '1';
    -- reset
    reset_in <= '0';
    WAIT FOR bitPeriod;
    reset_in <= '1', '0' AFTER 2 * clockPeriod;
    WAIT FOR bitPeriod;

    ---- loop pelos casos de teste
    FOR i IN casos_teste'RANGE LOOP
      ASSERT false REPORT "Caso de teste " & INTEGER'image(casos_teste(i).id) SEVERITY note;
      serialData <= casos_teste(i).data; -- caso de teste "i"
      WAIT FOR 10 * clockPeriod;

      -- 1) envia bits seriais para circuito de recepcao
      UART_WRITE_BYTE (Data_In => serialData, Serial_Out => entrada_serial_in);
      entrada_serial_in <= '1'; -- repouso
      WAIT FOR bitPeriod;

      -- 2) simula recebimento do dado (p.ex. circuito principal registra saida)
      WAIT UNTIL falling_edge(clock_in);
      recebe_in <= '1', '0' AFTER 2 * clockPeriod;

      -- 3) intervalo entre casos de teste
      WAIT FOR 2 * bitPeriod;
    END LOOP;

    ---- final dos casos de teste da simulacao
    ASSERT false REPORT "fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT; -- fim da simula��o: aguarda indefinidamente

  END PROCESS stimulus;

END tb;