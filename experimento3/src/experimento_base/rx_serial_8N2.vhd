------------------------------------------------------------------
-- Arquivo   : rx_serial_8N2.vhd
-- Projeto   : Experiencia 3 - Recepcao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 3 
--             > implementa configuracao 8N2
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     24/09/2021  1.0     Gabriel Kishida   versao inicial
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rx_serial_8N2 is
    port (
        clock               : in  std_logic;
        reset               : in  std_logic;
        dado_serial         : in  std_logic;
        recebe_dado         : in  std_logic;
        pronto_rx           : out std_logic;
        tem_dado            : out std_logic;
        dado_recebido       : out std_logic_vector (7 downto 0);
        db_dado_recebido_0  : out std_logic_vector (6 downto 0);
        db_dado_recebido_1  : out std_logic_vector (6 downto 0);
        db_erro_paridade    : out std_logic;
        db_tick             : out std_logic;
        db_half_tick        : out std_logic;
        db_estado           : out std_logic_vector (6 downto 0)
    );
end entity;

architecture rx_serial_8N2_arch of rx_serial_8N2 is
     
    component rx_serial_tick_uc port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        sinal           : in  std_logic;
        tick            : in  std_logic;
        half_tick       : in  std_logic;
        fim_sinal       : in  std_logic;
        paridade        : in  std_logic;
        recebe_dado     : in  std_logic;
        zera            : out std_logic;
        conta           : out std_logic;
        carrega         : out std_logic;
        pronto          : out std_logic;
        tem_dado        : out std_logic;
        erro_paridade   : out std_logic;
		db_estado       : out std_logic_vector (3 downto 0)
    );
    end component;

    component rx_serial_8N2_fd port (
        clock, reset                    : in  std_logic;
        zera, conta, carrega, desloca   : in  std_logic;
        entrada_serial                  : in  std_logic;
        tick, half_tick, fim_sinal      : out std_logic;
        dados_ascii                     : out std_logic_vector (7 downto 0)
    );
    end component;
	 
	component hex7seg port (
        hexa : in  std_logic_vector(3 downto 0);
        sseg : out std_logic_vector(6 downto 0)
    );
	end component;

    signal s_zera, s_conta, s_desloca, s_tick   : std_logic;
    signal s_half_tick, s_fim_sinal, s_paridade : std_logic;

    signal s_dados_ascii    : std_logic_vector(7 downto 0);
    signal s_db_estado      : std_logic_vector (3 downto 0);

begin
    -- unidade de controle
    U1_UC: rx_serial_tick_uc port map (
        clock,
        reset,
        dado_serial,
        s_tick,
        s_half_tick,
        s_fim_sinal,
        s_paridade,
        recebe_dado,
        s_zera,
        s_conta,
        open,
        pronto_rx,
        tem_dado,
        db_erro_paridade,
        s_db_estado
    );

    -- fluxo de dados
    U2_FD: rx_serial_8N2_fd port map (
        clock,
        reset,
        s_zera,
        s_conta,
        '0',
        s_desloca,
        dado_serial,
        s_tick,
        s_half_tick,
        s_fim_sinal,
        s_dados_ascii
    );
	 
	DB_ESTADO_7SEG: hex7seg port map (
        hexa => s_db_estado(3 downto 0),
        sseg => db_estado
    );

	DB_DADO_7SEG_0: hex7seg port map (
        hexa => s_dados_ascii(3 downto 0),
        sseg => db_dado_recebido_0
    );

    DB_DADO_7SEG_1: hex7seg port map (
        hexa => '0' & s_dados_ascii(6 downto 4),
        sseg => db_dado_recebido_1
    );

    s_paridade <=   s_dados_ascii(0) xor s_dados_ascii(1) xor s_dados_ascii(2) xor 
                    s_dados_ascii(3) xor s_dados_ascii(4) xor s_dados_ascii(5) xor 
                    s_dados_ascii(6) xor s_dados_ascii(7);

    dado_recebido <= s_dados_ascii;
	db_tick <= s_tick;
    db_half_tick <= s_half_tick;
    
end architecture;

