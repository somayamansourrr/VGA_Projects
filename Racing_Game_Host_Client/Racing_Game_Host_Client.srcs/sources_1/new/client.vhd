----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/10/2024 07:44:59 PM
-- Design Name: 
-- Module Name: host - Behavioral
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

entity client is
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
end client;

architecture Behavioral of client is

signal num_players : std_logic_vector(2 downto 0);

begin

flag_player_1 <= '1';
flag_player_2 <= '1' when num_players >= "010" else '0';
flag_player_3 <= '1' when num_players >= "011" else '0';
flag_player_4 <= '1' when num_players >= "100" else '0';

start_flag <= '0';
reset_flag <= '0';

setting_num_players : process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
    if(data_received = x"31") then 
        num_players <= "001";
    elsif(data_received = x"32") then
        num_players <= "010";
    elsif(data_received = x"33") then
        num_players <= "011";
    elsif(data_received = x"34") then
        num_players <= "100";
     end if;
 end if;
end process;

end Behavioral;
