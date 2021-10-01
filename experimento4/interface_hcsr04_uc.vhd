
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY interface_hcsr04_uc IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        medir : IN STD_LOGIC;
        fim : IN STD_LOGIC;
        registra : OUT STD_LOGIC;
        gera : OUT STD_LOGIC;
        zera : OUT STD_LOGIC;
        pronto : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR(3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE interface_hcsr04_uc_arch OF interface_hcsr04_uc IS

    TYPE tipo_estado IS (
        inicio,
        preparacao,
        envio,
        espera,
        armazena,
        final
    );

    SIGNAL Eatual : tipo_estado; -- estado atual
    SIGNAL Eprox : tipo_estado; -- proximo estado

BEGIN

    -- memoria de estado
    PROCESS (reset, clock)
    BEGIN
        IF reset = '1' THEN
            Eatual <= inicio;
        ELSIF clock'event AND clock = '1' THEN
            Eatual <= Eprox;
        END IF;
    END PROCESS;

    -- logica de proximo estado
    PROCESS (medir, fim, reset, Eatual)
    BEGIN
        CASE Eatual IS
            WHEN inicio => IF medir = '1' THEN
                Eprox <= preparacao;
            ELSE
                Eprox <= inicio;
        END IF;

        WHEN preparacao => Eprox <= envio;

        WHEN envio => Eprox <= espera;

        WHEN espera => IF (fim = '1') THEN
        Eprox <= armazena;
    ELSE
        Eprox <= espera;
    END IF;
    WHEN armazena => Eprox <= final;

    WHEN final => IF reset = '1' THEN
    Eprox <= inicio;
ELSE
    Eprox <= final;
END IF;

WHEN OTHERS => Eprox <= inicio;

END CASE;
END PROCESS;

-- logica de saida (Moore)
WITH Eatual SELECT
    gera <= '1' WHEN envio, '0' WHEN OTHERS;

WITH Eatual SELECT
    registra <= '1' WHEN armazena, '0' WHEN OTHERS;

WITH Eatual SELECT
    zera <= '1' WHEN preparacao, '0' WHEN OTHERS;

WITH Eatual SELECT
    pronto <= '1' WHEN final, '0' WHEN OTHERS;

WITH Eatual SELECT
    db_estado <= "0001" WHEN inicio,
    "0010" WHEN preparacao,
    "0011" WHEN envio,
    "0100" WHEN espera,
    "0101" WHEN armazena,
    "0110" WHEN final,
    "0001" WHEN OTHERS;

END interface_hcsr04_uc_arch;