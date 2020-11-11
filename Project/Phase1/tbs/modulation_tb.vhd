library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.Phase1_Package.all;

entity modulation_tb is
end modulation_tb;

architecture tb_arch of modulation_tb is
    component modulation
        port(
            clk_100mhz                            : in  std_logic; 
            reset                                 : in  std_logic; 
            interleaver_out_valid                 : in  std_logic; 
            data_in                               : in  std_logic; 
            modulation_out_valid                  : out std_logic; 
            output1, output2                      : out std_logic_vector(15 downto 0) 

        );
    end component;
    
    --signals 
    signal   clk_100                              : std_logic := '0'; 
    signal   reset                                : std_logic; 
    signal   en                                   : std_logic; 
    signal   test_in_vector                       : std_logic_vector(191 downto 0);
    signal   demodulation_vector                  : std_logic_vector(191 downto 0) := (others => '0');
    signal   test_in_bit                          : std_logic;
    signal   test_out1_bit                        : std_logic_vector(15 downto 0) ;
    signal   test_out2_bit                        : std_logic_vector(15 downto 0) ;
    signal   out_valid                            : std_logic;
    
    
begin 

    --instant 
    uut: modulation port map 
    (
        clk_100mhz              => clk_100, 
        reset                   => reset, 
        interleaver_out_valid   => en, 
        data_in                 => test_in_bit, 
        modulation_out_valid    => out_valid, 
        output1                 => test_out1_bit, 
        output2                 => test_out2_bit
    );  

    test_in_vector <= INPUT_MODULATION_VECTOR_CONST; 
    --clk process 
    clk_100 <= not clk_100 after CLK_100_HALF_PERIOD; 

    --serial input in 
    process  
    begin 
        reset   <= '1'; 
        en      <= '0';
        wait for CLK_100_PERIOD + 5 ns; 
        reset   <= '0';
        en      <= '1';
        fill_192_inputs_procedure (0, 191, test_in_vector, test_in_bit);
        en  <= '0';
        wait;
    end process; 

    --demodulation test 
    process 
    variable i : integer := 191;
    --demodulation for testing 
    procedure demodulation_procedure is 
        begin 
            while (i > 0) loop 
                if (test_out1_bit = ZeroPointSeven and test_out2_bit = ZeroPointSeven) then 
                    demodulation_vector(i)      <= '0';
                    demodulation_vector(i-1)    <= '0';
                elsif(test_out1_bit = NegativeZeroPointSeven and test_out2_bit = NegativeZeroPointSeven) then 
                    demodulation_vector(i)      <= '1';
                    demodulation_vector(i-1)    <= '1';
                elsif(test_out1_bit = NegativeZeroPointSeven and test_out2_bit = ZeroPointSeven) then 
                    demodulation_vector(i)      <= '1';
                    demodulation_vector(i-1)    <= '0';
                elsif(test_out1_bit = ZeroPointSeven and test_out2_bit = NegativeZeroPointSeven) then
                    demodulation_vector(i)      <= '0';
                    demodulation_vector(i-1)    <= '1';
                end if;
                i := i - 2; 
                wait for 2 * CLK_100_PERIOD;
            end loop;
        end demodulation_procedure;
    begin         
        wait until out_valid = '1'; 
        wait for 2 ns; 
        report START_SIMULATION_MSG;
        report "Starting Demodulation of modulated output: " severity note;
        demodulation_procedure;
        report "Demodulation finished. " severity note;
        assert demodulation_vector /= INPUT_MODULATION_VECTOR_CONST
            report "Demodulated vector is equal to the input one, test succeeded" severity note; 
            assert demodulation_vector = INPUT_MODULATION_VECTOR_CONST
                report "Demodulated vector is not equal to the input one, test failed" severity error; 
        report END_SIMULATION_MSG;
        wait;
    end process;

end tb_arch;