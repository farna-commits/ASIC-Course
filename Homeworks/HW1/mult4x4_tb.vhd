library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult4x4_tb is
end mult4x4_tb;

architecture tb_arch of mult4x4_tb is
    component mult4x4
       port(
          a, b: in std_logic_vector(3 downto 0);
          outp: out std_logic_vector(7 downto 0)
       );
    end component;

    signal test_in1: std_logic_vector(3 downto 0);
    signal test_in2: std_logic_vector(3 downto 0);
    signal test_out: std_logic_vector(7 downto 0);
 
 begin
    -- instantiate the circuit under test
   uut: mult4x4
   port map (a => test_in1, b => test_in2, outp => test_out);
-- test vector generator

    process 
    begin
        for i in 0 to (15) loop
            test_in1 <= std_logic_vector(to_unsigned(i, test_in1'length)); 
            for j in 0 to (15) loop
                test_in2 <= std_logic_vector(to_unsigned(j, test_in2'length)); 
                wait for 25 ns; 
            end loop; 
	    wait for 25 ns;
        end loop;
    end process; 

   --verifier
   process
      variable test_pass: boolean;
   begin
      wait on test_in2;
      wait for 10 ns;
      if ((unsigned(test_in1) * unsigned(test_in2) = unsigned(test_out)))
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