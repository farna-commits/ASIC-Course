library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bcd8_tb is
end bcd8_tb;

architecture tb_arch of bcd8_tb is
    component bcd8
       port(
            b: in std_logic_vector(7 downto 0);
            unit, tens, hundreds: out std_logic_vector(3 downto 0)
       );
    end component;

    signal test_in: std_logic_vector(7 downto 0);
    signal test_out: std_logic_vector(11 downto 0);

begin 
    --instant
    uut: bcd8 port map (b => test_in, unit => test_out(3 downto 0), tens => test_out(7 downto 4), hundreds => test_out(11 downto 8));

    --test vector generator 
    process begin 
        for i in 0 to 255 loop
            test_in <= std_logic_vector(to_unsigned(i, test_in'length));
            wait for 25 ns; 
        end loop; 
    end process; 

    -- --verifier
    process
    variable test_pass: boolean;
    variable unit, tens, hundreds: integer; 
    begin
        --senstivity list var
        wait on test_in;
        wait for 10 ns;

        --computing units, tens and hundreds using algorithm 
        unit := to_integer(unsigned(test_in)) mod 10; 
        tens := (to_integer(unsigned(test_in)) / 10) mod 10;
        hundreds := (to_integer(unsigned(test_in)) / 100) mod 10;
        
        --check if algorithm's answer same to the RTL approach
        if ( (unit = to_integer(unsigned(test_out(3 downto 0)))) and (tens = to_integer(unsigned(test_out(7 downto 4)))) and (hundreds = to_integer(unsigned(test_out(11 downto 8)))) )
        then
            test_pass := true;
        else
            test_pass := false;
        end if;
        -- error reporting
        assert test_pass
            report "test failed."
            severity note;

    end process;
end tb_arch;
