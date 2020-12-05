library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
LIBRARY altera_mf;
USE altera_mf.altera_mf_components.all;

entity PingPong_tb is 
end PingPong_tb;

architecture tb_arch of PingPong_tb is

    --component 
    component PingPong is 
        port(	clock:	in std_logic;
        Rst:	in std_logic;
        Q:	out std_logic_vector(7 downto 0)
        );
    end component PingPong;

    --signals 
    signal clock    : std_logic; 
    signal Rst      : std_logic := '0';
    signal Q        : std_logic_vector(7 downto 0);

begin 

    --instant 
    uut: PingPong port map 
    (
        clock   => clock,
        Rst     => Rst  ,
        Q       => Q    
    );

    process begin 

    end 
    --clock 
    clock <= not clock after 20 ns;

end tb_arch;