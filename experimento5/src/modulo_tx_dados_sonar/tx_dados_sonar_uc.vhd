LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tx_dados_sonar_uc IS
    PORT (
        clock, reset : IN STD_LOGIC;
        transmitir : IN STD_LOGIC;
        fim_tx : IN STD_LOGIC;
        fim_contagem : IN STD_LOGIC;
        zera : OUT STD_LOGIC;
        enviar_palavra : OUT STD_LOGIC;
        pronto : OUT STD_LOGIC;
        conta : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE tx_dados_sonar_uc_arch OF tx_dados_sonar_uc IS

    TYPE tipo_estado IS (inicial, preparacao, transmite, fim_transmite, fim_total);

    SIGNAL Eatual : tipo_estado; -- estado atual
    SIGNAL Eprox : tipo_estado; -- proximo estado

BEGIN

    -- memoria de estado
    PROCESS (reset, clock)
    BEGIN
        IF reset = '1' THEN
            Eatual <= inicial;
        ELSIF clock'event AND clock = '1' THEN
            Eatual <= Eprox;
        END IF;
    END PROCESS;

    -- logica de proximo estado
    PROCESS (clock, fim, transmite)
    BEGIN
        CASE Eatual IS
            WHEN inicial =>
                IF transmitir = '1' THEN
                    Eprox <= preparacao;
                ELSE
                    Eprox <= inicial;
                END IF;

            WHEN preparacao => Eprox <= transmite;

            WHEN transmite =>
                IF fim_tx = '1' AND fim_contagem = '0' THEN
                    Eprox <= fim_transmite;
                ELSIF fim_tx = '1' AND fim_contagem = '1' THEN
                    Eprox <= fim_total;
                ELSE
                    Eprox <= transmite;
                END IF;

            WHEN fim_transmite => Eprox <= transmite;

            WHEN fim_total =>
                IF transmitir = '1' THEN
                    Eprox <= preparacao;
                ELSE
                    Eprox <= fim_total;
                END IF;
        END CASE;

    END PROCESS;

    WITH Eatual SELECT
        zera <= '1' WHEN preparacao, '0' WHEN OTHERS;

    WITH Eatual SELECT
        conta <= '1' WHEN fim_transmite, '0' WHEN OTHERS;

    WITH Eatual SELECT
        pronto <= '1' WHEN fim_total, '0' WHEN OTHERS;

    WITH Eatual SELECT
        enviar_palavra <= '1' WHEN transmite, '0' WHEN OTHERS;

    WITH Eatual SELECT
        db_estado <= "001" WHEN inicial,
        "010" WHEN preparacao,
        "011" WHEN transmite,
        "100" WHEN fim_transmite,
        "101" WHEN fim_total,
        "000" WHEN OTHERS;

END tx_dados_sonar_uc_arch;