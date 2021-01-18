library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity FSM_controller is
    Port ( CLK              : in  STD_LOGIC;
           Reset            : in  STD_LOGIC;
           Draw             : in  STD_LOGIC;
           B_center         : in  STD_LOGIC;
           Mouse_event      : in  STD_LOGIC;
           Pad_event        : in  STD_LOGIC;
           Position_reached : in  STD_LOGIC;
           
           Waiting          : out STD_LOGIC;
           Populate         : out STD_LOGIC;
           Position         : out STD_LOGIC;
           Addr             : out STD_LOGIC;
           Color            : out STD_LOGIC;
           Remove_cursor    : out STD_LOGIC;
           Write            : out STD_LOGIC;
           Leave_Draw       : out STD_LOGIC);
end FSM_controller;

architecture Behavioral of FSM_controller is

    Type Etats is ( off, wait_event, Calc_pos, change_state,
                    turn_cursor_off, write_true_color, calc_addr,
                    get_cell, calc_color, write_color);
    signal Etat_present, Etat_futur : Etats := off; 

begin
State_update : Process( CLK )
begin
    if rising_edge(clk) then
        if Reset = '1' then
            Etat_present <= off;
        else
            Etat_present <= Etat_futur;
        end if;
    end if;
end Process;

inner_state : Process(Etat_present, Draw, B_center, Mouse_event, Pad_event, Position_reached)
begin
    case Etat_present is
        when OFF                =>  if  Draw = '1' then
                                        Etat_futur <= CALC_ADDR;
                                    else
                                        Etat_futur <= OFF;
                                    end if;
                                    
        when WAIT_EVENT         =>  if Draw = '0' then
                                        Etat_futur <= TURN_CURSOR_OFF;        
                                    elsif B_center = '1' then
                                        Etat_futur <= CHANGE_STATE;
                                    elsif Mouse_event = '1' or Pad_event = '1' then
                                        Etat_futur <= CALC_POS;
                                    else
                                        Etat_futur <= WAIT_EVENT;
                                    end if;
        
        when CALC_POS           =>  Etat_futur <= TURN_CURSOR_OFF;
        
        when TURN_CURSOR_OFF    =>  Etat_futur <= WRITE_TRUE_COLOR;
        
        when WRITE_TRUE_COLOR   =>  if Draw = '0' then
                                        Etat_futur <= OFF;
                                    else
                                        Etat_futur <= CALC_ADDR;
                                    end if;
        
        when CALC_ADDR          =>  Etat_futur <= GET_CELL;     -- buffer state
        
        when GET_CELL           =>  Etat_futur <= CALC_COLOR;
        
        when CALC_COLOR         =>  Etat_futur <= WRITE_COLOR;
        
        when WRITE_COLOR        =>  if Position_reached = '1' then
                                        Etat_futur <= WAIT_EVENT;
                                    else
                                        Etat_futur <= CALC_POS;
                                    end if;
                                    
        when CHANGE_STATE       =>  Etat_futur <= WRITE_COLOR;
                        
                        

    end case;
end Process;

outputs : Process(Etat_present)
begin
    case Etat_present is
        when OFF                =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '0';
                                    Remove_cursor       <= '0';
                                    Write               <= '0';
                                    Leave_draw          <= '1';
                                
        when WAIT_EVENT         =>  Waiting             <= '1';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '0';
                                    Remove_cursor       <= '0';
                                    Write               <= '0';
                                    Leave_draw          <= '0';  
                                
        when CALC_POS           =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '1';
                                    Addr                <= '0';
                                    Color               <= '0';
                                    Remove_cursor       <= '0';
                                    Write               <= '0';
                                    Leave_draw          <= '0';  
                                
        when TURN_CURSOR_OFF    =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '1';
                                    Remove_cursor       <= '1';
                                    Write               <= '0';
                                    Leave_draw          <= '0';  
                                
        when WRITE_TRUE_COLOR   =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '0';
                                    Remove_cursor       <= '0';
                                    Write               <= '1';
                                    Leave_draw          <= '0';
                                
        when CALC_ADDR          =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '1';
                                    Color               <= '0';
                                    Remove_cursor       <= '0';
                                    Write               <= '0';
                                    Leave_draw          <= '0';
                                
        when GET_CELL           =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '0';
                                    Remove_cursor       <= '0';
                                    Write               <= '0';
                                    Leave_draw          <= '0';
                                
        when CALC_COLOR         =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '1';
                                    Remove_cursor       <= '0';
                                    Write               <= '0';
                                    Leave_draw          <= '0';
                                
        when WRITE_COLOR        =>  Waiting             <= '0';
                                    Populate            <= '0';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '0';
                                    Remove_cursor       <= '0';
                                    Write               <= '1';
                                    Leave_draw          <= '0';
                                
        when CHANGE_STATE       =>  Waiting             <= '0';
                                    Populate            <= '1';
                                    Position            <= '0';
                                    Addr                <= '0';
                                    Color               <= '1';
                                    Remove_cursor       <= '0';
                                    Write               <= '0';
                                    Leave_draw          <= '0';
    end case;
end process;


end Behavioral;
