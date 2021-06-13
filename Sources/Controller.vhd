library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Controller is
    Generic( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( CLK              : in    STD_LOGIC;
           Reset            : in    STD_LOGIC;
           Ce               : in    STD_LOGIC;
           Draw             : in    STD_LOGIC;
           Pad10            : in    STD_LOGIC;
           
           B_up             : in    STD_LOGIC;
           B_down           : in    STD_LOGIC;
           B_right          : in    STD_LOGIC;
           B_left           : in    STD_LOGIC;
           B_center         : in    STD_LOGIC;
           Mouse_data       : in    STD_LOGIC_VECTOR ( 23 downto 0 );
           Mouse_data_new   : in    STD_LOGIC; 
           
           Color_read       : in    STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);
           Leave_draw       : out   STD_LOGIC;

           ADDR             : out   STD_LOGIC_VECTOR (18 downto 0);
           Data_out         : out   STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);
           Write            : out   STD_LOGIC);
end Controller;

architecture Behavioral of Controller is
---------------------------------------------------------------------------
component FSM_controller is
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
end component;

component Pixel_read is
    Generic ( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( Color_read   : in STD_LOGIC_VECTOR( bit_per_pixel - 1 downto 0 );
           Cell_state   : out STD_LOGIC);
end component;
-----------------------------------------------------------------

-- MOUSE ASSOCIATED SIGNALS
-- Mouse parsed outputs
signal X_overflow, Y_overflow : std_logic;
signal X_sign, Y_sign         : std_logic;
signal LMB, MMB, RMB          : std_logic;
signal X_movement, Y_movement : std_logic_vector( 7 downto 0 );

-- FSM - STATE SIGNALS
signal i_waiting, i_populate, i_calc_position, i_calc_addr, i_calc_color, i_remove_cursor, i_write : std_logic;                                

-- CELL ASSOCIATED SIGNALS
signal i_addr       : unsigned( 18 downto 0 );                  -- ADDR for VGA RAM
signal cell_state   : std_logic := '0';                         -- Current cell state
signal i_color      : unsigned( bit_per_pixel - 1 downto 0 );   -- Color to show on screen

-- MOVEMENT ASSOCIATED SIGNALS
signal new_movement         : std_logic; -- pulse, high when new movement/event occurs
signal new_movement_impulse : std_logic; -- memorize the pulse
signal pad_movement         : std_logic; -- same for pad

signal X_pos, X_pos_futur : unsigned( 9 downto 0 );     -- X position ( X_pos_futur : intended position/aim )
signal Y_pos, Y_pos_futur : unsigned( 8 downto 0 );     -- Y position ( Y_pos_futur : intended position/aim )

signal teleport_cursor      : std_logic := '1'; -- high when mouse is moving but no buttons are pressed
signal X_trig, Y_trig       : std_logic := '0'; -- Determine if X position is at the intended position, same for Y
signal position_reached     : std_logic := '0'; -- high when the cursor is at the right position
---------------------------------------------------------------------------
begin

ADDR        <= std_logic_vector( i_addr );
Data_out    <= std_logic_vector( i_color );

decoder : Pixel_read generic map ( bit_per_pixel => bit_per_pixel )
                     port    map ( Color_read => Color_read,
                                   Cell_state => cell_state);

encoder : Process( CLK )
begin
    if rising_edge( CLK) then
        if Reset = '1' then
            i_color <= (others => '0');
        elsif ce = '1' and i_calc_color = '1' then
            if i_remove_cursor = '1' then
                if LMB = '1' then
                    i_color <= (others => '1');
                elsif RMB = '1' then
                    i_color <= (others => '0');
                elsif cell_state = '0' then
                    i_color <= (others => '0');
                else
                    i_color <= (others => '1');
                end if;
            elsif i_populate = '1' then
                if cell_state = '0' then
                    i_color <= to_unsigned( 2, bit_per_pixel );
                else
                    i_color <= to_unsigned( 6, bit_per_pixel );
                end if;
            else
                if LMB = '1' then
                    i_color <= to_unsigned( 2, bit_per_pixel );
                elsif cell_state = '0' or RMB = '1' then
                    i_color <= to_unsigned( 6, bit_per_pixel );
                else
                    i_color <= to_unsigned( 2, bit_per_pixel );
                end if;
            end if;
        end if;
    end if;
end process;

Write_enable : process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            write <= '0';
        elsif i_write = '1' then
            write <= '1';
        else
            write <= '0';
        end if;
    end if;
end process;


Update_addr : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            i_addr <= to_unsigned( 0, 19 );
        elsif ce = '1' and i_calc_addr = '1' then
            i_addr <= ( X_pos  +  Y_pos * to_unsigned( 512, 10 ) + Y_pos * to_unsigned( 128, 10 ) ) ;
        end if;
    end if;
end process;





-------------------------------------------------------------------
--        
--          COORDINATES  -  Dectector & more
--
-------------------------------------------------------------------
Parsing_mouse_data : Process( CLK )
begin
    if rising_edge( CLK ) then
        if reset = '1' then
            Y_overflow <= '0';
            X_overflow <= '0';
            Y_sign     <= '0';
            X_sign     <= '0';
            MMB        <= '0';
            RMB        <= '0';
            LMB        <= '0';
            X_movement <= std_logic_vector( to_unsigned( 0, 8 ) );
            Y_movement <= std_logic_vector( to_unsigned( 0, 8 ) );
        elsif Ce = '1' and mouse_data_new = '1' then
            Y_overflow <= mouse_data( 23 );
            X_overflow <= mouse_data( 22 );
            Y_sign     <= mouse_data( 21 );
            X_sign     <= mouse_data( 20 );
            MMB        <= mouse_data( 18 );
            RMB        <= mouse_data( 17 );
            LMB        <= mouse_data( 16 );
            X_movement <= mouse_data( 15 downto 8 );
            Y_movement <= mouse_data(  7 downto 0 );
        end if;
    end if;
end process;

pad_movement_detector : process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            pad_movement <= '0';
        elsif B_up = '1' or B_down = '1' or B_right = '1' or B_left = '1' then
            pad_movement <= '1';
        else
            pad_movement <= '0';
        end if;
    end if;
end process;

Mouse_movement_detector : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or Draw = '0' then
            new_movement            <= '0';
            new_movement_impulse    <= '0';
        elsif ce = '1' and Draw = '1' then
            if mouse_data_new = '1' and new_movement_impulse = '0' then
                new_movement            <= '1';
                new_movement_impulse    <= '1';
            elsif mouse_data_new = '0' and new_movement_impulse = '1' then
                new_movement            <= '0';
                new_movement_impulse    <= '0';
            else
                new_movement            <= '0';
            end if;
        end if;
    end if;
end process;


-- Determine if the cursor has to go through all pixel
-- to draw or erase or if with just display it
X_Y_incrementation_mod : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            teleport_cursor <= '1';
        else
            if ( LMB = '1' or RMB = '1' ) then
                teleport_cursor <= '0';
            else
                teleport_cursor <= '1';
            end if;
        end if;
    end if;
end process;


-------------------------------------------------------------------
--        
--          COORDINATES  -  X_futur & Y_futur
--
-------------------------------------------------------------------

X_next_position : Process( CLK )
variable X_inter : unsigned( 10 downto 0 );
variable X_inc   : unsigned( 10 downto 0 );
begin
    if rising_edge( CLK) then
        if Reset = '1' then
            X_pos_futur <= to_unsigned( 319, 10 );
        elsif Ce = '1' and i_waiting = '1' then
            -- PAD
            if B_Left = '1' then
                if X_pos_futur = to_unsigned( 0, 10 ) or (X_pos_futur <= to_unsigned( 10, 10 ) and Pad10 = '1') then
                    X_pos_futur <= to_unsigned( 0, 10 );
                else
                    if Pad10 = '1' then
                        X_pos_futur <= X_pos_futur - to_unsigned( 10, 10 );
                    else
                        X_pos_futur <= X_pos_futur - to_unsigned( 1, 10 );
                    end if;
                end if;
            elsif B_Right = '1' then
                if X_pos_futur = to_unsigned( 639, 10 ) or (X_pos_futur >= to_unsigned( 629, 10 ) and Pad10 = '1') then
                    X_pos_futur <= to_unsigned( 639, 10 );
                else
                    if Pad10 = '1' then
                        X_pos_futur <= X_pos_futur + to_unsigned( 10, 10 );
                    else
                        X_pos_futur <= X_pos_futur + to_unsigned( 1, 10 );
                    end if;
                end if;
            -- MOUSE
            elsif New_movement = '1' then
                if X_sign = '0' then
                    if X_overflow = '1' then
                        X_inc := to_unsigned( 256, 11 );
                    else
                        X_inc := unsigned( "000" & X_movement );
                    end if;
                    X_inter :=  unsigned( "0" & X_pos_futur ) + X_inc;
                    
                    -- check that cursor stay on the screen
                    if X_inter >= to_unsigned( 640, 11 ) then
                        X_pos_futur <= to_unsigned( 639, 10 );
                    else
                        X_pos_futur <= X_inter( 9 downto 0 );
                    end if;
                else
                    if X_overflow = '1' then
                        X_inc := "11100000000";
                    else
                        X_inc := unsigned( "111" & X_movement );
                    end if;
                    X_inter :=  unsigned( "0" & X_pos_futur ) + X_inc;
                    
                    -- check that cursor stay on the screen
                    if X_inter(10) = '1' then   -- equivalent to X_inter < 0
                        X_pos_futur <= (others => '0'); --to_unsigned( 0, 10 );
                    else
                        X_pos_futur <= X_inter( 9 downto 0 );
                    end if;
                
                end if;
            else
                X_pos_futur <= X_pos_futur;
            end if;
        end if;
    end if;
end process;

Y_next_position : Process( CLK )
variable Y_inter : unsigned( 10 downto 0 );
variable Y_inc   : unsigned( 10 downto 0 );
begin
    if rising_edge( CLK) then
        if Reset = '1' then
            Y_pos_futur <= to_unsigned( 239, 9 );
        elsif Ce = '1' and i_waiting = '1' then
            -- PAD
            if B_Up = '1' then
                if Y_pos_futur = to_unsigned( 0, 9 ) or (Y_pos_futur <= to_unsigned( 10, 9 ) and Pad10 = '1') then
                    Y_pos_futur <= to_unsigned( 0, 9 );
                else
                    if Pad10 = '1' then
                        Y_pos_futur <= Y_pos_futur - to_unsigned( 10, 9 );
                    else
                        Y_pos_futur <= Y_pos_futur - to_unsigned( 1, 9 );
                    end if;
                end if;
            elsif B_Down = '1' then
                if Y_pos_futur = to_unsigned( 479, 9 ) or (Y_pos_futur >= to_unsigned( 469, 9 ) and Pad10 = '1') then
                    Y_pos_futur <= to_unsigned( 479, 9 );
                else
                    if Pad10 = '1' then
                        Y_pos_futur <= Y_pos_futur + to_unsigned( 10, 9 );
                    else
                        Y_pos_futur <= Y_pos_futur + to_unsigned( 1, 9 );
                    end if;
                end if;
            -- MOUSE     
            elsif new_movement = '1' then
                if Y_sign = '0' then
                    if Y_overflow = '1' then
                        Y_inc := to_unsigned( 256, 11 );
                    else
                        Y_inc := unsigned( "000" & Y_movement );
                    end if;
                    Y_inter :=  unsigned( "00" & Y_pos_futur ) - Y_inc;
                    
                    -- check that cursor stay on the screen
                    if Y_inter(10) = '1' then   -- equivalent to X_inter < 0
                        Y_pos_futur <= (others => '0'); --to_unsigned( 0, 9 );
                    else
                        Y_pos_futur <= Y_inter( 8 downto 0 );
                    end if;
                else
                    if Y_overflow = '1' then
                        Y_inc := "11100000000";
                    else
                        Y_inc := unsigned( "111" & Y_movement );
                    end if;
                    Y_inter :=  unsigned( "00" & Y_pos_futur ) - Y_inc;
                    
                    -- check that cursor stay on the screen
                    if Y_inter >= to_unsigned( 480, 11 ) then
                        Y_pos_futur <= to_unsigned( 479, 9 );
                    else
                        Y_pos_futur <= Y_inter( 8 downto 0 );
                    end if;
                end if;
            else
                Y_pos_futur <= Y_pos_futur;
            end if;
        end if;
    end if;
end process;

-------------------------------------------------------------------
--        
--          COORDINATES  -  X_pos = X_pos_futur & Y_pos = Y_pos_futur
--
-------------------------------------------------------------------
         
X_trig <= '1' when ( X_pos /= X_pos_futur and i_calc_position = '1' ) else
          '0';
Y_trig <= '1' when (  Y_pos /= Y_pos_futur and i_calc_position = '1' ) else
          '0';    

position_reached <= '1' when X_pos = X_pos_futur and Y_pos = Y_pos_futur else
                    '0';

-------------------------------------------------------------------
--        
--          COORDINATES  -  X & Y
--
-------------------------------------------------------------------

x_inc : Process( CLK ) 
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            X_pos <= to_unsigned( 319, 10 );
        elsif ce = '1' and X_trig = '1' then
            if teleport_cursor = '1' then
                X_pos <= X_pos_futur;
            else
                if X_pos < X_pos_futur then
                    if X_pos = to_unsigned( 639, 10 ) then
                        X_pos <= to_unsigned( 639, 10 );
                    else
                        X_pos <= X_pos + to_unsigned( 1, 10 );
                    end if;
                elsif X_pos > X_pos_futur then
                    if X_pos = to_unsigned( 0, 10 ) then
                        X_pos <= to_unsigned( 0, 10 );
                    else
                        X_pos <= X_pos - to_unsigned( 1, 10 );
                    end if;
                end if;
            end if;
        end if;
    end if;
end Process;

y_inc : Process( CLK ) 
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            Y_pos <= to_unsigned( 239, 9 );
        elsif ce = '1' and Y_trig = '1' then
            if teleport_cursor = '1' then
                Y_pos <= Y_pos_futur;
            else
                if Y_pos > Y_pos_futur  then
                    if Y_pos = to_unsigned( 0, 9 ) then
                        Y_pos <= to_unsigned( 0, 9 );
                    else
                        Y_pos <= Y_pos - to_unsigned( 1, 9 );
                    end if;
                elsif Y_pos < Y_pos_futur then
                    if Y_pos = to_unsigned( 479, 9 ) then
                        Y_pos <= to_unsigned( 479, 9 );
                    else
                        Y_pos <= Y_pos + to_unsigned( 1, 9 );
                    end if;
                end if;
            end if;
        end if;
    end if;
end Process;

-------------------------------------------------------------------
--        
--          COMPONENTS
--
-------------------------------------------------------------------

FSM : FSM_controller port map ( CLK                 => CLK,
                                Reset               => Reset,
                                Draw                => Draw,
                                B_center            => B_center,
                                Mouse_event         => new_movement,
                                Pad_event           => pad_movement,
                                
                                Position_reached    => position_reached,
                                waiting             => i_waiting,
                                Populate            => i_populate,
                                Position            => i_calc_position,
                                Addr                => i_calc_addr,
                                Color               => i_calc_color,
                                Remove_cursor       => i_remove_cursor,
                                Write               => i_write,
                                Leave_Draw          => Leave_draw);

end Behavioral;
