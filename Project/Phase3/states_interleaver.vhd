library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity states_interleaver is 
    port(
        clk_100mhz                            : in    std_logic; 
        reset, FEC_encoder_out_valid          : in    std_logic; 
        data_in                               : in    std_logic; 
        interleaver_out_valid                 : out   std_logic; 
        data_out                              : out   std_logic
    );
end states_interleaver;

architecture states_interleaver_arch of states_interleaver is
    --constants 
    constant BUFFER_SIZE                      : integer := 192;
    constant BUFFER_SIZE2                     : integer := 384;
    --signals 
    signal   data_in_buffer                   : std_logic_vector(BUFFER_SIZE-1 downto 0);
    signal   counter                          : unsigned(7 downto 0);
    signal   counter_out                      : integer;
    signal   counter_kmod16                   : unsigned(3 downto 0);
    signal   mk_pos                           : integer; 
    signal   finished_buffering_flag          : std_logic;
    signal   finished_outputting_flag         : std_logic;
    signal   PingPong_flag                    : std_logic;

    --state machine 
    type input_state_type is (idle, buffer_first_input, PingPong_state); 
    signal state_reg   : input_state_type;

    --component 
    component Int_RAM_2port is 
        PORT
        (
            address_a	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
            address_b	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
            clock		: IN STD_LOGIC  := '1';
            data_a		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
            data_b		: IN STD_LOGIC_VECTOR (0 DOWNTO 0);
            wren_a		: IN STD_LOGIC  := '0';
            wren_b		: IN STD_LOGIC  := '0';
            q_a		    : OUT STD_LOGIC_VECTOR (0 DOWNTO 0);
            q_b		    : OUT STD_LOGIC_VECTOR (0 DOWNTO 0)
        );

    end component Int_RAM_2port;
     
    --ram signals 
    signal address_a	:  STD_LOGIC_VECTOR (8 DOWNTO 0);
    signal address_b	:  STD_LOGIC_VECTOR (8 DOWNTO 0);
    signal clock		:  STD_LOGIC  := '1';
    signal data_a		:  STD_LOGIC_VECTOR (0 DOWNTO 0);
    signal data_b		:  STD_LOGIC_VECTOR (0 DOWNTO 0);
    signal wren_a		:  STD_LOGIC  := '0';
    signal wren_b		:  STD_LOGIC  := '0';
    signal q_a		    :  STD_LOGIC_VECTOR (0 DOWNTO 0);
    signal q_b		    :  STD_LOGIC_VECTOR (0 DOWNTO 0);

begin 

    --instant 
    ram1: Int_RAM_2port port map
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
    clock	    <= clk_100mhz;	 
    address_a   <= std_logic_vector(to_unsigned(mk_pos, address_a'length)); 
    address_b   <= std_logic_vector(to_unsigned(counter_out, address_b'length));
    data_a(0)   <= data_in;
    wren_a      <= FEC_encoder_out_valid; 
    data_out    <= q_b(0);


    --continous 
    mk_pos  <= ( (12 * to_integer(counter_kmod16)) + (to_integer(counter) / 16) ) when (PingPong_flag = '0') else
               ( ((12 * to_integer(counter_kmod16)) + (to_integer(counter) / 16) ) + 192) when (PingPong_flag = '1') else
                0; 
    
    
    process(clk_100mhz, reset) begin 
        if (reset = '1') then 
            counter_kmod16              <= (others => '0');
            counter                     <= (others => '0');
            data_in_buffer              <= (others => '0'); 
            counter_out                 <=  0; 
            interleaver_out_valid       <= '0';
            PingPong_flag               <= '0';
            state_reg                   <= idle;
        elsif(rising_edge(clk_100mhz)) then 
            case state_reg is 
                when idle =>      
                    interleaver_out_valid   <= '0';               
                    if (FEC_encoder_out_valid = '1') then      
                        if (counter < BUFFER_SIZE-1) then 
                            counter_kmod16          <= counter_kmod16 + 1;
                            counter                 <= counter + 1;
                        end if; 
                        state_reg   <= buffer_first_input;
                    else
                        state_reg   <= idle; 
                    end if;
                when buffer_first_input => 
                    if (counter < BUFFER_SIZE-1) then 
                        counter_kmod16          <= counter_kmod16 + 1;
                        counter                 <= counter + 1;
                        state_reg               <= buffer_first_input;
                    else 
                        counter                 <= "00000000";
                        counter_kmod16          <= "0000";
                        state_reg               <= PingPong_state;
                        counter_out             <= counter_out + 1;
                        interleaver_out_valid   <= '1';
                        PingPong_flag   <= '1';
                    end if; 
                when PingPong_state =>
                    if (counter = BUFFER_SIZE-1) then 
                        PingPong_flag           <= not PingPong_flag;
                        counter                 <= "00000000";
                        counter_kmod16          <= "0000";
                    end if;
                    if(counter_out >= 0 and counter_out < BUFFER_SIZE2-1) then 
                        counter_out             <= counter_out + 1;
                        state_reg               <= PingPong_state;
                        interleaver_out_valid   <= '1';
                        if (counter < BUFFER_SIZE-1) then
                            counter_kmod16          <= counter_kmod16 + 1;
                            counter                 <= counter + 1;
                        end if;
                    else 
                        counter_out             <= 0;
                        state_reg               <= PingPong_state;
                        counter_kmod16          <= counter_kmod16 + 1;
                        counter                 <= counter + 1;
                    end if;
                    if ( (FEC_encoder_out_valid = '0') and (counter_out = 191 or counter_out = 383) ) then 
                        counter_out             <= 0;
                        state_reg               <= idle;
                        -- interleaver_out_valid   <= '0';
                    end if;
            end case;
        end if;
    end process;
end states_interleaver_arch; 