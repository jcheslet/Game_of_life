library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity Futur_state is
    Generic ( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( CLK                  : in STD_LOGIC;
           Reset                : in STD_LOGIC;
           Ce                   : in STD_LOGIC;                                         -- Clock enable of both shift registers
           Flag_Top, Flag_Bot, Flag_left, Flag_right : in STD_LOGIC;                    -- Flags to calculate next state of border pixel (which do not have neighbour)
           Color_read           : in STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0);     -- Color read from memory ( VGA )
           Color_write          : out STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0));   -- Color to write into memory ( VGA )
end Futur_state;

architecture Behavioral of Futur_state is
----------------------------------------------------------------------------------
component Pixel_read is
    Generic ( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( Color_read   : in STD_LOGIC_VECTOR( bit_per_pixel - 1 downto 0 );
           Cell_state   : out STD_LOGIC);
end component;


component Pixel_read_Memory is
    Port ( CLK              : in STD_LOGIC;
           Reset            : in STD_LOGIC;
           Ce               : in STD_LOGIC;
           Top_line         : in STD_LOGIC;
           Bottom_line      : in STD_LOGIC;
           Left_line        : in STD_LOGIC;
           Right_line       : in STD_LOGIC;
           Cell_state       : in STD_LOGIC;
           Neighbourhood    : out STD_LOGIC_VECTOR (8 downto 0));
end component;


component cellUpdate is
    Port ( Cells_neighbourhood  : in STD_LOGIC_VECTOR (8 downto 0);
           Alive                : out STD_LOGIC);
end component;

component Write_cell_state is
    Generic ( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( Cell_state       : in STD_LOGIC;
           Cell_color       : out STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0));
end component;

----------------------------------------------------------------------------------
signal cell_state_read : std_logic;                     -- cursor's Cell state 

signal neighbourhood : std_logic_vector( 8 downto 0 );  -- 9 cells array to calculate next state

signal Cell_state_updated : std_logic;                  -- Futur state

signal Cell_state_to_write : std_logic;                 -- Cell to write into VGA memory (and calculate color on the way)
----------------------------------------------------------------------------------
begin

decoder : Pixel_read    generic map( bit_per_pixel => bit_per_pixel )
                        port map ( Color_read => Color_read,
                                   Cell_state => cell_state_read);

Memory_read_management : Pixel_read_Memory port map ( CLK               => CLK,
                                                      Reset             => Reset,
                                                      Ce                => Ce,
                                                      Top_line          => Flag_top,
                                                      Bottom_line       => Flag_bot,
                                                      Left_line         => Flag_left,
                                                      Right_line        => Flag_right,
                                                      Cell_state        => cell_state_read,
                                                      Neighbourhood     => neighbourhood);


Update_cell : cellUpdate port map ( Cells_neighbourhood => neighbourhood,
                                    Alive               => Cell_state_updated);                                                      
                                                 

Encoder : Write_cell_state generic map ( bit_per_pixel => bit_per_pixel )
                              port map ( Cell_state => Cell_state_updated,
                                         Cell_color => Color_write);               


end Behavioral;
