library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity top_mult_count is
    port(

       clk: in std_logic; 
       ssd_out_A ,ssd_out_B, ssd_out_C: out std_logic_vector(6 downto 0);
       result: out std_logic_vector(7 downto 0)
    );
 end top_mult_count;

 architecture top_mult_count_arch of top_mult_count is
    --Components declerations 
    component mult4x4_top2
    port(
       a, b: in std_logic_vector(3 downto 0);
       digit1, digit2, digit3: out std_logic_vector(6 downto 0);
       result: out std_logic_vector(7 downto 0)
    );
    end component;

    component counter
        port(
            clk: in std_logic;
            reset: in std_logic;
            enable: in std_logic;
            count: out std_logic_vector(3 downto 0)
        );
    end component;   

    component gen_reset
        port(
            clk: in std_logic;
            reset: out std_logic;
            enable: out std_logic
        );
    end component;   
    --signals 
    signal count1_out, count2_out: std_logic_vector(3 downto 0);
    signal gen_reset_out_enable, gen_reset_out_reset: std_logic;

begin 

    --instants
    m1: mult4x4_top2 port map(a => count1_out, b => count2_out, digit1 => ssd_out_B, digit2 => ssd_out_A, digit3 => ssd_out_C, result => result );
    c1: counter port map(clk => clk, reset => gen_reset_out_reset, enable => gen_reset_out_enable, count => count1_out);
    c2: counter port map(clk => clk, reset => gen_reset_out_reset, enable => gen_reset_out_enable, count => count2_out);
    g1: gen_reset port map(clk => clk, reset => gen_reset_out_reset, enable => gen_reset_out_enable);

end top_mult_count_arch; 


