
library IEEE;
use IEEE.std_logic_1164.all;
 
entity tb_maquina_billetes is
end;
 
architecture testbench of tb_maquina_billetes is
 
    signal reset: std_logic;
    signal clk: std_logic;
    signal in10: boolean;
    signal in20: boolean;
    signal in50: boolean;
    signal out10: boolean;
    signal out20: boolean;
    signal expende: boolean;
 
    component maquina_billetes
        port (
             reset: in std_logic;
             clk: in std_logic;
             in10, in20, in50: in boolean;
             out10, out20, expende: out boolean
        );
    end component;

begin
 
    UUT: maquina_billetes
        port map (
             reset => reset,
             clk => clk,
             in10 => in10,
             in20 => in20,
             in50 => in50,
             out10 => out10,
             out20 => out20,
             expende => expende
        );

    -- Reloj
    process
    begin
        clk <= '0', '1' after 50 ns;
        wait for 100 ns;
    end process;
 
    -- Reset
    process
    begin
        reset <= '0', '1' after 45 ns, '0' after 200 ns;
        wait;
    end process;
 
    -- Entrada de monedas
    process
    begin
        in10 <= TRUE after 110 ns, FALSE after 160 ns;
        in20 <= TRUE after 210 ns, FALSE after 260 ns;
        in50 <= TRUE after 310 ns, FALSE after 360 ns;
        wait for 500 ns;
    end process;

end testbench;

