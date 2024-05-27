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

entity game_top is
  Port ( 
    clk : in std_logic;
    ps2_clk    : IN  STD_LOGIC;                    
    ps2_data   : IN  STD_LOGIC; 
    ascii_new  : out std_logic;                   
    Hsync : out std_logic;
    Vsync : out std_logic;
    ascii_out: out std_logic_vector(6 downto 0);
    top: out std_logic;
    bottom: out std_logic;
    R : out std_logic_vector (3 downto 0);
    G : out std_logic_vector (3 downto 0);
    B : out std_logic_vector (3 downto 0)
  );
end game_top;

architecture Behavioral of game_top is

signal move_up: std_logic;
signal move_down: std_logic; 
signal move_left: std_logic; 
signal move_right: std_logic;
signal restart_game: std_logic; 
signal keyboard_char: std_logic_vector (6 downto 0);
 

component vga_game_background is
Port (
    clk_100mhz : in std_logic;
    btnT       : in std_logic;
    btnB       : in std_logic;
    btnL       : in std_logic;
    btnR       : in std_logic;
    btnRST     : in std_logic;
    keyboard_char: in std_logic_vector (6 downto 0);
    Hsync      : out std_logic;
    Vsync      : out std_logic;
    R          : out std_logic_vector (3 downto 0);
    G          : out std_logic_vector (3 downto 0);
    B          : out std_logic_vector (3 downto 0));
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

begin

  game:  vga_game_background
    PORT MAP(
    clk_100mhz => clk, 
    btnT => move_up, 
    btnB => move_down, 
    btnL => move_left, 
    btnR => move_right,
    btnRST => restart_game,
    keyboard_char => keyboard_char,
    Hsync => Hsync,
    Vsync => Vsync,
    R => R,
    G => G,
    B => B
    );
    

  ps2_keyboard:  ps2_keyboard_to_ascii
    GENERIC MAP(
    clk_freq => 100_000_000, 
    ps2_debounce_counter_size => 9)
    PORT MAP(
    clk => clk, 
    ps2_clk => ps2_clk, 
    ps2_data => ps2_data, 
    ascii_new => ascii_new, 
    ascii_code => keyboard_char);
    
move_up      <= '1' when keyboard_char = x"77" else '0';
move_down    <= '1' when keyboard_char = (x"73" or x"53") else '0';
move_left    <= '1' when keyboard_char = (x"61" or x"41") else '0';
move_right   <= '1' when keyboard_char = (x"64" or x"44") else '0';
restart_game <= '1' when keyboard_char = x"20" else '0';    

top <= move_up;
bottom <= move_down;

ascii_out <= keyboard_char;
    



end Behavioral;
