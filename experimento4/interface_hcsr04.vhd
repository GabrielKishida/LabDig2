library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity interface_hcsr04 is
    port (
        clock               : in  std_logic;
        reset               : in  std_logic;
        echo				: in  std_logic;
		medir				: in  std_logic;
		pronto				: out std_logic;
		trigger				: out std_logic;
		medida				: out std_logic_vector(11 downto 0);
		db_estado			: out std_logic_vector(3 downto 0)
    );
end entity;

architecture interface_hcsr04_arch of interface_hcsr04 is
     
  
	
	component interface_hcsr04_uc
		port (
			clock           : in  std_logic;
			reset           : in  std_logic;
			medir			: in  std_logic;
			fim 			: in  std_logic;
			registra		: out std_logic;
			gera			: out std_logic;
			zera			: out std_logic;
			pronto			: out std_logic;
			db_estado		: out std_logic_vector(3 downto 0)
		);
	end component;
	
	
	component interface_hcsr04_fd
		port (
			clock, conta, zera, registra, gera  : in  std_logic;
			distancia                 : out std_logic_vector (11 downto 0);
			trigger, fim                     : out std_logic
		);
	end component;
	
    

    signal s_pronto, s_fim, s_zera, s_gera, s_registra : std_logic;
    

begin
    -- unidade de controle
    U1_UC: interface_hcsr04_uc port map (
        clock,
        reset,
		medir,
		s_fim,
		s_registra,
		s_gera,
		s_zera,
		pronto,
		db_estado
       
    );

    -- fluxo de dados
    U2_FD: interface_hcsr04_fd port map (
        clock,
		echo,
        s_zera,
		s_registra,
		s_gera,
		medida,
		trigger,
		s_fim        
    );
	 
    
end architecture;