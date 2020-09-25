library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity counter is
   port(
      clk: in std_logic;
      reset: in std_logic;
      enable: in std_logic;
      count: out std_logic_vector(3 downto 0)
   );
end counter;

architecture counter_arch of counter is
signal counter_signal: std_logic_vector(3 downto 0);
begin
    process(clk, reset, enable)
    begin 
        if (reset = '1') then 
            counter_signal <= "0000"; 
        elsif (rising_edge(clk)) then 
            if (enable = '1') then 
                counter_signal <= std_logic_vector(unsigned(counter_signal) + 1); 
            end if;
        end if; 
    end process;
    --assign output to internal signal 
    count <= counter_signal; 
end counter_arch;