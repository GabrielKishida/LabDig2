
library ieee;
use ieee.std_logic_1164.all;

entity interface_hcsr04_uc is 
    port (
        clock           : in  std_logic;
        reset           : in  std_logic;
		medir			: in  std_logic;
		fim 			: in  std_logic;
		registra		: out std_logic;
		gera			: out std_logic;
		zera			: out std_logic;
		pronto			: out std_logic;
		db_estado		: out std_logic_vector(3 downto 0)
    );
end entity;

architecture interface_hcsr04_uc_arch of interface_hcsr04_uc is

    type tipo_estado is (
        inicio,
		preparacao,
		envio,
		espera,
		armazena,
		final
    );

    signal Eatual: tipo_estado;  -- estado atual
    signal Eprox:  tipo_estado;  -- proximo estado

begin

    -- memoria de estado
    process (reset, clock)
    begin
        if reset = '1' then
            Eatual <= inicio;
        elsif clock'event and clock = '1' then
            Eatual <= Eprox; 
        end if;
    end process;

  -- logica de proximo estado
    process (medir, fim, reset, Eatual) 
    begin
      case Eatual is
        when inicio =>         if medir='1' then Eprox <= preparacao;
										  else Eprox <= inicio;
										  end if;
										  
		when preparacao =>		  Eprox <= envio;
		
		when envio =>			Eprox <= espera;

        when espera =>          if (fim='1') then Eprox <= armazena;
                                else Eprox <= espera;
                                end if;
										  
										  
		when armazena => 		  Eprox <= final;
		
		when final =>			if reset='1' then Eprox <= inicio;
								else Eprox <= final;
								end if;	
		  
        when others =>          Eprox <= inicio;
		  
      end case;
    end process;

    -- logica de saida (Moore)
    with Eatual select
        gera <= '1' when envio, '0' when others;
		  
	 with Eatual select
		registra <= '1' when armazena, '0' when others;

    with Eatual select
        zera <= '1' when preparacao, '0' when others;

    with Eatual select
        pronto <= '1' when final, '0' when others;
    
	 with Eatual select
			db_estado <=    "0001" when inicio,
								 "0010" when preparacao,
							    "0011" when envio,
							    "0100" when espera,
							    "0101" when armazena,
								"0110" when final,
						 	    "0001" when others;

end interface_hcsr04_uc_arch;