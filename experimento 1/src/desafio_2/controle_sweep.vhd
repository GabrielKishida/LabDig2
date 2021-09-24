library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity controle_sweep is
port (
      clock    	: in  std_logic; -- 50MHz
      reset    	: in  std_logic;
      liga			: in  std_logic;
		db_posicao	: out std_logic_vector(2 downto 0);
		db_slider	: out std_logic_vector(2 downto 0);
      pwm      	: out std_logic;
		db_pwm		: out std_logic);
		
end controle_sweep;

architecture arch_controle_sweep of controle_sweep is

  component controle_servo is
    port (
      clock    	: in  std_logic;
      reset    	: in  std_logic;
      posicao  	: in  std_logic_vector(2 downto 0);
		db_posicao	: out std_logic_vector(2 downto 0);
      pwm      	: out std_logic;
		db_pwm		: out std_logic
    );
  end component;
  
  component contador_3bits is
	port (
      clock    : in  std_logic;
		enable	: in  std_logic;
		reset    : in  std_logic;
		dado		: out std_logic_vector(2 downto 0)
		);
  end component;
  
  signal s_posicao : std_logic_vector(2 downto 0);
  signal s_db_posicao: std_logic_vector(2 downto 0);
  signal s_pwm: std_logic;
  signal s_db_pwm: std_logic;
  
begin
	contador : contador_3bits port map(
			clock => clock,
			enable => liga,
			reset => reset,
			dado => s_posicao);
			
	controle: controle_servo port map(
			clock => clock,
			reset => reset,
			posicao => s_posicao,
			pwm => s_pwm,
			db_pwm => s_db_pwm,
			db_posicao => s_db_posicao);
			
	db_posicao <= s_db_posicao;
	db_slider <= s_db_posicao;
	pwm <= s_pwm;
	db_pwm <= s_db_pwm;
  
end arch_controle_sweep;