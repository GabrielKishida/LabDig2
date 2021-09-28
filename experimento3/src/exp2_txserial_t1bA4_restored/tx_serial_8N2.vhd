
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity tx_serial_8N2 is
    port (
        clock, reset, partida	: in  std_logic;
        dados_ascii				: in  std_logic_vector (7 downto 0);
        saida_serial, pronto 	: out std_logic;
		  db_deslocado				: out std_logic_vector (11 downto 0);
		  db_deslocado_7seg_0	: out std_logic_vector (6 downto 0);
		  db_deslocado_7seg_1	: out std_logic_vector (6 downto 0);
		  db_deslocado_7seg_2	: out std_logic_vector (6 downto 0);
		  db_tick					: out std_logic;
		  db_estado					: out std_logic_vector (2 downto 0)
    );
end entity;

architecture tx_serial_8N2_arch of tx_serial_8N2 is
     
    component tx_serial_tick_uc port ( 
            clock, reset, partida, tick, fim:      in  std_logic;
            zera, conta, carrega, desloca, pronto: out std_logic;
				db_estado:									   out std_logic_vector (2 downto 0)
    );
    end component;

    component tx_serial_8N2_fd port (
        clock, reset: in std_logic;
        zera, conta, carrega, desloca: in std_logic;
        dados_ascii: in std_logic_vector (7 downto 0);
        saida_serial, fim : out std_logic;
		  db_deslocado:	out std_logic_vector (11 downto 0)
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
    
    component edge_detector is port ( 
             clk         : in   std_logic;
             signal_in   : in   std_logic;
             output      : out  std_logic
    );
    end component;
	 
	 component hexa7seg is
    port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
	 end component;
    
    signal s_reset, s_partida, s_partida_ed: std_logic;
    signal s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim: std_logic;
	 signal s_db_deslocado: std_logic_vector (11 downto 0);
	 signal s_db_estado: std_logic_vector (2 downto 0);

begin

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset   <= reset;
    s_partida <= partida;

    -- unidade de controle
    U1_UC: tx_serial_tick_uc port map (clock, s_reset, s_partida_ed, s_tick, s_fim,
                                       s_zera, s_conta, s_carrega, s_desloca, pronto, s_db_estado);

    -- fluxo de dados
    U2_FD: tx_serial_8N2_fd port map (clock, s_reset, s_zera, s_conta, s_carrega, s_desloca, 
                                      dados_ascii, saida_serial, s_fim, s_db_deslocado);

    -- gerador de tick
    -- fator de divisao 50MHz para 9600 bauds (5208=50M/9600), 13 bits
    U3_TICK: contador_m generic map (M => 5208, N => 13) port map (clock, s_zera, '1', open, s_tick);
 
    -- detetor de borda para tratar pulsos largos
    U4_ED: edge_detector port map (clock, s_partida, s_partida_ed);
	 
	 hex7seg0: hexa7seg port map (hexa => s_db_deslocado(3 downto 0), sseg => db_deslocado_7seg_0);
	 hex7seg1: hexa7seg port map (hexa => s_db_deslocado(7 downto 4), sseg => db_deslocado_7seg_1);
	 hex7seg2: hexa7seg port map (hexa => s_db_deslocado(11 downto 8), sseg => db_deslocado_7seg_2);
	 
	 db_tick <= s_tick;
	 db_estado <= s_db_estado;
	 
    
end architecture;

