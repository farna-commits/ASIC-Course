library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd8 is
    port(
       b: in std_logic_vector(7 downto 0);
       unit, tens, hundreds: out std_logic_vector(3 downto 0)
    );
 end bcd8;

architecture bcd8_arch of bcd8 is 

    component add3
        port(
            a: in std_logic_vector(3 downto 0);
            s: out std_logic_vector(3 downto 0)
        );
    end component;

    --signals 
    signal c1_in, c1_out, c2_in, c2_out, c3_in, c3_out, c4_in, c4_out, c5_in, c5_out, c6_in, c6_out, c7_in, c7_out: std_logic_vector(3 downto 0);

begin 
    --instantiations
    c1: add3 port map(a => c1_in, s => c1_out);
    c2: add3 port map(a => c2_in, s => c2_out);
    c3: add3 port map(a => c3_in, s => c3_out);
    c4: add3 port map(a => c4_in, s => c4_out);
    c5: add3 port map(a => c5_in, s => c5_out);
    c6: add3 port map(a => c6_in, s => c6_out);
    c7: add3 port map(a => c7_in, s => c7_out);

    --assigning internal signals 
    c1_in <= '0' & b(7 downto 5);
    c2_in <= c1_out(2 downto 0) & b(4);
    c3_in <= c2_out(2 downto 0) & b(3);
    c4_in <= c3_out(2 downto 0) & b(2);
    c5_in <= c4_out(2 downto 0) & b(1);
    c6_in <= '0' & c1_out(3) & c2_out(3) & c3_out(3);
    c7_in <= c6_out(2 downto 0) & c4_out(3);

    --assigning outputs
    hundreds <= '0' & '0' & c6_out(3) & c7_out(3);
    tens     <= c7_out(2 downto 0) & c5_out(3);
    unit     <= c5_out(2 downto 0) & b(0);
    
end bcd8_arch;