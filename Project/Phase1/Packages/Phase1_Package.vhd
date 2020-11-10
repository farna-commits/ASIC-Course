library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

package Phase1_Package is 
--=============================================================================================================================================
------------------------------------------------------------------constants------------------------------------------------------------------ 
--=============================================================================================================================================
    --Shared
    constant CLK_50_PERIOD                      : Time:= 20 ns; 
    constant CLK_50_HALF_PERIOD                 : Time:= CLK_50_PERIOD / 2; 
    constant CLK_100_PERIOD                     : Time:= 10 ns; 
    constant CLK_100_HALF_PERIOD                : Time:= CLK_100_PERIOD / 2; 
    constant START_SIMULATION_MSG               : string := "================Simulation started================";
    constant END_SIMULATION_MSG                 : string := "================Simulation finished=============="; 
    --Randomizer
    constant INPUT_RANDOMIZER_VECTOR_CONST      : std_logic_vector(95 downto 0)  := x"ACBCD2114DAE1577C6DBF4C9"; 
    constant OUTPUT_RANDOMIZER_VECTOR_CONST     : std_logic_vector(95 downto 0)  := x"558AC4A53A1724E163AC2BF9";
    --FEC Encoder
    constant INPUT_FEC_VECTOR_CONST             : std_logic_vector(95 downto 0)  := x"558AC4A53A1724E163AC2BF9";
    --Interleaver
    constant INPUT_INTERLEAVER_VECTOR_CONST     : std_logic_vector(191 downto 0) := x"2833E48D392026D5B6DC5E4AF47ADD29494B6C89151348CA";
    --Modulation 
    constant ZeroPointSeven                     : std_logic_vector(15 downto 0)  := "0101101001111111";
    constant NegativeZeroPointSeven             : std_logic_vector(15 downto 0)  := "1010010110000001";
    constant INPUT_MODULATION_VECTOR_CONST      : std_logic_vector(191 downto 0) := x"4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E";
--=============================================================================================================================================
--=============================================================================================================================================    
--=============================================================================================================================================


--=============================================================================================================================================
------------------------------------------------------------------Functions & Procedures------------------------------------------------------ 
--=============================================================================================================================================
    -- procedures 
    --fill input 
    procedure fill_96_inputs_procedure  (start, endd : in integer; input_vector : std_logic_vector(95 downto 0); signal test_data_bit : out std_logic); 
    procedure fill_192_inputs_procedure (start, endd : in integer; input_vector : std_logic_vector(191 downto 0); signal test_data_bit : out std_logic); 
--=============================================================================================================================================
--=============================================================================================================================================    
--=============================================================================================================================================   
end package Phase1_Package;

package body Phase1_Package is 
    --procedures
    --fill input 
    procedure fill_96_inputs_procedure (start, endd : in integer; input_vector : std_logic_vector(95 downto 0); signal test_data_bit : out std_logic) is 
        begin 
            for i in endd downto start loop       --flipped loop because A is the first input in the word doc
                test_data_bit <= input_vector(i); 
                wait for CLK_50_PERIOD;                 --to take next input after next pos edge 
            end loop; 
        end fill_96_inputs_procedure;
    
    procedure fill_192_inputs_procedure (start, endd : in integer; input_vector : std_logic_vector(191 downto 0); signal test_data_bit : out std_logic) is 
        begin 
            for i in endd downto start loop 
                test_data_bit <= input_vector(i);
                wait for CLK_100_PERIOD; 
            end loop;
        end fill_192_inputs_procedure;
end package body Phase1_Package; 