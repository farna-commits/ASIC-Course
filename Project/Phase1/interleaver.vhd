library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity interleaver is 
    port(
        clk_100mhz                            : in    std_logic; 
        reset, FEC_encoder_out_valid          : in    std_logic; 
        data_in                               : in    std_logic; 
        interleaver_out_valid                 : out   std_logic; 
        data_out                              : out   std_logic
    );
end interleaver;

architecture interleaver_arch of interleaver is
    --constants 
    constant BUFFER_SIZE                      : integer := 192;
    --signals 
    signal   data_in_buffer                   : std_logic_vector(BUFFER_SIZE-1 downto 0);
    signal   counter                          : unsigned(7 downto 0);
    signal   counter_out                      : integer;
    signal   counter_kmod16                   : unsigned(3 downto 0);
    signal   mk_pos                           : integer; 
    signal   finished_buffering_flag          : std_logic;
    signal   finished_outputting_flag         : std_logic;

begin 

    --continous 
    mk_pos  <= (12 * to_integer(counter_kmod16)) + (to_integer(counter) / 16); 

    --buffer input from FEC
    process(clk_100mhz, reset) begin 
        if (reset = '1') then 
            counter_kmod16          <= (others => '0');
            counter                 <= (others => '0');
            data_in_buffer          <= (others => '0'); 
            finished_buffering_flag <= '0';
        elsif (rising_edge(clk_100mhz)) then
            if (FEC_encoder_out_valid = '1') then 
                if (counter < BUFFER_SIZE) then 
                    if (finished_buffering_flag = '0') then 
                        data_in_buffer(mk_pos)  <= data_in; 
                        counter_kmod16          <= counter_kmod16 + 1;
                        counter                 <= counter + 1;
                    end if;
                else 
                    counter                 <= (others => '0');
                    counter_kmod16          <= (others => '0');
                    finished_buffering_flag <= '1';
                end if; 
            end if; 
        end if; 
    end process;

    --output bits with new indecies 
    process (clk_100mhz, reset) begin 
        if(reset = '1') then 
            data_out                    <= '0';
            counter_out                 <= 191; 
            finished_outputting_flag    <= '0';
            interleaver_out_valid       <= '0';
        elsif(rising_edge(clk_100mhz)) then 
            if (FEC_encoder_out_valid = '1') then 
                if (finished_buffering_flag = '1') then 
                    if (finished_outputting_flag = '0') then 
                        if(counter_out >= 0) then 
                            data_out                <= data_in_buffer(counter_out);
                            interleaver_out_valid   <= '1'; 
                            counter_out             <= counter_out - 1;
                        else 
                            counter_out <= 191;
                            finished_outputting_flag    <= '1';
                        end if;
                    end if;
                end if;
            else
                interleaver_out_valid   <= '0';
            end if; 
        end if;
    end process; 

end interleaver_arch; 