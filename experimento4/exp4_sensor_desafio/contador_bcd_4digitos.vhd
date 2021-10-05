--------------------------------------------------------------------
-- Arquivo   : contador_bcd_4digitos.vhd
-- Projeto   : Experiencia 4 - Interface com sensor de distancia
--------------------------------------------------------------------
-- Descricao : contador bcd com 4 digitos (modulo 10.000) 
--             descricao VHDL comportamental
--             1) reset sincrono
--             2) saida de fim de contagem para 9999
--------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     19/09/2020  1.0     Edson Midorikawa  versao inicial
--     26/09/2020  1.1     Edson Midorikawa  revisao
--     19/09/2021  1.2     Edson Midorikawa  revisao
--------------------------------------------------------------------
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY contador_bcd_4digitos IS
    PORT (
        clock, zera, conta : IN STD_LOGIC;
        dig3, dig2, dig1, dig0 : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        fim : OUT STD_LOGIC
    );
END contador_bcd_4digitos;

ARCHITECTURE comportamental OF contador_bcd_4digitos IS

    SIGNAL s_dig3, s_dig2, s_dig1, s_dig0 : unsigned(3 DOWNTO 0);

BEGIN

    PROCESS (clock)
    BEGIN
        IF (clock'event AND clock = '1') THEN
            IF (zera = '1') THEN -- reset sincrono
                s_dig0 <= "0000";
                s_dig1 <= "0000";
                s_dig2 <= "0000";
                s_dig3 <= "0000";
            ELSIF (conta = '1') THEN
                IF (s_dig0 = "1001") THEN
                    s_dig0 <= "0000";
                    IF (s_dig1 = "1001") THEN
                        s_dig1 <= "0000";
                        IF (s_dig2 = "1001") THEN
                            s_dig2 <= "0000";
                            IF (s_dig3 = "1001") THEN
                                s_dig3 <= "0000";
                            ELSE
                                s_dig3 <= s_dig3 + 1;
                            END IF;
                        ELSE
                            s_dig2 <= s_dig2 + 1;
                        END IF;
                    ELSE
                        s_dig1 <= s_dig1 + 1;
                    END IF;
                ELSE
                    s_dig0 <= s_dig0 + 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- fim de contagem (comando VHDL when else)
    fim <= '1' WHEN s_dig3 = "1001" AND s_dig2 = "1001" AND
        s_dig1 = "1001" AND s_dig0 = "1001" ELSE
        '0';

    -- saidas
    dig3 <= STD_LOGIC_VECTOR(s_dig3);
    dig2 <= STD_LOGIC_VECTOR(s_dig2);
    dig1 <= STD_LOGIC_VECTOR(s_dig1);
    dig0 <= STD_LOGIC_VECTOR(s_dig0);

END comportamental;