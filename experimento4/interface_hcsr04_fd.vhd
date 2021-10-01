

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity interface_hcsr04_fd is
    port (
        clock, conta, zera, registra, gera  : in  std_logic;
        distancia                 : out std_logic_vector (11 downto 0);
        trigger, fim                     : out std_logic
    );
end entity;

architecture arch of interface_hcsr04_fd is
     
	 
	component medidor_largura 
		port ( clock, zera, echo:     in  std_logic;
			   dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
			   fim:                    out std_logic
		);
	end component;
	
	component registrador_n
	 generic(
			constant N: integer
	 );
	 port(
			clock:  in  std_logic;
			clear:  in  std_logic;
			enable: in  std_logic;
			D:      in  std_logic_vector (N-1 downto 0);
			Q:      out std_logic_vector (N-1 downto 0) 
	 );
	end component;
	 
    component gerador_pulso
	   port(
		  clock:  in  std_logic;
		  reset:  in  std_logic;
		  gera:   in  std_logic;
		  para:   in  std_logic;
		  pulso:  out std_logic;
		  pronto: out std_logic
	   );
	end component;
	
	
	signal s_dig2, s_dig1, s_dig0: std_logic_vector(3 downto 0);
	signal s_distancia: std_logic_vector(11 downto 0);

begin

	CONTAGEM: medidor_largura
		port map(
		clock,
		zera,
		conta,
		open,
		s_dig2,
		s_dig1,
		s_dig0,
		fim					
		);

	REGISTRADOR: registrador_n generic map (N => 12) port map(
		  clock,
		  zera,
		  registra,
		  s_distancia,
		  distancia
	);
	
	GERADOR_TRIGGER: gerador_pulso
		port map(
		clock,
		zera,
		gera,
		'0',
		trigger,
		open
		);

	s_distancia <= s_dig2 & s_dig1 & s_dig0;
    
	
end architecture;