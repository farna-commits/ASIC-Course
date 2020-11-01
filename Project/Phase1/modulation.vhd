library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity modulation is 
    port(
        clk_100mhz              : in  std_logic; 
        reset                   : in  std_logic; 
        interleaver_out_valid   : in  std_logic; 
        data_in                 : in  std_logic; 
        modulation_out_valid    : out std_logic; 
        output1, output2        : out std_logic_vector(15 downto 0) 
    );
end modulation;

architecture modulation_arch of modulation is

    --signals 
    signal data_in_reg  : std_logic_vector(1 downto 0);
    signal counter1     : unsigned(1 downto 0); 
    signal done_flag    : std_logic; 
    
begin

    process (clk_100mhz, reset) begin 
        if (reset = '1') then  
            counter1                <= "00";
        elsif (rising_edge(clk_100mhz)) then 
            if (interleaver_out_valid = '1') then 
                if (counter1 < 2) then 
                    data_in_reg(to_integer(counter1))   <= data_in; 
                    counter1                            <= counter1 + 1;
                else 
                    if (done_flag = '1') then 
                        counter1                            <= "00"; 
                    end if; 
                end if; 
            end if; 
        end if; 
    end process;

    process (counter1) begin 
        if (reset = '1') then 
            output1                 <= (others => '0'); 
            output2                 <= (others => '0');
            modulation_out_valid    <= '0'; 
            done_flag               <= '0';
        else 
            done_flag <= '0';
            if (counter1 = 2) then 
                for i in 0 to 1 loop
                    if (i = 0) then  
                        if (data_in_reg(i) = '0') then
                            output1                 <= "0101101001111111"; --   0.707 in Q15 format 
                            modulation_out_valid    <= '1'; 
                        else 
                            output1                 <= "1010010110000001";  -- -0.707 in Q15 format 
                            modulation_out_valid    <= '1'; 
                        end if;
                    else 
                        if (data_in_reg(i) = '0') then
                            output2     <= "0101101001111111"; --   0.707 in Q15 format  
                            done_flag   <= '1';
                        else 
                            output2     <= "1010010110000001"; --   -0.707 in Q15 format 
                            done_flag   <= '1';
                        end if;                
                    end if;
                end loop;
            end if; 
        end if;
    end process; 

end modulation_arch; 