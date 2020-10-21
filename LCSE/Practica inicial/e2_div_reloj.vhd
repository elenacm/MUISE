------------------------------------------------------
-- EJEMPLO 2: DIVISIÓN DE LA FRECUENCIA DEL RELOJ
--
-- Departamento de Ingeniería Electrónica (2013)
------------------------------------------------------ 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity div_reloj is
    Port ( CLK : in  STD_LOGIC;    -- Reloj de entrada a la FPGA
           SAL : out  STD_LOGIC);  -- salida del circuito para conectar al LED
end div_reloj;

architecture a_div_reloj of div_reloj is
signal contador : STD_LOGIC_VECTOR (31 downto 0);
signal flag : STD_LOGIC;
begin
  PROC_CONT : process (CLK)
    begin
    if CLK'event and CLK='1' then
      contador <= std_logic_vector( (unsigned(contador) + to_unsigned(1, 32)) );
      if unsigned(contador)=50000000 then   -- el reloj tiene un periodo de 10 ns (100 MHz)
        flag<=not flag;           -- tras 50e6 cuentas habrán transcurrido 500 ms                    
	     contador<=(others=>'0');
      end if;	 
    end if;	
    end process;
  SAL<=flag;
end a_div_reloj;
