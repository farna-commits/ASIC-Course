library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult4x4_top is
    port(
       a, b: in std_logic_vector(3 downto 0);
       digit1, digit2, digit3: out std_logic_vector(6 downto 0)
    );
 end mult4x4_top;

architecture mult4x4_top_arch of mult4x4_top is
    --Components declerations 
    component mult4x4
    port(
        a, b: in std_logic_vector(3 downto 0);
        outp: out std_logic_vector(7 downto 0)
    );
    end component;

    component bcd8
        port(
            b: in std_logic_vector(7 downto 0);
            unit, tens, hundreds: out std_logic_vector(3 downto 0)
         );
    end component;   

    component ssd
        port(
            bcd: in std_logic_vector(3 downto 0);
            ssdOut: out std_logic_vector(6 downto 0)
        );
    end component;    
    
    --signals 
    signal mult_out: std_logic_vector(7 downto 0);
    signal bcd_u, bcd_t, bcd_h: std_logic_vector(3 downto 0);

begin

    --instantiations
    m1  :   mult4x4 port map(a => a, b => b, outp => mult_out); 
    bcd1:   bcd8 port map(b => mult_out, unit => bcd_u, tens => bcd_t, hundreds => bcd_h);
    ssd1:   ssd port map(bcd => bcd_u, ssdOut => digit1);
    ssd2:   ssd port map(bcd => bcd_t, ssdOut => digit2);
    ssd3:   ssd port map(bcd => bcd_h, ssdOut => digit3);

end mult4x4_top_arch;