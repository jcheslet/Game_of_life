library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Top_GoL is
    Port ( CLK              : in STD_LOGIC;
           Reset            : in STD_LOGIC;
           B_center         : in STD_LOGIC;
           B_up             : in STD_LOGIC;
           B_right          : in STD_LOGIC;
           B_down           : in STD_LOGIC;
           B_left           : in STD_LOGIC;
           S_Draw           : in STD_lOGIC;
           S_pad_10         : in STD_LOGIC;
           S_Clear          : in STD_LOGIC;
           S_Ite            : in STD_LOGIC;
           S_Speed          : in STD_LOGIC;
           PS2_clk          : inout STD_LOGIC;
           PS2_data         : inout STD_LOGIC;
           VGA_hs           : out STD_LOGIC;
           VGA_vs           : out STD_LOGIC;
           VGA_red          : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_green        : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_blue         : out STD_LOGIC_VECTOR (3 downto 0);
           seg7             : out STD_LOGIC_VECTOR (6 downto 0);
           DP               : out STD_LOGIC;
           seg7_selector    : out STD_LOGIC_VECTOR (7 downto 0));
end Top_GoL;

architecture Behavioral of Top_GoL is

component filter_input is
    Port ( CLK  : in STD_LOGIC;
           I    : in STD_LOGIC;
           O    : out STD_LOGIC);
end component;

COMPONENT ps2_mouse IS
	GENERIC(
			clk_freq				    :	INTEGER := 50_000_000;	--system clock frequency in Hz
			ps2_debounce_counter_size	:	INTEGER := 8);				--set such that 2^size/clk_freq = 5us (size = 8 for 50MHz)
	PORT(
			clk				:	IN			STD_LOGIC;								--system clock input
			reset_n			:	IN			STD_LOGIC;								--active low asynchronous reset
			ps2_clk			:	INOUT		STD_LOGIC;								--clock signal from PS2 mouse
			ps2_data		:	INOUT		STD_LOGIC;								--data signal from PS2 mouse
			mouse_data		:	OUT		STD_LOGIC_VECTOR(23 DOWNTO 0);	        --data received from mouse
			mouse_data_new	:	OUT		STD_LOGIC);								--new data packet available flag
END COMPONENT;

component clock_manag is
    Port ( CLK          : in STD_LOGIC;
           R            : in STD_LOGIC;
           Ce_aff       : out STD_LOGIC;
           Ce_VGA       : out STD_LOGIC;
           Ce_30Hz      : out STD_LOGIC);
end component;
                                  

component FSM_Iteration is
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
end component;

component initialize_memory is
    generic( bit_per_pixel : integer range 1 to 12 := 1);
    Port ( CLK          : in STD_LOGIC;
           Reset        : in STD_LOGIC;
           Init         : in STD_LOGIC;
           ADDR         : out STD_LOGIC_VECTOR (18 downto 0);
           write        : out STD_LOGIC;
           data_out     : out STD_LOGIC_VECTOR ( bit_per_pixel - 1 downto 0);
           init_done    : out STD_LOGIC);
end component;

component Futur_state is
    Generic ( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( CLK                  : in STD_LOGIC;
           Reset                : in STD_LOGIC;
           Ce                   : in STD_LOGIC;
           Flag_Top, Flag_Bot, Flag_left, Flag_right : in STD_LOGIC;
           Color_read           : in STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);
           Color_write          : out STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0));
end component;

component ADDR_manag is
    Port ( CLK                  : in STD_LOGIC;
           Reset                : in STD_LOGIC;
           PLAY                 : in STD_LOGIC;
           Start_60hz           : in STD_LOGIC;        -- VGA 60Hz
           Start_30hz           : in STD_LOGIC;        -- VGA 30Hz
           Speed_select         : in STD_LOGIC;
           Enable_reading       : out STD_LOGIC; -- control TOP_read (shift register)
           Flag_Top, Flag_Bot, Flag_left, Flag_right : out STD_LOGIC;
           ADDR                 : out STD_LOGIC_VECTOR (18 downto 0);
           Write                : out STD_LOGIC;
           Iteration_over       : out STD_LOGIC);
end component;

component Mux_Input_VGA is
    Generic( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( INIT             : in STD_LOGIC;
           PLAY             : in STD_LOGIC;
           
           ADDR_init        : in STD_LOGIC_VECTOR (18 downto 0);
           Data_init        : in STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);
           Write_init       : in STD_LOGIC;
           
           ADDR_ite         : in STD_LOGIC_VECTOR (18 downto 0);
           Data_ite         : in STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);
           Write_ite        : in STD_LOGIC;
           
           ADDR_draw        : in STD_LOGIC_VECTOR (18 downto 0);
           Data_draw        : in STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);
           Write_draw       : in STD_LOGIC;
           
           ADDR             : out STD_LOGIC_VECTOR (18 downto 0);
           Data_out         : out STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);
           Write            : out STD_LOGIC);
