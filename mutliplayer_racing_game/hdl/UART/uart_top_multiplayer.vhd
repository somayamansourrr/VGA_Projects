----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/17/2024 06:21:22 PM
-- Design Name: 
-- Module Name: uart_top_multiplayer - Behavioral
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
use work.uart_constants.ALL;
use work.constants.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity uart_top_multiplayer is
Port (
   clk                 :        in  std_logic;
   rx_in               :        in  std_logic;
   ascii_new           :        in  std_logic; -- from keyboard
   ascii_code          :        in  std_logic_vector(6 downto 0);-- from keyboard  
   data_received       :        out std_logic_vector(7 downto 0);-- from keyboard
   data_received_flag  :        out std_logic;
   tx_out              :        out std_logic
 );
end uart_top_multiplayer;

architecture Behavioral of uart_top_multiplayer is

signal to_transmit: std_logic_vector(7 downto 0);

signal o_TX_Active: std_logic;
signal o_TX_Done  : std_logic;

component uart_rx is
  generic (
    g_CLKS_PER_BIT : integer := 2605     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_RX_Serial : in  std_logic;
    o_RX_DV     : out std_logic;
    o_RX_Byte   : out std_logic_vector(7 downto 0)
    );
end component;

component uart_tx is 
  generic (
    g_CLKS_PER_BIT : integer := 2605     -- Needs to be set correctly
    );
  port (
    i_Clk       : in  std_logic;
    i_TX_DV     : in  std_logic;
    i_TX_Byte   : in  std_logic_vector(7 downto 0);
    o_TX_Active : out std_logic;
    o_TX_Serial : out std_logic;
    o_TX_Done   : out std_logic
    );
end component;

begin

to_transmit <= '0' & ascii_code; 

uart_rx_0: uart_rx  
port map(
    i_Clk       => clk,
    i_RX_Serial => rx_in,
    o_RX_DV     => data_received_flag,
    o_RX_Byte   => data_received
);

 uart_tx_0: uart_tx 
 port map(
    i_Clk       => clk,
    i_TX_DV     => ascii_new,
    i_TX_Byte    => to_transmit ,
    o_TX_Active  => o_TX_Active,
    o_TX_Serial  => tx_out,
    o_TX_Done    => o_TX_Done
 ); 
 
end Behavioral;
