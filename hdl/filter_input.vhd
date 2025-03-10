library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;


entity filter_input is
    Port ( clk  : in STD_LOGIC;
           I    : in STD_LOGIC;
           O    : out STD_LOGIC);
end filter_input;

architecture Behavioral of filter_input is

signal mem: std_logic := '0';

begin

Process(clk)
begin
    if rising_edge(clk) then
        if (I = '1' and mem = '0') then
            o <= '1';
            mem <= '1';
        elsif (I = '0' and mem = '1') then
            o <= '0';
            mem <= '0';
        else
            o <= '0';
        end if;
    end if;
end Process;


end Behavioral;
