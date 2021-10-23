library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity medidor_largura is 
    port ( clock, zera, echo:     in  std_logic;
           dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
           fim:                    out std_logic
    );
end medidor_largura;

architecture medidor_arch of medidor_largura is

	component contador_bcd_4digitos
    port (
           clock, zera, conta:     in  std_logic;
           dig3, dig2, dig1, dig0: out std_logic_vector(3 downto 0);
           fim:                    out std_logic
    );
	end component;
	
	component contador_divisor
	port(
			clock, zera_as, zera_s, conta: in std_logic;
			Q: out std_logic_vector (natural(ceil(log2(real(2941))))-1 downto 0);
			fim, meio: out std_logic 
	);
	end component;

	signal dig3_final, dig2_final, dig1_final, dig0_final: std_logic_vector(3 downto 0);
	signal s_cm, s_fim: std_logic;
	
begin

	CONTADOR_INICIAL: contador_divisor port map(
		clock,
		zera,
		zera,
		echo,
		open,
		s_cm,
		open
	);
	
	CONTADOR_FINAL:	contador_bcd_4digitos port map(
		clock,
		zera,
		s_cm,
		dig3_final,
		dig2_final,
		dig1_final,
		dig0_final,
		s_fim		
	);
	
	fim <= s_fim;
	dig3 <= dig3_final;
	dig2 <= dig2_final;
	dig1 <= dig1_final;
	dig0 <= dig0_final;


end medidor_arch;