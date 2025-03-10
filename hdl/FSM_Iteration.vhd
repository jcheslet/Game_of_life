library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

Entity FSM_Iteration is
    Port ( clk                      : in STD_LOGIC;
           Reset                    : in STD_LOGIC;
           B_up                     : in STD_LOGIC;
           B_right                  : in STD_LOGIC;
           B_down                   : in STD_LOGIC;
           B_left                   : in STD_LOGIC;
           B_center                 : in STD_LOGIC;
           S_draw                   : in STD_LOGIC;
           S_ite                    : in STD_LOGIC;
           S_clear                  : in STD_LOGIC;
           Iteration_done           : in STD_LOGIC;
           Initialization_done      : in STD_LOGIC;
           Leave_draw               : in STD_LOGIC;
           Initialisation           : out STD_LOGIC;
           Play                     : out STD_LOGIC;
           Draw                     : out STD_LOGIC);
end FSM_Iteration;

architecture Behavioral of FSM_Iteration is

    Type Etats is (init, pause, iteration, drawing, exiting_draw);
    signal Etat_present, Etat_futur : Etats := init; 

begin
State_update : Process( CLK )
begin
    if rising_edge(clk) then
        if Reset = '1' then
            Etat_present <= init;
        else
            Etat_present <= Etat_futur;
        end if;
    end if;
end Process;

inner_state : Process(Etat_present, B_center, S_draw, S_ite, S_clear, Leave_draw, Iteration_done, Initialization_done)
begin
    case Etat_present is
        when INIT =>    if  Initialization_done = '1' then
                            Etat_futur <= PAUSE;
                        else
                            Etat_futur <= INIT;
                        end if;
                        
        
        when PAUSE =>   if S_clear = '1' then
                            Etat_futur <= INIT;
                        elsif S_draw = '1' then
                            Etat_futur <= DRAWING;     
                        elsif B_center = '1' then
                            Etat_futur <= ITERATION;
                        elsif S_ite = '1' then
                            Etat_futur <= ITERATION;
                        else
                            Etat_futur <= PAUSE;
                        end if;

        when ITERATION =>   if Iteration_done = '1' then
                                Etat_futur <= PAUSE;
                            else
                                Etat_futur <= ITERATION;
                            end if;
        
        when DRAWING =>     if S_draw = '0' then
                                Etat_futur <= EXITING_DRAW;
                            else
                                Etat_futur <= DRAWING;
                            end if;
                            
        when EXITING_DRAW => if Leave_draw = '1' then
                                Etat_futur <= PAUSE;
                            else
                                Etat_futur <= EXITING_DRAW;
                            end if;
                            
    end case;
end Process;

outputs : Process(Etat_present)
begin
    case Etat_present is
        when INIT =>            Initialisation  <= '1';
                                Play            <= '0';
                                Draw            <= '0';

        when PAUSE =>           Initialisation  <= '0';
                                Play            <= '0';
                                Draw            <= '0';

        when ITERATION =>       Initialisation  <= '0';
                                Play            <= '1';
                                Draw            <= '0';
        
        when DRAWING =>         Initialisation  <= '0';
                                Play            <= '0';
                                Draw            <= '1';
                                  
        when EXITING_DRAW =>    Initialisation  <= '0';
                                Play            <= '0';
                                Draw            <= '0';                          

    end case;
end process;

end Behavioral ; -- behavioral