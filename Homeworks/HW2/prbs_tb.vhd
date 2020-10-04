library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prbs_tb is
end prbs_tb;

architecture tb_arch of prbs_tb is
    component prbs
       generic (SEED_WIDTH : integer);
       port(
            clk, reset, en, load: in std_logic; 
            seed_in: in std_logic_vector(SEED_WIDTH-1 downto 0);
            dataIn: in std_logic;
            dataOut: out std_logic
       );
    end component;

    --constants 
    constant SEED_WIDTH: integer := 15; 
    constant SEED: std_logic_vector(SEED_WIDTH-1 downto 0) := "101010001110110"; 
    constant INPUT_VECTOR_CONST: std_logic_vector(95 downto 0):= x"ACBCD2114DAE1577C6DBF4C9"; 
    constant OUTPUT_VECTOR_CONST: std_logic_vector(95 downto 0):= x"558AC4A53A1724E163AC2BF9";
    constant CLK_HALF_PERIOD: Time:= 25 ns; 
    constant CLK_PERIOD: Time:= 2 * CLK_HALF_PERIOD; 

    --signals 
    signal clk: std_logic := '0';   --start clk with 0 
    signal reset, en, load: std_logic;  
    signal test_seed_in: std_logic_vector(SEED_WIDTH-1 downto 0); 
    signal test_dataIn, test_dataOut: std_logic; 
    signal input_vector, output_vector: std_logic_vector(95 downto 0);


begin 
    --instant 
    uut: prbs   generic map (SEED_WIDTH => SEED_WIDTH)
                port map (clk => clk, reset => reset, en => en, load => load,
                        seed_in => test_seed_in,
                        dataIn => test_dataIn, dataOut => test_dataOut);
    
                    
    --initilaize constants                         
    test_seed_in <= SEED; --set seed 
    input_vector <= INPUT_VECTOR_CONST; --set input test case 
    output_vector <= OUTPUT_VECTOR_CONST; --set output test case 

    --clock process 
    clk <= not clk after CLK_HALF_PERIOD;


    --assigning input bits from the vector 
    process begin 
        reset <= '0'; --initialize values 
        wait for CLK_HALF_PERIOD + 5 ns;     --make sure a pos edge came before changing the reset 
        reset <= '1'; 
        load <= '1';    --take seed into module 
        wait for CLK_PERIOD; --bec of 75 ns edge the next pos edge so make sure a pos edge came 
        load <= '0'; 
        en <= '1'; 

        for i in 95 downto 0 loop       --flipped loop because A is the first input in the word doc
            test_dataIn <= input_vector(i); 
            wait for CLK_PERIOD;                 --to take next input after next pos edge 
        end loop; 
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