library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FEC_encoder is 
    port(
        clk_50mhz, clk_100mhz               : in    std_logic; 
        reset, rand_out_valid               : in    std_logic; 
        tail_bits_in                        : in    std_logic_vector(5 downto 0); 
        data_in                             : in    std_logic; 
        x_output, y_output                  : out   std_logic; 
        FEC_encoder_out_valid               : out   std_logic; 
        data_out                            : out   std_logic

    );
end FEC_encoder;

architecture FEC_encoder_arch of FEC_encoder is
    --signals 
    signal g1                               : std_logic_vector(5 downto 0); 
    signal x_output_signal, y_output_signal : std_logic; 
    signal flag                             : std_logic; 
    
begin

    --contineous 
    x_output    <= x_output_signal; 
    y_output    <= y_output_signal; 
    data_out    <= x_output_signal when (flag = '1') else y_output_signal;

    process(clk_50mhz, reset) begin 
        if (reset = '1') then 
            g1  <= tail_bits_in; 
        elsif (rising_edge(clk_50mhz)) then 
            if (rand_out_valid = '1') then 
                g1 <= data_in & g1(5 downto 1); 
            end if; 
        end if; 
    end process; 

    process (clk_100mhz, reset) begin 
        if (reset = '1') then 
            flag                    <= '1'; 
            x_output_signal         <= '0';
            y_output_signal         <= '0';
            FEC_encoder_out_valid   <= '0';
        elsif(rising_edge(clk_100mhz)) then 
            if (rand_out_valid = '1') then 
                if (flag = '1') then 
                    x_output_signal         <= data_in xor g1(0) xor g1(3) xor g1(4) xor g1(5);
                    flag                    <= '0'; 
                    FEC_encoder_out_valid   <= '1'; 
                else 
                    y_output_signal     <= data_in xor g1(0) xor g1(1) xor g1(3) xor g1(4);  
                    flag                <= '1';
                end if; 
            end if; 
        end if;
    end process; 

end FEC_encoder_arch; 