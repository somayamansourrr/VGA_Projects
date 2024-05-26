
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mesh_network_tb is
--  Port ( );
end mesh_network_tb;

architecture Behavioral of mesh_network_tb is

component mesh_network is 
    Port ( 
    clk        : in  std_logic;
    reset      : in  std_logic; 
    ps2_clk    : in  std_logic;                    
    ps2_data   : in  std_logic;
    my_id      : in  std_logic_vector(3 downto 0);
    sending_to : in  std_logic_vector(3 downto 0);
    rx_in    : in  std_logic;  
    rx_in_2    : in  std_logic;
    tx_out   : out std_logic;
    tx_out_2   : out std_logic;                
    Hsync      : out std_logic;
    Vsync      : out std_logic;
    --retransmit : out std_logic;
    test       : out std_logic_vector (7 downto 0);
    test2      : out std_logic_vector (7 downto 0);
    --tx_start   : out std_logic_vector (1 downto 0);
    --tx_test : out std_logic;
    R          : out std_logic_vector (3 downto 0);
    G          : out std_logic_vector (3 downto 0);
    B          : out std_logic_vector (3 downto 0)
  );
end component;

signal clk, reset: std_logic := '0';
signal rx_in, rx_in_2, ps2_clk, ps2_data  : std_logic := '1';
signal my_id, sending_to : std_logic_vector(3 downto 0) := "0000";
signal tx_out, tx_out_2, Hsync, Vsync : std_logic;
signal test : std_logic_vector(7 downto 0);
signal test2: std_logic_vector(7 downto 0);
signal tx_start: std_logic_vector(1 downto 0);
signal tx_test: std_logic;
signal R, G, B: std_logic_vector(3 downto 0);
 

begin

    uut: mesh_network port map(clk => clk,
                               reset => reset,
                               ps2_clk => ps2_clk,
                               ps2_data => ps2_data,
                               my_id => my_id,
                               sending_to => sending_to,
                               rx_in => rx_in,
                               rx_in_2 => rx_in_2,
                               tx_out => tx_out,
                               tx_out_2 => tx_out_2,
                               Hsync => Hsync,
                               Vsync => Vsync,
                               test => test,
                               test2 => test2,
                              -- tx_start => tx_start,
                               --tx_test => tx_test,
                               R => R,
                               G => G,
                               B => B);
                             
    clock_process: process 
        begin
            clk <= '0'; wait for 5ns;
            clk <= '1'; wait for 5ns;
        end process;
        
--    ps2_clk_1 : process
--        begin
        
--        wait for 35000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';                
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';
--        wait for 50000ns; ps2_clk <= '1';
--        wait for 50000ns; ps2_clk <= '0';        
--        wait for 50000ns; ps2_clk <= '1'; wait;
                                                      
--        end process;    
        
        
        
    stimulus_process: process
        begin
            --my_id <= "0010"; sending_to <= "0100";  
            my_id <= "1000"; sending_to <= "0000"; 
            wait for 1000ns;
            rx_in_2 <= '0'; rx_in <= '1'; wait for 208320ns;
            rx_in_2 <= '1'; wait for 104160ns;
            rx_in_2 <= '1'; wait for 104160ns;
            rx_in_2 <= '1'; wait for 104160ns;
            rx_in_2 <= '1'; wait for 104160ns;
            rx_in_2 <= '0'; wait for 104160ns;
            rx_in_2 <= '1'; wait for 104160ns;
            rx_in_2 <= '0'; wait for 104160ns;
            rx_in_2 <= '1'; wait for 104160ns;
            rx_in_2 <= '0'; wait for 104160ns;
            rx_in_2 <= '1'; wait;
        end process; 

end Behavioral;
