LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tx_dados_sonar_teste IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        transmitir : IN STD_LOGIC;
        saida_serial : OUT STD_LOGIC;
        pronto : OUT STD_LOGIC;
        db_transmitir : OUT STD_LOGIC;
        db_transmite_dado : OUT STD_LOGIC;
        db_saida_serial : OUT STD_LOGIC;
        db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        db_estado_uc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE tx_dados_sonar_teste_arch OF tx_dados_sonar_teste IS

    COMPONENT tx_dados_sonar IS
        PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        transmitir : IN STD_LOGIC;
        angulo2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        angulo1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        angulo0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        saida_serial : OUT STD_LOGIC;
        pronto : OUT STD_LOGIC;
        db_transmitir : OUT STD_LOGIC;
        db_transmite_dado : OUT STD_LOGIC;
        db_saida_serial : OUT STD_LOGIC;
        db_estado_tx : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        db_estado_uc : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
        );
    END COMPONENT;
	 
	 COMPONENT edge_detector IS 
	 PORT ( 
		clk         : in   std_logic;
      signal_in   : in   std_logic;
      output      : out  std_logic
		);
	 END COMPONENT;
	 
	 SIGNAL s_transmitir : STD_LOGIC;

BEGIN

	 ED: edge_detector pORT MAP(
		  clock,
		  transmitir,
		  s_transmitir
	 );

    DUT : tx_dados_sonar PORT MAP(
        clock => clock,
        reset => reset,
        transmitir => s_transmitir,
        angulo2 => "0011",
        angulo1 => "0101",
        angulo0 => "0001",
        distancia2 => "0111",
        distancia1 => "0001",
        distancia0 => "0000",
        saida_serial => saida_serial,
        pronto => pronto,
        db_transmitir => db_transmitir,
        db_transmite_dado => db_transmite_dado,
        db_saida_serial => db_saida_serial,
        db_estado_tx => db_estado_tx,
        db_estado_uc => db_estado_uc
    );

END tx_dados_sonar_teste_arch;