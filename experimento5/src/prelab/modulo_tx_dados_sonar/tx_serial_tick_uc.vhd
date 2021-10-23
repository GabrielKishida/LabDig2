------------------------------------------------------------------
-- Arquivo   : tx_serial_tick_uc.vhd
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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY tx_serial_tick_uc IS
    PORT (
        clock, reset, partida, tick, fim : IN STD_LOGIC;
        zera, conta, carrega, desloca, pronto : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE tx_serial_tick_uc_arch OF tx_serial_tick_uc IS

    TYPE tipo_estado IS (inicial, preparacao, espera, transmissao, final);
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
    PROCESS (partida, tick, fim, Eatual)
    BEGIN

        CASE Eatual IS

            WHEN inicial => IF partida = '1' THEN
                Eprox <= preparacao;
            ELSE
                Eprox <= inicial;
        END IF;

        WHEN preparacao => Eprox <= espera;

        WHEN espera => IF tick = '1' THEN
        Eprox <= transmissao;
    ELSIF fim = '0' THEN
        Eprox <= espera;
    ELSE
        Eprox <= final;
    END IF;

    WHEN transmissao => IF fim = '0' THEN
    Eprox <= espera;
ELSE
    Eprox <= final;
END IF;

WHEN final => Eprox <= inicial;

WHEN OTHERS => Eprox <= inicial;

END CASE;

END PROCESS;

-- logica de saida (Moore)
WITH Eatual SELECT
    carrega <= '1' WHEN preparacao, '0' WHEN OTHERS;

WITH Eatual SELECT
    zera <= '1' WHEN preparacao, '0' WHEN OTHERS;

WITH Eatual SELECT
    desloca <= '1' WHEN transmissao, '0' WHEN OTHERS;

WITH Eatual SELECT
    conta <= '1' WHEN transmissao, '0' WHEN OTHERS;

WITH Eatual SELECT
    pronto <= '1' WHEN final, '0' WHEN OTHERS;

WITH Eatual SELECT
    db_estado <= "0001" WHEN inicial,
    "0010" WHEN preparacao,
    "0011" WHEN espera,
    "0100" WHEN transmissao,
    "0101" WHEN final,
    "0000" WHEN OTHERS;

END tx_serial_tick_uc_arch;