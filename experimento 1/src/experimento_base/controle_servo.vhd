library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_servo is
port (
      clock    : in  std_logic; -- 50MHz
      reset    : in  std_logic;
      posicao  : in  std_logic_vector(1 downto 0);  --  00=0ms,  01=1ms  10=1.5ms  11=2ms
      pwm      : out std_logic );
end controle_servo;

architecture rtl of controle_servo is

  constant CONTAGEM_MAXIMA : integer := 1000000;
  signal contagem     : integer range 0 to CONTAGEM_MAXIMA-1;
  signal posicao_pwm  : integer range 0 to CONTAGEM_MAXIMA-1;
  signal s_posicao    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock,reset,posicao)
  begin
    -- inicia contagem e posicao
    if(reset='1') then
      contagem    <= 0;
      pwm         <= '0';
      posicao_pwm <= s_posicao;
    elsif(rising_edge(clock)) then
        -- saida
        if(contagem < posicao_pwm) then
          pwm  <= '1';
        else
          pwm  <= '0';
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
      when "01" =>    s_posicao <=   50000;  -- pulso de  1ms
      when "10" =>    s_posicao <=   75000;  -- pulso de 1.5 ms
      when "11" =>    s_posicao <=  100000;  -- pulso de 2 ms
      when others =>  s_posicao <=       0;  -- nulo saida 0
    end case;
  end process;
  
end rtl;