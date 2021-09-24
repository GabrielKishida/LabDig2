library ieee;
use ieee.std_logic_1164.all;

entity controle_servo_tb is
end entity;

architecture tb of controle_servo_tb is
  
  component controle_servo is
    port (
      clock   : in  std_logic;
      reset   : in  std_logic;
      posicao : in  std_logic_vector(1 downto 0);
      pwm     : out std_logic
    );
  end component;
  
  signal clock_in: std_logic := '0';
  signal reset_in: std_logic := '0';
  signal posicao_in: std_logic_vector (1 downto 0) := "00";
  signal pwm_out: std_logic := '0';

  signal keep_simulating: std_logic := '0'; 
  constant clockPeriod: time := 20 ns;
  
begin

  clock_in <= (not clock_in) and keep_simulating after clockPeriod/2;

  dut: controle_servo port map( 
         clock=>   clock_in,
         reset=>   reset_in,
         posicao=> posicao_in,
         pwm=>     pwm_out
      );

  stimulus: process is
  begin
  
    assert false report "Inicio da simulacao" & LF & "... Simulacao ate 800 ms. Aguarde o final da simulacao..." severity note;
    keep_simulating <= '1';
    
    ---- inicio: reset ----------------
    reset_in <= '1'; 
    wait for 2*clockPeriod;
    reset_in <= '0';
    wait for 2*clockPeriod;

    ---- casos de teste
    -- posicao=00
    posicao_in <= "00"; -- largura de pulso de 0V
    wait for 200 ms;

    -- posicao=01
    posicao_in <= "01"; -- largura de pulso de 1ms
    wait for 200 ms;

    -- posicao=10
    posicao_in <= "10"; -- largura de pulso de 1,5ms
    wait for 200 ms;

    -- posicao=11
    posicao_in <= "11"; -- largura de pulso de 2ms
    wait for 200 ms;

    ---- final dos casos de teste  da simulacao
    assert false report "Fim da simulacao" severity note;
    keep_simulating <= '0';
    
    wait;
  end process;


end architecture;
