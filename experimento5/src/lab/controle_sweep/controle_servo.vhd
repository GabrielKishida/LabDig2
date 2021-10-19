LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY controle_servo IS
  PORT (
    clock : IN STD_LOGIC; -- 50MHz
    reset : IN STD_LOGIC;
    posicao : IN STD_LOGIC_VECTOR(2 DOWNTO 0); --  00=0ms,  01=1ms  10=1.5ms  11=2ms
    db_posicao : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
    pwm : OUT STD_LOGIC;
    db_pwm : OUT STD_LOGIC);

END controle_servo;

ARCHITECTURE rtl OF controle_servo IS

  CONSTANT CONTAGEM_MAXIMA : INTEGER := 1000000;
  SIGNAL s_pwm : STD_LOGIC;
  SIGNAL contagem : INTEGER RANGE 0 TO CONTAGEM_MAXIMA - 1;
  SIGNAL posicao_pwm : INTEGER RANGE 0 TO CONTAGEM_MAXIMA - 1;
  SIGNAL s_posicao : INTEGER RANGE 0 TO CONTAGEM_MAXIMA - 1;

BEGIN

  PROCESS (clock, reset, posicao)
  BEGIN
    -- inicia contagem e posicao
    IF (reset = '1') THEN
      contagem <= 0;
      s_pwm <= '0';
      posicao_pwm <= s_posicao;
    ELSIF (rising_edge(clock)) THEN
      -- saida
      IF (contagem < posicao_pwm) THEN
        s_pwm <= '1';
      ELSE
        s_pwm <= '0';
      END IF;
      -- atualiza contagem e posicao
      IF (contagem = CONTAGEM_MAXIMA - 1) THEN
        contagem <= 0;
        posicao_pwm <= s_posicao;
      ELSE
        contagem <= contagem + 1;
      END IF;
    END IF;
  END PROCESS;

  PROCESS (posicao)
  BEGIN
    CASE posicao IS
      WHEN "000" => s_posicao <= 50000; -- pulso de 1ms
      WHEN "001" => s_posicao <= 57143; -- pulso de 1,143ms
      WHEN "010" => s_posicao <= 64300; -- pulso de 1.286ms
      WHEN "011" => s_posicao <= 71450; -- pulso de 1.429ms
      WHEN "100" => s_posicao <= 78550; -- pulso de 1.571ms
      WHEN "101" => s_posicao <= 85700; -- pulso de 1.714ms
      WHEN "110" => s_posicao <= 92850; -- pulso de 1.857ms
      WHEN "111" => s_posicao <= 100000; -- pulso de 2ms
      WHEN OTHERS => s_posicao <= 0; -- nulo saida 0
    END CASE;
  END PROCESS;

  db_pwm <= s_pwm;
  pwm <= s_pwm;
  db_posicao <= posicao;

END rtl;