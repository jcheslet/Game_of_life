library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Write_cell_state is
    Generic ( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( Cell_state       : in STD_LOGIC;
           Cell_color       : out STD_LOGIC_VECTOR (bit_per_pixel - 1 downto 0));
end Write_cell_state;

architecture Behavioral of Write_cell_state is

begin

color_encoder : Process( Cell_state )
begin
    if Cell_state = '1' then
        Cell_color <= (others => '1');
    else
        Cell_color <= (others => '0');
    end if;
end process;

end Behavioral;
