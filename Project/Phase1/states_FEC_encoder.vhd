library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity states_FEC_encoder is 
    port(
        clk_50mhz, clk_100mhz                 : in    std_logic; 
        reset, rand_out_valid                 : in    std_logic; 
        tail_bits_in                          : in    std_logic_vector(5 downto 0); 
        data_in                               : in    std_logic; 
        x_output, y_output                    : out   std_logic; 
        FEC_encoder_out_valid                 : out   std_logic; 
        data_out                              : out   std_logic

    );
end states_FEC_encoder;

architecture states_FEC_encoder_arch of states_FEC_encoder is
    --constant 
    constant BUFFER_SIZE                      : integer := 12; 
    --signals 
    signal   shift_reg                        : std_logic_vector(5 downto 0); 
    signal   x_output_signal, y_output_signal : std_logic; 
    signal   flag                             : std_logic; 
    signal   counter_buffer_input             : integer; 
    signal   counter_shift_and_output         : integer; 
    signal   finished_buffering_flag          : std_logic;
    signal   finished_outputting_flag         : std_logic;
    signal   data_in_buffer                   : std_logic_vector(BUFFER_SIZE-1 downto 0);

    --state machines 
    type input_state_type is (idle, buffer_input, get_tail_bits, shifting); 
    signal input_state_reg, input_state_next    : input_state_type; 
    
begin

    --contineous 
    x_output    <= x_output_signal; 
    y_output    <= y_output_signal; 
    data_out    <= x_output_signal when (flag = '1') else y_output_signal;

    --state1 register
    process (clk_50mhz, reset) begin 
        if (reset = '1') then 
            input_state_reg <= idle; 
        elsif (rising_edge(clk_50mhz)) then 
            input_state_reg <= input_state_next; 
        end if;
    end process;

    --state1 next state logic 
    process (reset, clk_50mhz, input_state_reg, rand_out_valid, counter_buffer_input, counter_shift_and_output, finished_outputting_flag) begin 
        if (reset = '1') then 
            data_in_buffer              <= (others => '0'); 
            counter_buffer_input        <= 0;
            shift_reg                   <= (others => '0');
            counter_shift_and_output    <= 0;
            finished_buffering_flag     <= '0';
            finished_outputting_flag    <= '0';
        elsif (rising_edge(clk_50mhz)) then 
            case input_state_reg is 
                when idle => 
                    if (rand_out_valid = '1') then 
                        if (finished_outputting_flag = '1') then 
                            finished_buffering_flag <= '0';
                        end if;
                        input_state_next    <= buffer_input; 
                    else 
                        input_state_next    <= idle; 
                    end if;
                when buffer_input => 
                    if (counter_buffer_input < BUFFER_SIZE) then
                        if (finished_buffering_flag = '0') then 
                            input_state_next                     <= buffer_input; 
                            data_in_buffer(counter_buffer_input) <= data_in; 
                            counter_buffer_input                 <= counter_buffer_input + 1;
                        end if; 
                    elsif (counter_buffer_input = BUFFER_SIZE) then 
                        input_state_next                     <= get_tail_bits;
                        counter_buffer_input                 <= 0;
                        finished_buffering_flag              <= '1'; 
                    end if;
                when get_tail_bits => 
                    shift_reg           <= data_in_buffer(BUFFER_SIZE-6) & data_in_buffer(BUFFER_SIZE-5) & data_in_buffer(BUFFER_SIZE-4) & data_in_buffer(BUFFER_SIZE-3) & data_in_buffer(BUFFER_SIZE-2) & data_in_buffer(BUFFER_SIZE-1); --take tail bits as last 6 bits from buffer
                    input_state_next    <= shifting; 
                when shifting => 
                    if (finished_buffering_flag = '1') then 
                        if (counter_shift_and_output < BUFFER_SIZE) then 
                            input_state_next            <= shifting;
                            shift_reg                   <= data_in_buffer(counter_shift_and_output) & shift_reg(5 downto 1); 
                            counter_shift_and_output    <= counter_shift_and_output + 1;
                            finished_outputting_flag    <= '0';
                        else 
                            input_state_next            <= idle;
                            counter_shift_and_output    <= 0;
                            finished_outputting_flag    <= '1';
                        end if;
                    end if;
            end case;
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
            if (counter_shift_and_output < BUFFER_SIZE) then 
                if (flag = '1') then 
                    x_output_signal         <= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5);
                    flag                    <= '0'; 
                    FEC_encoder_out_valid   <= '1'; 
                else 
                    y_output_signal         <= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(1) xor shift_reg(3) xor shift_reg(4);  
                    flag                    <= '1';
                end if; 
            end if; 
        end if; 
    end if;
end process; 
end states_FEC_encoder_arch; 