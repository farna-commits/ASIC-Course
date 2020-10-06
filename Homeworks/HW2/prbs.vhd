library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prbs is 
    generic (SEED_WIDTH : integer);
    port(
        clk, reset, en, load: in std_logic; 
        seed_in: in std_logic_vector(SEED_WIDTH-1 downto 0);
        dataIn: in std_logic;
        dataOut: out std_logic
    );
end prbs;

architecture prbs_arch of prbs is
    --internal signals 
    signal dataIn_reg, dataOut_reg: std_logic;  --signals for input and output port (for protecting input and output)
    signal seed_reg: std_logic_vector(SEED_WIDTH-1 downto 0);   --seeding signal
    signal xor_1: std_logic;    --xoring signal 
begin
    
    --continuous assignments
    dataIn_reg <= dataIn;   --connect input with internal signal
    dataOut <= dataOut_reg; --connect output with internal signal 
    xor_1 <= '0' when (en = '0') else seed_reg(SEED_WIDTH-1) xor seed_reg(SEED_WIDTH-2); --xor last 2 bits, but init if enable is lo
    dataOut_reg <= '0' when (en = '0') else dataIn_reg xor xor_1; --xor dataIn with xoring result of last 2 bits, but init if enable is lo

    process (clk, reset) begin 
        --initialize 
        if (reset = '0') then --my reset is active low
            seed_reg <= (others => '0');    --init with zeros 
        elsif (rising_edge(clk)) then 
        -- if reset is high then operate, but check enable and load first 
            if(load = '1') then
                seed_reg <= seed_in;    --initialize the seed reg with input seed
            elsif(en = '1' and load = '0') then
                seed_reg <= seed_reg(SEED_WIDTH-2 downto 0) & xor_1;    --shift left by 1 and xor with xoring result of last 2 bits
            end if;
        end if;
    end process; 

end prbs_arch;