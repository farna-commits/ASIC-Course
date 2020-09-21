library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mult4x4 is
   port
   (
      a, b: in std_logic_vector(3 downto 0);
      outp: out std_logic_vector(7 downto 0)
   );
end entity mult4x4;

architecture Behavioral of mult4x4 is
begin
    outp <= std_logic_vector(unsigned(a) * unsigned(b));
end architecture Behavioral; 