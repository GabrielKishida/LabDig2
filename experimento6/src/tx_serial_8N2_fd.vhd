------------------------------------------------------------------
-- Arquivo   : tx_serial_7E2_fd.vhd
-- Projeto   : Experiencia 2 - Transmissao Serial Assincrona
------------------------------------------------------------------
-- Descricao : fluxo de dados do circuito da experiencia 2 
--             > implementa configuracao 7E2
--             > 
--             > bit de paridade calculada usando portas XOR 
--             > (veja linha 64)
------------------------------------------------------------------
-- Revisoes  :
--     Data        Versao  Autor             Descricao
--     09/09/2021  1.0     Edson Midorikawa  versao inicial
------------------------------------------------------------------
--

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY tx_serial_8N2_fd IS
    PORT (
        clock, reset : IN STD_LOGIC;
        zera, conta, carrega, desloca : IN STD_LOGIC;
        dados_ascii : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        saida_serial, fim : OUT STD_LOGIC;
        db_deslocado : OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE tx_serial_8N2_fd_arch OF tx_serial_8N2_fd IS

    COMPONENT deslocador_n
        GENERIC (
            CONSTANT N : INTEGER
        );
        PORT (
            clock, reset : IN STD_LOGIC;
            carrega, desloca, entrada_serial : IN STD_LOGIC;
            dados : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
            saida : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0);
            db_deslocador : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT contador_m
        GENERIC (
            CONSTANT M : INTEGER
        );
        PORT (
            clock, zera_as, zera_s, conta : IN STD_LOGIC;
            Q : OUT STD_LOGIC_VECTOR (NATURAL(ceil(log2(real(M)))) - 1 DOWNTO 0);
            fim, meio : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL s_dados, s_saida, s_db_deslocado : STD_LOGIC_VECTOR (11 DOWNTO 0);

BEGIN

    s_dados(0) <= '1'; -- repouso
    s_dados(1) <= '0'; -- start bit
    s_dados(9 DOWNTO 2) <= dados_ascii;
    s_dados(11 DOWNTO 10) <= "11"; -- stop bits

    U1 : deslocador_n GENERIC MAP(N => 12) PORT MAP(clock, reset, carrega, desloca, '1', s_dados, s_saida, s_db_deslocado);

    U2 : contador_m GENERIC MAP(M => 13) PORT MAP(clock, zera, '0', conta, OPEN, fim, OPEN);

    db_deslocado <= s_db_deslocado;

    saida_serial <= s_saida(0);

END ARCHITECTURE;