----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Elena Cantero Molina
-- 
-- Create Date: 18.10.2020 18:39:57
-- Design Name: 
-- Module Name: RS232_RX - Behavioral
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

entity RS232_RX is
  Port (
      Clk       : IN  STD_LOGIC;
      Reset     : IN  STD_LOGIC;
      LineRD_in : IN  STD_LOGIC;
      Valid_out : OUT STD_LOGIC;
      Code_out  : OUT STD_LOGIC;
      Store_out : OUT STD_LOGIC);
end RS232_RX;

architecture Behavioral of RS232_RX is
    
TYPE estado is (IDLE, STARTBIT, RCVDATA, STOPBIT); -- ESTADOS
SIGNAL estado_actual, estado_siguiente : estado;

--VARIABLES--
SIGNAL Data_count: STD_LOGIC_VECTOR (2 DOWNTO 0) := "000";
SIGNAL BitCounter: STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
SIGNAL Valid_out_aux, Code_out_aux, Store_out_aux: STD_LOGIC;

--CONSTANTES--
CONSTANT end_BitCounter: STD_LOGIC_VECTOR (7 DOWNTO 0) := "10101110";
CONSTANT end_HalfBitCounter : STD_LOGIC_VECTOR (7 DOWNTO 0) := "01010111";

BEGIN

    -- Estado actual
    RELOJ: PROCESS (Reset, Clk, estado_actual, estado_siguiente, Bitcounter, Store_out_aux, Code_out_aux, Valid_out_aux)
    BEGIN
        IF(Reset = '0') THEN
            estado_actual <= IDLE;
            bitcounter <= "00000000";
            Data_count <= "000";
            Valid_out <= '0';
            Code_out <= '0';
            Store_out <= '0';
                          
        ELSIF rising_edge(Clk) THEN
            Valid_out <= Valid_out_aux;
            Code_out <= Code_out_aux;
            Store_out <= Store_out_aux;
                
            estado_actual <= estado_siguiente;
            
            --Si no estamos en IDLE
            IF  estado_siguiente /= IDLE THEN
                IF bitcounter >= end_BitCounter THEN 
                    bitcounter <= "00000000";
                ELSE
                    bitcounter <= bitcounter + 1;
                END IF;
            END IF; 
                
            IF estado_siguiente = IDLE THEN
                bitcounter <= "00000000";
                Data_count <= "000";
            END IF;
                
            IF estado_actual = RCVDATA AND bitcounter = end_BitCounter THEN 
                Data_count <= Data_count + 1;
            END IF;
        END IF;

        END process RELOJ;
        
        --Estados siguientes
        FSM: PROCESS(Clk, estado_actual, estado_siguiente, bitcounter, LineRD_in, Data_count, Reset)
        BEGIN
                   
            CASE estado_actual IS
            
                WHEN IDLE => 
                    IF LineRD_in = '0' and Reset = '1' THEN
                        estado_siguiente <= STARTBIT;
        			ELSE 
                        estado_siguiente <= IDLE;
        			END IF;
        				            
                WHEN STARTBIT =>
                    IF bitcounter = end_BitCounter and LineRD_in = '0' THEN 
                        estado_siguiente <= RCVDATA;
                    ELSE 
          			   estado_siguiente <= STARTBIT;
                    END IF;

                WHEN RCVDATA =>
                    IF (Data_count = "111" and bitcounter = end_BitCounter) THEN
                        estado_siguiente <= STOPBIT;
                    ELSE
                        estado_siguiente <= RCVDATA;
                    END IF;
            
                WHEN STOPBIT =>
                    IF bitcounter = end_BitCounter and LineRD_in = '1' THEN
                        estado_siguiente <= IDLE;
                    ELSE
                        estado_siguiente <= STOPBIT; 
                    END IF;

            END CASE;
        END process FSM;

        --Salidas
        OUTPUTS: process(Clk, estado_actual, bitcounter, Data_count, LineRD_in)
        BEGIN
            
            CASE estado_actual IS
                    
                WHEN IDLE =>
                    Valid_out_aux <= '0';
                    Code_out_aux <= '0';
                    Store_out_aux <= '0';

                WHEN STARTBIT =>
                    Valid_out_aux <= '0';
                    Code_out_aux <= '0';
                    Store_out_aux <= '0';  
                
                WHEN RCVDATA =>      
                    IF bitcounter = end_halfbitcounter THEN
                        Valid_out_aux <= '1';
                    ELSE 
                        Valid_out_aux<='0';                           
                    END IF;              
                                        
                    Code_out_aux <= LineRD_in;
                    Store_out_aux <= '0';
                      
                WHEN STOPBIT =>
                    Valid_out_aux <= '0';
                    Code_out_aux<='0';
                    IF bitcounter < "00000001" THEN
                        Store_out_aux<='1';
                    ELSE 
                        Store_out_aux<='0';                           
                    END IF;
    
                END CASE;
        END PROCESS OUTPUTS;

END Behavioral;
