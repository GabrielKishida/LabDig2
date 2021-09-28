------------------------------------------------------------------
-- Arquivo   : rx_serial_tick_uc.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
--             > unidade de controle para o circuito
--             > de recepcao serial assincrona
--             > usa a tecnica de superamostragem com o uso
--             > de sinal de tick para recepcao de dados
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     24/09/2021  1.0     Gabriel Kishida   versao inicial
------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;

entity rx_serial_tick_uc is 
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
        sinal           : in  std_logic;
        tick            : in  std_logic;
        fim_sinal       : in  std_logic;
        recebe_dado     : in  std_logic;
        zera            : out std_logic;
        conta           : out std_logic;
        carrega         : out std_logic;
        pronto          : out std_logic;
        tem_dado        : out std_logic;
		  registra			: out std_logic;
		  limpa				: out std_logic;
		  desloca			: out std_logic;
		  db_estado       : out std_logic_vector (3 downto 0)
    );
end entity;

architecture rx_serial_tick_uc_arch of rx_serial_tick_uc is

    type tipo_estado is (
        inicial,
        preparacao,
        espera,
        recepcao,
        armazena,
        final,
        dado_presente
    );

    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicial;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (sinal, tick, fim_sinal, Eatual, recebe_dado) 
    begin
      case Eatual is
        when inicial =>         if sinal='0' then Eprox <= preparacao;
										  else Eprox <= inicial;
										  end if;
										  
		  when preparacao =>		  Eprox <= espera;

        when espera =>          if (tick='1') then Eprox <= recepcao;
                                elsif (fim_sinal='1') then Eprox <= armazena;
										  else Eprox <= espera;
                                end if;
										  
										  
		  when recepcao => 		  Eprox <= espera;
		  

        when armazena =>		  Eprox <= final;
		  
		  when final =>			  Eprox <= dado_presente;
		  
		  when dado_presente =>   if recebe_dado = '1' then Eprox <= inicial;
										  else Eprox <= dado_presente;
										  end if;

        when others =>          Eprox <= inicial;
		  
      end case;
    end process;

    -- logica de saida (Moore)
    with Eatual select
        carrega <= '1' when preparacao, '0' when others;
		  
	 with Eatual select
		  limpa <= '1' when preparacao, '0' when others;

    with Eatual select
		  registra <= '1' when armazena, '0' when others;

    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        conta <= '1' when recepcao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;

    with Eatual select
        tem_dado <= '1' when dado_presente, '0' when others;
		  
	 with Eatual select
		  desloca <= '1' when recepcao, '0' when others;
    
	 with Eatual select
			db_estado <=    "0001" when inicial,
								 "0010" when preparacao,
							    "0011" when espera,
							    "0100" when recepcao,
							    "0101" when armazena,
                         "0110" when final,
                         "0111" when dado_presente,
						 	    "0001" when others;

end rx_serial_tick_uc_arch;