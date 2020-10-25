library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.math_real.all;


entity elevator_ctrl_tb is 
end elevator_ctrl_tb;

architecture tb_arch of elevator_ctrl_tb is

    --constants 
    constant CLK_PERIOD                             : Time := 20 ns;  
    constant CLK_HALF_PERIOD                        : Time := CLK_PERIOD / 2; 
    constant NUMBER_OF_FLOORS                       : integer := 9; 
    --signals 
    signal clk                                      : std_logic := '0';   --start clk with 0 
    signal reset, en                                : std_logic;
    signal inside_buttons, outside_buttons          : std_logic_vector(NUMBER_OF_FLOORS downto 0);
    signal up_signal, down_signal, door_open_signal : std_logic; 
    signal floor_signal                             : std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0); 
    signal floor_ssd_signal                         : std_logic_vector(6 downto 0);

    --component 
    component elevator_ctrl 
        generic (NUMBER_OF_FLOORS: integer);
        port
        (
            clk, reset, en                          : in  std_logic; 
            a, b                                    : in std_logic_vector(NUMBER_OF_FLOORS downto 0);
            up, down, door_open                     : out std_logic;
            floor                                   : out std_logic_vector(integer(ceil(log2(real(NUMBER_OF_FLOORS)))) - 1 downto 0); 
            floor_ssd                               : out std_logic_vector(6 downto 0)

        ); 
    
    end component; 
begin 

    --clock process 
    clk <= not clk after CLK_HALF_PERIOD;

    --instant 
    uut: elevator_ctrl  generic map(NUMBER_OF_FLOORS => NUMBER_OF_FLOORS)
                        port map (clk => clk, reset => reset, en => en,
                                  a => inside_buttons, b => outside_buttons, 
                                  up => up_signal, down => down_signal, door_open => door_open_signal, 
                                  floor => floor_signal, floor_ssd => floor_ssd_signal);

    --setting control signals 
    process begin 
        reset           <= '1'; 
        en              <= '0'; 
        inside_buttons  <= "0000000000";
        outside_buttons <= "0000000000";
        wait for (CLK_PERIOD * 5);
        reset           <= '0'; 
        en              <= '1';
        inside_buttons  <= "0000001000";    --Inside call to 3rd
        outside_buttons <= "0000100000";    --outside call to 5th at the same time
        wait for (CLK_PERIOD * 5);
        inside_buttons  <= "0000000000";    --remove finger from push button
        outside_buttons <= "0000000000";    --remove finger from push button
        wait for (CLK_PERIOD * 55);         
        outside_buttons <= "0000000010";    -- while going to 5th floor call to 1st 
        wait for (CLK_PERIOD * 5);
        outside_buttons <= "0000000000";    --remove finger from push button
        wait for (CLK_PERIOD * 70);
        outside_buttons <= "0000010000";    --outside call to 4th 
        wait for (CLK_PERIOD * 5);
        outside_buttons <= "0000000000";    --remove finger from push button
        wait for (CLK_PERIOD * 60);         --make sure it reached 4th 
        inside_buttons  <= "0000000010";    --inside call to 1st 
        wait for (CLK_PERIOD * 5);
        inside_buttons  <= "0000000000";    --remove finger from push button
        wait for (CLK_PERIOD * 30); 
        outside_buttons <= "0100000000";    --while going down to 1st call at 8th 
        wait for (CLK_PERIOD * 5);
        outside_buttons <= "0000000000";    --remove finger from push button
        wait for (CLK_PERIOD * 200);        --make sure there's enough time it went to 1st then 8th at last 
        wait; 
    end process; 
end tb_arch; 