end component;

component VGA_bitmap_640x480 is
  generic(bit_per_pixel : integer range 1 to 12:=1;    -- number of bits per pixel
          grayscale     : boolean := false);           -- should data be displayed in grayscale
  port(clk          : in  std_logic;
       reset        : in  std_logic;
       VGA_hs       : out std_logic;   -- horisontal vga syncr.
       VGA_vs       : out std_logic;   -- vertical vga syncr.
       VGA_red      : out std_logic_vector(3 downto 0);   -- red output
       VGA_green    : out std_logic_vector(3 downto 0);   -- green output
       VGA_blue     : out std_logic_vector(3 downto 0);   -- blue output

       ADDR         : in  std_logic_vector(18 downto 0);
       data_in      : in  std_logic_vector(bit_per_pixel - 1 downto 0);
       data_write   : in  std_logic;
       data_out     : out std_logic_vector(bit_per_pixel - 1 downto 0));
end component;

component aff_7_seg is
    Port ( clk            : in STD_LOGIC;
		   Reset          : in STD_LOGIC;
		   ce_aff         : in STD_LOGIC;
		   Init           : in STD_LOGIC;
		   incr_iter      : in STD_LOGIC;
           Val_out        : out STD_LOGIC_VECTOR (6 downto 0);
		   aff_nb         : out STD_LOGIC_VECTOR (7 downto 0);
		   DP             : out STD_LOGIC);
end component;

component Controller is
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
end component;                                            
--------------------------------------------------------------------------------------------
-- VGA constant
constant bit_per_pixel  : integer range 1 to 12 := 3;
constant grayscale      : boolean := false;

-- Buttons
signal i_B_center, i_B_up, i_B_down, i_B_left, i_B_right : std_logic;

-- Mouse
signal reset_n         : std_logic;
signal mouse_data_new  : std_logic;
signal mouse_data      : std_logic_vector( 23 downto 0 );

-- FSM state related outputs
signal i_init, i_play, i_draw : std_logic;

-- Clock manager signals
signal i_ce_aff, i_ce_iter, i_ce_vga, i_ce_30Hz : std_logic;

-- Output initialization screen
signal ADDR_init    : std_logic_vector( 18 downto 0 );
signal data_init    : std_logic_vector (bit_per_pixel - 1 downto 0);
signal write_init   : std_logic;
signal i_init_over  : std_logic;    -- Indicate when initialization is over to the FSM_iteration

-- ADDR management
signal i_flag_Top, i_flag_Bot, i_flag_left, i_flag_right : std_logic;   -- Border detector signals
signal Ce_ite : std_logic;                                              -- Clock enable for shift registers
 
signal ADDR_ite         : std_logic_vector( 18 downto 0 );
signal data_ite         : std_logic_vector (bit_per_pixel - 1 downto 0);
signal write_ite        : std_logic;
signal iteration_done   : std_logic; -- Indicate when an iteration is over to the FSM_iteration

-- DRAWING
signal ADDR_draw    : std_logic_vector( 18 downto 0 );
signal data_draw    : std_logic_vector (bit_per_pixel - 1 downto 0);
signal write_draw   : std_logic;
signal i_exit_draw  : std_logic; -- Indicate when FSM_iteration can safely return in Pause state

-- Mux_input_VGA
signal ADDR     : std_logic_vector( 18 downto 0 );
signal data_in  : std_logic_vector (bit_per_pixel - 1 downto 0);
signal write    : std_logic;
-- VGA Output (read)
signal color_pixel_read : std_logic_vector (bit_per_pixel - 1 downto 0); -- Color read from VGA's memory
--------------------------------------------------------------------------------------------

begin

filter_B_center : filter_input port map (clk => clk, I => B_center, O => i_B_center);
filter_B_up     : filter_input port map (clk => clk, I => B_up,     O => i_B_up);
filter_B_down   : filter_input port map (clk => clk, I => B_down,   O => i_B_down);
filter_B_left   : filter_input port map (clk => clk, I => B_left,   O => i_B_left);
filter_B_right  : filter_input port map (clk => clk, I => B_right,  O => i_B_right);

-- Mouse reset handler
reset_n <= '0' when Reset = '1' else
           '1';

Mouse_manager : ps2_mouse generic map ( clk_freq => 100000000,          -- System clock
                                        ps2_debounce_counter_size => 9) -- Respect 2^(ps2_debounce_counter_size) / clk_freq = 5us
                          port    map ( clk             => CLK,
                                        reset_n         => reset_n,
                                        ps2_clk         => ps2_clk,
                                        ps2_data        => ps2_data,
                                        mouse_data      => mouse_data,
                                        mouse_data_new  => mouse_data_new);
                                        
