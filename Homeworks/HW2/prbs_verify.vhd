library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity prbs_verify is 
    port(
        clk, reset, en, load: in std_logic; 
        pass: out std_logic
    );
end prbs_verify;


architecture prbs_verify_arch of prbs_verify is

    --prbs component 
    component prbs
       generic (SEED_WIDTH : integer);
       port(
            clk, reset, en, load: in std_logic; 
            seed_in: in std_logic_vector(SEED_WIDTH-1 downto 0);
            dataIn: in std_logic;
            dataOut: out std_logic
       );
    end component;

    --constants 
    constant SEED_WIDTH: integer := 15; 
    constant INOUT_SIZE: integer := 96; 

    --ROMs 
    constant seed_rom:      std_logic_vector(SEED_WIDTH-1 downto 0)  := "101010001110110"; 
    constant in_data_rom:   std_logic_vector(INOUT_SIZE-1 downto 0)  := x"ACBCD2114DAE1577C6DBF4C9"; 
    constant out_data_rom:  std_logic_vector(INOUT_SIZE-1 downto 0)  := x"558AC4A53A1724E163AC2BF9";

    --signals 
    signal clk_signal, reset_signal, load_signal, pass_signal: std_logic; --protection for inputs and outputs 
    signal data_out_before_verify: std_logic; --output of prbs module 
    signal seed_in_signal: std_logic_vector(SEED_WIDTH-1 downto 0); --output of seed_rom
    signal data_in_signal: std_logic_vector(INOUT_SIZE-1 downto 0); --output of in_data_rom 
    signal data_in_signal_bit: std_logic; --1 bit of the rom as input to prbs module is 1 bit only 
    signal flag: std_logic := '0'; --flag for verification 
    signal counter, counter2: unsigned(6 downto 0) := "1011111"; --indecies for ROMs to access individual bits 
    signal en_signal: std_logic;    -- this is the enable of prbs module, if the enable of the top module is 1, set this as 1
                                    -- that is done in order to have the first input and the first enable come in sync
                                    -- because if they arent in sync, first input will come with the 2nd seed value not the initial one
                                    -- so a solution would be initializing the seed with another value so that when its shifted it gives OUR initial
                                    -- one, or have a hidden enable that enables the small module when the global enable is asserted. 
    signal temp1: std_logic; 

begin 

    --continuous assignments 
    clk_signal <= clk; 
    reset_signal <= reset; 
    load_signal <= load; 
    pass <= pass_signal; 
    seed_in_signal <= seed_rom; 
    data_in_signal <= in_data_rom;


    --instant 
    prbs1: prbs generic map(SEED_WIDTH => SEED_WIDTH)
                port map(clk => clk_signal, reset => reset_signal, en => en_signal, load => load_signal,
                         seed_in => seed_in_signal,
                         dataIn => data_in_signal_bit, dataOut => data_out_before_verify); 


    
    --take input into module 
    process (clk_signal) begin 
        if (load_signal = '0' and rising_edge(clk_signal) and counter >= 0 and en = '1') then 
            en_signal <= '1';
            data_in_signal_bit <= data_in_signal(to_integer(counter)); --take 1 bit from rom 
            counter <= counter - 1; 
        end if; 
    end process;

    --extracting bit by bit from output rom
    temp1 <= out_data_rom(to_integer(counter2));

    --verify logic
    process (clk_signal) begin 
        if (load_signal = '0' and rising_edge(clk_signal) and counter2 >= 0 and en_signal = '1') then --check on en_signal as it is asserted when first input is given
            if (data_out_before_verify = temp1) and (flag = '0') then --if there are no mismatches 
                pass_signal <= '1'; --make the pass as 1 until one mismatch occures
                counter2 <= counter2 - 1; 
            else --a mismatch occured 
                flag <= '1'; 
                pass_signal <= '0'; --show that there was a mismatch 
            end if;
        end if; 
    end process; 

end prbs_verify_arch; 