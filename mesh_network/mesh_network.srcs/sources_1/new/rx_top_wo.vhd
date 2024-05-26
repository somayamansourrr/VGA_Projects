----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.05.2024 20:16:57
-- Design Name: 
-- Module Name: rx_top_wo - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;
use work.uart_constants.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values


-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity rx_top_wo is
Port (
        clk             : in std_logic;
        reset           : in std_logic;
        rx_in           : in  STD_LOGIC;
        ascii_new_out   : out std_logic;
        ascii_code_out  : out std_logic_vector(8 downto 0)
 );
end rx_top_wo;

architecture Behavioral of rx_top_wo is


component uart_rx is
  Port (
    clk,uart_clk,rst    : in std_logic;
    rx_in               : in std_logic;
    data                : out std_logic_vector(8 downto 0);
    data_new            : out std_logic    
    );
end component;

signal ascii_new        : std_logic := '0';
signal ascii_code       : std_logic_vector(8 downto 0) := "000000000";
signal past_ascii_new   : std_logic := '0';

signal count            : integer range 0 to BIT_TIME-1;
signal uart_clk         : std_logic; -- 1 when count is 0 and 0 otherwise

begin
uart_rx_0: uart_rx  
    port map(clk=>clk,uart_clk=>uart_clk,rst=>reset,rx_in=>rx_in,data=>ascii_code,data_new=>ascii_new);   

    ascii_new_out <= ascii_new;
    ascii_code_out <= ascii_code;
  
    
    process(clk)    -- handling count and uart clk
    begin
        if(rising_edge(clk)) then
            if(count = 0) then
                count <= BIT_TIME - 1;
                uart_clk <= '1';
            else 
                count <= count-1;
                uart_clk <= '0';
            end if;
        end if;
    end process;


end Behavioral;
