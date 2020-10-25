library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity elevator_ctrl is 
    generic (NUMBER_OF_FLOORS: integer := 9);
    port
    (
        clk, reset, en               : in  std_logic; 
        a, b                         : in std_logic_vector(NUMBER_OF_FLOORS downto 0);
        up, down, door_open          : out std_logic;
        floor                        : out std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0); 
        floor_ssd                    : out std_logic_vector(6 downto 0)

    ); 
end elevator_ctrl;

architecture elevator_ctrl_arch of elevator_ctrl is

    -- signals 
    signal  req_signal                                : std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0);  
    signal  floor_signal                              : std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1  downto 0);
    --components 
    component UnitControl
        generic (NUMBER_OF_FLOORS: integer);
        port
        (
            clk, reset, en               : in  std_logic; 
            req                          : in  std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0);
            up, down, door_open          : out std_logic;
            floor                        : out std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0) 

        ); 
    end component;

    component RequestResolverWithLoops
        generic (NUMBER_OF_FLOORS: integer);
        port
        (
            clk, reset, en               : in  std_logic; 
            floor                        : in std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0);
            a, b                         : in std_logic_vector(NUMBER_OF_FLOORS downto 0);
            req                          : out  std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0)    

        );  
    end component;
  
    component ssd
        port(
            bcd: in std_logic_vector(3 downto 0);
            ssdOut: out std_logic_vector(6 downto 0)
        );
    end component; 
begin

    floor <= floor_signal; 

    --Instants 
    UC1: UnitControl    generic map(NUMBER_OF_FLOORS => NUMBER_OF_FLOORS)
                        port map(clk => clk, reset => reset, en => en,
                                 req => req_signal,
                                 up => up, down => down, door_open => door_open,
                                 floor => floor_signal); 

    RR1: RequestResolverWithLoops    generic map(NUMBER_OF_FLOORS => NUMBER_OF_FLOORS)
                                     port map(clk => clk, reset => reset, en => en,
                                              req => req_signal,
                                              a => a, b => b, 
                                              floor => floor_signal);

    ssd1:   ssd port map(bcd => floor_signal, ssdOut => floor_ssd);

end elevator_ctrl_arch; 