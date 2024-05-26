----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2024 09:24:42 PM
-- Design Name: 
-- Module Name: uart_top - Behavioral
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

entity uart_top is
  Port ( 
    clk                        : in  std_logic;
    rst                        : in  std_logic;
    tx_en                      : in  std_logic;
    rx_in                      : in  std_logic;
    reg_sel                    : in  std_logic_vector(1 downto 0);
    data_to_be_displayed_flag  : in std_logic;
    data_to_be_displayed       : in  std_logic_vector(8 downto 0);
    my_id                      : in  std_logic_vector(3 downto 0);
    ps2_clk                    : in  std_logic;
    ps2_data                   : in  STD_LOGIC;
    retransmit_1               : out std_logic_vector(1 downto 0);
    uart_1_data                : out std_logic_vector(8 downto 0);
    tx_out                     : out std_logic;
    h_sync                     : out std_logic;
    v_sync                     : out STD_LOGIC;
    r, g, b                    : out STD_LOGIC_VECTOR(3 downto 0)   --pixel color           
  );
end uart_top;

architecture Behavioral of uart_top is

signal retransmit: std_logic_vector(1 downto 0);

component rx_top is
      Port (
        clk                        : in std_logic;
        reset                      : in std_logic;
        rx_in                      : in  STD_LOGIC;
        data_to_be_displayed_flag  : in std_logic;
        data_to_be_displayed       : in  std_logic_vector(8 downto 0);
        my_id                      : in  std_logic_vector(3 downto 0);
        retransmit                 : out std_logic_vector(1 downto 0);
        uart_1_data                : out std_logic_vector(8 downto 0);
        h_sync                     : out STD_LOGIC;                   --h_sync    
        v_sync                     : out STD_LOGIC;                   --v_sync
        r, g, b                    : out STD_LOGIC_VECTOR(3 downto 0) --pixel color  
        );
end component;

component tx_top is
    Port ( clk: in STD_LOGIC;
           rst: in STD_LOGIC; 
           ps2_clk: in STD_LOGIC; 
           ps2_data: in STD_LOGIC;
           retransmit                 : in std_logic_vector(1 downto 0);
           data_to_be_displayed       : in  std_logic_vector(8 downto 0);
           tx_en : in STD_LOGIC;
           reg_sel  : in  std_logic_vector(1 downto 0);
           tx_out : out STD_LOGIC);
end component;

begin

retransmit_1 <= retransmit;

rx: rx_top
port map (
    clk                       => clk,
    reset                     => rst,
    rx_in                     => rx_in,
    data_to_be_displayed_flag => data_to_be_displayed_flag,
    data_to_be_displayed      => data_to_be_displayed,
    my_id                     => my_id,
    retransmit                => retransmit,
    uart_1_data               => uart_1_data,
    h_sync                    => h_sync,
    v_sync                    => v_sync,
    r                         => r,
    g                         => g,
    b                         => b
);

tx :tx_top
port map (
    clk      => clk,
    rst      => rst,
    tx_en    => tx_en,
    tx_out   => tx_out,
    retransmit                => retransmit,
    data_to_be_displayed      => data_to_be_displayed,
    reg_sel  => reg_sel,
    ps2_clk  => ps2_clk,
    ps2_data => ps2_data
);

end Behavioral;
