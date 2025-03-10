library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity Pixel_read_Memory is
    Port ( CLK              : in STD_LOGIC;
           Reset            : in STD_LOGIC;
           Ce               : in STD_LOGIC;
           Top_line         : in STD_LOGIC;
           Bottom_line      : in STD_LOGIC;
           Left_line        : in STD_LOGIC;
           Right_line       : in STD_LOGIC;
           Cell_state       : in STD_LOGIC;
           Neighbourhood    : out STD_LOGIC_VECTOR (8 downto 0));
end Pixel_read_Memory;

architecture Behavioral of Pixel_read_Memory is

--function createNeighbourhood( shift_register : std_logic_vector( 1282 downto 0 );
--                              Top_line : std_logic;
--                              Bottom_line : std_logic;
--                              Left_line : std_logic;
--                              Right_line : std_logic )
--                              return std_logic_vector is

--variable Neighbourhood : std_logic_vector( 8 downto 0 );
--begin

--Neighbourhood := shift_register( 641 ) & shift_register(1282 downto 1280 ) & shift_register( 642 ) & shift_register( 640 ) & shift_register(2 downto 0 );
--    if    Top_line = '1'    then  Neighbourhood(7) := '0';  Neighbourhood(6) := '0';  Neighbourhood(5) := '0';
--    elsif Bottom_line = '1' then  Neighbourhood(2) := '0';  Neighbourhood(1) := '0';  Neighbourhood(0) := '0';
--    end if;
    
--    if    Left_line = '1'   then  Neighbourhood(7) := '0';  Neighbourhood(4) := '0';  Neighbourhood(2) := '0'; 
--    elsif Right_line = '1'  then  Neighbourhood(5) := '0';  Neighbourhood(3) := '0';  Neighbourhood(0) := '0';
--    end if;
    
--    return Neighbourhood;
--end createNeighbourhood;


-- signal shift_register : std_logic_vector( 1282 downto 0 ); -- 2*640 + 3
signal shift_register_1 : std_logic_vector( 2 downto 0 );
signal shift_register_2 : std_logic_vector( 2 downto 0 );
signal shift_register_3 : std_logic_vector( 2 downto 0 );

signal big_shift_register_1 : std_logic_vector( 636 downto 0 );
signal big_shift_register_2 : std_logic_vector( 636 downto 0 );

signal Top_left,    Top,    Top_right    : std_logic;
signal Left,        center, Right        : std_logic;
signal Bottom_left, Bottom, Bottom_right : std_logic;

begin

-- With function (not tested recently, but gave same performance with one or two less LUT)
--Neighbourhood <= createNeighbourhood( shift_register,
--                                      Top_line,
--                                      Bottom_line,
--                                      Left_line,
--                                      Right_line);

Neighbourhood <= center & Top_left & Top & Top_right & Left & Right & Bottom_left & Bottom & Bottom_right;

Process( Cell_state, shift_register_1, shift_register_2, shift_register_3, Top_line, Bottom_line, Left_line, Right_line,
         Top_left, Top, Top_right, Left, Center, Right, Bottom_left, Bottom, Bottom_right )
begin
    -- TOP LEFT => Shift_register : 1282 & Neighbourhood 7
    if Top_line = '1' or Left_line = '1' then
        Top_left <= '0';
    else
        Top_left <= shift_register_3( 2 );
    end if;
    
    -- TOP CENTER => Shift_register : 1281 & Neighbourhood 6
    if Top_line = '1' then
        Top <= '0';
    else
        Top <= shift_register_3( 1 );
    end if;
    
    -- TOP RIGHT => Shift_register : 1280 & Neighbourhood 5
    if Top_line = '1' or Right_line = '1' then
        Top_right <= '0';
    else
        Top_right <= shift_register_3( 0 );
    end if;
    
    -- CENTER LEFT => Shift_register : 642 & Neighbourhood 4
    if Left_line = '1' then
        Left <= '0';
    else
        Left <= shift_register_2( 2 );
    end if;
    
    -- CENTER CENTER => Shift_register : 641 & Neighbourhood 8
    Center <= shift_register_2( 1 );
    
    -- CENTER RIGHT => Shift_register : 640 & Neighbourhood 3
    if Right_line = '1' then
        Right <= '0';
    else
        Right <= shift_register_2( 0 );
    end if;
    
    -- BOTTOM LEFT => Shift_register : 2 & Neighbourhood 2
    if Bottom_line = '1' or Left_line = '1' then
        Bottom_left <= '0';
    else
        Bottom_left <= shift_register_1( 2 );
    end if;
    
    -- BOTTOM CENTER => Shift_register : 1 & Neighbourhood 1
    if Bottom_line = '1' then
        Bottom <= '0';
    else
        Bottom <= shift_register_1( 1 );
    end if;
    
    -- BOTTOM RIGHT => Shift_register : 0 & Neighbourhood 0
    if Bottom_line = '1' or Right_line = '1' then
        Bottom_right <= '0';
    else
        Bottom_right <= shift_register_1( 0 );
    end if;
end process;  


Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            -- shift_register <= shift_register( 1281 downto 0 ) & '0';
            shift_register_1 <= (others => '0');
            shift_register_2 <= (others => '0');
            shift_register_3 <= (others => '0');

            big_shift_register_1 <= big_shift_register_1( 635 downto 0 ) & '0';
            big_shift_register_2 <= big_shift_register_2( 635 downto 0 ) & '0';
        elsif Ce = '1' then
            shift_register_1     <= shift_register_1( 1 downto 0 ) & Cell_state;
            big_shift_register_1 <= big_shift_register_1( 635 downto 0 ) & shift_register_1( 2 );
            shift_register_2     <= shift_register_2( 1 downto 0 ) & big_shift_register_1( 636 );
            big_shift_register_2 <= big_shift_register_2( 635 downto 0 ) & shift_register_2( 2 );
            shift_register_3     <= shift_register_3( 1 downto 0 ) & big_shift_register_2( 636 );

            --shift_register <= shift_register( 1281 downto 0 ) & Cell_state; 
        end if;
    end if;

end process;

end Behavioral;
