library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ADDR_manag is
    Port ( CLK                  : in STD_LOGIC;
           Reset                : in STD_LOGIC;
           PLAY                 : in STD_LOGIC;
           Start_60hz           : in STD_LOGIC;        -- VGA 60Hz
           Start_30hz           : in STD_LOGIC;        -- VGA 30Hz
           Speed_select         : in STD_LOGIC;
           Enable_reading       : out STD_LOGIC;        -- control TOP_read (shift register)
           Flag_Top, Flag_Bot, Flag_left, Flag_right : out STD_LOGIC;
           ADDR                 : out STD_LOGIC_VECTOR (18 downto 0);
           Write                : out STD_LOGIC;
           Iteration_over       : out STD_LOGIC);
end ADDR_manag;

architecture Behavioral of ADDR_manag is

-- High when iteration is really running (sync with VGA)
signal running : std_logic := '0';

signal i_addr_read, i_addr_write : integer range 0 to 307199 := 0;      -- ADDR for the reading and the writing
signal read_write : std_logic := '0';                                   -- Allow read or write and incrementing i_addr_read/write

signal flags_counter : std_logic;                                       -- Start the counter for flags, delayed because we need to read
                                                                        -- a part of the screen before being able to calculate next state                                                          
signal start_flags : std_logic := '0';                                  -- Same purpose as before
signal start_writing : std_logic := '0';                                -- Start i_addr_write counter (after 1283 read)

signal hcounter : integer range 0 to 639 := 0;                          -- Horizontale counter for flags
signal vcounter : integer range 0 to 479 := 0;                          -- Vertical counter for flags

begin

-------------------------------------------------------------------
--        
--          OUTPUTS  -  ADDR & WRITE & Shift_register_enable_reading
--
-------------------------------------------------------------------
ADDR_Mux : process( read_write, i_addr_read, i_addr_write ) 
begin
    if read_write = '0' then
        ADDR <= std_logic_vector( to_unsigned( i_addr_read, 19 ) );
    else  
        ADDR <= std_logic_vector( to_unsigned( i_addr_write, 19 ) );
    end if;
end process;

Write <= read_write;

-- Enable_reading (Shift register shift)
process( read_write, start_writing ) 
begin
    if start_writing = '0' then
        enable_reading <= '1';
    else  
        enable_reading <= read_write;
    end if;
end process;

-------------------------------------------------------------------
--        
--          OUTPUTS  -  ADDR & WRITE & Shift_register_enable_reading
--
-------------------------------------------------------------------

Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or PLAY = '0' then
            start_flags      <= '0';
            start_writing    <= '0';
        else
            case( i_addr_read ) is
                when 641  => start_flags      <= '1'; -- 641 because of 1 clk'event to setup flags_counter (642 otherwise)
                when 642  => start_writing    <= '1';
                when others  => null;
             end case;
        end if;
    end if;
end process;

Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or PLAY = '0' then
            read_write      <= '0';
            i_addr_read     <= 0;
            i_addr_write    <= 0;
        elsif running = '1' then            -- Run one iteration
        --------------------------------------------------------------------------------------------------
            if start_writing = '0' then                         -- ONLY READING
                if i_addr_read = 642 then
                    read_write <= '1';
                    i_addr_read <= i_addr_read;
                else
                    i_addr_read <= i_addr_read + 1;
                    read_write <= '0';
                end if;
        --------------------------------------------------------------------------------------------------
            elsif start_writing = '1' then                      -- ALTERNATE WRITING AND READING
                if read_write = '0' then
                    read_write <= '1';
                    if i_addr_write = 307199 then
                        i_addr_write <= 0;
                    else
                        i_addr_write <= i_addr_write + 1;
                    end if;
                else
                    read_write <= '0';
                    if i_addr_read = 307199 then
                        i_addr_read <= 0;
                    else
                        i_addr_read <= i_addr_read + 1;
                    end if;
                end if;
            end if;
        --------------------------------------------------------------------------------------------------
        end if;
    end if;
end process;

-------------------------------------------------------------------
--        
--          Start / Stop Iteration
--
-------------------------------------------------------------------
Start_iteration : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or PLAY = '0' then
            running <= '0';
        elsif PLAY = '1' then
            if Speed_select = '0' and Start_60Hz = '1' then     -- Start an iteration every time VGA start displaying the beginning ( 60 ite/s )
                running <= '1';
            elsif Speed_select = '1' and Start_30Hz = '1' then  -- Same as above but at 30 iterations / s
                running <= '1';
            end if;
        end if;
    end if;
end process;


Stop_iteration : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or PLAY = '0' then
            Iteration_over <= '0';
        elsif i_addr_write = 307199 then        -- Every state has been updated and written
            Iteration_over <= '1';
        else
            Iteration_over <= '0';
        end if;
    end if;
end process;

-------------------------------------------------------------------
--        
--          Flags managements - Detect the start ans the end of each line, as well as top line and bottom line of VGA
--
-------------------------------------------------------------------

enable_position_counter : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or PLAY = '0' then
            flags_counter <= '0';
         elsif start_flags = '1' then
            if start_writing = '0' or flags_counter = '0' then
                flags_counter <= '1';
            else
                flags_counter <= '0';
            end if;
        end if;
    end if;
end process;

position_counter : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or PLAY = '0' then
            hcounter <= 0;
            vcounter <= 0;
        elsif start_flags = '1' then
            if flags_counter = '1' then
                if hcounter = 639 then
                    hcounter <= 0;
                    if vcounter = 479 then
                        vcounter <= 0;
                    else
                        vcounter <= vcounter + 1;
                    end if;
                else
                    hcounter <= hcounter + 1;
                end if;
             end if;
         end if;
     end if;
end process;

flag_management : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or PLAY = '0' then
            flag_top <= '1';
            flag_bot <= '0';
            flag_left <= '1';
            flag_right <= '0';
        else
            case hcounter is
                when 0      =>   flag_left <= '1';   flag_right <= '0';         -- Left border of the screen
                when 639    =>   flag_left <= '0';   flag_right <= '1';         -- Right border of the screen
                when others =>   flag_left <= '0';   flag_right <= '0';         -- Nor left or right
            end case;
            
           case vcounter is
                when 0      =>   flag_top <= '1';   flag_bot <= '0';            -- Top border of the screen
                when 479    =>   flag_top <= '0';   flag_bot <= '1';            -- Bottom border of the screen
                when others =>   flag_top <= '0';   flag_bot <= '0';            -- Nor top or bottom
            end case;
        end if;
    end if;
end process;

end Behavioral;
