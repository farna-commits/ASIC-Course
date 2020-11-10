library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Phase1_Package.all;

entity fec_tb is
end fec_tb;

architecture tb_arch of fec_tb is
    component states_FEC_encoder
        port(
            clk_50mhz, clk_100mhz                 : in    std_logic; 
            reset, rand_out_valid                 : in    std_logic; 
            data_in                               : in    std_logic; 
            x_output, y_output                    : out   std_logic; 
            FEC_encoder_out_valid                 : out   std_logic; 
            data_out                              : out   std_logic

        );
    end component;

    --signals                 
    signal   clk_50                               : std_logic := '0'; 
    signal   clk_100                              : std_logic := '1'; 
    signal   reset                                : std_logic; 
    signal   en                                   : std_logic; 
    signal   test_in_vector                       : std_logic_vector(95 downto 0);
    signal   test_out_vector                      : std_logic_vector(191 downto 0) := (others => '0');
    signal   test_in_bit                          : std_logic;
    signal   test_out_bit                         : std_logic;
    signal   test_out_x                           : std_logic;
    signal   test_out_y                           : std_logic;
    signal   out_valid                            : std_logic;
    signal   flag                                 : std_logic := '0';

begin 

    --instant 
    uut: states_FEC_encoder port map (

        clk_50mhz               => clk_50, 
        clk_100mhz              => clk_100, 
        reset                   => reset, 
        rand_out_valid          => en, 
        data_in                 => test_in_bit, 
        x_output                => test_out_x, 
        y_output                => test_out_y, 
        FEC_encoder_out_valid   => out_valid, 
        data_out                => test_out_bit
        );

    --clk process 
    clk_50 <= not clk_50 after CLK_50_HALF_PERIOD; 
    clk_100 <= not clk_100 after CLK_100_HALF_PERIOD; 

    test_in_vector  <= INPUT_FEC_VECTOR_CONST; 
    --serial input in 
    process begin 
        reset   <= '1'; 
        wait for CLK_50_PERIOD + 10 ns; 
        reset   <= '0';
        en      <= '1';
        fill_96_inputs_procedure(0, 95, test_in_vector, test_in_bit);
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
        assert test_out_vector /= INPUT_INTERLEAVER_VECTOR_CONST
            report "Output vector is equal to the output in the test case provided, test succeeded" severity note; 
        assert test_out_vector = INPUT_INTERLEAVER_VECTOR_CONST
            report "Output vector is not equal to the output in the test case provided, test failed" severity error;
        report END_SIMULATION_MSG;
        wait;
    end process;
end tb_arch; 