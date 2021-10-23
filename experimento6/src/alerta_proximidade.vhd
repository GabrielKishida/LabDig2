LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity alerta_proximidade is
    port ( 
        medida : in STD_LOGIC_VECTOR(11 DOWNTO 0);
        proximo: out std_logic
    );
end entity;

architecture behav of alerta_proximidade is
begin
    process(medida)
	begin
		if (medida(11 downto 8) = "0000" and 
			medida(7 downto 4) = "0001") then
			proximo <= '1';
		elsif (medida(11 downto 8) = "0000" and 
				medida(7 downto 4) = "0010" and
				medida(3 downto 0) = "0000") then
			proximo <= '1';
		else 
			proximo <= '0';
		end if;
	end process;

end behav;