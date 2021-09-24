library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
port (
      clock    	: in  std_logic; -- 50MHz
      reset    	: in  std_logic;
      posicao  	: in  std_logic_vector(2 downto 0);  --  00=0ms,  01=1ms  10=1.5ms  11=2ms
		db_posicao	: out std_logic_vector(2 downto 0);
      pwm      	: out std_logic;
		db_pwm		: out std_logic);
		
end controle_servo;

architecture rtl of controle_servo is

  constant CONTAGEM_MAXIMA : integer := 1000000;
  signal s_pwm			: std_logic;
  signal contagem    : integer range 0 to CONTAGEM_MAXIMA-1;
  signal posicao_pwm : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_posicao   : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock,reset,posicao)
  begin
    -- inicia contagem e posicao
    if(reset='1') then
      contagem    <= 0;
      s_pwm       <= '0';
      posicao_pwm <= s_posicao;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < posicao_pwm) then
          s_pwm  <= '1';
        else
          s_pwm  <= '0';
        end if;
        -- atualiza contagem e posicao
        if(contagem=CONTAGEM_MAXIMA-1) then
          contagem   <= 0;
          posicao_pwm <= s_posicao;
        else
          contagem   <= contagem + 1;
        end if;
    end if;
  end process;

  process(posicao)
  begin
    case posicao is
      when "001" =>    s_posicao <=   50000;  -- pulso de  1ms
      when "010" =>    s_posicao <=   58333;  -- pulso de  1.16ms
      when "011" =>    s_posicao <=   66666;  -- pulso de  1.33ms
		when "100" =>    s_posicao <=   75000;  -- pulso de  1.5ms
      when "101" =>    s_posicao <=   83333;  -- pulso de  1.66 ms
      when "110" =>    s_posicao <=   91666;  -- pulso de  1.83 ms
		when "111" =>    s_posicao <=  100000;  -- pulso de  2 ms
      when others =>  s_posicao  <=       0;  -- nulo saida 0
    end case;
  end process;
  
  db_pwm <= s_pwm;
  pwm <= s_pwm;
  db_posicao <= posicao;
  
end rtl;