
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
use IEEE.math_real.all;

entity rx_serial_8N2_fd is
    port (
        clock, reset                    : in  std_logic;
        zera, conta, carrega, desloca   : in  std_logic;
		  limpa, registra						 : in  std_logic;
        entrada_serial                  : in  std_logic;
        tick, fim_sinal                 : out std_logic;
        dados_ascii                     : out std_logic_vector (7 downto 0);
		  db_deslocador						 : out std_logic_vector (7 downto 0)
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
        saida: out  std_logic_vector (N-1 downto 0)
    );
    end component;

    component contador_m
    generic (
        constant M: integer
    );
    port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
        fim, meio: out std_logic 
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
    
    signal s_reset_cont: std_logic;
	 signal s_reset_cont_final: std_logic;
	 signal s_dados:     std_logic_vector(7 downto 0);

begin

    DESLOCADOR: deslocador_n generic map (N => 8)  port map (
        clock,
        reset,
        '0',
        desloca, 
        entrada_serial, 
        "00000000", 
        s_dados
    );

    CONTADOR_SINAL: contador_m generic map (M => 10) port map (
        clock,
		  reset,
        zera, 
        conta, 
        open, 
        fim_sinal,
		  open
    );

    CONTADOR_TICK: contador_m generic map (M => 5208) port map (
        clock,
		  reset,
        zera,  -- s_reset_cont_final, 
        '1',   -- clock, 
        open, 
        open,  -- s_reset_cont,
		  tick  
    );

	 
	 REGISTRADOR: registrador_n generic map (N => 8) port map(
		  clock,
		  limpa,
		  registra,
		  s_dados,
		  dados_ascii
	 );
	
	db_deslocador <= s_dados;
	s_reset_cont_final <= s_reset_cont or zera;
    
end architecture;