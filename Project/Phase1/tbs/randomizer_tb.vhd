library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity randomizer_tb is
end randomizer_tb;

architecture tb_arch of randomizer_tb is
    component randomizer
       port(
            clk_50mhz, reset, rand_in_ready     : in  std_logic; 
            load                                : in  std_logic;
            rand_in                             : in  std_logic;
            rand_out                            : out std_logic;
            rand_out_valid                      : out std_logic
       );
    end component;

    --constants 
    constant SEED_WIDTH             : integer := 15; 
    constant INPUT_VECTOR_CONST     : std_logic_vector(95 downto 0):= x"ACBCD2114DAE1577C6DBF4C9"; 
    constant OUTPUT_VECTOR_CONST    : std_logic_vector(95 downto 0):= x"558AC4A53A1724E163AC2BF9";
    constant CLK_PERIOD             : Time:= 20 ns; 
    constant CLK_HALF_PERIOD        : Time:= CLK_PERIOD / 2; 

    --signals 
    signal clk                          : std_logic := '0';   --start clk with 0 
    signal reset, en, load              : std_logic;  
    signal test_dataIn, test_dataOut    : std_logic; 
    signal out_valid                    : std_logic;
    signal input_vector, output_vector  : std_logic_vector(95 downto 0);
    signal output_vector_sum            : std_logic_vector(95 downto 0) := (others => '0');


begin 
    --instant 
    uut: randomizer port map (clk_50mhz => clk, reset => reset, rand_in_ready => en, load => load,
                              rand_in => test_dataIn, rand_out => test_dataOut, rand_out_valid => out_valid);
    
                    
    --initilaize constants                         
    input_vector    <= INPUT_VECTOR_CONST; --set input test case 

    output_vector   <= OUTPUT_VECTOR_CONST; --set output test case 

    --clock process 
    clk <= not clk after CLK_HALF_PERIOD;

    --assigning input bits from the vector 
    process begin 
        reset <= '1'; --initialize values 
        en    <= '0';
        wait for CLK_HALF_PERIOD + 5 ns;     --make sure a pos edge came before changing the reset 
        reset <= '0'; 
        load <= '1';    --take seed into module 
        wait for CLK_PERIOD; --bec of 75 ns edge the next pos edge so make sure a pos edge came 
        load <= '0'; 
        en <= '1'; 

        for i in 95 downto 0 loop       --flipped loop because A is the first input in the word doc
            test_dataIn <= input_vector(i); 
            wait for CLK_PERIOD;                 --to take next input after next pos edge 
        end loop; 
        en  <= '0';
        wait; --makes process executes once 
    end process;

    --checking on output 
    --verifier
    process
    variable test_pass: boolean;
    begin
        wait on test_dataIn;    --wait for a change in the input
        wait for 10 ns;         --to give time between input and output 

        for i in 95 downto 0 loop
            output_vector_sum(i) <= test_dataOut; 
            if (test_dataOut = output_vector(i)) then   --compare output vector and module output 
                test_pass := true;
            else
                test_pass := false;
            end if;
            -- error reporting
            assert test_pass
            report "test failed."
            severity note;
            wait for CLK_PERIOD; 
        end loop;
        wait; 
    end process;

end tb_arch;