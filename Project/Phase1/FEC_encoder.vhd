library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FEC_encoder is 
    port(
        clk_50mhz, clk_100mhz                 : in    std_logic; 
        reset, rand_out_valid                 : in    std_logic; 
        tail_bits_in                          : in    std_logic_vector(5 downto 0); 
        data_in                               : in    std_logic; 
        x_output, y_output                    : out   std_logic; 
        FEC_encoder_out_valid                 : out   std_logic; 
        data_out                              : out   std_logic

    );
end FEC_encoder;

architecture FEC_encoder_arch of FEC_encoder is
    --constant 
    constant BUFFER_SIZE                      : integer := 12; 
    --signals 
    signal   g1                               : std_logic_vector(5 downto 0); 
    signal   x_output_signal, y_output_signal : std_logic; 
    signal   flag                             : std_logic; 
    signal   counter                          : unsigned(6 downto 0);
    signal   counter2                         : unsigned(6 downto 0);
    signal   finished_buffering_flag          : std_logic;
    signal   finished_outputting_flag         : std_logic;
    signal   data_in_buffer                   : std_logic_vector(BUFFER_SIZE-1 downto 0);

    
begin

    --contineous 
    x_output    <= x_output_signal; 
    y_output    <= y_output_signal; 
    data_out    <= x_output_signal when (flag = '1') else y_output_signal;

    --buffer input from randomizer 
    process (clk_50mhz, reset) begin 
        if (reset = '1') then 
            data_in_buffer          <= (others => '0'); 
            counter                 <= (others => '0');
            finished_buffering_flag <= '0';
        elsif(rising_edge(clk_50mhz)) then 
            if(rand_out_valid = '1') then 
                if (finished_outputting_flag = '1') then 
                    finished_buffering_flag <= '0';
                end if; 
                if (counter < BUFFER_SIZE) then
                    if (finished_buffering_flag = '0') then  
                        data_in_buffer(to_integer(counter)) <= data_in; 
                        counter                             <= counter + 1;
                    end if;
                else   
                    finished_buffering_flag <= '1';
                    counter                 <= (others => '0'); 
                end if;
            end if; 
        end if;
    end process; 

    --start shifting after buffering finishes 
    process(clk_50mhz, reset, counter) begin 
        if (reset = '1') then 
            g1                          <= (others => '0');
            counter2                    <= (others => '0');
            finished_outputting_flag    <= '0';
        elsif (rising_edge(clk_50mhz)) then 
            if (rand_out_valid = '1') then
                if (counter = BUFFER_SIZE) then 
                    g1 <= data_in_buffer(BUFFER_SIZE-1) & data_in_buffer(BUFFER_SIZE-2) & data_in_buffer(BUFFER_SIZE-3) & data_in_buffer(BUFFER_SIZE-4) & data_in_buffer(BUFFER_SIZE-5) & data_in_buffer(BUFFER_SIZE-6); --take tail bits as last 6 bits from buffer
                end if;
                if (finished_buffering_flag = '1') then 
                    if(counter2 < BUFFER_SIZE) then 
                        g1                          <= data_in_buffer(to_integer(counter2)) & g1(5 downto 1); 
                        counter2                    <= counter2 + 1;
                        finished_outputting_flag    <= '0';
                    else
                        counter2                    <= (others => '0'); 
                        finished_outputting_flag    <= '1';

                    end if; 
                end if; 
            end if; 
        end if; 
    end process; 

    --produce outputs 
    process (clk_100mhz, reset) begin 
        if (reset = '1') then 
            flag                    <= '1'; 
            x_output_signal         <= '0';
            y_output_signal         <= '0';
            FEC_encoder_out_valid   <= '0';
        elsif(rising_edge(clk_100mhz)) then 
            if (rand_out_valid = '1') then 
                if (counter2 < BUFFER_SIZE) then 
                    if (flag = '1') then 
                        x_output_signal         <= data_in_buffer(to_integer(counter2)) xor g1(0) xor g1(3) xor g1(4) xor g1(5);
                        flag                    <= '0'; 
                        FEC_encoder_out_valid   <= '1'; 
                    else 
                        y_output_signal         <= data_in_buffer(to_integer(counter2)) xor g1(0) xor g1(1) xor g1(3) xor g1(4);  
                        flag                    <= '1';
                    end if; 
                end if; 
            end if; 
        end if;
    end process; 

end FEC_encoder_arch;