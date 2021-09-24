------------------------------------------------------------------
-- Arquivo   : rx_serial_8N2_fd.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 3 
--             > implementa configuracao 8N2
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     24/09/2021  1.0     Gabriel Kishida   versao inicial
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_8N2_fd is
    port (
        clock, reset                    : in  std_logic;
        zera, conta, carrega, desloca   : in  std_logic;
        entrada_serial                  : in  std_logic;
        tick, half_tick, fim_sinal      : out std_logic;
        dados_ascii                     : out std_logic_vector (7 downto 0);
		db_deslocado                    : out std_logic_vector (11 downto 0)
    );
end entity;

architecture rx_serial_8N2_fd_arch of rx_serial_8N2_fd is
     
    component deslocador_n
    generic (
        constant N: integer 
    );
    port (
        clock, reset: in std_logic;
        carrega, desloca, entrada_serial: in std_logic; 
        dados: in std_logic_vector (N-1 downto 0);
        saida: out  std_logic_vector (N-1 downto 0);
		db_deslocado: out std_logic_vector (N-1 downto 0)
    );
    end component;

    component contador_m
    generic (
        constant M: integer; 
        constant N: integer 
    );
    port (
        clock, zera, conta: in std_logic;
        Q: out std_logic_vector (N-1 downto 0);
        fim: out std_logic
    );
    end component;
    
    signal s_db_deslocado: std_logic_vector (8 downto 0);
    signal s_half_tick: std_logic;

begin

    DESLOCADOR: deslocador_n generic map (N => 8)  port map (
        clock,
        reset,
        "0",
        desloca, 
        entrada_serial, 
        "00000000", 
        s_saida <= dados_ascii, 
        s_db_deslocado
    );

    CONTADOR_SINAL: contador_m generic map (M => 8, N => 3) port map (
        clock, 
        zera, 
        conta, 
        open, 
        fim <= fim_sinal
    );

    CONTADOR_TICK: contador_m generic map (M => 2, N => 1) port map (
        clock <= s_half_tick, 
        zera, 
        conta, 
        open, 
        fim <= tick
    );

    CONTADOR_HALF_TICK: contador_m generic map (M => 2604, N => 12) port map (
        clock, 
        zera, 
        conta, 
        open, 
        fim <= s_half_tick
    );
	 
	db_deslocado <= s_db_deslocado;
    half_tick <= s_half_tick;
    saida_serial <= s_saida(0);
    
end architecture;

