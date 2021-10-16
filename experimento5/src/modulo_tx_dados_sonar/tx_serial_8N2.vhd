LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE IEEE.math_real.ALL;

ENTITY tx_serial_8N2 IS
    PORT (
        clock, reset, partida : IN STD_LOGIC;
        dados_ascii : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        saida_serial, pronto : OUT STD_LOGIC;
        db_deslocado : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
        db_deslocado_7seg_0 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_deslocado_7seg_1 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_deslocado_7seg_2 : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        db_tick : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR (6 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE tx_serial_8N2_arch OF tx_serial_8N2 IS

    COMPONENT tx_serial_tick_uc PORT (
        clock, reset, partida, tick, fim : IN STD_LOGIC;
        zera, conta, carrega, desloca, pronto : OUT STD_LOGIC;
        db_estado : OUT STD_LOGIC_VECTOR (2 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT tx_serial_8N2_fd PORT (
        clock, reset : IN STD_LOGIC;
        zera, conta, carrega, desloca : IN STD_LOGIC;
        dados_ascii : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        saida_serial, fim : OUT STD_LOGIC;
        db_deslocado : OUT STD_LOGIC_VECTOR (11 DOWNTO 0)
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
    COMPONENT edge_detector IS PORT (
        clk : IN STD_LOGIC;
        signal_in : IN STD_LOGIC;
        output : OUT STD_LOGIC
        );
    END COMPONENT;

    COMPONENT hexa7seg IS
        PORT (
            hexa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
            sseg : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT;

    SIGNAL s_reset, s_partida, s_partida_ed : STD_LOGIC;
    SIGNAL s_zera, s_conta, s_carrega, s_desloca, s_tick, s_fim : STD_LOGIC;
    SIGNAL s_db_deslocado : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL s_db_estado : STD_LOGIC_VECTOR (2 DOWNTO 0);
    SIGNAL s_db_estado_hex_in : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN

    -- sinais reset e partida mapeados na GPIO (ativos em alto)
    s_reset <= reset;
    s_partida <= partida;

    -- unidade de controle
    U1_UC : tx_serial_tick_uc PORT MAP(
        clock, s_reset, s_partida_ed, s_tick, s_fim,
        s_zera, s_conta, s_carrega, s_desloca, pronto, s_db_estado);

    -- fluxo de dados
    U2_FD : tx_serial_8N2_fd PORT MAP(
        clock, s_reset, s_zera, s_conta, s_carrega, s_desloca,
        dados_ascii, saida_serial, s_fim, s_db_deslocado);

    -- gerador de tick
    -- fator de divisao 50MHz para 9600 bauds (5208=50M/9600)
    U3_TICK : contador_m GENERIC MAP(M => 5208) PORT MAP(clock, s_zera, '0', '1', OPEN, s_tick, OPEN);

    -- detetor de borda para tratar pulsos largos
    U4_ED : edge_detector PORT MAP(clock, s_partida, s_partida_ed);

    hex7seg0 : hexa7seg PORT MAP(hexa => s_db_deslocado(3 DOWNTO 0), sseg => db_deslocado_7seg_0);
    hex7seg1 : hexa7seg PORT MAP(hexa => s_db_deslocado(7 DOWNTO 4), sseg => db_deslocado_7seg_1);
    hex7seg2 : hexa7seg PORT MAP(hexa => s_db_deslocado(11 DOWNTO 8), sseg => db_deslocado_7seg_2);

    s_db_estado_hex_in <= '0' & s_db_estado;
    hex7seg_estado : hexa7seg PORT MAP(hexa => s_db_estado_hex_in, sseg => db_estado);

    db_tick <= s_tick;

END ARCHITECTURE;