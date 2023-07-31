library ieee;
use ieee.std_logic_1164.all;

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
    type state_type is (reading_z_bits, reding_address_bits, loading_data, output_data, save_address);

    signal bit_0 : std_logic;
    signal bit_1 : std_logic;


    signal adder_in : std_logic_vector(15 downto 0);
    signal adder_out : std_logic_vector(15 downto 0);


    signal REG_ADDRESS : std_logic_vector(15 downto 0) := (others => '0');

    signal address_vector : std_logic_vector(15 downto 0);

    signal save_mem_addr_flag : std_logic := '0';

    signal mux_address_select : std_logic;
    
    signal previous_i_start : std_logic := '1';

    -- Demultiplexer signals

    signal demux_input : std_logic := '1';
    signal demux_out_0 : std_logic;
    signal demux_out_1 : std_logic;
    signal demux_out_2 : std_logic;
    signal demux_out_3 : std_logic;
    
    -- New signals

    signal REG_DATA : std_logic_vector(7 downto 0);
    
    signal MUX_DATA : std_logic_vector(7 downto 0);
    
    -- Output register signals

    signal o_z0_reg : std_logic_vector(7 downto 0);
    signal o_z1_reg : std_logic_vector(7 downto 0);
    signal o_z2_reg : std_logic_vector(7 downto 0);
    signal o_z3_reg : std_logic_vector(7 downto 0);

begin

    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then

            bit_0 <= '0';
            bit_1 <= '0';
            REG_ADDRESS <= (others => '0');
            save_mem_addr_flag <= '0';
            previous_i_start <= '1';
            o_z0_reg <= (others => '0');
            o_z1_reg <= (others => '0');
            o_z2_reg <= (others => '0');
            o_z3_reg <= (others => '0');

        elsif rising_edge(i_clk) then

            if (REG_B0_enable = '1') then
                bit_0 <= i_w;

            end if;
            if (REG_B1_enable = '1') then
                bit_1 <= i_w;

            end if;
            
            -- Save the output of the multiplexer to REG_ADDRESS when its save signal is active
            if (REG_ADDRESS_save = '1') then
                REG_ADDRESS <= (mux_address_select = '0' ? (others => '0') : adder_out);

            end if;

            -- Check if i_start signal goes low
            if (previous_i_start = '1' and i_start = '0') then
                if (save_mem_addr_flag = '0') then
                    o_mem_addr <= REG_ADDRESS;
                    save_mem_addr_flag <= '1';
                end if;
            end if;
            
            -- Check if i_start signal goes high
            if (previous_i_start = '0' and i_start = '1') then
                save_mem_addr_flag <= '0';
            end if;

            -- Save i_mem_data to REG_DATA when data_save signal is active
            if (data_save = '1') then
                REG_DATA <= i_mem_data;
            end if;
            
            -- Save MUX_DATA to the appropriate o_zx register when the corresponding demux_out_x signal is '1'
            if (demux_out_0 = '1') then
                o_z0_reg <= MUX_DATA;
            end if;
            if (demux_out_1 = '1') then
                o_z1_reg <= MUX_DATA;
            end if;
            if (demux_out_2 = '1') then
                o_z2_reg <= MUX_DATA;
            end if;
            if (demux_out_3 = '1') then
                o_z3_reg <= MUX_DATA;
            end if;

            -- Update previous_i_start
            previous_i_start <= i_start;
        end if;
    end process;

    -- Convert i_w to 16-bit vector
    adder_in <= ("000000000000000" & i_w);

    -- Add adder_in and the 16-bit vector
    adder_out <= std_logic_vector(unsigned(adder_in) + unsigned(loopback_in));

    -- Output the contents of REG_ADDRESS to address_vector
    address_vector <= REG_ADDRESS;

    -- Loopback vector for the adder
    loopback_in <= address_vector(14 downto 0) & '0';



    -- Demultiplexer
    process(bit_0, bit_1)
    begin
        -- Reset outputs
        demux_out_0 <= '0';
        demux_out_1 <= '0';
        demux_out_2 <= '0';
        demux_out_3 <= '0';

        -- Determine output based on select lines
        case (bit_1 & bit_0) is
            when "00" => demux_out_0 <= demux_input;
            when "01" => demux_out_1 <= demux_input;
            when "10" => demux_out_2 <= demux_input;
            when "11" => demux_out_3 <= demux_input;
            when others => null; -- Should never happen
        end case;
    end process;

    -- New MUX
    MUX_DATA <=  REG_DATA;
    
    -- Assign output register signals to output ports
    o_z0 <= o_z0_reg;
    o_z1 <= o_z1_reg;
    o_z2 <= o_z2_reg;
    o_z3 <= o_z3_reg;

end Behavioral;







    -- State Machine
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            state <= idle;
        elsif rising_edge(i_clk) then
            case state is
                when idle =>
                    if i_start = '1' then
                        state <= read_channel;
                    end if;
                when read_channel =>
                    if bit_count = 2 then
                        bit_count <= 0;
                        state <= read_address;
                    end if;
                when read_address =>
                    if i_start = '0' then
                        bit_count <= 0;
                        state <= output_data;
                    end if;
                when output_data =>
                    if o_done = '1' then
                        o_done <= '0';
                        state <= idle;
                    end if;
            end case;
        end if;
    end process;
end behavior;
