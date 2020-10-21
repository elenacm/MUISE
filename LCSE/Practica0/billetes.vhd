
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY maquina_billetes IS
    PORT (
         reset: in std_logic;
         clk: in std_logic;
         in10, in20, in50: in boolean;
         out10, out20, expende: out boolean
    );
END;

ARCHITECTURE behavior OF maquina_billetes IS

    TYPE estados IS (idle, st10, st20, st30, st40, st50, st60, debo20);
    SIGNAL current_state, next_state: estados;
    SIGNAL out10_tmp, out20_tmp, expende_tmp: boolean;

BEGIN

    PROCESS(reset, current_state, in10, in20, in50)
    BEGIN
        -- Asignaciones por defecto
        next_state <= current_state;
        expende_tmp <= FALSE;
        out10_tmp <= FALSE;
        out20_tmp <= FALSE;

        -- Reset síncrono
        IF (reset='1') THEN
            next_state <= idle;
        ELSE
            -- Lógica para transiciones y salidas
            CASE current_state IS

                WHEN idle =>
                    IF (in10) THEN
                        next_state <= st10;
                    ELSIF (in20) THEN
                        next_state <= st20;
                    ELSIF (in50) THEN
                        next_state <= st50;
                    END IF;

                WHEN st10 =>
                    IF (in10) THEN
                        next_state <= st20;
                    ELSIF (in20) THEN
                        next_state <= st30;
                    ELSIF (in50) THEN
                        next_state <= st60;
                    END IF;

                WHEN st20 =>
                    IF (in10) THEN
                        next_state <= st30;
                    ELSIF (in20) THEN
                        next_state <= st40;
                    ELSIF (in50) THEN
                        next_state <= idle;
                        expende_tmp <= TRUE;
                    END IF;

                WHEN st30 =>
                    IF (in10) THEN
                        next_state <= st40;
                    ELSIF (in20) THEN
                        next_state <= st50;
                    ELSIF (in50) THEN
                        next_state <= idle;  -- 80
                        expende_tmp <= TRUE;
                        out10_tmp <= TRUE;
                    END IF;

                WHEN st40 =>
                    IF (in10) THEN
                        next_state <= st50;
                    ELSIF (in20) THEN
                        next_state <= st60;
                    ELSIF (in50) THEN
                        next_state <= idle;  -- 90
                        expende_tmp <= TRUE;
                        out20_tmp <= TRUE;
                    END IF;

                WHEN st50 =>
                    IF (in10) THEN
                        next_state <= st60;
                    ELSIF (in20) THEN
                        next_state <= idle;  -- exacto
                        expende_tmp <= TRUE;
                    ELSIF (in50) THEN
                        next_state <= idle;  -- 100
                        expende_tmp <= TRUE;
                        out10_tmp <= TRUE;
                        out20_tmp <= TRUE;
                    END IF;

                WHEN st60 =>
                    IF (in10) THEN
                        next_state <= idle;  -- exacto
                        expende_tmp <= TRUE;
                    ELSIF (in20) THEN
                        next_state <= idle;  -- 80
                        expende_tmp <= TRUE;
                        out10_tmp <= TRUE;
                    ELSIF (in50) THEN
                        next_state <= debo20;  -- 110
                        expende_tmp <= TRUE;
                        out20_tmp <= TRUE;
                    END IF;

                WHEN debo20 =>
                        next_state <= idle;
                        out20_tmp <= TRUE;
            END CASE;
        END IF;
    END PROCESS;

    -- Registro de estado y salidas registradas
    PROCESS (clk)
    BEGIN
        IF clk'event AND clk='1' THEN
            current_state <= next_state;
            expende <= expende_tmp;
            out10 <= out10_tmp;
            out20 <= out20_tmp;
        END IF;
    END PROCESS;

END behavior;
