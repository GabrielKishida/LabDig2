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

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY rx_serial_tick_uc IS
    PORT (
        clock : IN STD_LOGIC;
        reset : IN STD_LOGIC;
        sinal : IN STD_LOGIC;
        tick : IN STD_LOGIC;
        fim_sinal : IN STD_LOGIC;
        recebe_dado : IN STD_LOGIC;
        zera : OUT STD_LOGIC;
        conta : OUT STD_LOGIC;
        carrega : OUT STD_LOGIC;
        pronto : OUT STD_LOGIC;
        tem_dado : OUT STD_LOGIC;
        registra : OUT STD_LOGIC;
        limpa : OUT STD_LOGIC;
        desloca : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE rx_serial_tick_uc_arch OF rx_serial_tick_uc IS

    TYPE tipo_estado IS (
        inicial,
        preparacao,
        espera,
        recepcao,
        armazena,
        final,
        dado_presente
    );

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
    PROCESS (sinal, tick, fim_sinal, Eatual, recebe_dado)
    BEGIN
        CASE Eatual IS
            WHEN inicial => IF sinal = '0' THEN
                Eprox <= preparacao;
            ELSE
                Eprox <= inicial;
        END IF;

        WHEN preparacao => Eprox <= espera;

        WHEN espera => IF (tick = '1') THEN
        Eprox <= recepcao;
    ELSIF (fim_sinal = '1') THEN
        Eprox <= armazena;
    ELSE
        Eprox <= espera;
    END IF;
    WHEN recepcao => Eprox <= espera;
    WHEN armazena => Eprox <= final;

    WHEN final => Eprox <= dado_presente;

    WHEN dado_presente => IF recebe_dado = '1' THEN
    Eprox <= inicial;
ELSE
    Eprox <= dado_presente;
END IF;

WHEN OTHERS => Eprox <= inicial;

END CASE;
END PROCESS;

-- logica de saida (Moore)
WITH Eatual SELECT
    carrega <= '1' WHEN preparacao, '0' WHEN OTHERS;

WITH Eatual SELECT
    limpa <= '1' WHEN preparacao, '0' WHEN OTHERS;

WITH Eatual SELECT
    registra <= '1' WHEN armazena, '0' WHEN OTHERS;

WITH Eatual SELECT
    zera <= '1' WHEN preparacao, '0' WHEN OTHERS;

WITH Eatual SELECT
    conta <= '1' WHEN recepcao, '0' WHEN OTHERS;

WITH Eatual SELECT
    pronto <= '1' WHEN final, '0' WHEN OTHERS;

WITH Eatual SELECT
    tem_dado <= '1' WHEN dado_presente, '0' WHEN OTHERS;

WITH Eatual SELECT
    desloca <= '1' WHEN recepcao, '0' WHEN OTHERS;

WITH Eatual SELECT
    db_estado <= "0001" WHEN inicial,
    "0010" WHEN preparacao,
    "0011" WHEN espera,
    "0100" WHEN recepcao,
    "0101" WHEN armazena,
    "0110" WHEN final,
    "0111" WHEN dado_presente,
    "0001" WHEN OTHERS;

END rx_serial_tick_uc_arch;