library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity randomizer is 
    port(
        clk_50mhz, reset, rand_in_ready     : in  std_logic; 
        load                                : in  std_logic;
        rand_in                             : in  std_logic;
        rand_out                            : out std_logic;
        rand_out_valid                      : out std_logic
    );
end randomizer;

architecture randomizer_arch of randomizer is
    --constants 
    constant SEED_WIDTH                     : integer := 15; 
    constant seed_rom                       : std_logic_vector(SEED_WIDTH-1 downto 0)  := "101010001110110";
    --internal signals 
    signal rand_in_reg, rand_out_reg        : std_logic;  --signals for input and output port (for protecting input and output)
    signal seed_reg                         : std_logic_vector(SEED_WIDTH-1 downto 0);   --seeding signal
    signal seed_reg2                        : std_logic_vector(SEED_WIDTH-1 downto 0);   --seeding signal
    signal xor_1                            : std_logic;    --xoring signal 
    signal counter_reset_seed               : integer; 
begin
    
    --continuous assignments
    rand_in_reg         <= rand_in;   --connect input with internal signal
    rand_out            <= rand_out_reg; --connect output with internal signal 
    seed_reg2           <= seed_rom; 
    xor_1               <= '0' when (rand_in_ready = '0') else seed_reg(SEED_WIDTH-1) xor seed_reg(SEED_WIDTH-2); --xor last 2 bits, but init if enable is lo
    rand_out_reg        <= '0' when (rand_in_ready = '0') else rand_in_reg xor xor_1; --xor dataIn with xoring result of last 2 bits, but init if enable is lo
    rand_out_valid      <= '0' when (rand_in_ready = '0') else '1';

    process (clk_50mhz, reset) begin 
        --initialize 
        if (reset = '1') then --my reset is active high
            seed_reg            <= (others => '0');    --init with zeros 
            counter_reset_seed  <= 0;
        elsif (rising_edge(clk_50mhz)) then 
        -- if reset is high then operate, but check enable and load first 
            if(load = '1') then
                seed_reg <= seed_reg2;    --initialize the seed reg with input seed
            elsif(rand_in_ready = '1') then
                seed_reg            <= seed_reg(SEED_WIDTH-2 downto 0) & xor_1;    --shift left by 1 and xor with xoring result of last 2 bits
                counter_reset_seed  <= counter_reset_seed + 1;
                if (counter_reset_seed = 95) then 
                    counter_reset_seed  <= 0;
                    seed_reg            <= seed_reg2; 
                end if;
            end if;
        end if;
    end process; 

end randomizer_arch;