library ieee ;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

----------------------------------------------------

entity PingPong is
port(	clock:	in std_logic;
	Rst:	in std_logic;
	Q:	out std_logic_vector(7 downto 0)
);
end PingPong; 

----------------------------------------------------

architecture behv of PingPong is		 	  

		component Clock_100MHz is
		port (
			refclk   : in  std_logic := 'X'; 
			rst      : in  std_logic := 'X'; 
			outclk_0 : out std_logic;        
			outclk_1 : out std_logic;        
			locked   : out std_logic         
		);
	end component Clock_100MHz;

	
	component RAM_2port IS
	PORT
	(
		address_a	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		address_b	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
		clock_a		: IN STD_LOGIC  := '1';
		clock_b		: IN STD_LOGIC ;
		data_a		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		data_b		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
		wren_a		: IN STD_LOGIC  := '0';
		wren_b		: IN STD_LOGIC  := '0';
		q_a		    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		q_b		    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
	);
	END component;
	
	signal Clk_50MHz,Clk_100MHz : std_logic;
	signal locked : std_logic;
	
	signal address_a	: STD_LOGIC_VECTOR (8 DOWNTO 0);
	signal address_b	: STD_LOGIC_VECTOR (8 DOWNTO 0);
	signal data_a		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal data_b		: STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal wren_a		: STD_LOGIC  := '1';
	signal wren_b		: STD_LOGIC  := '0';
	signal q_a		    : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal q_b		    : STD_LOGIC_VECTOR (7 DOWNTO 0);
    signal q_b2		    : STD_LOGIC_VECTOR (7 DOWNTO 0);
	
    signal Pre_Q: std_logic_vector(8 downto 0);

begin

    q_b2    <= q_b; 
	clock_100mhz_inst : Clock_100MHz
		port map (
			refclk   => clock,   
			rst      => Rst,      
			outclk_0 => Clk_50MHz, 
			outclk_1 => Clk_100MHz, 
			locked   => locked    
		);
		
		RAM_2portIns: RAM_2port
		PORT map 
		(
			address_a   => address_a,
			address_b   => address_b,
			clock_a     => Clk_50MHz, 
			clock_b     => Clk_100MHz,
			data_a      => data_a,
			data_b      => data_b,
			wren_a      => '1',
			wren_b      => '0',
			q_a         => q_a,
			q_b         => q_b
		);



    process(Clk_50MHz, Rst)
    begin
	if Rst = '1' then
 	    Pre_Q <= (others=>'0');
	elsif (Clk_50MHz='1' and Clk_50MHz'event) then
	    if locked = '1' then
				Pre_Q <= Pre_Q + 1;
	    end if;
	end if;
    end process;	
	
    -- concurrent assignment statement
     address_a <= Pre_Q;
	 address_b <= not(Pre_Q(8)) & Pre_Q(7 downto 0);
	 data_a <= Pre_Q(7 downto 0);
	 data_b <= "00000000";

	 Q <= q_b2;

end behv;
