library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity Mux_Input_VGA is
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
end Mux_Input_VGA;

architecture Behavioral of Mux_Input_VGA is

begin

Process( INIT, PLAY, ADDR_init, Data_init, Write_init, ADDR_ite, Data_ite, Write_ite, ADDR_draw, Data_draw, Write_Draw )
begin
    if Init = '1' then
        ADDR        <= ADDR_init;
        Data_out    <= Data_init;
        Write       <= Write_init;
    elsif PLAY = '1' then
        ADDR        <= ADDR_ite;
        Data_out    <= Data_ite;
        Write       <= Write_ite;
    else
        ADDR        <= ADDR_draw;
        Data_out    <= Data_draw;
        Write       <= Write_draw;
    end if;
end process;

end Behavioral;
