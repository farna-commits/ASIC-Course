library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity gen_reset is
   port(
      clk: in std_logic;
      reset: out std_logic;
      enable: out std_logic
   );
end gen_reset;


architecture gen_reset_arch of gen_reset is
signal my_reg: std_logic_vector (7 downto 0):="00000000";
signal asserted: std_logic:= '0'; 
constant time_max: integer:= 8; 
begin 
    process(clk)
    begin 
        if (asserted = '0') then
            reset <= '1'; 
            enable <= '0';
            if (rising_edge(clk)) then
                my_reg <= std_logic_vector(unsigned(my_reg) + 1);
            end if; 
            if (unsigned(my_reg) >= time_max) then
                asserted <= '1';
            end if; 
        elsif (asserted = '1') then 
                reset <= '0'; 
                enable <= '1';
        end if; 
    end process; 
end gen_reset_arch;