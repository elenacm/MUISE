------------------------------------------------------
-- EJEMPLO 1: ENCENDIDO DE UN LED
--
-- Departamento de Ingeniería Electrónica (2013)
------------------------------------------------------ 


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity prueba_led is
  port (
    CONMUT : in   STD_LOGIC;    -- Conmutador conectado a una entrada 
    LED    : out   STD_LOGIC    -- LED conectado a una salida
	 );  
end prueba_led;

architecture a_prueba_led of prueba_led is

begin
LED<=CONMUT;
end a_prueba_led;
