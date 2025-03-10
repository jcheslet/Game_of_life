library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity initialize_memory is
    generic( bit_per_pixel : integer range 1 to 12 := 1);
    Port ( CLK          : in STD_LOGIC;
           Reset        : in STD_LOGIC;
           Init         : in STD_LOGIC;
           ADDR         : out STD_LOGIC_VECTOR (18 downto 0);
           write        : out STD_LOGIC;
           data_out     : out STD_LOGIC_VECTOR ( bit_per_pixel - 1 downto 0);
           init_done    : out STD_LOGIC);
end initialize_memory;

architecture Behavioral of initialize_memory is

signal counter : integer range 0 to 307199 := 0;    -- ADDR counter

begin

data_out <= std_logic_vector ( TO_UNSIGNED ( 0, bit_per_pixel ) );      -- Kill every cells
ADDR     <= std_logic_vector ( TO_UNSIGNED ( counter, 19 ) );

ADDR_counter : process( CLK )
begin
    if rising_edge ( CLK ) then
        if Reset = '1' or init = '0' then
            counter <= 0;
            init_done <= '0';
         elsif init = '1' then 
            if counter = 307199 then
                init_done <= '1';
                counter <= 0;
            else
                init_done <= '0';
                counter <= counter + 1;
            end if;
        end if;
    end if;
end process;

write_memory : process( CLK )
begin
    if rising_edge ( CLK ) then
        if Reset = '1' or init = '0' then
            write <= '0';
        elsif init = '1' then
            write <= '1';
        end if;
    end if;
end process;

end Behavioral;
