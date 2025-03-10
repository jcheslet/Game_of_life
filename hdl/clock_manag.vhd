


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;


entity clock_manag is
    Port ( CLK          : in STD_LOGIC;
           R            : in STD_LOGIC;
           Ce_aff       : out STD_LOGIC;
           Ce_VGA       : out STD_LOGIC;
           Ce_30Hz      : out STD_LOGIC
           );
end clock_manag;

architecture Behavioral of clock_manag is

signal Q_i_aff : unsigned (15 downto 0);    -- rafraichissement 7 segments
signal Q_i_VGA : unsigned (20 downto 0);    -- rafraichissement d'image VGA - 60Hz
signal Q_i_30hz : unsigned (21 downto 0);   -- 30 Hz

begin

    Process(CLK, R)
        begin
        if R = '1' then
            Q_i_aff <= "0000000000000000";
            elsif(rising_edge(CLK)) then
                if (Q_i_aff = "1000001000110101") then
                    Q_i_aff <= "0000000000000000";
                else
                    Q_i_aff <= Q_i_aff + "0000000000000001";
                end if;              
        end if;
     end process;
      
    Process(CLK, R)
        begin
            if R = '1' then
                Q_i_VGA <= to_unsigned( 0, 21 );
            elsif(rising_edge(CLK)) then
                if (Q_i_VGA = to_unsigned(1667200, 21)) then -- 520 * 3200 = 1 664 000 => 16,640 ms
                    Q_i_VGA <= to_unsigned( 0, 21 );
                else
                    Q_i_VGA <= Q_i_VGA + to_unsigned( 1, 21 );
                end if;              
            end if;
    end process;
      
    Process(CLK, R)
        begin
            if R = '1' then
                Q_i_30hz <= to_unsigned( 0, 22 );
            elsif(rising_edge(CLK)) then
                if (Q_i_30hz = to_unsigned(3334400, 22)) then -- 520 * 3200 = 1 664 000 => 16,640 ms
                    Q_i_30hz <= to_unsigned( 0, 22 );
                else
                    Q_i_30hz <= Q_i_30hz + to_unsigned( 1, 22 );
                end if;              
            end if;
    end process;
      

    Process(Q_i_aff, R)
        begin
            if R = '1' then
                Ce_aff <= '0';
            elsif Q_i_aff = "1000001000110101" then
                Ce_aff <= '1';
            else
                Ce_aff <= '0';
            end if;
    end process;
    
    Process(Q_i_VGA, R)
        begin
            if R = '1' then
                Ce_VGA <= '0';
            elsif Q_i_VGA = to_unsigned(1667200, 21) then
                Ce_VGA <= '1';
            else
                Ce_VGA <= '0';
            end if;
    end process;
    
    Process(Q_i_30hz, R)
        begin
            if R = '1' then
                Ce_30Hz <= '0';
            elsif Q_i_30hz = to_unsigned(3334400, 22) then
                Ce_30Hz <= '1';
            else
                Ce_30Hz <= '0';
            end if;
    end process;
        
            
end Behavioral;
