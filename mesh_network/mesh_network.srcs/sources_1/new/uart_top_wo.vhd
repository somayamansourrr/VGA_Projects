----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.05.2024 20:22:11
-- Design Name: 
-- Module Name: uart_top_wo - Behavioral
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

entity uart_top_wo is
  Port ( 
    clk                 : in  std_logic;
    rst                 : in  std_logic;
    tx_en               : in  std_logic;
    rx_in               : in  std_logic;
    ps2_clk             : in  std_logic;
    ps2_data            : in  STD_LOGIC;
    reg_sel             : in  std_logic_vector(1 downto 0);
    tx_out              : out std_logic;
    ascii_new_out       : out std_logic;
    ascii_code_out      : out std_logic_vector(8 downto 0)      
  );
end uart_top_wo;

architecture Behavioral of uart_top_wo is

signal retransmit: std_logic_vector(1 downto 0):="00";
signal data_to_be_displayed: std_logic_vector (8 downto 0);
signal tx_test: std_logic;


component rx_top_wo is
      Port (
        clk             : in std_logic;
        reset           : in std_logic;
        rx_in           : in  STD_LOGIC;
        ascii_new_out   : out std_logic;        
        ascii_code_out  : out std_logic_vector(8 downto 0)
        );
end component;

component tx_top is
    Port ( clk: in STD_LOGIC;
           rst: in STD_LOGIC; 
           ps2_clk: in STD_LOGIC; 
           ps2_data: in STD_LOGIC;
           tx_en : in STD_LOGIC;
           retransmit                 : in std_logic_vector(1 downto 0);
           data_to_be_displayed       : in  std_logic_vector(8 downto 0);
           reg_sel  : in  std_logic_vector(1 downto 0);
           tx_test  : out std_logic;
           tx_out : out STD_LOGIC);
end component;

begin

rx: rx_top_wo
port map (
    clk             => clk,
    reset           => rst,
    rx_in           => rx_in,
    ascii_new_out   => ascii_new_out,
    ascii_code_out  => ascii_code_out
);

tx :tx_top
port map (
    clk             => clk,
    rst             => rst,
    tx_en           => tx_en,
    tx_out          => tx_out,
    reg_sel         => reg_sel,
    retransmit      => retransmit,
    tx_test         => tx_test,
    data_to_be_displayed => data_to_be_displayed,
    ps2_clk         => ps2_clk,
    ps2_data        => ps2_data
);


end Behavioral;
