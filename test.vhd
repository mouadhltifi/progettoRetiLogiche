library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_reti_logiche is
    port (
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

architecture behavior of project_reti_logiche is
    type state_type is (reset, waiting_start, reading_z1_bit, reading_address_bits, waiting_mem, loading_data, saving_data, output_data);
    signal cur_state, next_state : state_type;

    signal bit_0 : std_logic;
    signal bit_1 : std_logic;
    signal b0_save : std_logic;
    signal b1_save : std_logic;

    signal addr_in : std_logic_vector(15 downto 0);
    signal addr_out : std_logic_vector(15 downto 0);
    signal address_vector : std_logic_vector(15 downto 0);
    signal reg_address : std_logic_vector(15 downto 0) := (others => '0');

    signal addr_save : std_logic;
    
    signal reg_data : std_logic_vector (7 downto 0);
    signal data_save : std_logic;
    
    signal out_save : std_logic;
    signal z0_save : std_logic;
    signal z1_save : std_logic;
    signal z2_save : std_logic;
    signal z3_save : std_logic;

    signal o_z0_reg : std_logic_vector(7 downto 0);
    signal o_z1_reg : std_logic_vector(7 downto 0);
    signal o_z2_reg : std_logic_vector(7 downto 0);
    signal o_z3_reg : std_logic_vector(7 downto 0);

begin

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            bit_0 <= '0';
        elsif i_clk'event and i_clk = '1' then
            if(b0_save = '1') then
                bit_0 <= i_w;
            end if;
        end if;
    end process;
    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            bit_1 <= '0';
        elsif i_clk'event and i_clk = '1' then
            if(b1_save = '1') then
                bit_1 <= i_w;
            end if;
        end if;
    end process;
    
    -- State Machine
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= reset;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;

    process(cur_state, i_start, mem_done)
    begin
        next_state <= cur_state;

            case cur_state is
                when reset =>
                    next_state <= waiting_start;
                    
                when waiting_start =>
                    if i_start = '0' then
                        next_state <= waiting_start;
                    else
                        next_state <= reading_z1_bit;                        
                    end if;

                when reading_z1_bit =>
                if i_start ='1' then
                    next_state <= reading_address_bit;
                else
                    next_state <= waiting_mem;
                end if;
            
                when reding_address_bits =>
                if i_start = '1' then
                    next_state <= reading_address_bit;
                else
                    next_state <= waiting_mem;
                end if;
                
                when waiting_mem =>
                if mem_done = '1' then
                    next_state <= loading_data;
                else
                    next_state <= waiting_mem;
                end if;

                when loading_data =>
                    next_state <= saving_data;

                when saving_data =>
                    next_state <= output_data;

                when output_data =>
                    next_state <= waiting_start;

            end case;
        end if;
    end process;

    process(cur_state)
    begin
        b0_save <= '0';
        b1_save <= '0';
        mux_addr <= '0';
        addr_save <= '0';
        data_save <= '0';
        out_save <= '0';
        read <= '0';
        o_done <= '0';

        case cur_state is
            when reset =>
            when waiting_start =>
                b0_save <= '1';
            when reading_z1_bit =>
                b1_save <= '1';
            when reading_address_bit =>
                mux_addr <= '1';
                addr_save <= '1';
            when waiting_mem =>
                read = '1';
            when loading_data =>
                data_save = '1';
            when saving_data =>
                out_save = '1';
            when output_data =>
                o_done = '1';
    end process;
end Behavioral;

    

