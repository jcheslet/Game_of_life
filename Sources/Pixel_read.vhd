library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Pixel_read is
    Generic ( bit_per_pixel : integer range 1 to 12 := 3);
    Port ( Color_read   : in STD_LOGIC_VECTOR( bit_per_pixel - 1 downto 0 );
           Cell_state   : out STD_LOGIC);
end Pixel_read;

architecture Behavioral of Pixel_read is

begin


Color_decoder : Process( Color_read )
begin
    case Color_read is
        -- Black : dead cell
        when "000"  =>  Cell_state <= '0';
        -- Yellow : Cursor on a dead cell
        when "110"  =>  Cell_state <= '0';
        
        -- White : living cell
        when "111"  =>  Cell_state <= '1';
        -- Green : Cursor on a living cell
        when "010"  =>  Cell_state <= '1';
        
        when others =>  Cell_state <= '0';  
    end case;
end process;

end Behavioral;
