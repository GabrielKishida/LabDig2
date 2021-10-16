LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tx_dados_sonar IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        transmitir : IN STD_LOGIC;
        angulo2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- digitos BCD
        angulo1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- de angulo
        angulo0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0); -- digitos de distancia
        distancia1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        distancia0 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
        saida_serial : OUT STD_LOGIC;
        pronto : OUT STD_LOGIC;
        db_transmitir : OUT STD_LOGIC;
        db_saida_serial : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE tx_dados_sonar_arch pf tx_dados_sonar IS

END tx_dados_sonar_arch;