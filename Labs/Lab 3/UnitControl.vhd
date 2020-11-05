library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UnitControl is 
    generic (NUMBER_OF_FLOORS: integer);
    port
    (
        clk, reset, en                                   : in  std_logic; 
        req                                              : in  std_logic_vector(NUMBER_OF_FLOORS - 1 downto 0);
        up, down, door_open                              : out std_logic;
        floor                                            : out std_logic_vector(NUMBER_OF_FLOORS - 1 downto 0) 

    ); 
end UnitControl;

architecture UnitControl_arch of UnitControl is
    type    state_type is (idle, up_state, down_state, door_state);

    constant NUMBER_OF_SECONDS_FLOOR_BITS                : integer   := 3; 
    constant NUMBER_OF_SECONDS_DOOR_BITS                 : integer   := 3; 

    --internal signals 
    signal  up_signal, down_signal, door_open_signal     : std_logic; 
    signal  state_reg, state_next                        : state_type; 
    signal  floor_signal                                 : std_logic_vector(NUMBER_OF_FLOORS -1  downto 0);
    signal  clk_div_counter                              : unsigned(27 downto 0); 
    signal  clk_div_counter_next                         : unsigned(27 downto 0); 
    signal  door_open_counter                            : unsigned(NUMBER_OF_SECONDS_DOOR_BITS-1 downto 0);
    signal  floor_to_floor_counter                       : unsigned(NUMBER_OF_SECONDS_FLOOR_BITS-1 downto 0);
    signal  door_open_counter_next                       : unsigned(NUMBER_OF_SECONDS_DOOR_BITS-1 downto 0);
    signal  floor_to_floor_counter_next                  : unsigned(NUMBER_OF_SECONDS_FLOOR_BITS-1 downto 0);

    --Constants 																						0010111110101111000010000000
    constant CLK_DIV_COUNTER_MAX                         : unsigned(27 downto 0):= "0010111110101111000010000000"; --this is 5, replace by 50M here (0010111110101111000010000000)
    constant DOOR_OPEN_COUNTER_MAX                       : unsigned(NUMBER_OF_SECONDS_DOOR_BITS-1 downto 0):= "011";    -- door opens and closes in 3s
    constant FLOOR_TO_FLOOR_COUNTER_MAX                  : unsigned(NUMBER_OF_SECONDS_FLOOR_BITS-1 downto 0):= "010";   -- time between 2 floors is 2s
begin

-------------------------------------------------clk divisions and counters-------------------------------------------------------
    --clk divider process
    process (clk, reset) begin 
        if (reset = '0') then 
            clk_div_counter         <= (others => '0');
        --increment a counter for every rising edge of the 50MHz clk
        elsif (rising_edge(clk)) then 
            if (en = '1') then 
                clk_div_counter <= clk_div_counter_next + 1;
                if (clk_div_counter = (CLK_DIV_COUNTER_MAX-1)) then
                    clk_div_counter <= (others => '0');
                end if;
            end if;
        end if; 
    end process;

    --Updating counter of the door and floor to floor counter
    process (clk_div_counter, reset, en) begin 

        if (reset = '0') then 
            door_open_counter <= (others => '0');
            floor_to_floor_counter <= (others => '0');
        elsif (en = '1') then 
            if ( (clk_div_counter = CLK_DIV_COUNTER_MAX-1) and ( (state_reg = up_state) or (state_reg = down_state)) ) then 
                floor_to_floor_counter  <= floor_to_floor_counter_next + 1;
            end if;
            if ( (clk_div_counter = CLK_DIV_COUNTER_MAX-1) and (state_reg = door_state ) ) then 
                door_open_counter  <= door_open_counter_next + 1;
            end if;

            if (door_open_counter = DOOR_OPEN_COUNTER_MAX) then 
                door_open_counter <= (others => '0');
            end if;

            if (floor_to_floor_counter = FLOOR_TO_FLOOR_COUNTER_MAX) then 
                floor_to_floor_counter <= (others => '0');
            end if;
        end if;
    end process; 


-------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------State Machine-----------------------------------------------------------
    --4 segment implementation: 

    --state register 
    process (clk, reset) begin 
        if (reset = '0') then 
            state_reg       <= idle; 
        elsif (rising_edge(clk)) then 
            if (en = '1') then 
                state_reg <= state_next; 
            end if; 
        end if;
    end process; 

    --next state logic
    process (floor_to_floor_counter, clk_div_counter, state_reg, req, floor_signal, door_open_counter) begin 
        
    
        --initialization unless another value was given for them underneeth 
        clk_div_counter_next <= clk_div_counter;
        floor_to_floor_counter_next <= floor_to_floor_counter; 
        door_open_counter_next <= door_open_counter;

        
        case state_reg is 

            when idle => 
                if (req > floor_signal) then 
                    clk_div_counter_next <= (others => '0');
                    floor_to_floor_counter_next <= (others => '0');
                    state_next <= up_state; 
                elsif (req < floor_signal) then 
                    clk_div_counter_next <= (others => '0');
                    floor_to_floor_counter_next <= (others => '0');
                    state_next <= down_state; 
                else 
                    state_next <= idle; 
                end if; 

            when up_state  =>
                if (req = floor_signal) then 
                    state_next <= door_state;
                else 
                    state_next <= up_state; 
                end if;
                
            when down_state =>
                if (req = floor_signal) then 
                    state_next <= door_state;
                    door_open_counter_next <= (others => '0');
                else 
                    state_next <= down_state; 
                end if;
            when door_state =>
                if (door_open_counter = DOOR_OPEN_COUNTER_MAX) then 
                    state_next <= idle; 
                else
                    state_next <= door_state; 
                end if; 
        end case;
    end process; 

    --states logic 
    process (reset, en, state_reg, floor_to_floor_counter) begin 
        
        if (reset = '0') then
            up_signal           <= '0'; 
            down_signal         <= '0';
            door_open_signal    <= '0';
            floor_signal        <= (others => '0'); 

        elsif (en = '1') then 
        

            case state_reg is 
                when idle =>
                    up_signal           <= '0'; 
                    down_signal         <= '0';
                    door_open_signal    <= '0';
                    floor_signal        <= floor_signal; 
                    
                when up_state => 
                    up_signal           <= '1'; 
                    down_signal         <= '0';
                    door_open_signal    <= '0';
                    if (floor_to_floor_counter = FLOOR_TO_FLOOR_COUNTER_MAX) then 
                        floor_signal        <= std_logic_vector(unsigned(floor_signal) + 1);
                    else 
                        floor_signal        <= floor_signal; 
                    end if; 

                when down_state => 
                    up_signal           <= '0'; 
                    down_signal         <= '1';
                    door_open_signal    <= '0';
                    if (floor_to_floor_counter = FLOOR_TO_FLOOR_COUNTER_MAX) then 
                        floor_signal        <= std_logic_vector(unsigned(floor_signal) - 1);
                    else 
                        floor_signal        <= floor_signal; 
                    end if; 

                when door_state => 
                    up_signal           <= '0'; 
                    down_signal         <= '0';
                    door_open_signal    <= '1';
                    floor_signal        <= floor_signal;
                when others => 
            end case; 
        end if; 
    end process; 

-------------------------------------------------------------------------------------------------------------------------------------    
    --continous assignments for outputs 
    up          <= up_signal; 
    down        <= down_signal; 
    door_open   <= door_open_signal; 
    floor       <= floor_signal; 
-------------------------------------------------------------------------------------------------------------------------------------    
end UnitControl_arch; 