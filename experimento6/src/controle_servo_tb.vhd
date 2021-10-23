LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY controle_servo_tb IS
END ENTITY;

ARCHITECTURE tb OF controle_servo_tb IS

  COMPONENT controle_servo IS
    PORT (
      clock : IN STD_LOGIC; -- 50MHz
      reset : IN STD_LOGIC;
      posicao : IN STD_LOGIC_VECTOR(2 DOWNTO 0); --  00=0ms,  01=1ms  10=1.5ms  11=2ms
      db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
      pwm : OUT STD_LOGIC;
      db_pwm : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL clock_in : STD_LOGIC := '0';
  SIGNAL reset_in : STD_LOGIC := '0';
  SIGNAL posicao_in : STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
  SIGNAL pwm_out : STD_LOGIC;
  SIGNAL db_posicao_out : STD_LOGIC_VECTOR(2 DOWNTO 0);
  SIGNAL db_pwm_out : STD_LOGIC;

  SIGNAL keep_simulating : STD_LOGIC := '0';
  CONSTANT clockPeriod : TIME := 20 ns;

BEGIN

  clock_in <= (NOT clock_in) AND keep_simulating AFTER clockPeriod/2;

  dut : controle_servo PORT MAP(
    clock => clock_in,
    reset => reset_in,
    posicao => posicao_in,
    db_posicao => db_posicao_out,
    pwm => pwm_out,
    db_pwm => db_pwm_out
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
    -- posicao=000
    posicao_in <= "000"; -- largura de pulso de 0V
    WAIT FOR 200 ms;

    -- posicao=001
    posicao_in <= "001"; -- largura de pulso de 1ms
    WAIT FOR 200 ms;

    -- posicao=010
    posicao_in <= "010"; -- largura de pulso de 1.16ms
    WAIT FOR 200 ms;

    -- posicao=011
    posicao_in <= "011"; -- largura de pulso de 1.33ms
    WAIT FOR 200 ms;

    -- posicao=100
    posicao_in <= "100"; -- largura de pulso de 1.5ms
    WAIT FOR 200 ms;

    -- posicao=101
    posicao_in <= "101"; -- largura de pulso de 1.66ms
    WAIT FOR 200 ms;

    -- posicao=110
    posicao_in <= "110"; -- largura de pulso de 1.83ms
    WAIT FOR 200 ms;

    -- posicao=111
    posicao_in <= "111"; -- largura de pulso de 2ms
    WAIT FOR 200 ms;

    ---- final dos casos de teste  da simulacao
    ASSERT false REPORT "Fim da simulacao" SEVERITY note;
    keep_simulating <= '0';

    WAIT;
  END PROCESS;
END ARCHITECTURE;