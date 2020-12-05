library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

use work.Phase1_Package.all;

entity WiMax_verifier is 
    port(
        clk_50mhz   : in    std_logic; 
        reset       : in    std_logic; 
        en          : in    std_logic; 
        load        : in    std_logic; 
        rand_pass   : out   std_logic;
        fec_pass    : out   std_logic;
        int_pass    : out   std_logic;
        mod_pass    : out   std_logic
    );
end WiMax_verifier;


architecture WiMax_verifier_arch of WiMax_verifier is

    --component 
    component WiMax_phase3 is 
        port(
            clk_50mhz                            	  : in    std_logic; 
            clk_100mhz                                : in    std_logic;
            reset                 	                  : in    std_logic; 
            en                 	                      : in    std_logic; 
            load               	                      : in    std_logic; 
            data_in                               	  : in    std_logic; 
            out_rand_out                              : out   std_logic;
            out_rand_valid                            : out   std_logic;
            out_fec_out                               : out   std_logic;
            out_fec_valid                             : out   std_logic;
            out_int_out                               : out   std_logic;
            out_int_valid                             : out   std_logic;
            WiMax_out_valid                           : out   std_logic;
            data_out1                              	  : out   std_logic_vector(15 downto 0);
            data_out2                              	  : out   std_logic_vector(15 downto 0) 
        );
    end component;

    component PLL is 
        port (
            refclk                                : in  std_logic := 'X'; --  refclk.clk
            rst                                   : in  std_logic := 'X'; --   reset.reset
            outclk_0                              : out std_logic;        -- outclk0.clk
            outclk_1                              : out std_logic;        -- outclk1.clk
            locked                                : out std_logic         --  locked.export
        );
    end component;

    --ROMs
    signal seed_rom                               : std_logic_vector(14 downto 0)   := SEED_KO;
    signal rand_in_data_rom                       : std_logic_vector(95 downto 0)   := INPUT_RANDOMIZER_VECTOR_CONST; 
    signal rand_out_data_rom                      : std_logic_vector(95 downto 0)   := OUTPUT_RANDOMIZER_VECTOR_CONST;
    signal fec_out_data_rom                       : std_logic_vector(191 downto 0)  := INPUT_INTERLEAVER_VECTOR_CONST;
    signal int_out_data_rom                       : std_logic_vector(191 downto 0)  := INPUT_MODULATION_VECTOR_CONST;
    signal mod_out_data_rom                       : std_logic_vector(191 downto 0)  := INPUT_MODULATION_VECTOR_CONST;
    
    
    --PLL
    signal clk_50mhz_sig                          : std_logic;
    signal clk_100mhz_sig                         : std_logic;
    signal locked                                 : std_logic;
    signal locked2                                : std_logic;
    --General
    signal data_in_signal_bit                     : std_logic;     
    signal en_signal                              : std_logic;
    --rand
    signal rand_out                               : std_logic;
    signal rand_out_valid                         : std_logic;
    signal counter_rand, counter2_rand            : integer;
    signal flag_rand                              : std_logic;     
    --fec
    signal fec_out                                : std_logic;
    signal fec_out_valid                          : std_logic;
    signal counter_fec                            : integer;
    signal flag_fec                               : std_logic; 
    --int
    signal int_out                                : std_logic;
    signal int_out_valid                          : std_logic;
    signal counter_int                            : integer;
    signal flag_int                               : std_logic; 
    --mod
    signal mod_out1                               : std_logic_vector(15 downto 0);
    signal mod_out2                               : std_logic_vector(15 downto 0);
    signal mod_out_valid                          : std_logic;
    signal counter_mod                            : integer;
    signal flag_mod                               : std_logic; 


