LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY medidor_largura IS
	PORT (
		clock, zera, echo : IN STD_LOGIC;
		dig3, dig2, dig1, dig0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
		fim : OUT STD_LOGIC
	);
END medidor_largura;

ARCHITECTURE medidor_arch OF medidor_largura IS

	COMPONENT contador_bcd_4digitos
		PORT (
			clock, zera, conta : IN STD_LOGIC;
			dig3, dig2, dig1, dig0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			fim : OUT STD_LOGIC
		);
	END COMPONENT;

	COMPONENT contador_divisor
		PORT (
			clock, zera_as, zera_s, conta : IN STD_LOGIC;
			Q : OUT STD_LOGIC_VECTOR (NATURAL(ceil(log2(real(2941)))) - 1 DOWNTO 0);
			fim, meio : OUT STD_LOGIC
		);
	END COMPONENT;

	SIGNAL dig3_final, dig2_final, dig1_final, dig0_final : STD_LOGIC_VECTOR(3 DOWNTO 0);
	SIGNAL s_cm, s_fim : STD_LOGIC;

BEGIN

	CONTADOR_INICIAL : contador_divisor PORT MAP(
		clock,
		zera,
		zera,
		echo,
		OPEN,
		s_cm,
		OPEN
	);

	CONTADOR_FINAL : contador_bcd_4digitos PORT MAP(
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
END medidor_arch;