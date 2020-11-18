library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity interleaver_tb is
end interleaver_tb;

architecture tb_arch of interleaver_tb is
    component states_interleaver
        port(
            clk_100mhz                            : in    std_logic; 
            reset, FEC_encoder_out_valid          : in    std_logic; 
            data_in                               : in    std_logic; 
            interleaver_out_valid                 : out   std_logic; 
            data_out                              : out   std_logic
        );
    end component;

    --constants 
    constant CLK_PERIOD                           : Time := 10 ns; 
    constant CLK_HALF_PERIOD                      : Time := CLK_PERIOD / 2; 
    --signals 
    signal clk                                    : std_logic := '0'; 
    signal reset                                  : std_logic; 
    signal en                                     : std_logic; 
    signal test_in_vector                         : std_logic_vector(191 downto 0) := x"2833E48D392026D5B6DC5E4AF47ADD29494B6C89151348CA";
    signal test_out_vector                        : std_logic_vector(191 downto 0) := x"000000000000000000000000000000000000000000000000";
    signal test_in_bit                            : std_logic;
    signal test_out_bit                           : std_logic;
    signal out_valid                              : std_logic;
    signal flag                                   : std_logic := '0';


begin 

    --instant 
    uut: states_interleaver port map (clk_100mhz => clk, reset => reset, FEC_encoder_out_valid => en, 
                                data_in => test_in_bit, interleaver_out_valid => out_valid, 
                                data_out => test_out_bit);

    --clk process 
    clk <= not clk after CLK_HALF_PERIOD; 

    --serial input in 
    process begin 
        reset   <= '1'; 
        wait for CLK_PERIOD + 5 ns; 
        reset   <= '0';
        en      <= '1';
        for i in 0 to 191 loop 
            test_in_bit <= test_in_vector(i);
            wait for CLK_PERIOD; 
        end loop;
        wait until flag = '1'; 
        en  <= '0';
        wait;
    end process; 

    --check output 
    process begin 
        wait until out_valid = '1'; 
        wait for 2 ns; 
        for i in 191 downto 0 loop 
            test_out_vector(i) <= test_out_bit; 
            wait for CLK_PERIOD; 
        end loop;
        flag    <= '1';
        wait;
    end process;

end tb_arch;