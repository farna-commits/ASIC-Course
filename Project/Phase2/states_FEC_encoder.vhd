library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

-- Note: senstivity list of a syncronus process must have clk and async reset only

entity states_FEC_encoder is 
    port(
        clk_50mhz, clk_100mhz                 	: in    std_logic; 
        reset, rand_out_valid                 	: in    std_logic; 
        data_in                               	: in    std_logic; 
        x_output, y_output                    	: out   std_logic; 
        FEC_encoder_out_valid_out             	: out   std_logic; 
        data_out                              	: out   std_logic

    );
end states_FEC_encoder;

architecture states_FEC_encoder_arch of states_FEC_encoder is
    --constant 
    constant BUFFER_SIZE                      	: integer := 96; 
    --signals 	
    signal   shift_reg                        	: std_logic_vector(5 downto 0); 
    signal   shift_reg_initial                 	: std_logic_vector(5 downto 0); 
    signal   x_output_signal, y_output_signal 	: std_logic; 
    signal   flag                             	: std_logic; 
    signal   counter_buffer_input             	: integer; 
    signal   counter_shift_and_output         	: integer; 
	signal   finished_buffering_flag          	: std_logic;
	signal   finished_tail_flag          	  	: std_logic;
    signal   finished_outputting_flag         	: std_logic;
    signal   data_in_buffer                   	: std_logic_vector(BUFFER_SIZE-1 downto 0);
    signal   FEC_encoder_out_valid              : std_logic; 

    --state machines 
    type input_state_type is (idle, buffer_input, shifting); 
	signal input_state_reg, input_state_next    : input_state_type; 
	type output_state_type is (idle, x, y); 
    signal output_state_reg, output_state_next  : output_state_type;
    
    --RAM 
    component FEC_RAM_2port is 
        PORT
        (
            address_a	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            address_b	: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data_a		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
            data_b		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
            wren_a		: IN STD_LOGIC  := '0';
            wren_b		: IN STD_LOGIC  := '0';
            q_a		    : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
            q_b		    : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
        );
    end component FEC_RAM_2port; 

    --ram signals 
    signal address_a	:  STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal address_b	:  STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal clock		:  STD_LOGIC  := '1';
    signal data_a		:  STD_LOGIC_VECTOR (0 DOWNTO 0);
    signal data_b		:  STD_LOGIC_VECTOR (0 DOWNTO 0);
    signal wren_a		:  STD_LOGIC  := '0';
    signal wren_b		:  STD_LOGIC  := '0';
    signal q_a		    :  STD_LOGIC_VECTOR (0 DOWNTO 0);
    signal q_b		    :  STD_LOGIC_VECTOR (0 DOWNTO 0);    

