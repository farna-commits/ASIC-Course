library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;

entity RequestResolver is 
    generic (NUMBER_OF_FLOORS: integer);
    port
    (
        clk, reset, en               : in  std_logic; 
        floor                        : in std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0);
        a, b                         : in std_logic_vector(NUMBER_OF_FLOORS downto 0);
        req                          : out  std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0)    

    ); 
end RequestResolver;

architecture RequestResolver_arch of RequestResolver is

    --protection signals 
    signal  clk_signal, reset_signal, en_signal          : std_logic; 
    signal  floor_signal                                 : std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0);
    signal  a_signal, b_signal                           : std_logic_vector(NUMBER_OF_FLOORS downto 0);
    signal  req_signal                                   : std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0); 
    signal  counter                                      : unsigned(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0); 
begin

    --continious assignments for protection signals 
    clk_signal      <= clk;
    reset_signal    <= reset; 
    en_signal       <= en;
    floor_signal    <= floor; 
    req             <= req_signal;     


    process (clk_signal, reset_signal) begin 
        if (reset_signal ='1') then 
            a_signal        <= (others => '0');
            b_signal        <= (others => '0');
            counter         <= (others => '0'); 
            req_signal      <= (others => '0');
        elsif (rising_edge(clk_signal)) then 
            if (en_signal = '1') then 

                a_signal   <= a_signal or a;
                b_signal   <= b_signal or b;

                if (counter = NUMBER_OF_FLOORS) then 
                    counter <= (others => '0');
                else 
                    counter <= counter + 1;
                end if;
                
                if ( (a_signal(to_integer(counter))='1') or b_signal(to_integer(counter)) = '1') then 
                    req_signal <= std_logic_vector(counter); 
                else 
                    req_signal <= req_signal; 
                end if; 

                if (floor_signal = req_signal) then 
                    a_signal(to_integer(counter)) <= '0';
                    b_signal(to_integer(counter)) <= '0';
                    
                end if; 

            end if; 
        end if; 
    end process;
end RequestResolver_arch;