clock_manager : clock_manag port map(   CLK     => CLK,
                                        R       => Reset,
                                        Ce_aff  => i_ce_aff,
                                        Ce_VGA  => i_ce_vga,
                                        Ce_30Hz => i_ce_30Hz);    
                                        
                                        
FSM : FSM_Iteration port map ( CLK                  => CLK,
                               Reset                => Reset,
                               B_up                 => i_B_up,
                               B_right              => i_B_right,
                               B_down               => i_B_down,
                               B_left               => i_B_left,
                               B_center             => i_B_center,
                               S_draw               => S_draw,
                               S_ite                => S_Ite,
                               S_clear              => S_Clear,
                               Iteration_done       => iteration_done,
                               Initialization_done  => i_init_over,
                               Leave_draw           => i_exit_draw,
                               Initialisation       => i_init,
                               Play                 => i_play,
                               Draw                 => i_draw);


init_vga : initialize_memory generic map (  bit_per_pixel => bit_per_pixel)
                             port    map (  CLK        => CLK,
                                            Reset      => Reset,
                                            Init       => i_init,
                                            ADDR       => ADDR_init,
                                            write      => write_init,
                                            data_out   => data_init,
                                            init_done  => i_init_over);
      

memory_iteration : Futur_state generic map ( bit_per_pixel => bit_per_pixel )
                               port    map ( CLK          => CLK,
                                             Reset        => Reset,
                                             Ce           => Ce_ite,
                                             Flag_Top     => i_flag_top,
                                             Flag_bot     => i_flag_bot,
                                             Flag_Left    => i_flag_left,
                                             Flag_right   => i_flag_right,
                                             color_read   => color_pixel_read,
                                             color_write  => data_ite);
    

ADDR_management : ADDR_manag port map ( CLK             => CLK,
                                        Reset           => Reset,
                                        PLAY            => i_play,
                                        Start_60hz      => i_ce_vga,
                                        Start_30hz      => i_ce_30Hz,
                                        Speed_select    => S_Speed,
                                        Enable_reading  => Ce_ite,
                                        Flag_Top        => i_flag_top,
                                        Flag_bot        => i_flag_bot,
                                        Flag_Left       => i_flag_left,
                                        Flag_right      => i_flag_right,
                                        ADDR            => ADDR_ite,
                                        Write           => write_ite,
                                        Iteration_over  => iteration_done);

display_iter : aff_7_seg port map ( CLK         => CLK,
                                    Reset       => Reset,
                                    Init        => i_init,
                                    ce_aff      => i_ce_aff,
                                    incr_iter   => i_play,
                                    val_out     => seg7,
                                    aff_nb      => seg7_selector,
                                    DP          => DP);      

Controller_Draw :  Controller generic map ( bit_per_pixel => bit_per_pixel )
                              port    map ( CLK             => CLK,
                                            Reset           => Reset,
                                            Ce              => '1',
                                            Draw            => i_draw,
                                            Pad10           => S_Pad_10,
                                            
                                            B_Up            => i_B_up,
                                            B_Down          => i_B_down,
                                            B_Left          => i_B_left,
                                            B_Right         => i_B_right,
                                            B_center        => i_B_center,
                                            Mouse_data      => Mouse_data,
                                            Mouse_data_new  => Mouse_data_new,
                                            
                                            Color_read      => color_pixel_read,
                                            Leave_draw      => i_exit_draw,
                                            
                                            ADDR            => ADDR_draw,
                                            Data_out        => data_draw,
                                            Write           => write_draw);
                                            
MUX_VGA : Mux_Input_VGA generic map (   bit_per_pixel => bit_per_pixel )
                        port    map (   INIT => i_init, PLAY => i_play,
                                        ADDR_init => ADDR_init, Data_init => data_init, Write_init => write_init,
                                        ADDR_ite  => ADDR_ite,  Data_ite  => data_ite,  Write_ite  => write_ite,
                                        ADDR_draw => ADDR_draw, Data_draw => data_draw, Write_draw => write_draw,
                                   
                                        ADDR      => ADDR,      Data_out  => Data_in,   Write      => Write);
                                   


VGA : VGA_bitmap_640x480 generic map (  bit_per_pixel => bit_per_pixel,
                                        grayscale     => grayscale)
                         port    map (  CLK => CLK,
                                        Reset => Reset,
                                            
                                        VGA_hs      => VGA_hs,
                                        VGA_vs      => VGA_vs,
                                        VGA_red     => VGA_red,
                                        VGA_green   => VGA_green,
                                        VGA_blue    => VGA_blue,
                                            
                                        ADDR        => ADDR,
                                        data_in     => data_in,
                                        data_write  => write,
                                        data_out    => color_pixel_read);

end Behavioral;
