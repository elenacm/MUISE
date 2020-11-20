
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Elena Cantero Molina
-- 
-- Create Date: 02.10.2020 16:27:26
-- Design Name: 
-- Module Name: ShiftRegister - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ShiftRegister is
  Port (
      Reset  : in  STD_LOGIC;
      Clk    : in  STD_LOGIC;
      Enable : in  STD_LOGIC;
      D      : in  STD_LOGIC;
      Q      : out STD_LOGIC_VECTOR(7 DOWNTO 0));
end ShiftRegister;

architecture Behavioral of ShiftRegister is

    signal salida, salida_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    
begin
    process(Clk, Reset)
    begin 
        if (Reset = '0') then
            salida <= (others => '0');
            salida_sig <= (others => '0');
        elsif (Clk'event and Clk = '1') then            
            if (Enable = '1') then
                salida_sig <= D & salida(7 downto 1);
            end if;  
            salida <= salida_sig;                       
        end if;
    end process;

    Q <= salida;

end Behavioral;