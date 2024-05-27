----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.04.2024 19:49:23
-- Design Name: 
-- Module Name: game_top - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity multiplayer_game_top is
  Port ( 
    clk        : in  std_logic;
    reset      : in  std_logic;
    ps2_clk    : in  std_logic;                   
    ps2_data   : in  std_logic; 
    rx_in_1    : in  std_logic;
    rx_in_2    : in  std_logic;
    rx_in_3    : in  std_logic;        
    tx_out_1   : out std_logic;    
    tx_out_2   : out std_logic;                    
    tx_out_3   : out std_logic;                                        
    Hsync      : out std_logic;
    Vsync      : out std_logic;
    R          : out std_logic_vector (3 downto 0);
    G          : out std_logic_vector (3 downto 0);
    B          : out std_logic_vector (3 downto 0);
    data_out: out std_logic_vector (7 downto 0);
    data_out_en: out std_logic
  );
end multiplayer_game_top;

architecture Behavioral of multiplayer_game_top is


signal ascii_new            : std_logic;
signal data_received_flag_1 : std_logic; 
signal data_received_flag_2 : std_logic; 
signal data_received_flag_3 : std_logic; 
signal start_flag           : std_logic;
signal reset_flag           : std_logic;
signal player_en_1          : std_logic;
signal player_en_2          : std_logic;
signal player_en_3          : std_logic;
signal player_en_4          : std_logic;
signal data_received_1      : std_logic_vector (7 downto 0);
signal data_received_2      : std_logic_vector (7 downto 0);
signal data_received_3      : std_logic_vector (7 downto 0);
signal keyboard_char        : std_logic_vector (6 downto 0);
signal input_host           : std_logic_vector (7 downto 0);

signal clk_25mhz: std_logic;
 

component vga_multiplayer is
Port (
    clk_100mhz      : in std_logic;
    data_received_1 : in std_logic_vector (7 downto 0);
    data_received_2 : in std_logic_vector (7 downto 0);
    data_received_3 : in std_logic_vector (7 downto 0);      
    keyboard_char   : in std_logic_vector (6 downto 0);
    player_en_2     : in std_logic;
    player_en_3     : in std_logic;
    player_en_4     : in std_logic;
    start_flag      : in std_logic;
    reset_flag      : in std_logic;
    Hsync           : out std_logic;
    Vsync           : out std_logic;
    R               : out std_logic_vector (3 downto 0);
    G               : out std_logic_vector (3 downto 0);
    B               : out std_logic_vector (3 downto 0));
end component; 

component ps2_keyboard_to_ascii is
  GENERIC(
      clk_freq                  : INTEGER := 50_000_000; 
      ps2_debounce_counter_size : INTEGER := 8);         
  PORT(
      clk        : IN  STD_LOGIC;                   
      ps2_clk    : IN  STD_LOGIC;                    
      ps2_data   : IN  STD_LOGIC;                     
      ascii_new  : OUT STD_LOGIC;                     
      ascii_code : OUT STD_LOGIC_VECTOR(6 DOWNTO 0));
end component; 

component uart_top_multiplayer is
Port (
   clk                 :        in  std_logic;
   rx_in               :        in  std_logic;
   ascii_new           :        in  std_logic;                   -- from keyboard
   ascii_code          :        in  std_logic_vector(6 downto 0);-- from keyboard  
   data_received       :        out std_logic_vector(7 downto 0);
   data_received_flag  :        out std_logic;
   tx_out              :        out std_logic
 );
end component;

component clk_wiz_0 
    port(
    clk_in1 : in std_logic;
    clk_out1: out std_logic
    );
end component;

component host 
 Port ( 
        clk_25mhz         : in  std_logic;
        data_received     : in  std_logic_vector (7 downto 0);
        start_flag        : out std_logic;
        reset_flag        : out std_logic;
        flag_player_1     : out std_logic;
        flag_player_2     : out std_logic;
        flag_player_3     : out std_logic;
        flag_player_4     : out std_logic 
 );
end component;

begin

input_host <= '0' & keyboard_char when start_flag ='1' else data_received_2;

clk_wizard: clk_wiz_0 
    port map(
    clk_in1  => clk,
    clk_out1 =>  clk_25mhz
);

  game:  vga_multiplayer
    PORT MAP(
    clk_100mhz      => clk, 
    data_received_1 => data_received_1,
    data_received_2 => data_received_2,
    data_received_3 => data_received_3,
    player_en_2     => player_en_2,
    player_en_3     => player_en_3,
    player_en_4     => player_en_4,
    start_flag      => start_flag,
    reset_flag      => reset_flag,
    keyboard_char   => keyboard_char,
    Hsync           => Hsync,
    Vsync           => Vsync,
    R               => R,
    G               => G,
    B               => B
    );
    

  ps2_keyboard:  ps2_keyboard_to_ascii
    GENERIC MAP(
    clk_freq => 100_000_000, 
    ps2_debounce_counter_size => 9)
    PORT MAP(
    clk        => clk, 
    ps2_clk    => ps2_clk, 
    ps2_data   => ps2_data, 
    ascii_new  => ascii_new, 
    ascii_code => keyboard_char);
  
 uart_1:  uart_top_multiplayer
    PORT MAP(
       clk                 => clk_25mhz,
       rx_in               => rx_in_1,
       ascii_new           => ascii_new,
       ascii_code          => keyboard_char,
       data_received       => data_received_1,
       data_received_flag  => data_received_flag_1,
       tx_out              => tx_out_1
    );
    
 uart_2:  uart_top_multiplayer
    PORT MAP(
       clk                 => clk_25mhz,
       rx_in               => rx_in_2,
       ascii_new           => ascii_new,
       ascii_code          => keyboard_char,
       data_received       => data_received_2,
       data_received_flag  => data_received_flag_2,
       tx_out              => tx_out_2
    );
    
 uart_3:  uart_top_multiplayer
    PORT MAP(
       clk                 => clk_25mhz,
       rx_in               => rx_in_3,
       ascii_new           => ascii_new,
       ascii_code          => keyboard_char,
       data_received       => data_received_3,
       data_received_flag  => data_received_flag_3,
       tx_out              => tx_out_3
    );        
        
    
    data_out <= data_received_1;
    data_out_en <= data_received_flag_1;
    
host_client: host 
 Port map ( 
        clk_25mhz         => clk_25mhz,    
        data_received     => input_host,
        start_flag        => start_flag,
        reset_flag        => reset_flag,
        flag_player_1     => player_en_1,
        flag_player_2     => player_en_2,
        flag_player_3     => player_en_3,
        flag_player_4     => player_en_4
   );
 
   

end Behavioral;
