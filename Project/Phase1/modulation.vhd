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
    signal   data_in_buffer             : std_logic;
    signal   flag                       : std_logic; 
    signal   data_in_fuse               : std_logic_vector(1 downto 0); 
    signal   done_flag                  : std_logic;
    signal   counter_done               : integer := 0; 
    --constants
    constant ZeroPointSeven             : std_logic_vector(15 downto 0) := "0101101001111111";
    constant NegativeZeroPointSeven     : std_logic_vector(15 downto 0) := "1010010110000001";
    
begin
    data_in_fuse    <= data_in & data_in_buffer when (flag = '1') else "00"; 
    process (clk_100mhz, reset) begin 
        if (reset = '1') then
            data_in_buffer  <= '0';
            flag            <= '0';
            done_flag       <= '0';
        elsif (rising_edge(clk_100mhz)) then 
            if (interleaver_out_valid = '1') then 
                data_in_buffer  <= data_in;
                flag            <= '1';
                if (flag = '1') then 
                    flag  <= '0';       
                end if;
            elsif(interleaver_out_valid = '0') then 
                done_flag   <= '1'; 
            end if;
        end if; 
    end process;

    process (clk_100mhz, reset, flag) begin 
        if (reset = '1') then 
            output1                 <= (others => '0'); 
            output2                 <= (others => '0');
            modulation_out_valid    <= '0'; 
        elsif(rising_edge(clk_100mhz)) then 
            if (interleaver_out_valid = '1') then 
                if (flag = '1') then 
                    case (data_in_fuse) is 
                        when "00" => 
                            output1                 <= ZeroPointSeven; 
                            output2                 <= ZeroPointSeven; 
                            modulation_out_valid    <= '1'; 
                        when "01" => 
                            output1                 <= NegativeZeroPointSeven; 
                            output2                 <= ZeroPointSeven;
                            modulation_out_valid    <= '1'; 
                        when "11" =>
                            output1                 <= NegativeZeroPointSeven; 
                            output2                 <= NegativeZeroPointSeven;
                            modulation_out_valid    <= '1'; 
                        when "10" =>
                            output1                 <= ZeroPointSeven; 
                            output2                 <= NegativeZeroPointSeven;
                            modulation_out_valid    <= '1'; 
                        when others =>
                            output1 <= (others => '0'); 
                            output2 <= (others => '0');
                    end case; 
                end if;
            elsif(done_flag = '1') then 
                modulation_out_valid    <= '0';
            end if;
        end if;
    end process; 

end modulation_arch; 