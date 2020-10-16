library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity initialize_inputs is 
    port(
        clk                 : in  std_logic; 
        reset, en, load     : out  std_logic
    );
end initialize_inputs;


architecture initialize_inputs_arch of initialize_inputs is
signal counter  : unsigned(6 downto 0) := "0000000"; 
begin
    process (clk, counter) begin 
        if (rising_edge(clk)) then 
            counter <= counter + 1;
        end if; 

        if (counter = "0000000") then 
            reset <= '1'; 
            load <= '0';
            en <= '0'; 
        elsif (counter = "0000100") then 
            reset <= '0'; 
            load <= '0';
            en <= '0'; 
        elsif (counter = "0000101") then 
            reset <= '0'; 
            load <= '1';
            en <= '0'; 
        elsif (counter = "0000111") then 
            reset <= '0'; 
            load <= '0';
            en <= '1'; 
        elsif (counter = "1101000") then 
            reset <= '0'; 
            load <= '0';
            en <= '0'; 
            counter <= "0000000";
        end if; 

    end process; 


end initialize_inputs_arch;