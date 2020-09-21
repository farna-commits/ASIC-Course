library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult4x4_top_tb is
end mult4x4_top_tb;

architecture tb_arch of mult4x4_top_tb is
    component mult4x4_top
       port(
            a, b: in std_logic_vector(3 downto 0);
            digit1, digit2, digit3: out std_logic_vector(6 downto 0)
       );
    end component;

    --signals 
    signal test_in_a, test_in_b: std_logic_vector(3 downto 0);
    signal test_out_digit1, test_out_digit2, test_out_digit3: std_logic_vector(6 downto 0);
    signal mult_out: std_logic_vector(7 downto 0);

begin 

    --instant 
    uut: mult4x4_top port map (a => test_in_a, b => test_in_b, digit1 => test_out_digit1, digit2 => test_out_digit2, digit3 => test_out_digit3);

    --test vector generator
    process 
    begin
        for i in 0 to (15) loop
            test_in_a <= std_logic_vector(to_unsigned(i, test_in_a'length)); 
            for j in 0 to (15) loop
                test_in_b <= std_logic_vector(to_unsigned(j, test_in_b'length)); 
                wait for 25 ns; 
            end loop; 
	    wait for 25 ns;
        end loop;
    end process;    
    
    --signal to carry out multiplication here in the tb
    mult_out <= std_logic_vector(unsigned(test_in_a) * unsigned(test_in_b));
    
   --verifier
   process
      variable test_pass: boolean;
      variable units_out, tens_out, hundreds_out: integer;
   begin
      wait on test_in_b;
      wait for 10 ns;

      --calculating units, tens and hundreds 
      units_out := to_integer(unsigned(mult_out)) mod 10;
      tens_out := to_integer(unsigned(mult_out)/10) mod 10;
      hundreds_out := to_integer(unsigned(mult_out)/100) mod 10;        

      --checking if the output matches the truth table of the ssd (for each digit)
      if (
          ( 
              (units_out=0 and test_out_digit1  = "1000000") or 
              (units_out=1 and test_out_digit1  = "1111001") or
              (units_out=2 and test_out_digit1  = "0100100") or
              (units_out=3 and test_out_digit1  = "0110000") or
              (units_out=4 and test_out_digit1  = "0011001") or
              (units_out=5 and test_out_digit1  = "0010010") or
              (units_out=6 and test_out_digit1  = "0000010") or
              (units_out=7 and test_out_digit1  = "1111000") or
              (units_out=8 and test_out_digit1  = "0000000") or
              (units_out=9 and test_out_digit1  = "0010000") or
              (units_out=10 and test_out_digit1 = "0001000") or
              (units_out=11 and test_out_digit1 = "0000011") or
              (units_out=12 and test_out_digit1 = "0111001") or
              (units_out=13 and test_out_digit1 = "0100001") or
              (units_out=14 and test_out_digit1 = "0000110") or
              (units_out=15 and test_out_digit1 = "0001110") 
              )
          and 
          ( 
              (tens_out=0 and test_out_digit2  = "1000000")  or 
              (tens_out=1 and test_out_digit2  = "1111001")  or 
              (tens_out=2 and test_out_digit2  = "0100100")  or
              (tens_out=3 and test_out_digit2  = "0110000")  or
              (tens_out=4 and test_out_digit2  = "0011001")  or
              (tens_out=5 and test_out_digit2  = "0010010")  or
              (tens_out=6 and test_out_digit2  = "0000010")  or
              (tens_out=7 and test_out_digit2  = "1111000")  or
              (tens_out=8 and test_out_digit2  = "0000000")  or
              (tens_out=9 and test_out_digit2  = "0010000")  or
              (tens_out=10 and test_out_digit2 = "0001000")  or
              (tens_out=11 and test_out_digit2 = "0000011")  or
              (tens_out=12 and test_out_digit2 = "0111001")  or
              (tens_out=13 and test_out_digit2 = "0100001")  or
              (tens_out=14 and test_out_digit2 = "0000110")  or
              (tens_out=15 and test_out_digit2 = "0001110")  
              )
          and 
          ( 
              (hundreds_out=0 and test_out_digit3  = "1000000") or 
              (hundreds_out=1 and test_out_digit3  = "1111001") or
              (hundreds_out=2 and test_out_digit3  = "0100100") or
              (hundreds_out=3 and test_out_digit3  = "0110000") or
              (hundreds_out=4 and test_out_digit3  = "0011001") or
              (hundreds_out=5 and test_out_digit3  = "0010010") or
              (hundreds_out=6 and test_out_digit3  = "0000010") or
              (hundreds_out=7 and test_out_digit3  = "1111000") or
              (hundreds_out=8 and test_out_digit3  = "0000000") or
              (hundreds_out=9 and test_out_digit3  = "0010000") or
              (hundreds_out=10 and test_out_digit3 = "0001000") or
              (hundreds_out=11 and test_out_digit3 = "0000011") or
              (hundreds_out=12 and test_out_digit3 = "0111001") or
              (hundreds_out=13 and test_out_digit3 = "0100001") or
              (hundreds_out=14 and test_out_digit3 = "0000110") or
              (hundreds_out=15 and test_out_digit3 = "0001110") 
              )
          
          )
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
