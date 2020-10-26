library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity verify_wrapper is 
    port(
        clk     : in  std_logic; 
        success : out std_logic
    );
end verify_wrapper;

architecture verify_wrapper_arch of verify_wrapper is

    --prbs verifier component 
    component prbs_verify
        port(
            clk, reset, en, load    : in  std_logic; 
            pass                    : out std_logic
        );
    end component;    

    --initialize component 
    component initialize_inputs
        port(
            clk                 : in  std_logic; 
            reset, en, load     : out  std_logic
        );
    end component;   

    --signals 
    signal en_prbsIn, load_prbsIn, reset_prbsIn : std_logic;  
begin 

    --instant 
    init1: initialize_inputs port map(clk => clk, reset => reset_prbsIn, en => en_prbsIn, load => load_prbsIn);

    prbsVerify1: prbs_verify port map(clk => clk, reset => reset_prbsIn, en => en_prbsIn, load => load_prbsIn, pass => success);

end verify_wrapper_arch; 