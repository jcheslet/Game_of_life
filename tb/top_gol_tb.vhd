library IEEE;
use IEEE.Std_logic_1164.all;
use IEEE.Numeric_Std.all;

entity top_gol_tb is
end;

architecture bench of top_gol_tb is

  component Top_GoL
    Port ( CLK              : in STD_LOGIC;
           Reset            : in STD_LOGIC;
           B_center         : in STD_LOGIC;
           B_up             : in STD_LOGIC;
           B_right          : in STD_LOGIC;
           B_down           : in STD_LOGIC;
           B_left           : in STD_LOGIC;
           S_Draw           : in STD_lOGIC;
           S_Ite            : in STD_LOGIC;
           S_Speed          : in STD_LOGIC;
           S_pad_10         : in STD_LOGIC;
           S_Clear          : in STD_LOGIC;
           VGA_hs           : out STD_LOGIC;
           VGA_vs           : out STD_LOGIC;
           VGA_red          : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_green        : out STD_LOGIC_VECTOR (3 downto 0);
           VGA_blue         : out STD_LOGIC_VECTOR (3 downto 0);
           seg7             : out STD_LOGIC_VECTOR (6 downto 0);
           DP               : out STD_LOGIC;
           seg7_selector    : out STD_LOGIC_VECTOR (7 downto 0));
  end component;
  
component recreate_img is
    Generic ( width  : integer range 1 to 1920 := 640;
              height : integer range 1 to 1080 := 480;
              bit_per_pixel : integer range 1 to 12 := 1;
              grayscale : boolean := false);
    Port ( CLK : in STD_LOGIC;
           R : in STD_LOGIC;
           VGA_hs : in STD_LOGIC;
           VGA_vs : in STD_LOGIC;
           VGA_red : in STD_LOGIC_VECTOR (3 downto 0);
           VGA_green : in STD_LOGIC_VECTOR (3 downto 0);
           VGA_blue : in STD_LOGIC_VECTOR (3 downto 0));
end component;

  constant bit_per_pixel : integer := 3;    
  constant grayscale : boolean := false;    
  constant width : integer := 640;    
  constant height : integer := 480;

  signal CLK: STD_LOGIC;
  signal Reset: STD_LOGIC;
  signal B_center: STD_LOGIC;
  signal B_up: STD_LOGIC;
  signal B_right: STD_LOGIC;
  signal B_down: STD_LOGIC;
  signal B_left: STD_LOGIC;
  signal S_Draw: STD_lOGIC;
  signal S_ite : STD_lOGIC;
  signal S_pad_10 : STD_lOGIC;
  signal S_Speed : STD_lOGIC;
  signal S_Clear : STD_lOGIC;
  signal VGA_hs: STD_LOGIC;
  signal VGA_vs: STD_LOGIC;
  signal VGA_red: STD_LOGIC_VECTOR (3 downto 0);
  signal VGA_green: STD_LOGIC_VECTOR (3 downto 0);
  signal VGA_blue: STD_LOGIC_VECTOR (3 downto 0);
  signal seg7: STD_LOGIC_VECTOR (6 downto 0);
  signal DP: STD_LOGIC;
  signal seg7_selector: STD_LOGIC_VECTOR (7 downto 0);

  constant clock_period: time := 10 ns;
  signal stop_the_clock: boolean;
  
  signal x : integer range 0 to 99 := 0;
  signal y : integer range 0 to 199 := 0;
  
