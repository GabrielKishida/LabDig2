library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity exp4_sensor is
 port (
 clock: in std_logic;
 reset: in std_logic;
 medir: in std_logic;
 echo: in std_logic;
 trigger: out std_logic;
 hex0: out std_logic_vector(6 downto 0); 
 hex1: out std_logic_vector(6 downto 0);
 hex2: out std_logic_vector(6 downto 0);
 pronto: out std_logic;
 db_trigger: out std_logic;
 db_echo: out std_logic;
 db_estado: out std_logic_vector(6 downto 0) 
 );
end entity exp4_sensor;

architecture arch of exp4_sensor is

component interface_hcsr04
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
end component;


component edge_detector
	port ( clk         : in   std_logic;
           signal_in   : in   std_logic;
           output      : out  std_logic
    );
end component;


component hex7seg
	port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
end component;

signal s_db_estado, s_medida0, s_medida1, s_medida2: std_logic_vector(3 downto 0);
signal s_medida: std_logic_vector(11 downto 0);
signal s_medir, s_db_echo, s_trigger: std_logic;

begin

DETECTOR_DE_BORDA: edge_detector port map(
	clock,
	medir,
	s_medir
);

INTERFACE: interface_hcsr04 port map(
	clock,
	reset,
	echo,
	s_medir,
	pronto,
	s_trigger,
	s_medida,
	s_db_estado
);

HEXA_ESTADO: hex7seg port map(
	s_db_estado,
	db_estado
);

HEXA_DIGITO0: hex7seg port map(
	s_medida0,
	hex0
);

HEXA_DIGITO1: hex7seg port map(
	s_medida1,
	hex1
);

HEXA_DIGITO2: hex7seg port map(
	s_medida2,
	hex2
);

s_medida0 <= s_medida (3 downto 0);
s_medida1 <= s_medida (7 downto 4);
s_medida2 <= s_medida (11 downto 8);
db_echo <= echo;
db_trigger <= s_trigger;
trigger <= s_trigger;





end arch;
