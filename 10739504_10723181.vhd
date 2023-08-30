library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_reti_logiche is
    Port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
            
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);        
        o_done : out std_logic;
        
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);      
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
    type state_type is (waiting_start, reading_int_bit, reading_address_bits, waiting_mem, loading_data, selecting_channel,
    saving_data, output_data);
    signal cur_state, next_state : state_type;

    signal bit_0 : std_logic;
    signal bit_1 : std_logic;
    signal b0_save : std_logic;
    signal b1_save : std_logic;

    signal addr_in : std_logic_vector(15 downto 0);
    signal addr_out : std_logic_vector(15 downto 0);
    signal addr_back : std_logic_vector(15 downto 0);
    signal new_bit : std_logic_vector(15 downto 0);
    signal reg_address : std_logic_vector(15 downto 0) := (others => '0');
    signal mux_addr : std_logic;

    signal addr_save : std_logic;
    
    signal reg_data : std_logic_vector (7 downto 0);
    signal data_save : std_logic;
    
    signal out_save : std_logic;
    signal z0_save : std_logic;
    signal z1_save : std_logic;
    signal z2_save : std_logic;
    signal z3_save : std_logic;

    signal write_out : std_logic;
    signal o_z0_reg : std_logic_vector(7 downto 0);
    signal o_z1_reg : std_logic_vector(7 downto 0);
    signal o_z2_reg : std_logic_vector(7 downto 0);
    signal o_z3_reg : std_logic_vector(7 downto 0);

begin

    -- Datapath
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            bit_0 <= '0';
        elsif rising_edge(i_clk) then
            if(b0_save = '1') then
                bit_0 <= i_w;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            bit_1 <= '0';
        elsif rising_edge(i_clk) then
            if(b1_save = '1') then
                bit_1 <= i_w;
            end if;
        end if;
    end process;

    new_bit <= ("000000000000000" & i_w);
    addr_back <= (reg_address(14 downto 0) & '0');
    addr_in <= std_logic_vector(unsigned(new_bit) + unsigned(addr_back));

    with mux_addr select
        addr_out <= "0000000000000000" when '0',
                    addr_in when '1',
                    "XXXXXXXXXXXXXXXX" when others;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            reg_address <= "0000000000000000";
        elsif rising_edge(i_clk) then
            if (addr_save = '1') then
                reg_address <= addr_out;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            z0_save <= '0';
            z1_save <= '0';
            z2_save <= '0';
            z3_save <= '0';
        elsif rising_edge(i_clk) then
            case bit_0 is
                when '0' =>
                case bit_1 is
                    when '0' => z0_save <= out_save;
                    when '1' => z1_save <= out_save;
                    when others => 
                        z0_save <= 'X';
                        z1_save <= 'X';
                        z2_save <= 'X';
                        z3_save <= 'X';
                end case;    
                when '1' =>
                case bit_1 is
                    when '0' => z2_save <= out_save;
                    when '1' => z3_save <= out_save;
                    when others => 
                        z0_save <= 'X';
                        z1_save <= 'X';
                        z2_save <= 'X';
                        z3_save <= 'X';
                end case;
                when others => 
                        z0_save <= 'X';
                        z1_save <= 'X';
                        z2_save <= 'X';
                        z3_save <= 'X';
           end case;     
        end if;
    end process;
    
    -- Come leggere e scrivere dalla memoria nel registro reg_data
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_mem_addr <= "0000000000000000";
        elsif rising_edge(i_clk) then
            o_mem_addr <= reg_address;
        end if;
    end process;
    

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            reg_data <= "00000000";
        elsif rising_edge(i_clk) then
            if(data_save = '1') then               
                reg_data <= i_mem_data;
            end if;
        end if;
    end process;
    -- Fine memoria

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_z0_reg <= "00000000";
        elsif rising_edge(i_clk) then
            if(z0_save = '1') then
                o_z0_reg <= reg_data;
            end if;
        end if;
    end process;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_z1_reg <= "00000000";
        elsif rising_edge(i_clk) then
            if(z1_save = '1') then
                o_z1_reg <= reg_data;
            end if;
        end if;
    end process;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_z2_reg <= "00000000";
        elsif rising_edge(i_clk) then
            if(z2_save = '1') then
                o_z2_reg <= reg_data;
            end if;
        end if;
    end process;

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_z3_reg <= "00000000";
        elsif rising_edge(i_clk) then
            if(z3_save = '1') then
                o_z3_reg <= reg_data;
            end if;
        end if;
    end process;

    with write_out select
        o_z0 <= "00000000" when '0',
                o_z0_reg when '1',
                "XXXXXXXX" when others;

    with write_out select
        o_z1 <= "00000000" when '0',
                o_z1_reg when '1',
                "XXXXXXXX" when others;
                
    with write_out select
        o_z2 <= "00000000" when '0',
                o_z2_reg when '1',
                "XXXXXXXX" when others;
                
    with write_out select
        o_z3 <= "00000000" when '0',
                o_z3_reg when '1',
                "XXXXXXXX" when others;
        

    -- State Machine
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= waiting_start;
        elsif rising_edge(i_clk) then
            cur_state <= next_state;
        end if;
    end process;
    
    process(cur_state, i_start, i_rst)
    begin
        next_state <= cur_state;

           
                case cur_state is
                    when waiting_start =>
                        if i_rst ='1' then
                            next_state <= waiting_start;
                        elsif i_start = '1' then
                            next_state <= reading_int_bit;
                        else                            
                            next_state <= waiting_start;                      
                        end if;
                    
                    when reading_int_bit =>
                        if i_rst ='1' then
                            next_state <= waiting_start;
                        elsif i_start ='1' then
                            next_state <= reading_address_bits;
                        else
                            next_state <= waiting_start;
                        end if;
            
                    when reading_address_bits =>
                        if i_rst ='1' then
                            next_state <= waiting_start;
                        elsif i_start = '1' then
                            next_state <= reading_address_bits;
                        else
                            next_state <= waiting_mem;
                        end if;
                
                    when waiting_mem =>
                        if i_rst ='1' then
                            next_state <= waiting_start;
                        else 
                            next_state <= loading_data;
                        end if;

                    when loading_data =>
                        if i_rst ='1' then
                            next_state <= waiting_start;
                        else
                            next_state <= selecting_channel;
                        end if;

                    when selecting_channel =>
                        if i_rst ='1' then
                            next_state <= waiting_start;
                        else
                            next_state <= saving_data;
                        end if;

                    when saving_data =>
                        if i_rst ='1' then
                            next_state <= waiting_start;
                        else
                            next_state <= output_data;
                        end if;

                    when output_data =>
                        next_state <= waiting_start;
                        

                end case;
    end process;

    process(cur_state)
    begin
        b0_save <= '0';
        b1_save <= '0';
        mux_addr <= '0';
        addr_save <= '0';
        data_save <= '0';
        out_save <= '0';
        o_done <= '0';
        o_mem_we <= '0';
        o_mem_en <= '0';
        write_out <= '0';

        case cur_state is 
            when waiting_start =>
                mux_addr <= '0';
                addr_save <= '1';
                b0_save <= '1';
            when reading_int_bit =>
                b1_save <= '1';
            when reading_address_bits =>
                mux_addr <= '1';
                addr_save <= '1';
            when waiting_mem =>
                o_mem_en <= '1';
            when loading_data =>
                o_mem_en <= '1';
                data_save <= '1';
            when selecting_channel =>
                out_save <= '1';
            when saving_data =>
                out_save <= '1';
            when output_data =>
                o_done <= '1';
                write_out <= '1';
        end case;
    end process;

end Behavioral;