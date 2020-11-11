library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RequestResolverWithLoops is 
    generic (NUMBER_OF_FLOORS: integer := 4);
    port
    (
        clk, reset, en               : in  std_logic; 
        floor                        : in std_logic_vector(NUMBER_OF_FLOORS - 1 downto 0);
        a, b                         : in std_logic_vector(NUMBER_OF_FLOORS downto 0);
        req                          : out  std_logic_vector(NUMBER_OF_FLOORS - 1 downto 0)    

    ); 
end RequestResolverWithLoops;

architecture RequestResolverWithLoops_arch of RequestResolverWithLoops is

    type    state_type is (idle, up_state, down_state);
    signal  state_reg, state_next                        : state_type; 

    --protection signals 
    signal  clk_signal, reset_signal, en_signal          : std_logic; 
    signal  floor_signal                                 : std_logic_vector(NUMBER_OF_FLOORS - 1 downto 0);
    signal  a_signal, b_signal                           : std_logic_vector(NUMBER_OF_FLOORS downto 0);
    signal  req_signal                                   : std_logic_vector(NUMBER_OF_FLOORS - 1 downto 0); 
    signal  counter                                      : unsigned(NUMBER_OF_FLOORS - 1 downto 0); 
    
begin

    --continious assignments for protection signals 
    clk_signal      <= clk;
    reset_signal    <= reset; 
    en_signal       <= en;
    floor_signal    <= floor; 
    req             <= req_signal;     


    process (clk_signal, reset_signal) begin 
        if (reset_signal = '0') then 

            a_signal        <= (others => '0');
            b_signal        <= (others => '0');
            counter         <= (others => '0'); 
            state_reg       <= idle; 
        elsif (rising_edge(clk_signal)) then 
            if (en_signal = '1') then 
                a_signal   <= a_signal or a;
                b_signal   <= b_signal or b;
                state_reg  <= state_next;

                if (floor_signal = req_signal) then 
                    a_signal(to_integer(unsigned(floor_signal))) <= '0'; 
                    b_signal(to_integer(unsigned(floor_signal))) <= '0'; 
                end if; 
            end if; 
        end if; 
    end process;

    process (state_reg, a_signal, b_signal) begin 

        if (reset_signal = '0') then 
            req_signal      <= (others => '0');
        elsif (en_signal = '1') then 

            case state_reg is 
                when idle => 
                    if (a_signal = (a_signal'range=>'0') and b_signal = (b_signal'range=>'0')) then 
                        state_next <= idle; 
                    else 
                        for i in NUMBER_OF_FLOORS downto 0 loop
                            if ( (a_signal(i) = '1') or (b_signal(i) = '1')) then 
                                req_signal <= std_logic_vector(to_unsigned(i, req_signal'length));
                                if (std_logic_vector(to_unsigned(i, floor_signal'length)) >= floor_signal) then 
                                    state_next <= up_state; 
                                else   
                                    state_next <= down_state; 
                                end if;
                            end if;
                        end loop;
                    end if; 

                when up_state => 
                    --make initilaize state is down, else go to idle or up, as vhdl takes last assignment in the process 
                    state_next <= down_state; 
                    if (a_signal = (a_signal'range=>'0') and b_signal = (b_signal'range=>'0')) then 
                            state_next <= idle; 
                    else 
                        for i in NUMBER_OF_FLOORS downto 0 loop
                            if ( (a_signal(i) = '1') or (b_signal(i) = '1')) then 
                                if (std_logic_vector(to_unsigned(i, floor_signal'length)) >= floor_signal) then 
                                    req_signal <= std_logic_vector(to_unsigned(i, req_signal'length));
                                    state_next <= up_state;  
                                end if;
                            end if;
                        end loop;
                    end if; 


                when down_state => 
                    --make initilaize state is up, else go to idle or down, as vhdl takes last assignment in the process  
                    state_next <= up_state;           
                    if (a_signal = (a_signal'range=>'0') and b_signal = (b_signal'range=>'0')) then 
                            state_next <= idle; 
                    else 
                        for i in 0 to NUMBER_OF_FLOORS loop
                            if ( (a_signal(i) = '1') or (b_signal(i) = '1')) then 
                                if (std_logic_vector(to_unsigned(i, floor_signal'length)) <= floor_signal) then 
                                    req_signal <= std_logic_vector(to_unsigned(i, req_signal'length));
                                    state_next <= down_state; 
                                end if;
                            end if;
                        end loop;
                    end if;             
            end case; 
        end if; 
    end process; 
end RequestResolverWithLoops_arch;