----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Elena Cantero Molina
-- 
-- Create Date: 09.10.2020 18:22:59
-- Design Name: 
-- Module Name: RS232_TX - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RS232_TX is
    Port ( 
        Clk     : IN    STD_LOGIC;
        Reset   : IN    STD_LOGIC;
        Start   : IN    STD_LOGIC;
        Data    : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
        EOT     : OUT   STD_LOGIC;
        TX      : OUT   STD_LOGIC);
end RS232_TX;

architecture Behavioral of RS232_TX is
    
    TYPE estado is (IDLE, STARTBIT, SENDDATA, STOPBIT); -- ESTADOS
    SIGNAL estado_actual, estado_siguiente: estado;
    
    --Variables--
    SIGNAL data_aux: STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL TX_aux, EOT_aux: STD_LOGIC := '1';
    SIGNAL Pulse_width: STD_LOGIC_VECTOR (7 DOWNTO 0):= "00000000";
    SIGNAL Data_count: integer := 0;
    SIGNAL data_count_aux : integer := 0;

    --Constantes--
    CONSTANT PulseEndOfCount: std_logic_vector (7 downto 0) := "10101110";
        
    BEGIN
    
    -- Estado actual
    RELOJ: PROCESS (Reset, Clk, estado_actual, estado_siguiente, Pulse_width, TX_aux, EOT_aux)
    BEGIN
    
      EOT <= EOT_aux;
      TX <= TX_aux;
   
      IF(Reset = '0') THEN
        --se resetean las variables para tener los datos inicializados a 0
        estado_actual <= IDLE;
        Pulse_width <= "00000000";
        Data_count <= 0;

      ELSIF rising_edge(Clk) THEN 
        estado_actual <= estado_siguiente;  

        IF estado_siguiente /= IDLE THEN
          IF Pulse_width = "10101110" THEN 
            Pulse_width <= "00000000";
          ELSE
            Pulse_width <= Pulse_width + 1;
          END IF;
        END IF;

        IF estado_siguiente = IDLE THEN
          Pulse_width<="00000000";
          Data_count <= 0;
        END IF;

        IF estado_actual = SENDDATA and Pulse_width = PulseEndOfCount THEN 
            
            IF Data_count >= 0 THEN
            Data_count <= Data_count + 1;
            else 
            Data_count <= 0;
            end IF;
          
          end IF;
        end IF;

    END PROCESS RELOJ;
    
    --Estado siguiente
    FSM: PROCESS(Clk, estado_actual, Pulse_width, estado_siguiente, data_aux, START, Reset, Data_count, Data)
    BEGIN
      data_aux <= DATA;
      estado_siguiente <= estado_actual;
    
      CASE estado_actual IS
               
        WHEN IDLE =>  
          IF START = '1' and Reset = '1' THEN
            estado_siguiente <= STARTBIT;
          else 
            estado_siguiente <= IDLE;
          end IF;

        WHEN STARTBIT =>
          IF Pulse_width = PulseEndOfCount THEN
           estado_siguiente <= SENDDATA;
          ELSIF Pulse_width < PulseEndOfCount and START = '1' THEN
            estado_siguiente <= STARTBIT;
          ELSIF START = 'Z' THEN
            estado_siguiente <= IDLE;
          end IF;

        WHEN SENDDATA =>
          IF Data_count = 7 and Pulse_width = PulseEndOfCount THEN   
            estado_siguiente <= STOPBIT;
          else
            estado_siguiente <= SENDDATA;
          end IF;

        WHEN STOPBIT=>
          IF Pulse_width = PulseEndOfCount THEN 
            estado_siguiente <= IDLE;
          else 
           estado_siguiente <= STOPBIT;
          end IF;
    
      END CASE;
    END PROCESS FSM;

--    EOT <= EOT_aux;
--    TX <= TX_aux;          
    OUTPUTS: process(Clk, estado_actual, estado_siguiente, Data_count, data_aux, data_count_aux)
    BEGIN

      CASE estado_actual IS
               
        WHEN IDLE => 
            TX_aux <= '1';
            EOT_aux<='1';
               
        WHEN STARTBIT =>       
            TX_aux<='0';
            EOT_aux<='0'; 
                
        WHEN SENDDATA =>
            EOT_aux<='0';
            TX_aux<= data_aux(Data_count);

        WHEN STOPBIT =>
            TX_aux<='1';
            EOT_aux<='0';

      end CASE;
    END PROCESS OUTPUTS;  
    
end Behavioral;
