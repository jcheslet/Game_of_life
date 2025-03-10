library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity aff_7_seg is
    Port ( clk            : in STD_LOGIC;
		   Reset          : in STD_LOGIC;
		   ce_aff         : in STD_LOGIC;
		   Init           : in STD_LOGIC;
		   incr_iter      : in STD_LOGIC;
           Val_out        : out STD_LOGIC_VECTOR (6 downto 0);
		   aff_nb         : out STD_LOGIC_VECTOR (7 downto 0);
		   DP             : out STD_LOGIC);
end aff_7_seg;


architecture Behavioral of aff_7_seg is

component aff_7_seg_univ is
	Port ( Val_in : in STD_LOGIC_VECTOR (3 downto 0);
           Val_out : out STD_LOGIC_VECTOR (6 downto 0));
end component;


component filter_input is
    Port ( clk : in STD_LOGIC;
           I : in STD_LOGIC;
           O : out STD_LOGIC);
end component;

signal s_valeur : STD_LOGIC_VECTOR(13 downto 0);
signal s_DM, s_M, s_C, s_D, s_U : STD_LOGIC_VECTOR(3 downto 0);
signal s_indic_7_seg : unsigned( 2 downto 0 );
signal DM_7seg, M_7seg, D_7seg, C_7seg, U_7seg : STD_LOGIC_VECTOR(6 downto 0);

signal i_ite : STD_LOGIC;

signal i_DM, i_M, i_C, i_D, i_U : unsigned(3 downto 0);

begin


DP <= '1'; -- Constant : turn off dots on 7 segments


-- Increment on every new PLAY rising edge, according to FSM_iteration
filter_play : filter_input port map( CLK => CLK, I => incr_iter, O => i_ite);


-------------------------------------------------------------------
--        
--          BCD COUNTERS  -  units, tens, hundreds, thousands, and tens of thousands
--
-------------------------------------------------------------------

Unite : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or Init = '1' then
            i_U <= to_unsigned( 0, 4 );
        elsif i_ite = '1' then
            if i_U = to_unsigned( 9, 4 ) then
                i_U <= to_unsigned( 0, 4 );
            else
                i_U <= i_U + to_unsigned( 1, 4 );
            end if;
        end if;
    end if;
end process;


dizaine : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or Init = '1' then
            i_D <= to_unsigned( 0, 4 );
        elsif i_ite = '1' and i_U = to_unsigned( 9, 4 ) then
            if i_D = to_unsigned( 9, 4 ) then
                i_D <= to_unsigned( 0, 4 );
            else
                i_D <= i_D + to_unsigned( 1, 4 );
            end if;
        end if;
    end if;
end process;

centaine : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or Init = '1' then
            i_C <= to_unsigned( 0, 4 );
        elsif i_ite = '1' and i_D = to_unsigned( 9, 4 ) and i_U = to_unsigned( 9, 4 ) then
            if i_C = to_unsigned( 9, 4 ) then
                i_C <= to_unsigned( 0, 4 );
            else
                i_C <= i_C + to_unsigned( 1, 4 );
            end if;
        end if;
    end if;
end process;

millier : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or Init = '1' then
            i_M <= to_unsigned( 0, 4 );
        elsif i_ite = '1' and i_C = to_unsigned( 9, 4 ) and i_D = to_unsigned( 9, 4 ) and i_U = to_unsigned( 9, 4 ) then
            if i_M = to_unsigned( 9, 4 ) then
                i_M <= to_unsigned( 0, 4 );
            else
                i_M <= i_M + to_unsigned( 1, 4 );
            end if;
        end if;
    end if;
end process;

dizaine_de_millier : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' or Init = '1' then
            i_DM <= to_unsigned( 0, 4 );
        elsif i_ite = '1' and i_M = to_unsigned( 9, 4 ) and i_C = to_unsigned( 9, 4 ) and i_D = to_unsigned( 9, 4 ) and i_U = to_unsigned( 9, 4 ) then
            if i_DM = to_unsigned( 9, 4 ) then
                i_DM <= to_unsigned( 0, 4 );
            else
                i_DM <= i_DM + to_unsigned( 1, 4 );
            end if;
        end if;
    end if;
end process;

s_U  <= std_logic_vector( i_U  );
s_D  <= std_logic_vector( i_D  );
s_C  <= std_logic_vector( i_C  );
s_M  <= std_logic_vector( i_M  );
s_DM <= std_logic_vector( i_DM );


DM_7seg_format  : aff_7_seg_univ port map (Val_in=>s_DM, Val_out=> DM_7seg);
M_7seg_format   : aff_7_seg_univ port map (Val_in=>s_M,  Val_out=> M_7seg);
C_7seg_format   : aff_7_seg_univ port map (Val_in=>s_C,  Val_out=> C_7seg);
D_7seg_format   : aff_7_seg_univ port map (Val_in=>s_D,  Val_out=> D_7seg);
U_7seg_format   : aff_7_seg_univ port map (Val_in=>s_U,  Val_out=> U_7seg);	

-------------------------------------------------------------------
--        
--          7 segments attribution  -  Counter and mux
--
-------------------------------------------------------------------

-- Count 0 to 7 to select every 7seg
cpt_0_7 : Process( CLK )
begin
    if rising_edge( CLK ) then
        if Reset = '1' then
            s_indic_7_seg <= to_unsigned( 0, 3);
        elsif ce_aff = '1' then
            s_indic_7_seg <= s_indic_7_seg + to_unsigned( 1, 3 );
        end if;
    end if;
end process;


Process( s_indic_7_seg, U_7seg, D_7seg, C_7seg, M_7seg, DM_7seg )
begin
    case( s_indic_7_seg ) is
       when "000" =>   Val_out <= U_7seg;
                       aff_nb<= "11111110";
                       
	   when "001" =>   Val_out <= D_7seg;
                       aff_nb<= "11111101";
                       
       when "010" =>   Val_out <= C_7seg;
                       aff_nb<= "11111011";
                       
	   when "011" =>   Val_out <= M_7seg;
                       aff_nb<= "11110111";
                       
       when "100" =>   Val_out <= DM_7seg;
                       aff_nb<= "11101111";
                       
	   when "101" =>   Val_out <= "0000001";
                       aff_nb<= "11011111";
                       
       when "110" =>   Val_out <= "0000001";
                       aff_nb<= "10111111";
                       
	   when "111" =>   Val_out <= "0000001";
                       aff_nb<= "01111111";
                       
       when others =>  Val_out <= "0000001";
                       aff_nb<= "11111110";
   end case;
end process;
  
end Behavioral;
