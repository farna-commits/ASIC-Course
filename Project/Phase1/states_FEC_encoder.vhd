library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Note: senstivity list of a syncronus process must have clk and async reset only

entity states_FEC_encoder is 
    port(
        clk_50mhz, clk_100mhz                 	: in    std_logic; 
        reset, rand_out_valid                 	: in    std_logic; 
        data_in                               	: in    std_logic; 
        x_output, y_output                    	: out   std_logic; 
        FEC_encoder_out_valid                 	: out   std_logic; 
        data_out                              	: out   std_logic

    );
end states_FEC_encoder;

architecture states_FEC_encoder_arch of states_FEC_encoder is
    --constant 
    constant BUFFER_SIZE                      	: integer := 96; 
    --signals 	
    signal   shift_reg                        	: std_logic_vector(5 downto 0); 
    signal   x_output_signal, y_output_signal 	: std_logic; 
    signal   flag                             	: std_logic; 
    signal   counter_buffer_input             	: integer; 
    signal   counter_shift_and_output         	: integer; 
	signal   finished_buffering_flag          	: std_logic;
	signal   finished_tail_flag          	  	: std_logic;
    signal   finished_outputting_flag         	: std_logic;
	signal   data_in_buffer                   	: std_logic_vector(BUFFER_SIZE-1 downto 0);

    --state machines 
    type input_state_type is (idle, buffer_input, shifting); 
	signal input_state_reg, input_state_next    : input_state_type; 
	type output_state_type is (idle, x, y); 
    signal output_state_reg, output_state_next  : output_state_type;
    
begin

    --contineous 
    x_output  <= x_output_signal; 
    y_output  <= y_output_signal; 
    data_out  <= ( data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5) ) when ( (output_state_reg = idle and finished_tail_flag = '1') or output_state_reg = x) else 
    (data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(1) xor shift_reg(3) xor shift_reg(4)) when (output_state_reg = y); 
    FEC_encoder_out_valid	<= '1' when (input_state_reg = shifting) else '0';	

    -----------------------------------------------------------------------------state machine 1 -----------------------------------------------------------------------------
    process (reset, clk_50mhz) begin 
        if (reset = '1') then 
            data_in_buffer              <= (others => '0'); 
            counter_buffer_input        <= 0;
            shift_reg                   <= (others => '0');
            counter_shift_and_output    <= 0;
            finished_buffering_flag     <= '0';
			finished_outputting_flag    <= '0';
			finished_tail_flag			<= '0';
        elsif (rising_edge(clk_50mhz)) then 
            case input_state_reg is 
                when idle => 
                    if (rand_out_valid = '1') then 
                        if (finished_outputting_flag = '1') then 
                            finished_buffering_flag <= '0';
                        end if;
						if (finished_buffering_flag = '0') then 
                            data_in_buffer(counter_buffer_input) <= data_in; 
							counter_buffer_input                 <= counter_buffer_input + 1;
							input_state_reg                      <= buffer_input; 
                        end if; 
                    else 
                        input_state_reg    <= idle; 
                    end if;
                when buffer_input => 
                    if (counter_buffer_input < BUFFER_SIZE-1) then
                        if (finished_buffering_flag = '0') then 
                            input_state_reg                     	<= buffer_input; 
                            data_in_buffer(counter_buffer_input) 	<= data_in; 
                            counter_buffer_input                 	<= counter_buffer_input + 1;
                        end if; 
                    elsif (counter_buffer_input = BUFFER_SIZE-1) then 
                        data_in_buffer(counter_buffer_input) 	<= data_in; 
                        counter_buffer_input                 	<= counter_buffer_input + 1;
                        counter_buffer_input                 	<= 0;
                        finished_buffering_flag              	<= '1'; 
                        --get tail bits 
                        shift_reg                               <= data_in & data_in_buffer(BUFFER_SIZE-2) & data_in_buffer(BUFFER_SIZE-3) & data_in_buffer(BUFFER_SIZE-4) & data_in_buffer(BUFFER_SIZE-5) & data_in_buffer(BUFFER_SIZE-6); --take tail bits as last 6 bits from buffer
                        input_state_reg    	                    <= shifting; 
                        finished_tail_flag	                    <= '1';
                    end if;
				when shifting => 
                    if (finished_buffering_flag = '1') then 
                        if (counter_shift_and_output < BUFFER_SIZE-1) then 
                            input_state_reg            	<= shifting;
                            shift_reg                   <= data_in_buffer(counter_shift_and_output) & shift_reg(5 downto 1); 
                            counter_shift_and_output    <= counter_shift_and_output + 1;
                            finished_outputting_flag    <= '0';
                        elsif (counter_shift_and_output = 95) then 
                            input_state_reg            	<= idle;
                            -- counter_shift_and_output    <= 0;
                            finished_outputting_flag    <= '1';                            
							finished_buffering_flag		<= '0';
                        end if;
                    end if;
            end case;
        end if;
    end process;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------state machine 2 -----------------------------------------------------------------------------
	process (clk_100mhz, reset) begin 
	if (reset = '1') then 
		x_output_signal         <= '0';
		y_output_signal         <= '0';
		flag					<= '1'; 
	elsif(rising_edge(clk_100mhz)) then 
        if (finished_tail_flag = '1') then
			case output_state_reg is 
				when idle => 
					if (counter_shift_and_output = 0) then 
						x_output_signal     	<= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5);
						output_state_reg		<= y; 
						flag					<= '1';					
					else 
						output_state_reg		<= idle;
					end if; 
				when x => 
						x_output_signal     	<= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5);
						flag					<= '1';
					if (counter_shift_and_output <= BUFFER_SIZE-1) then 										
						output_state_reg		<= y;
					end if;
				when y => 
						y_output_signal         <= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(1) xor shift_reg(3) xor shift_reg(4);
						flag					<= '0';	
					if (counter_shift_and_output < BUFFER_SIZE-1) then 		  										
						output_state_reg		<= x;
					else 
						output_state_reg		<= idle;						
					end if;
			end case;
		end if; 
	end if;
	end process; 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

end states_FEC_encoder_arch;

