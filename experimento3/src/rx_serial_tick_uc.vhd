------------------------------------------------------------------
-- Arquivo   : rx_serial_tick_uc.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : circuito da experiencia 2 
--             > unidade de controle para o circuito
--             > de transmissao serial assincrona
--             > 
--             > usa a tecnica de superamostragem com o uso
--             > de sinal de tick para transmissao de dados
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
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
        half_tick       : in  std_logic;
        fim             : in  std_logic;
        paridade        : in  std_logic;
        zera            : out std_logic;
        conta           : out std_logic;
        carrega         : out std_logic;
        pronto          : out std_logic;
        erro_paridade   : out std_logic;
		db_estado       : out std_logic_vector (2 downto 0)
    );
end entity;

architecture rx_serial_tick_uc_arch of rx_serial_tick_uc is

    type tipo_estado is (
        inicial,
        espera,
        inicio_amostra,
        espera_amostra,
        amostra,
        checa_paridade,
        pronto,
        erro
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
    process (sinal, tick, half_tick, paridade, fim, Eatual) 
    begin
      case Eatual is
        when inicial        =>  Eprox <= espera;

        when espera =>          if sinal='0' then  Eprox <= inicio_amostra;
                                else Eprox <= espera;
                                end if;

        when inicio_amostra =>  if half_tick='1' then Eprox <= amostra;
                                else Eprox <= inicio_amostra;
                                end if;
        
        when amostra =>         if fim='1' then Eprox <= checa_paridade;
                                else Eprox <= espera_amostra;
                                end if;
        
        when espera_amostra =>  if tick='1' then Eprox <= amostra;
                                else Eprox <= espera_amostra;
                                end if;
                                   
        when checa_paridade =>  if paridade='1' then Eprox <= pronto;
                                else Eprox <= erro;
                                end if;

        when pronto =>          Eprox <= espera;

        when erro =>            Eprox <= espera;

        when others =>          Eprox <= inicial;
      end case;
    end process;

    -- logica de saida (Moore)
    with Eatual select
        carrega <= '1' when amostra, '0' when others;

    with Eatual select
        zera <= '1' when amostra or espera, '0' when others;

    with Eatual select
        conta <= '1' when inicio_amostra or espera_amostra, '0' when others;

    with Eatual select
        pronto <= '1' when pronto or erro, '0' when others;

    with Eatual select
        erro_paridade <= '1' when pronto or erro, '0' when others;
    
	 with Eatual select
			db_estado <=    "0001" when inicial,
							"0010" when espera,
							"0011" when inicio_amostra,
							"0100" when espera_amostra,
							"0101" when amostra,
                            "0110" when checa_paridade,
                            "0111" when pronto,
                            "1000" when erro,
							"0000" when others;

end rx_serial_tick_uc_arch;
