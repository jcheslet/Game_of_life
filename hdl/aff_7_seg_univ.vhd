library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity aff_7_seg_univ is
    Port ( Val_in   : in STD_LOGIC_VECTOR (3 downto 0);
           Val_out  : out STD_LOGIC_VECTOR (6 downto 0));
end aff_7_seg_univ;

architecture Behavioral of aff_7_seg_univ is

begin
    process(Val_in)
    begin
        if(Val_in = "0000") then
            Val_out <= "0000001";
        elsif (Val_in = "0001") then
            Val_out <= "1001111";
        elsif (Val_in = "0010") then
            Val_out <= "0010010";
        elsif (Val_in = "0011") then
            Val_out <= "0000110";
        elsif (Val_in = "0100") then
            Val_out <= "1001100";
        elsif (Val_in = "0101") then
            Val_out <= "0100100";
        elsif (Val_in = "0110") then
            Val_out <= "0100000";
        elsif (Val_in = "0111") then
            Val_out <= "0001111";
        elsif (Val_in = "1000") then
            Val_out <= "0000000";
        elsif (Val_in = "1001") then
            Val_out <= "0000100";
        else 
            Val_out <= "1111111";
    end if;  
    end process;
     
end Behavioral;
