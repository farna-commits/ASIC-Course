library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

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

    --constants 
    constant CLK_50_PERIOD                        : Time := 20 ns; 
    constant CLK_50_HALF_PERIOD                   : Time := CLK_50_PERIOD / 2; 
    constant CLK_100_PERIOD                       : Time := 10 ns; 
    constant CLK_100_HALF_PERIOD                  : Time := CLK_100_PERIOD / 2;

    signal   clk_50                               : std_logic := '0'; 
    signal   clk_100                              : std_logic := '1'; 
    signal   reset                                : std_logic; 
    signal   en                                   : std_logic; 
    signal   load                                 : std_logic; 
    signal   test_in_vector                       : std_logic_vector(95 downto 0) := x"ACBCD2114DAE1577C6DBF4C9";
    signal   test_out_vector                      : std_logic_vector(191 downto 0) := x"000000000000000000000000000000000000000000000000";
    signal   test_in_bit                          : std_logic;
    signal   test_out1_bit                        : std_logic_vector(15 downto 0) ;
    signal   test_out2_bit                        : std_logic_vector(15 downto 0) ;
    signal   out_valid                            : std_logic;
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
    -- -- clk_100 <= not clk_100 after CLK_100_HALF_PERIOD; 

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
        for i in 95 downto 0 loop    
            test_in_bit <= test_in_vector(i); 
            wait for CLK_50_PERIOD;                
        end loop;  

        for i in 95 downto 0 loop    
            test_in_bit <= test_in_vector(i); 
            wait for CLK_50_PERIOD;                
        end loop;  
        for i in 95 downto 0 loop    
            test_in_bit <= test_in_vector(i); 
            wait for CLK_50_PERIOD;                
        end loop;  
        for i in 95 downto 0 loop    
            test_in_bit <= test_in_vector(i); 
            wait for CLK_50_PERIOD;                
        end loop;  
        for i in 95 downto 0 loop    
            test_in_bit <= test_in_vector(i); 
            wait for CLK_50_PERIOD;                
        end loop;  

        en  <= '0';
        wait; --makes process executes once 
    end process;

    -- --demodulation test 
    -- process 
    -- variable i : integer := 191;
    -- begin         
    --     wait until out_valid = '1'; 
    --     -- wait on test_out2_bit;
    --     wait for 2 ns; 
    --     while (i > 0) loop 
    --         if (test_out1_bit = ZeroPointSeven and test_out2_bit = ZeroPointSeven) then 
    --             demodulation_vector(i)      <= '0';
    --             demodulation_vector(i-1)    <= '0';
    --         elsif(test_out1_bit = NegativeZeroPointSeven and test_out2_bit = NegativeZeroPointSeven) then 
    --             demodulation_vector(i)      <= '1';
    --             demodulation_vector(i-1)    <= '1';
    --         elsif(test_out1_bit = NegativeZeroPointSeven and test_out2_bit = ZeroPointSeven) then 
    --             demodulation_vector(i)      <= '1';
    --             demodulation_vector(i-1)    <= '0';
    --         elsif(test_out1_bit = ZeroPointSeven and test_out2_bit = NegativeZeroPointSeven) then
    --             demodulation_vector(i)      <= '0';
    --             demodulation_vector(i-1)    <= '1';
    --         end if;
    --         i := i - 2; 
    --         wait for 2 * CLK_100_PERIOD;
    --     end loop;
    --     wait;
    -- end process;
end tb_arch;