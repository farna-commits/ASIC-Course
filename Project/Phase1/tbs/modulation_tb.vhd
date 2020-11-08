library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modulation_tb is
end modulation_tb;

architecture tb_arch of modulation_tb is
    component modulation
        port(
            clk_100mhz              : in  std_logic; 
            reset                   : in  std_logic; 
            interleaver_out_valid   : in  std_logic; 
            data_in                 : in  std_logic; 
            modulation_out_valid    : out std_logic; 
            output1, output2        : out std_logic_vector(15 downto 0) 

        );
    end component;

    --constants 
    constant CLK_100_PERIOD                       : Time := 10 ns; 
    constant CLK_100_HALF_PERIOD                  : Time := CLK_100_PERIOD / 2;

    --signals 
    signal   clk_100                              : std_logic := '0'; 
    signal   reset                                : std_logic; 
    signal   en                                   : std_logic; 
    signal   test_in_vector                       : std_logic_vector(191 downto 0) := x"4B047DFA42F2A5D5F61C021A5851E9A309A24FD58086BD1E";
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

    --clk process 
    clk_100 <= not clk_100 after CLK_100_HALF_PERIOD; 

    --serial input in 
    process begin 
        reset   <= '1'; 
        en      <= '0';
        wait for CLK_100_PERIOD + 5 ns; 
        reset   <= '0';
        en      <= '1';
        for i in 191 downto 0 loop 
            test_in_bit <= test_in_vector(i);
            wait for CLK_100_PERIOD; 
        end loop;
        en  <= '0';
        wait;
    end process; 

end tb_arch;