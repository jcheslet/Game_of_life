library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cellUpdate is
    Port ( Cells_neighbourhood  : in STD_LOGIC_VECTOR (8 downto 0);
           Alive                : out STD_LOGIC);
end cellUpdate;

architecture Behavioral of cellUpdate is

function isAlive( neighbourhood : std_logic_vector(8 downto 0) ) return std_logic is
variable count : integer range 0 to 8 := 0;
begin
    for i in 0 to 7 loop
        if neighbourhood(i) = '1' then
            count := count + 1;
--            if count > 3 then     -- Slight difference with or without this part 
--                return '0';       -- in synthese despite the same truth table
--            end if;
        end if;
    end loop;
    
    if (count = 3) or ( (count = 2) and (neighbourhood(8) = '1') ) then
        return '1';
    else
        return '0';
    end if;
end isAlive;

begin

Alive <= isAlive( Cells_neighbourhood );

end Behavioral;
