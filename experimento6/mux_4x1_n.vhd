LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

entity mux_4x1_n is
    generic (
        constant BITS: integer := 4
    );
    port ( 
        D0 :     in  std_logic_vector (BITS-1 downto 0);
        D1 :     in  std_logic_vector (BITS-1 downto 0);
        D2 :     in  std_logic_vector (BITS-1 downto 0);
        D3 :     in  std_logic_vector (BITS-1 downto 0);
        SEL:     in  std_logic_vector (1 downto 0);
        MUX_OUT: out std_logic_vector (BITS-1 downto 0)
    );
end entity;

architecture behav of mux_4x1_n is
begin
    MUX_OUT <= D3 when (SEL = "11") else
               D2 when (SEL = "10") else
               D1 when (SEL = "01") else
               D0 when (SEL = "00") else
               (others => '1');
end behav;
