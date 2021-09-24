library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity contador_3bits is
port (
      clock    : in  std_logic;
		enable   : in  std_logic;
		reset    : in  std_logic;
		dado		: out std_logic_vector(2 downto 0)
		);
		
end contador_3bits;

architecture arch_contador_3bits of contador_3bits is

  constant CONTAGEM_MAXIMA : integer := 50000000 * 7;
  signal subindo 		: std_logic;
  signal contagem    : integer range 0 to CONTAGEM_MAXIMA-1;
  
begin

  process(clock,reset)
  begin
    -- inicia contagem e posicao
    if(reset='1') then
      contagem <= 0;
    elsif(rising_edge(clock) and enable = '1') then
        -- atualiza contagem e posicao
        if(contagem=CONTAGEM_MAXIMA-1) then
			 subindo <= '0';
		  elsif(contagem=0) then
			 subindo <= '1';
        end if;
		  
		  if(subindo = '0') then
          contagem <= contagem - 1;
		  else
			 contagem <= contagem + 1;
        end if;
		  
    end if;
  end process;

  process(contagem, reset)
  begin
	if (reset = '1') then
		dado <= "000";
	elsif (contagem < 50000000 * 1) then
		dado <= "001";
	elsif (50000000 * 1 <= contagem and contagem < 50000000 * 2) then 
		dado <= "010";
	elsif (50000000 * 2 <= contagem and contagem < 50000000 * 3) then
		dado <= "011";
	elsif (50000000 * 3 <= contagem and contagem < 50000000 * 4) then
		dado <= "100";
	elsif (50000000 * 4 <= contagem and contagem < 50000000 * 5) then
		dado <= "101";
	elsif (50000000 * 5 <= contagem and contagem < 50000000 * 6) then
		dado <= "110";
	elsif (50000000 * 6 <= contagem and contagem < 50000000 * 7) then
		dado <= "111";
	end if;
  end process;
  
end arch_contador_3bits;