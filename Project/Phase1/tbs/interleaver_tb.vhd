library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Phase1_Package.all;
use work.Phase1_Package.all;

entity interleaver_tb is
end interleaver_tb;

architecture tb_arch of interleaver_tb is
    component interleaver
        port(
            clk_100mhz                            : in    std_logic; 
            reset, FEC_encoder_out_valid          : in    std_logic; 
            data_in                               : in    std_logic; 
            interleaver_out_valid                 : out   std_logic; 
            data_out                              : out   std_logic
        );
    end component;

    --signals 
    signal clk                                    : std_logic := '0'; 
    signal reset                                  : std_logic; 
    signal en                                     : std_logic; 
    signal test_in_vector                         : std_logic_vector(191 downto 0);
    signal test_out_vector                        : std_logic_vector(191 downto 0) := (others => '0');
    signal test_in_bit                            : std_logic;
    signal test_out_bit                           : std_logic;
    signal out_valid                              : std_logic;
    signal flag                                   : std_logic := '0';


begin 

    --instant 
    uut: interleaver port map (
        clk_100mhz              => clk, 
        reset                   => reset, 
        FEC_encoder_out_valid   => en, 
        data_in                 => test_in_bit, 
        interleaver_out_valid   => out_valid, 
        data_out                => test_out_bit
        );

    test_in_vector  <= INPUT_INTERLEAVER_VECTOR_CONST;
    --clk process 
    clk <= not clk after CLK_100_HALF_PERIOD; 

    --serial input in 
    process begin 
        reset   <= '1'; 
        wait for CLK_100_PERIOD + 5 ns; 
        reset   <= '0';
        en      <= '1';
        fill_192_inputs_procedure (0, 191, test_in_vector, test_in_bit);
        wait until flag = '1'; 
        en  <= '0';
        wait;
    end process; 

    --check output 
    process begin 
        wait until out_valid = '1'; 
        wait for 2 ns; 
        fill_192_outputs_procedure (0, 191, test_out_vector, test_out_bit);
        flag    <= '1';
        report START_SIMULATION_MSG;
        assert test_out_vector /= INPUT_MODULATION_VECTOR_CONST
            report "Output vector is equal to the output in the test case provided, test succeeded" severity note; 
        assert test_out_vector = INPUT_MODULATION_VECTOR_CONST
            report "Output vector is not equal to the output in the test case provided, test failed" severity error;
        report END_SIMULATION_MSG;
        wait;
    end process;

end tb_arch;