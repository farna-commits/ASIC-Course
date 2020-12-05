library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity WiMax is 
    port(
        clk_50mhz                            	  : in    std_logic; 
        reset                 	                  : in    std_logic; 
        en                 	                      : in    std_logic; 
        load               	                      : in    std_logic; 
        data_in                               	  : in    std_logic; 
        WiMax_out_valid                           : out   std_logic;
        data_out1                              	  : out   std_logic_vector(15 downto 0);
        data_out2                              	  : out   std_logic_vector(15 downto 0) 
    );
end WiMax;

architecture WiMax_arch of WiMax is

    --components 
    component PLL is 
        port (
            refclk                                : in  std_logic := 'X'; --  refclk.clk
            rst                                   : in  std_logic := 'X'; --   reset.reset
            outclk_0                              : out std_logic;        -- outclk0.clk
            outclk_1                              : out std_logic;        -- outclk1.clk
            locked                                : out std_logic         --  locked.export
        );
    end component;

    component randomizer
       port(
            clk_50mhz, reset, rand_in_ready       : in  std_logic; 
            load                                  : in  std_logic;
            rand_in                               : in  std_logic;
            rand_out                              : out std_logic;
            rand_out_valid                        : out std_logic
       );
    end component;

    component states_FEC_encoder
        port(
            clk_50mhz, clk_100mhz                 : in    std_logic; 
            reset, rand_out_valid                 : in    std_logic; 
            data_in                               : in    std_logic; 
            FEC_encoder_out_valid_out             : out   std_logic; 
            data_out                              : out   std_logic
        );
    end component;

    component states_interleaver
        port(
            clk_100mhz                            : in    std_logic; 
            reset, FEC_encoder_out_valid          : in    std_logic; 
            data_in                               : in    std_logic; 
            interleaver_out_valid                 : out   std_logic; 
            data_out                              : out   std_logic
        );
    end component;

    component modulation
        port(
            clk_100mhz                            : in  std_logic; 
            reset                                 : in  std_logic; 
            interleaver_out_valid                 : in  std_logic; 
            data_in                               : in  std_logic; 
            modulation_out_valid                  : out std_logic; 
            output1, output2                      : out std_logic_vector(15 downto 0) 

        );
    end component;

    --signals 

    --PLL
    signal  clk_50mhz_sig                         : std_logic;
    signal  clk_100mhz_sig                        : std_logic;
    signal  locked                                : std_logic;
    signal  locked2                               : std_logic;
 
    --randomizer          
    signal  rand_out                              : std_logic;
    signal  rand_out_valid                        : std_logic;
 
    --FEC         
    signal  FEC_encoder_out_valid_out             : std_logic;
    signal  fec_out                               : std_logic;
 
    --Interleaver         
    signal  interleaver_out_valid                 : std_logic;
    signal  interleaver_out                       : std_logic;


begin
    --reset for other blocks (blocks' reset is active high)
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

    rand1: randomizer port map 
    (
        clk_50mhz                   => clk_50mhz_sig,
        reset                       => locked2,
        rand_in_ready               => en,
        load                        => load,             
        rand_in                     => data_in,               
        rand_out                    => rand_out,             
        rand_out_valid              => rand_out_valid             
    );

    fec1: states_FEC_encoder port map
    (
        clk_50mhz                   => clk_50mhz_sig,
        clk_100mhz                  => clk_100mhz_sig,
        reset                       => locked2, 
        rand_out_valid              => rand_out_valid,
        data_in                     => rand_out,
        FEC_encoder_out_valid_out   => FEC_encoder_out_valid_out, 
        data_out                    => fec_out       
    );

    int1: states_interleaver port map 
    (
        clk_100mhz                  => clk_100mhz_sig,           
        reset                       => locked2,
        FEC_encoder_out_valid       => FEC_encoder_out_valid_out,
        data_in                     => fec_out,      
        interleaver_out_valid       => interleaver_out_valid,
        data_out                    => interleaver_out 
    );

    mod1: modulation port map 
    (
        clk_100mhz                  => clk_100mhz_sig,   
        reset                       => locked2,
        interleaver_out_valid       => interleaver_out_valid,
        data_in                     => interleaver_out,
        modulation_out_valid        => WiMax_out_valid,
        output1                     => data_out1,
        output2                     => data_out2     
    );

end WiMax_arch;