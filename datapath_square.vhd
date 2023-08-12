
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity datapath is
    Port ( i_clk : in STD_LOGIC;
           i_res : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_data : out STD_LOGIC_VECTOR (7 downto 0);
           r1_load : in STD_LOGIC;
           r2_load : in STD_LOGIC;
           r3_load : in STD_LOGIC;
           r2_sel : in STD_LOGIC;
           r3_sel : in STD_LOGIC;
           d_sel : in STD_LOGIC;
           o_end : out STD_LOGIC);
end datapath;

architecture Behavioral of datapath is
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (15 downto 0);
signal sum : STD_LOGIC_VECTOR(15 downto 0);
signal mux_reg2 : STD_LOGIC_VECTOR(15 downto 0);
signal mux_reg3 : STD_LOGIC_VECTOR(7 downto 0);
signal sub : STD_LOGIC_VECTOR(7 downto 0);
signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
begin
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
    sum <= ("00000000" & o_reg1) + o_reg2;
    
    with r2_sel select
        mux_reg2 <= "0000000000000000" when '0',
                    sum when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg2 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= mux_reg2;
            end if;
        end if;
    end process;
    
    with d_sel select
        o_data <= o_reg2(7 downto 0) when '0',
                  o_reg2(15 downto 8) when '1',
                  "XXXXXXXX" when others;
    
    with r3_sel select
        mux_reg3 <= i_data when '0',
                    sub when '1',
                    "XXXXXXXX" when others;
    process(i_clk, i_res)
    begin
        if(i_res = '1') then
            o_reg3 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r3_load = '1') then
                o_reg3 <= mux_reg3;
            end if;
        end if;
    end process;
    
    sub <= o_reg3 - "00000001";
    
    o_end <= '1' when (o_reg3 = "00000000") else '0';

end Behavioral;
