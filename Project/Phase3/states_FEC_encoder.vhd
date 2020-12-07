library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;


entity states_FEC_encoder is 
    port(
        clk_50mhz, clk_100mhz                 	: in    std_logic; 
        reset, rand_out_valid                 	: in    std_logic; 
        data_in                               	: in    std_logic; 
        FEC_encoder_out_valid_out             	: out   std_logic; 
        data_out                              	: out   std_logic

    );
end states_FEC_encoder;

architecture states_FEC_encoder_arch of states_FEC_encoder is
    --constant 
    constant BUFFER_SIZE                      	: integer := 96; 
    constant BUFFER_SIZE2                     	: integer := 192; 
    --signals 	
    signal   shift_reg                        	: std_logic_vector(5 downto 0); 
    signal   shift_reg2                	        : std_logic_vector(5 downto 0); 
    signal   counter_buffer_input             	: integer; 
    signal   counter_shift_and_output         	: integer; 
	signal   finished_tail_flag          	  	: std_logic;
    signal   FEC_encoder_out_valid              : std_logic; 
    signal   PingPong_flag          	  	    : std_logic;

    --state machines 
    type input_state_type is (idle, buffer_first_input, PingPong_state); 
	signal input_state_reg    : input_state_type; 
	type output_state_type is (idle, x, y); 
    signal output_state_reg   : output_state_type;
    
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
    address_a   <= std_logic_vector(to_unsigned(counter_buffer_input, address_a'length)) when PingPong_flag = '0' else std_logic_vector(to_unsigned(counter_buffer_input + 96, address_a'length)); 
    address_b   <= std_logic_vector(to_unsigned(counter_shift_and_output, address_b'length));
    data_a(0)   <= data_in; 
    wren_a      <= rand_out_valid; 
    FEC_encoder_out_valid_out <= FEC_encoder_out_valid; 

    data_out  <= (q_b(0) xor shift_reg(0)   xor shift_reg(3)    xor shift_reg(4)    xor shift_reg(5))       when (PingPong_flag = '1' and ((output_state_reg = idle and finished_tail_flag = '1') or output_state_reg = x)) else 
                 (q_b(0) xor shift_reg(0)   xor shift_reg(1)    xor shift_reg(3)    xor shift_reg(4))       when (PingPong_flag = '1' and output_state_reg = y) else 
                 (q_b(0) xor shift_reg2(0)  xor shift_reg2(3)   xor shift_reg2(4)   xor shift_reg2(5))      when (PingPong_flag = '0' and ((output_state_reg = idle and finished_tail_flag = '1') or output_state_reg = x)) else
                 (q_b(0) xor shift_reg2(0)  xor shift_reg2(1)   xor shift_reg2(3)   xor shift_reg2(4))      when (PingPong_flag = '0' and output_state_reg = y) else 
                 '0'; 


    FEC_encoder_out_valid	<= '1' when (input_state_reg = PingPong_state) else '0';	
    
                                             
    -----------------------------------------------------------------------------state machine 1 -----------------------------------------------------------------------------
    process (reset, clk_50mhz) begin 
        if (reset = '1') then 
            counter_buffer_input        <= 0;
            shift_reg                   <= (others => '0');
            shift_reg2                  <= (others => '0');
            counter_shift_and_output    <= 0;
            finished_tail_flag			<= '0';
            PingPong_flag               <= '0';
            input_state_reg             <= idle;
        elsif (rising_edge(clk_50mhz)) then 
            input_state_reg<=input_state_reg;
            case input_state_reg is 
                when idle => 
                    if (rand_out_valid = '1') then 
                        counter_buffer_input                 <= counter_buffer_input + 1;
                        input_state_reg                      <= buffer_first_input; 
                    else 
                        input_state_reg    <= idle; 
                    end if;
                when buffer_first_input => 
                    if (counter_buffer_input = 90 or counter_buffer_input = 91 or counter_buffer_input = 92 or counter_buffer_input = 93 or counter_buffer_input = 94 or counter_buffer_input = 95) then 
                        shift_reg(counter_buffer_input - 90) <= data_in; 
                    end if;

                    if (counter_buffer_input < BUFFER_SIZE-1) then
                        input_state_reg                     	<= buffer_first_input; 
                        counter_buffer_input                 	<= counter_buffer_input + 1;
                    elsif (counter_buffer_input = BUFFER_SIZE-1) then 
                        counter_buffer_input                 	<= 0;
                        --get tail bits                         
                        input_state_reg    	                    <= PingPong_state; 
                        finished_tail_flag	                    <= '1';
                        counter_shift_and_output                <= counter_shift_and_output + 1;
                        PingPong_flag                           <= '1';
                    end if;
                when PingPong_state => 
                    -- tail bits 
                    if (counter_buffer_input = 90 or counter_buffer_input = 91 or counter_buffer_input = 92 or counter_buffer_input = 93 or counter_buffer_input = 94 or counter_buffer_input = 95) then 
                        if (PingPong_flag = '0') then 
                            shift_reg (counter_buffer_input - 90) <= data_in; 
                        else
                            shift_reg2(counter_buffer_input - 90) <= data_in; 
                        end if;
                    end if;

                    if (counter_shift_and_output < BUFFER_SIZE and PingPong_flag = '1') then 
                        input_state_reg            	<= PingPong_state;
                        shift_reg                   <= q_b(0) & shift_reg(5 downto 1); 
                        counter_shift_and_output    <= counter_shift_and_output + 1;
                        if (counter_buffer_input < BUFFER_SIZE-1) then 
                            counter_buffer_input    <= counter_buffer_input + 1;
                        end if;

                    
                    elsif((counter_shift_and_output >= BUFFER_SIZE and counter_shift_and_output < BUFFER_SIZE2) and PingPong_flag = '0') then 
                        input_state_reg            	<= PingPong_state;
                        shift_reg2                  <= q_b(0) & shift_reg2(5 downto 1); 
                        counter_shift_and_output    <= counter_shift_and_output + 1;
                        if (counter_buffer_input < BUFFER_SIZE-1) then 
                            counter_buffer_input    <= counter_buffer_input + 1;
                        end if;
                    elsif (counter_shift_and_output = BUFFER_SIZE2) then 
                        input_state_reg            	<= PingPong_state;
                        counter_shift_and_output    <= 0; 
                        counter_buffer_input        <= counter_buffer_input + 1;
                    end if;

                    --go to idle 
                    if (rand_out_valid = '0' and (counter_shift_and_output = 96 or counter_shift_and_output = 192)) then 
                        counter_shift_and_output    <= 0;  
                        input_state_reg            	<= idle;                              
                    end if;

                    if (counter_buffer_input = BUFFER_SIZE-1) then 
                        PingPong_flag   <= not PingPong_flag;   
                        counter_buffer_input    <= 0; 
                        if (counter_shift_and_output < BUFFER_SIZE2-1) then      
                            counter_shift_and_output    <= counter_shift_and_output + 1;
                        else
                            counter_shift_and_output <= 0 ;
                        end if;
                    end if;

                    if(counter_shift_and_output = 191) then 
                        counter_shift_and_output <= 0;
                    end if;
            end case;
        end if;
    end process;

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------



-----------------------------------------------------------------------------state machine 2 -----------------------------------------------------------------------------
	process (clk_100mhz, reset) begin 
	if (reset = '1') then 
        output_state_reg   <= idle;                     
	elsif(rising_edge(clk_100mhz)) then 
        if (finished_tail_flag = '1') then
			case output_state_reg is 
				when idle => 
					if (counter_shift_and_output = 1) then 
                        output_state_reg		<= y; 
                    else 
                        output_state_reg		<= idle;
					end if; 
				when x => 
					if (counter_shift_and_output <= BUFFER_SIZE2) then 										
                        output_state_reg		<= y;
                    else 
                        output_state_reg		<= x;
					end if;
                when y => 
                    if (FEC_encoder_out_valid = '0' and (counter_shift_and_output = BUFFER_SIZE+1 or counter_shift_and_output = BUFFER_SIZE2+1)) then 
                        output_state_reg		<= idle;
                    else 
                        output_state_reg		<= y;					
					end if;
					if (counter_shift_and_output < BUFFER_SIZE2 and FEC_encoder_out_valid = '1') then 		  										
                        output_state_reg		<= x;
                    else 
                        output_state_reg		<= y;
                    end if;
                    
			end case;
		end if; 
	end if;
	end process; 
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

end states_FEC_encoder_arch;

