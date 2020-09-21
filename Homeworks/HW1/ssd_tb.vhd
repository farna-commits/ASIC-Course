library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ssd_tb is
end ssd_tb;

architecture tb_arch of ssd_tb is 

    --component 
    component ssd 
        port (
            bcd: in std_logic_vector(3 downto 0);
            ssdOut: out std_logic_vector(6 downto 0)            
        );
    end component;

    --internal signals 
    signal test_in: std_logic_vector(3 downto 0); 
    signal test_out: std_logic_vector(6 downto 0); 

begin 
    --instantiation 
    uut: ssd port map (bcd => test_in, ssdOut => test_out);

    --test vector generator 
    process
    begin
        test_in <= "0000"; wait for 25 ns; 
        test_in <= "0001"; wait for 25 ns; 
        test_in <= "0010"; wait for 25 ns; 
        test_in <= "0011"; wait for 25 ns; 
        test_in <= "0100"; wait for 25 ns; 
        test_in <= "0101"; wait for 25 ns; 
        test_in <= "0110"; wait for 25 ns; 
        test_in <= "0111"; wait for 25 ns; 
        test_in <= "1000"; wait for 25 ns; 
        test_in <= "1001"; wait for 25 ns; 
        test_in <= "1010"; wait for 25 ns; 
        test_in <= "1011"; wait for 25 ns; 
        test_in <= "1100"; wait for 25 ns; 
        test_in <= "1101"; wait for 25 ns; 
        test_in <= "1110"; wait for 25 ns; 
        test_in <= "1111"; wait for 25 ns; 
    end process;

   --verifier
   process
      variable test_pass: boolean;
   begin
      wait on test_in;
      wait for 10 ns;
      if ((test_in="0000" and test_out = "1000000") or
          (test_in="0001" and test_out = "1111001") or
          (test_in="0010" and test_out = "0100100") or
          (test_in="0011" and test_out = "0110000") or
          (test_in="0100" and test_out = "0011001") or
          (test_in="0101" and test_out = "0010010") or
          (test_in="0110" and test_out = "0000010") or
          (test_in="0111" and test_out = "1111000") or
          (test_in="1000" and test_out = "0000000") or
          (test_in="1001" and test_out = "0010000") or
          (test_in="1010" and test_out = "0001000") or
          (test_in="1011" and test_out = "0000011") or
          (test_in="1100" and test_out = "0111001") or
          (test_in="1101" and test_out = "0100001") or
          (test_in="1110" and test_out = "0000110") or
          (test_in="1111" and test_out = "0001110"))
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