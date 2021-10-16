LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controle_sweep_tb IS
END ENTITY;

ARCHITECTURE tb OF controle_sweep_tb IS

  COMPONENT controle_sweep IS
    PORT (
      clock : IN STD_LOGIC; -- 50MHz
      reset : IN STD_LOGIC;
      liga : IN STD_LOGIC;
      db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      db_slider : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      pwm : OUT STD_LOGIC;
      db_pwm : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL clock_in : STD_LOGIC := '0';
  SIGNAL reset_in : STD_LOGIC := '0';
  SIGNAL liga_in : STD_LOGIC := '0';
  SIGNAL pwm_out : STD_LOGIC;
  SIGNAL db_pwm_out : STD_LOGIC;
  SIGNAL db_posicao_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL db_slider_out : STD_LOGIC_VECTOR(2 DOWNTO 0);

  SIGNAL keep_simulating : STD_LOGIC := '0';
  CONSTANT clockPeriod : TIME := 20 ns;

BEGIN

  clock_in <= (NOT clock_in) AND keep_simulating AFTER clockPeriod/2;

  dut : controle_sweep PORT MAP(
    clock => clock_in,
    reset => reset_in,
    liga => liga_in,
    pwm => pwm_out,
    db_pwm => db_pwm_out,
    db_posicao => db_posicao_out,
    db_slider => db_slider_out
  );

  stimulus : PROCESS IS
  BEGIN

    ASSERT false REPORT "Inicio da simulacao" & LF & "... Simulacao ate 800 ms. Aguarde o final da simulacao..." SEVERITY note;
    keep_simulating <= '1';

    ---- inicio: reset ----------------
    reset_in <= '1';
    WAIT FOR 2 * clockPeriod;
    reset_in <= '0';
    WAIT FOR 2 * clockPeriod;

    ---- casos de teste

    ---- servo indo para posicao 100

    liga_in <= '1';

    WAIT FOR 750 * clockPeriod;

    ASSERT db_posicao_out = "100" REPORT "Servo não demora o tempo esperado para atingir uma posição esperada" SEVERITY failure;

    liga_in <= '0';

    ---- teste do comando de reset

    reset_in <= '1';
    WAIT FOR 2 * clockPeriod;
    reset_in <= '0';
    WAIT FOR 2 * clockPeriod;

    ASSERT db_posicao_out = "000" REPORT "Reset não funciona como esperado" SEVERITY failure;

    ---- teste de varredura completa

    liga_in <= '1';

    WAIT FOR 10000 * clockPeriod;

    ---- final dos casos de teste  da simulacao
    ASSERT false REPORT "Fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT;
  END PROCESS;
END ARCHITECTURE;