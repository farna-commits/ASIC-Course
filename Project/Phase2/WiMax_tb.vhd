library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
use work.Phase1_Package.all;

entity WiMax_tb is 
end WiMax_tb;

architecture tb_arch of WiMax_tb is

    --component 
    component WiMax is 
        port(
            clk_50mhz                           	: in    std_logic; 
            reset                 	                : in    std_logic; 
            en                 	                    : in    std_logic; 
            load               	                    : in    std_logic; 
            data_in                               	: in    std_logic; 
            WiMax_out_valid                         : out   std_logic;
            data_out1                              	: out   std_logic_vector(15 downto 0);
            data_out2                              	: out   std_logic_vector(15 downto 0) 
        );
    end component;

    signal   clk_50                               : std_logic := '0'; 
    signal   reset                                : std_logic; 
    signal   en                                   : std_logic; 
    signal   load                                 : std_logic; 
    signal   test_in_vector                       : std_logic_vector(95 downto 0) := INPUT_RANDOMIZER_VECTOR_CONST;
    signal   demodulation_vector                  : std_logic_vector(191 downto 0) := (others => '0');
    signal   test_in_bit                          : std_logic;
    signal   test_out1_bit                        : std_logic_vector(15 downto 0) ;
    signal   test_out2_bit                        : std_logic_vector(15 downto 0) ;
    signal   out_valid                            : std_logic;
    signal   xfkd                                 : std_logic := '0';
begin 
    --instantiations 
    wm1: WiMax port map 
    (
        clk_50mhz       => clk_50,
        reset           => reset,            
        en              => en,    
        load            => load,    	   
        data_in         => test_in_bit,        
        WiMax_out_valid => out_valid,       
        data_out1       => test_out1_bit,           
        data_out2       => test_out2_bit         
    );

    --clk process 
    clk_50 <= not clk_50 after CLK_50_HALF_PERIOD; 

    --assigning input bits from the vector 
    process begin 
        reset <= '1'; --initialize values 
        en    <= '0';
        wait for 3*CLK_50_HALF_PERIOD;     --make sure a pos edge came before changing the reset 
        reset <= '0'; 
        wait for 2*CLK_50_HALF_PERIOD;
        load <= '1';    --take seed into module 
        wait for CLK_50_PERIOD; --bec of 75 ns edge the next pos edge so make sure a pos edge came 
        load <= '0'; 
        en <= '1'; 
        --Inputting steams 
        fill_96_inputs_procedure(0, 95, test_in_vector, test_in_bit);
        fill_96_inputs_procedure(0, 95, test_in_vector, test_in_bit);
        fill_96_inputs_procedure(0, 95, test_in_vector, test_in_bit);
        fill_96_inputs_procedure(0, 95, test_in_vector, test_in_bit);
        fill_96_inputs_procedure(0, 95, test_in_vector, test_in_bit);        
        en  <= '0';
        wait; --makes process executes once 
    end process;

    --demodulation test 
    process 
    variable i : integer := 191;
    --demodulation for testing 
    procedure demodulation_procedure is 
        begin 
            demodulation_vector <= (others => '0');
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
        report "--------Demodulating (5) output streams-------------" severity note;

        report "Starting Demodulation of modulated output 1 stream: " severity note;
        demodulation_procedure;
        report "Demodulation finished. " severity note;
        assert demodulation_vector /= INPUT_MODULATION_VECTOR_CONST
            report "Demodulated vector is equal to the input one, test succeeded on stream 1" severity note; 
            assert demodulation_vector = INPUT_MODULATION_VECTOR_CONST
                report "Demodulated vector is not equal to input 1 stream vector, test failed" severity error;
                
        report "Starting Demodulation of modulated output 2 stream: " severity note;
        demodulation_procedure;
        report "Demodulation finished. " severity note;
        assert demodulation_vector /= INPUT_MODULATION_VECTOR_CONST
            report "Demodulated vector is equal to the input one, test succeeded on stream 2" severity note; 
            assert demodulation_vector = INPUT_MODULATION_VECTOR_CONST
                report "Demodulated vector is not equal to input 2 stream vector, test failed" severity error;      
                
        report "Starting Demodulation of modulated output 3 stream: " severity note;
        demodulation_procedure;
        report "Demodulation finished. " severity note;
        assert demodulation_vector /= INPUT_MODULATION_VECTOR_CONST
            report "Demodulated vector is equal to the input one, test succeeded on stream 3" severity note; 
            assert demodulation_vector = INPUT_MODULATION_VECTOR_CONST
                report "Demodulated vector is not equal to input 3 stream vector, test failed" severity error;   

        report "Starting Demodulation of modulated output 4 stream: " severity note;
        demodulation_procedure;
        report "Demodulation finished. " severity note;
        assert demodulation_vector /= INPUT_MODULATION_VECTOR_CONST
            report "Demodulated vector is equal to the input one, test succeeded on stream 4" severity note; 
            assert demodulation_vector = INPUT_MODULATION_VECTOR_CONST
                report "Demodulated vector is not equal to input 4 stream vector, test failed" severity error;   

        report "Starting Demodulation of modulated output 5 stream: " severity note;
        demodulation_procedure;
        report "Demodulation finished. " severity note;
        assert demodulation_vector /= INPUT_MODULATION_VECTOR_CONST
            report "Demodulated vector is equal to the input one, test succeeded on stream 5" severity note; 
            assert demodulation_vector = INPUT_MODULATION_VECTOR_CONST
                report "Demodulated vector is not equal to input 5 stream vector, test failed" severity error;   

        report END_SIMULATION_MSG;
        xfkd <= '1';
        wait;
    end process;
end tb_arch;