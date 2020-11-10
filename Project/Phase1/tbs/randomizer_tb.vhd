library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Phase1_Package.all;

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

    --signals 
    signal clk                                  : std_logic := '0';   --start clk with 0 
    signal reset, en, load                      : std_logic;  
    signal test_dataIn, test_dataOut            : std_logic; 
    signal out_valid                            : std_logic;
    signal input_vector, output_vector          : std_logic_vector(95 downto 0);
    signal output_vector_sum                    : std_logic_vector(95 downto 0) := (others => '0');


begin 
    --instant 
    uut: randomizer port map (
        clk_50mhz       => clk, 
        reset           => reset, 
        rand_in_ready   => en, 
        load            => load,                              
        rand_in         => test_dataIn, 
        rand_out        => test_dataOut, 
        rand_out_valid  => out_valid
        );
    
                    
    --initilaize constants                         
    input_vector    <= INPUT_RANDOMIZER_VECTOR_CONST; --set input test case 

    output_vector   <= OUTPUT_RANDOMIZER_VECTOR_CONST; --set output test case 

    --clock process 
    clk <= not clk after CLK_50_HALF_PERIOD;

    --assigning input bits from the vector 
    process begin 
        reset <= '1'; --initialize values 
        en    <= '0';
        wait for CLK_50_HALF_PERIOD + 5 ns;     --make sure a pos edge came before changing the reset 
        reset <= '0'; 
        load <= '1';    --take seed into module 
        wait for CLK_50_PERIOD; --bec of 75 ns edge the next pos edge so make sure a pos edge came 
        load <= '0'; 
        en <= '1'; 
        fill_96_inputs_procedure(0, 95, input_vector, test_dataIn);  --definition in package  
        en  <= '0';
        wait; --makes process executes once 
    end process;

    --checking on output 
    --verifier
    process
        variable test_pass: boolean;
        --procedure to check each output bit with the corresponding one in the constant vector 
        procedure test_output_procedure is 
            begin 
            for i in 95 downto 0 loop
                output_vector_sum(i) <= test_dataOut; 
                if (test_dataOut = output_vector(i)) then   --compare output vector and module output 
                    test_pass := true;
                else
                    test_pass := false;
                end if;
                -- error reporting
                assert test_pass = true 
                    report "test failed."
                    severity error;
                wait for CLK_50_PERIOD; 
            end loop;
        end test_output_procedure;
    begin
        wait on test_dataIn;    --wait for a change in the input
        wait for 10 ns;         --to give time between input and output 
        report START_SIMULATION_MSG;
        report "Starting verification: ";
        test_output_procedure; 
        assert test_pass = false 
            report "Test on 92 inputs passed successfully!"
            severity note; 
        report END_SIMULATION_MSG severity note;
        wait; 
    end process;
end tb_arch;