begin

    --ram instant 
    ram1: FEC_RAM_2port port map
        (
            address_a   => address_a,
            address_b   => address_b,
            clock	    => clock	,
            data_a	    => data_a	,
            data_b	    => data_b	,
            wren_a	    => wren_a	,
            wren_b	    => wren_b	,
            q_a		    => q_a		,
            q_b		    => q_b		
        );
        
    --ram's signals assign      
    clock	    <= clk_50mhz;	 
    address_a   <= std_logic_vector(to_unsigned(counter_buffer_input, address_a'length)); 
    address_b   <= std_logic_vector(to_unsigned(counter_shift_and_output, address_b'length));
    data_a(0)   <= data_in; 
    wren_a      <= rand_out_valid; 
    -- data_out    <= q_b(0);
    FEC_encoder_out_valid_out <= FEC_encoder_out_valid; 

    --contineous 
    x_output  <= x_output_signal; 
    y_output  <= y_output_signal; 
    -- data_out  <= ( data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5) ) when ( (output_state_reg = idle and finished_tail_flag = '1') or output_state_reg = x) else 
    -- (data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(1) xor shift_reg(3) xor shift_reg(4)) when (output_state_reg = y); 
    -- FEC_encoder_out_valid	<= '1' when (input_state_reg = shifting) else '0';	
    data_out  <= ( q_b(0) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5) ) when ( (output_state_reg = idle and finished_tail_flag = '1') or output_state_reg = x) else 
    (q_b(0) xor shift_reg(0) xor shift_reg(1) xor shift_reg(3) xor shift_reg(4)) when (output_state_reg = y); 
    FEC_encoder_out_valid	<= '1' when (input_state_reg = shifting) else '0';	

    -- shift_reg_initial(counter_buffer_input - 90) <= (data_in) when (counter_buffer_input = 90 or counter_buffer_input = 91 or counter_buffer_input = 92 or counter_buffer_input = 93 or counter_buffer_input = 94 or counter_buffer_input = 95);
                                             
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
                            -- data_in_buffer(counter_buffer_input) <= data_in; 
							counter_buffer_input                 <= counter_buffer_input + 1;
							input_state_reg                      <= buffer_input; 
                        end if; 
                    else 
                        input_state_reg    <= idle; 
                    end if;
                when buffer_input => 
                    if (counter_buffer_input = 90 or counter_buffer_input = 91 or counter_buffer_input = 92 or counter_buffer_input = 93 or counter_buffer_input = 94 or counter_buffer_input = 95) then 
                        shift_reg(counter_buffer_input - 90) <= data_in; 
                    end if;
                    -- if (counter_buffer_input = 95) then 
                    --     shift_reg <= shift_reg_initial;
                    -- end if;

                    if (counter_buffer_input < BUFFER_SIZE-1) then
                        if (finished_buffering_flag = '0') then 
                            input_state_reg                     	<= buffer_input; 
                            data_in_buffer(counter_buffer_input) 	<= data_in; 
                            counter_buffer_input                 	<= counter_buffer_input + 1;
                        end if; 
                    elsif (counter_buffer_input = BUFFER_SIZE-1) then 
                        data_in_buffer(counter_buffer_input) 	<= data_in; 
                        counter_buffer_input                 	<= counter_buffer_input + 1;
                        -- counter_buffer_input                 	<= 0;
                        finished_buffering_flag              	<= '1'; 
                        --get tail bits 
                        -- shift_reg                               <= data_in & data_in_buffer(BUFFER_SIZE-2) & data_in_buffer(BUFFER_SIZE-3) & data_in_buffer(BUFFER_SIZE-4) & data_in_buffer(BUFFER_SIZE-5) & data_in_buffer(BUFFER_SIZE-6); --take tail bits as last 6 bits from buffer
                        input_state_reg    	                    <= shifting; 
                        finished_tail_flag	                    <= '1';
                        counter_shift_and_output    <= counter_shift_and_output + 1;
                    end if;
				when shifting => 
                    if (finished_buffering_flag = '1') then 
                        if (counter_shift_and_output < BUFFER_SIZE) then 
                            input_state_reg            	<= shifting;
                            -- shift_reg                   <= data_in_buffer(counter_shift_and_output) & shift_reg(5 downto 1); 
                            shift_reg                   <= q_b(0) & shift_reg(5 downto 1); 
                            counter_shift_and_output    <= counter_shift_and_output + 1;
                            finished_outputting_flag    <= '0';
                        elsif (counter_shift_and_output = 96) then 
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
					if (counter_shift_and_output = 1) then 
						-- x_output_signal     	<= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5);
						output_state_reg		<= y; 
						flag					<= '1';					
					else 
						output_state_reg		<= idle;
					end if; 
				when x => 
						-- x_output_signal     	<= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(3) xor shift_reg(4) xor shift_reg(5);
						flag					<= '1';
					if (counter_shift_and_output <= BUFFER_SIZE) then 										
						output_state_reg		<= y;
					end if;
				when y => 
						-- y_output_signal         <= data_in_buffer(counter_shift_and_output) xor shift_reg(0) xor shift_reg(1) xor shift_reg(3) xor shift_reg(4);
						flag					<= '0';	
					if (counter_shift_and_output < BUFFER_SIZE and FEC_encoder_out_valid = '1') then 		  										
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