begin

  uut: Top_GoL port map ( CLK           => CLK,
                             Reset         => Reset,
                             B_center      => B_center,
                             B_up          => B_up,
                             B_right       => B_right,
                             B_down        => B_down,
                             B_left        => B_left,
                             S_Draw        => S_Draw,
                             S_ite         => S_ite,
                             S_speed       => S_speed,
                             S_pad_10      => S_pad_10,
                             S_Clear       => S_Clear,
                             VGA_hs        => VGA_hs,
                             VGA_vs        => VGA_vs,
                             VGA_red       => VGA_red,
                             VGA_green     => VGA_green,
                             VGA_blue      => VGA_blue,
                             seg7          => seg7,
                             DP            => DP,
                             seg7_selector => seg7_selector );

  export_screen: recreate_img generic map ( width => width,
                             height => height,
                             bit_per_pixel => bit_per_pixel,
                             grayscale     =>  grayscale)
                  port map ( CLK           => CLK,
                             R             => Reset,
                             VGA_hs        => VGA_hs,
                             VGA_vs        => VGA_vs,
                             VGA_red       => VGA_red,
                             VGA_green     => VGA_green,
                             VGA_blue      => VGA_blue
                             );

  stimulus: process
  begin
  
    -- Put initialisation code here
  Reset <= '1';
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  S_Draw <= '0' ;
  S_ite <= '0';
  S_Speed <= '0';
  S_pad_10 <= '0';
  S_Clear <= '0';
  wait for 5ns;
  Reset <= '0';
  S_Draw <= '1';
  wait for 4ms;
--  B_center <= '0';
--  S_ite <= '0';
--  wait for 17ms;
  x <= 0;
  y <= 0;
    while x < 99 loop      
        B_center <= '0';
        B_left <= '1' ;
        wait for 100 * clock_period; 
  
        B_center <= '0';
        B_left <= '0' ;
        wait for 100 * clock_period;
        x <= x + 1;
    end loop;
    -- Put test bench stimulus code here
    
    wait for 1000ns;
      
    while Y < 199 loop      
      B_center <= '1';
      B_right <= '0' ;
      wait for 100 * clock_period;     
      
      B_center <= '0';
      B_right <= '0' ;
      wait for 100 * clock_period; 
      
      B_center <= '0';
      B_right <= '1' ;
      wait for 100 * clock_period; 
      
      B_center <= '0';
      B_right <= '0' ;
      wait for 100 * clock_period; 
      y <= y + 1;
    end loop;
    
  
  wait for 7ms;
  
  s_draw <= '0';
  wait for 100 * clock_period;
  
  wait for 3ms;
  
  s_ite <= '1';
  wait;
  
  
  B_center <= '1';
  B_right <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
    
  B_center <= '1';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period;     
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '1' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  wait for 100 * clock_period; 
  
  wait for 7ms;
  
  s_draw <= '0';
  wait for 100 * clock_period;
  
  s_ite <= '1';
  wait;
  

  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  S_draw <= '0';
  S_ite <= '0';
  wait for 12720us; 
     
  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  S_draw <= '0';
  S_ite <= '0';
  wait for 50 * clock_period; 

  B_center <= '0';
  B_up <= '0' ;
  B_right <= '0' ;
  B_down <= '0' ;
  B_left <= '0' ;
  S_draw <= '0';
  S_ite <= '1';
  wait for 16720us;  

--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 20 * clock_period;
  
--  B_center <= '1';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 50 * clock_period;
    
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 50 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '1' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 50 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 50 * clock_period;  
  
--  B_center <= '1';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 50 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 50 * clock_period;
    
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '1' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 20 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  wait for 50 * clock_period;
    
--  B_center <= '1';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  S_draw <= '1';
--  wait for 100 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  S_draw <= '1';
--  wait for 50 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  S_draw <= '0';
--  wait for 16500us;
  
--  B_center <= '1';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  S_draw <= '0';
--  wait for 50 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  S_draw <= '0';
--  wait for 16650 * clock_period; 
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  S_draw <= '0';
--  S_ite <= '1';
--  wait for 50 * clock_period;
  
--  B_center <= '0';
--  B_up <= '0' ;
--  B_right <= '0' ;
--  B_down <= '0' ;
--  B_left <= '0' ;
--  S_draw <= '0';
--  S_ite <= '1';
--  wait for 16650 * clock_period; 
  
    wait;
  end process;
  
  clocking: process
  begin
    while not stop_the_clock loop
      CLK <= '0', '1' after clock_period / 2;
      wait for clock_period;
    end loop;
    wait;
  end process;

end;