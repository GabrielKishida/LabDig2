
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.math_real.all;

entity contador_divisor is
  
   port (
        clock, zera_as, zera_s, conta: in std_logic;
        Q: out std_logic_vector (natural(ceil(log2(real(2941))))-1 downto 0);
        fim, meio: out std_logic 
   );
end entity contador_divisor;

architecture comportamental of contador_divisor is
    signal IQ: integer range 0 to 2941-1;
begin
  
    process (clock,zera_as,zera_s,conta,IQ)
    begin
        if zera_as='1' then IQ <= 0;   
        elsif rising_edge(clock) then
            if zera_s='1' then IQ <= 0;
            elsif conta='1' then 
                if IQ=2941-1 then IQ <= 0; 
                else IQ <= IQ + 1; 
                end if;
            else IQ <= IQ;
            end if;
        end if;

        -- fim de contagem    
        if IQ=2941-1 then fim <= '1'; 
        else fim <= '0'; 
        end if;

        -- meio da contagem
        if IQ=2941/2-1 then meio <= '1'; 
        else meio <= '0'; 
        end if;

        Q <= std_logic_vector(to_unsigned(IQ, Q'length));

    end process;

end comportamental;
