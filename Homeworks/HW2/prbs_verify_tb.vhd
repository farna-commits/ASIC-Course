library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prbs_verify_tb is
end prbs_verify_tb;


architecture tb_arch of prbs_verify_tb is
    component prbs_verify
       port(
            clk, reset, en, load    : in  std_logic; 
            pass                    : out std_logic
       );
    end component;

    --constants 
    constant CLK_HALF_PERIOD    : Time := 25 ns; 
    constant CLK_PERIOD         : Time := 2 * CLK_HALF_PERIOD;    
    
    --signals 
    signal clk              : std_logic := '0';   --start clk with 0 
    signal reset, en, load  : std_logic;
    signal test_pass_out    : std_logic; 


begin 

    --instant 
    uut: prbs_verify port map (clk => clk, reset => reset, en => en, load => load,
                               pass => test_pass_out); 

    --clock process 
    clk <= not clk after CLK_HALF_PERIOD; 

    --setting control signals 
    process begin 
        reset <= '1'; 
        wait for CLK_HALF_PERIOD + 5 ns; 
        reset <= '0'; 
        load <= '1'; 
        wait for CLK_PERIOD; 
        load <= '0'; 
        en <= '1'; 
        wait; 
    end process; 

    --checking on pass 
    process
    variable test_pass: boolean;
    begin
        wait on test_pass_out; --sense the pass from the top module 
        if (test_pass_out = '1') then --if at anytime it was LO then something is wrong 
            test_pass := true;
        else
            test_pass := false;
        end if;
        -- error reporting
        assert test_pass
        report "test failed."
        severity note;
        wait for CLK_PERIOD; 
        wait; 
    end process;
    
end tb_arch; 