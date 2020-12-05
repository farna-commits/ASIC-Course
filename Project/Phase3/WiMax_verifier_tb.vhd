-- vcom -reportprogress 300 -2008 -work work D:/AUC/Semester9(Fall2020)/ASIC/repo/ASIC-Course/Project/Phase3/WiMax_verifier_tb.vhd 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;
use work.Phase1_Package.all;

entity WiMax_verifier_tb is 
end WiMax_verifier_tb;

architecture tb_arch of WiMax_verifier_tb is
    component WiMax_verifier is 
        port(
            clk_50mhz   : in    std_logic; 
            reset       : in    std_logic; 
            en          : in    std_logic; 
            load        : in    std_logic; 
            rand_pass   : out   std_logic;
            fec_pass    : out   std_logic;
            int_pass    : out   std_logic;
            mod_pass    : out   std_logic
        );
    end component;

    signal   clk_50                               : std_logic := '0'; 
    signal   reset                                : std_logic; 
    signal   en                                   : std_logic; 
    signal   load                                 : std_logic; 
    signal   rand_led                             : std_logic;
    signal   fec_led                              : std_logic;
    signal   int_led                              : std_logic;
    signal   mod_led                              : std_logic;

    signal   rand_valid_alias_signal              : std_logic;
    signal   fec_valid_alias_signal               : std_logic;
    signal   int_valid_alias_signal               : std_logic;
    signal   mod_valid_alias_signal               : std_logic;
    
begin 

    rand_valid_alias_signal <= <<signal .WiMax_verifier_tb.uut.rand_out_valid : std_logic>>; 
    fec_valid_alias_signal  <= <<signal .WiMax_verifier_tb.uut.fec_out_valid  : std_logic>>;
    int_valid_alias_signal  <= <<signal .WiMax_verifier_tb.uut.int_out_valid  : std_logic>>;
    mod_valid_alias_signal  <= <<signal .WiMax_verifier_tb.uut.mod_out_valid  : std_logic>>;


    --instantiations
    uut: WiMax_verifier port map
    (
        clk_50mhz   =>  clk_50,
        reset       =>  reset,
        en          =>  en   ,
        load        =>  load ,
        rand_pass   =>  rand_led,
        fec_pass    =>  fec_led ,
        int_pass    =>  int_led ,
        mod_pass    =>  mod_led 
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
        wait for 1*CLK_50_PERIOD; --bec of 75 ns edge the next pos edge so make sure a pos edge came 
        load <= '0'; 
        en <= '1';        
        wait; --makes process executes once 
    end process;

    --verifiers 
    --rand
    process
    variable rand_test_pass: boolean;
    begin
        wait for 1 ns;
        wait until rand_valid_alias_signal = '1'; 
        wait for CLK_50_PERIOD;
        wait for 1 ns;
        if (rand_led = '1') then 
            rand_test_pass := true;
        else
            rand_test_pass := false;
        end if;
        -- error reporting
        assert rand_test_pass
        report "Randomizer test failed" severity failure;        
        wait for CLK_50_PERIOD; 
    end process;

    --fec
    process
    variable fec_test_pass: boolean;
    begin
        wait for 1 ns;
        wait until fec_valid_alias_signal = '1'; 
        wait for CLK_100_PERIOD;
        wait for 1 ns;
        if (fec_led = '1') then 
            fec_test_pass := true;
        else
            fec_test_pass := false;
        end if;
        -- error reporting
        assert fec_test_pass
        report "FEC test failed" severity failure;        
        wait for CLK_100_PERIOD; 
    end process;

    --int
    process
    variable int_test_pass: boolean;
    begin
        wait for 1 ns;
        wait until int_valid_alias_signal = '1'; 
        wait for CLK_100_PERIOD;
        wait for 1 ns;
        if (int_led = '1') then 
            int_test_pass := true;
        else
            int_test_pass := false;
        end if;
        -- error reporting
        assert int_test_pass
        report "Interleaver test failed" severity failure;        
        wait for CLK_100_PERIOD; 
    end process;

    --mod
    process
    variable mod_test_pass: boolean;
    begin
        wait for 1 ns;
        wait until mod_valid_alias_signal = '1'; 
        wait for CLK_50_PERIOD;
        wait for 1 ns;
        if (mod_led = '1') then 
            mod_test_pass := true;
        else
            mod_test_pass := false;
        end if;
        -- error reporting
        assert mod_test_pass
        report "Modulation test failed" severity failure;        
        wait for CLK_50_PERIOD; 
    end process;
end tb_arch;