begin 

    locked2 <= not locked; 
    --Instantiations
    pll1: PLL port map 
    (
        refclk                      => clk_50mhz,
        rst                         => reset,
        outclk_0                    => clk_100mhz_sig,
        outclk_1                    => clk_50mhz_sig,
        locked                      => locked
    );

    wimax1: WiMax_phase3 port map 
    (
        clk_50mhz       => clk_50mhz_sig,
        clk_100mhz      => clk_100mhz_sig,
        reset           => locked2, 
        en              => en_signal, 
        load            => load,
        data_in         => data_in_signal_bit,
        out_rand_out    => rand_out,
        out_rand_valid  => rand_out_valid,
        out_fec_out     => fec_out,
        out_fec_valid   => fec_out_valid,
        out_int_out     => int_out,
        out_int_valid   => int_out_valid,
        WiMax_out_valid => mod_out_valid, 
        data_out1       => mod_out1,
        data_out2       => mod_out2
    );

    --take input into module 
    process (clk_50mhz_sig, reset) begin 
        if (reset = '1') then 
            counter_rand <= 95;    
            en_signal    <= '0'; 
        elsif (rising_edge(clk_50mhz_sig)) then 
            if (load = '0' and counter_rand > 0 and counter_rand <= 95 and en = '1') then 
                en_signal <= '1';
                data_in_signal_bit <= rand_in_data_rom(counter_rand); 
                counter_rand <= counter_rand - 1; 
            elsif (load = '0' and counter_rand = 0 and en = '1') then 
                en_signal           <= '1';
                data_in_signal_bit  <= rand_in_data_rom(counter_rand); 
                counter_rand        <= 95;
            end if; 
        end if; 
    end process;

    --rand
    process (clk_50mhz_sig, reset) begin 
        if (reset = '1') then 
            counter2_rand <= 95; 
            flag_rand <= '0';
            rand_pass <= '0';            
        elsif (rising_edge(clk_50mhz_sig)) then 
            if (load = '0' and counter2_rand > 0 and counter2_rand <= 95 and en_signal = '1') then
                if ((rand_out = rand_out_data_rom(counter2_rand)) and (flag_rand = '0')) then 
                    rand_pass <= '1';
                    counter2_rand <= counter2_rand - 1; 
                else 
                    flag_rand       <= '1'; 
                    rand_pass       <= '0';                     
                end if;
            end if; 
            if(counter2_rand = 0) then 
                counter2_rand   <= 95;
            end if;
        end if; 
    end process; 

    --fec
    process (clk_100mhz_sig, reset) begin 
        if(reset = '1') then 
            fec_pass    <= '0';
            counter_fec <= 191;  
            flag_fec    <= '0';      
        elsif(rising_edge(clk_100mhz_sig)) then 
            if(fec_out_valid = '1') then 
                if(counter_fec >= 0) then 
                    if(fec_out = fec_out_data_rom(counter_fec) and flag_fec = '0') then 
                        fec_pass    <= '1';
                        counter_fec <= counter_fec - 1;
                    else 
                        flag_fec    <= '1';
                        fec_pass    <= '0';
                    end if;
                end if;
                if (counter_fec = 0) then 
                    counter_fec <= 191;
                end if;
            end if;
        end if;
    end process;

    --int
    process (clk_100mhz_sig, reset) begin 
        if(reset = '1') then 
            int_pass    <= '0';
            counter_int <= 191;  
            flag_int    <= '0';      
        elsif(rising_edge(clk_100mhz_sig)) then 
            if(int_out_valid = '1') then 
                if(counter_int >= 0) then 
                    if(int_out = int_out_data_rom(counter_int) and flag_int = '0') then 
                        int_pass    <= '1';
                        counter_int <= counter_int - 1;
                    else 
                        flag_int    <= '1';
                        int_pass    <= '0';                        
                    end if;
                end if;
                if (counter_int = 0) then 
                    counter_int <= 191;
                end if;
            end if;
        end if;
    end process;

    --mod
    process (clk_50mhz_sig, reset) begin 
        if(reset = '1') then 
            mod_pass    <= '0';
            counter_mod <= 191;  
            flag_mod    <= '0';      
        elsif(rising_edge(clk_50mhz_sig)) then 
            if(mod_out_valid = '1') then 
                if(counter_mod >= 1) then 
                    if(mod_out1(15) = mod_out_data_rom(counter_mod) and mod_out2(15) = mod_out_data_rom(counter_mod-1) and flag_mod = '0') then 
                        mod_pass    <= '1';
                        if(counter_mod > 1) then 
                            counter_mod <= counter_mod - 2;
                        end if;
                        if (counter_mod = 1) then
                           counter_mod  <= counter_mod - 1;         
                        end if;
                    else 
                        flag_mod    <= '1';
                        mod_pass    <= '0';
                    end if;
                end if;
                if (counter_mod = 1) then 
                    counter_mod <= 191;
                end if;
            end if;
        end if;
    end process;
end WiMax_verifier_arch;