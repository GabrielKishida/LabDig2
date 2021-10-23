------------------------------------------------------------------
-- Arquivo   : deslocador_n.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : deslocador de n bits 
--             > registrador de deslocamento com entrada serial,
--             > entrada paralela e saida paralela
--             >
--             > usa parametro generico para modulo N
--             > numero de bits do deslocador
--             > 
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
------------------------------------------------------------------
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY deslocador_n IS
    GENERIC (
        CONSTANT N : INTEGER := 11
    );
    PORT (
        clock, reset : IN STD_LOGIC;
        carrega, desloca, entrada_serial : IN STD_LOGIC;
        dados : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
        saida : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
        db_deslocador : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0)
    );
END deslocador_n;

ARCHITECTURE deslocador_n_arch OF deslocador_n IS

    SIGNAL IQ : STD_LOGIC_VECTOR (N - 1 DOWNTO 0);

BEGIN

    PROCESS (clock, reset, IQ)
    BEGIN
        IF reset = '1' THEN
            IQ <= (OTHERS => '1');
        ELSIF (clock'event AND clock = '1') THEN
            IF carrega = '1' THEN
                IQ <= dados;
            ELSIF desloca = '1' THEN
                IQ <= entrada_serial & IQ(N - 1 DOWNTO 1);
            ELSE
                IQ <= IQ;
            END IF;
        END IF;
        saida <= IQ;
        db_deslocador <= IQ;
    END PROCESS;

END deslocador_n_arch;