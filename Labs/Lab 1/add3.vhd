library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity add3 is
   port(
      a: in std_logic_vector(3 downto 0);
      s: out std_logic_vector(3 downto 0)
   );
end add3;

architecture add3_arch of add3 is
begin
   with a select 
    s <= a      when "0000", 
         a      when "0001", 
         a      when "0010", 
         a      when "0011", 
         a      when "0100", 
         "1000" when "0101", 
         "1001" when "0110", 
         "1010" when "0111", 
         "1011" when "1000", 
         "1100" when "1001", 
         "0000" when others; 
end add3_arch;