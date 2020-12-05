--# vcom -reportprogress 300 -93 -work work D:/AUC/Semester9(Fall2020)/ASIC/repo/ASIC-Course/Project/Phase2/WiMax_tb.vhd 

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
            clk_50mhz                             : in    std_logic; 
            reset                 	              : in    std_logic; 
            en                 	                  : in    std_logic; 
            load               	                  : in    std_logic; 
            data_in                               : in    std_logic; 
            WiMax_out_valid                       : out   std_logic;
            data_out1                             : out   std_logic_vector(15 downto 0);
            data_out2                             : out   std_logic_vector(15 downto 0) 
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

    --alias signals 
    signal  rand_out_alias_signal                 : std_logic;
    signal  rand_valid_alias_signal               : std_logic;
    signal  fec_out_alias_signal                  : std_logic;
    signal  fec_valid_alias_signal                : std_logic;
    signal  int_out_alias_signal                  : std_logic;
    signal  int_valid_alias_signal                : std_logic;
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
        wait for 1.5*CLK_50_PERIOD; --bec of 75 ns edge the next pos edge so make sure a pos edge came 
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
            i := 191;
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
        wait;
    end process;

    --------------------------------------------------------------Handshakes Verification-------------------------------------------------------------- 

    --Randomizer
    process 
        variable test_pass_randomizer: boolean := true;
        procedure checker_randomizer is 
            begin 
            for i in 95 downto 0 loop 
                if (rand_out_alias_signal /= OUTPUT_RANDOMIZER_VECTOR_CONST(i)) then 
                    report "Bit " & integer'image(i) & " is wrong, test failed" severity error; 
                    report "it is " & std_logic'image(rand_out_alias_signal) & " and it supposed to be: " & std_logic'image(OUTPUT_RANDOMIZER_VECTOR_CONST(i)) severity error;     
                    test_pass_randomizer := false;                                      
                end if;
            wait for CLK_50_PERIOD;
            end loop; 
        end checker_randomizer;
    begin 
        wait for 1 ns;
        wait until rand_valid_alias_signal = '1'; 
        wait for 5 ns;
        report "========================================================================================================";
        report "------------------------------------STARTED HANDSHAKES SELF CHECKER--------------------------";
        report "========================================================================================================";        
        report "-------------------Started handshake self checker for: Randomizer Block--------------------------";
        report "Randomizer stream 1: ";
        checker_randomizer;
        if (test_pass_randomizer = true) then 
            report "Randomizer stream 1 test passed successfully" ;
        end if;
        report "Randomizer stream 2: ";
        checker_randomizer;
        if (test_pass_randomizer = true) then 
            report "Randomizer stream 2 test passed successfully" ;
        end if;
        report "Randomizer stream 3: ";
        checker_randomizer;
        if (test_pass_randomizer = true) then 
            report "Randomizer stream 3 test passed successfully" ;
        end if;
        report "Randomizer stream 4: ";
        checker_randomizer;
        if (test_pass_randomizer = true) then 
            report "Randomizer stream 4 test passed successfully" ;
        end if;
        report "Randomizer stream 5: ";
        checker_randomizer;
        if (test_pass_randomizer = true) then 
            report "Randomizer stream 5 test passed successfully" ;
        end if;
        report "-------------------Finished handshake self checker for: Randomizer Block--------------------------";
        wait;
    end process;

    --FEC Enconder
    process 
        variable test_pass_fec_encoder: boolean := true;
        procedure fec_checker is 
        begin 
        for i in 191 downto 0 loop 
            if (fec_out_alias_signal /= INPUT_INTERLEAVER_VECTOR_CONST(i)) then 
                report "Bit " & integer'image(i) & " is wrong, test failed" severity error; 
                report "it is " & std_logic'image(fec_out_alias_signal) & " and it supposed to be: " & std_logic'image(INPUT_INTERLEAVER_VECTOR_CONST(i)) severity error;     
                test_pass_fec_encoder := false;                                      
            end if;
        wait for CLK_100_PERIOD;
        end loop; 
        end fec_checker;
    begin 
        wait for 1 ns;
        wait until fec_valid_alias_signal = '1'; 
        wait for 5 ns;
        report "-------------------Started handshake self checker for: FEC Encoder Block--------------------------";
        report "FEC stream 1: ";
        fec_checker;
        if (test_pass_fec_encoder = true) then 
            report "FEC Encoder stream 1 test passed successfully" ;
        end if;
        report "FEC stream 2: ";
        fec_checker;
        if (test_pass_fec_encoder = true) then 
            report "FEC Encoder stream 2 test passed successfully" ;
        end if;
        report "FEC stream 3: ";
        fec_checker;
        if (test_pass_fec_encoder = true) then 
            report "FEC Encoder stream 3 test passed successfully" ;
        end if;
        report "FEC stream 4: ";
        fec_checker;
        if (test_pass_fec_encoder = true) then 
            report "FEC Encoder stream 4 test passed successfully" ;
        end if;
        report "FEC stream 5: ";
        fec_checker;
        if (test_pass_fec_encoder = true) then 
            report "FEC Encoder stream 5 test passed successfully" ;
        end if;
        report "-------------------Finished handshake self checker for: FEC Encoder Block--------------------------";
        wait;
    end process;

    --Interleaver
    process 
        variable test_pass_interleaver: boolean := true;
        procedure interleaver_checker is 
        begin 
        for i in 191 downto 0 loop 
            if (int_out_alias_signal /= INPUT_MODULATION_VECTOR_CONST(i)) then 
                report "Bit " & integer'image(i) & " is wrong, test failed" severity error; 
                report "it is " & std_logic'image(int_out_alias_signal) & " and it supposed to be: " & std_logic'image(INPUT_MODULATION_VECTOR_CONST(i)) severity error;     
                test_pass_interleaver := false;                                      
            end if;
        wait for CLK_100_PERIOD;
        end loop;
        end interleaver_checker;
    begin 
        wait for 1 ns;
        wait until int_valid_alias_signal = '1'; 
        wait for 5 ns;
        report "-------------------Started handshake self checker for: Interleaver Block--------------------------";
        report "Interleaver stream 1: ";
        interleaver_checker;
        if (test_pass_interleaver = true) then 
            report "Interleaver stream 1 test passed successfully" ;
        end if;
        report "Interleaver stream 2: ";
        interleaver_checker;
        if (test_pass_interleaver = true) then 
            report "Interleaver stream 2 test passed successfully" ;
        end if;
        report "Interleaver stream 3: ";
        interleaver_checker;
        if (test_pass_interleaver = true) then 
            report "Interleaver stream 3 test passed successfully" ;
        end if;
        report "Interleaver stream 4: ";
        interleaver_checker;
        if (test_pass_interleaver = true) then 
            report "Interleaver stream 4 test passed successfully" ;
        end if;
        report "Interleaver stream 5: ";
        interleaver_checker;
        if (test_pass_interleaver = true) then 
            report "Interleaver stream 5 test passed successfully" ;
        end if;
        report "-------------------Finished handshake self checker for: Interleaver Block--------------------------";
        report "========================================================================================================";
        report "------------------------------------FINISHED HANDSHAKES SELF CHECKER--------------------------";
        report "========================================================================================================";
        wait;
    end process;

    --alias assignments 
    rand_out_alias_signal   <= <<signal .WiMax_tb.wm1.rand1.rand_out            : std_logic>>; 
    rand_valid_alias_signal <= <<signal .WiMax_tb.wm1.rand1.rand_out_valid      : std_logic>>; 
    fec_out_alias_signal    <= <<signal .WiMax_tb.wm1.fec_out                   : std_logic>>;  
    fec_valid_alias_signal  <= <<signal .WiMax_tb.wm1.FEC_encoder_out_valid_out : std_logic>>;
    int_out_alias_signal    <= <<signal .WiMax_tb.wm1.interleaver_out           : std_logic>>; 
    int_valid_alias_signal  <= <<signal .WiMax_tb.wm1.interleaver_out_valid     : std_logic>>;
------------------------------------------------------------------------------------------------------------------------------------------------------------------

end tb_arch;