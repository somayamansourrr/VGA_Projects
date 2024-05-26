----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.05.2024 22:02:29
-- Design Name: 
-- Module Name: mesh_network - Behavioral
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

entity mesh_network is
  Port ( 
    clk        : in  std_logic;
    reset      : in  std_logic; 
    ps2_clk    : in  std_logic;                    
    ps2_data   : in  std_logic;
    my_id      : in  std_logic_vector(3 downto 0);
    sending_to : in  std_logic_vector(3 downto 0);
    rx_in      : in  std_logic;  
    rx_in_2    : in  std_logic;
    tx_out     : out std_logic;
    tx_out_2   : out std_logic;                
    Hsync      : out std_logic;
    Vsync      : out std_logic;
    test       : out std_logic_vector (7 downto 0);
    test2      : out std_logic_vector (7 downto 0);
    R          : out std_logic_vector (3 downto 0);
    G          : out std_logic_vector (3 downto 0);
    B          : out std_logic_vector (3 downto 0)
  );
end mesh_network;

architecture Behavioral of mesh_network is

signal clk_25mhz                  : std_logic := '0';
signal tx_start1                  : std_logic;
signal tx_start2                  : std_logic;
signal data_received_flag_fpga3   : std_logic; 
signal data_received_fpga3        : std_logic_vector (8 downto 0);
signal data_received_fpga2        : std_logic_vector (8 downto 0);
signal reg_sel                    : std_logic_vector(1 downto 0);

signal retransmit : std_logic_vector(1 downto 0);



component uart_top is
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
    r, g, b                    : out STD_LOGIC_VECTOR(3 downto 0)
 );
end component;

component uart_top_wo
  Port ( 
    clk             : in  std_logic;
    rst             : in  std_logic;
    tx_en           : in  std_logic;
    rx_in           : in  std_logic;
    ps2_clk         : in  std_logic;
    ps2_data        : in  STD_LOGIC;
    reg_sel         : in  std_logic_vector(1 downto 0);
    tx_out          : out std_logic;
    ascii_new_out   : out std_logic;
    ascii_code_out  : out std_logic_vector(8 downto 0)      
  );
end component;

begin

reg_sel <= "00" when sending_to = "0001" else 
           "01" when sending_to = "0010" else 
           "10" when sending_to = "0100" else 
           "11" when sending_to = "1000";

FPGA_sel:process(clk)
begin   
    if(my_id = "0001") then 
        if sending_to = "0010" then
            tx_start1 <= '1';
            tx_start2 <= '0';
        elsif sending_to = "0100" or sending_to = "1000" then
            tx_start2 <= '1';
            tx_start1 <= '0';
        else
            tx_start2 <= '0';
            tx_start1 <= '0';
        end if;
    elsif(my_id = "0010") then
        if sending_to = "0001" then
            tx_start1 <= '1';
            tx_start2 <= '0';
        elsif sending_to = "1000" or sending_to = "0100" then
            tx_start2 <= '1';
            tx_start1 <= '0';
        else
            tx_start2 <= '0';
            tx_start1 <= '0';            
        end if;
        
    elsif(my_id = "0100") then
        if sending_to = "0001" or sending_to = "0010" then
            tx_start2 <= '1';
            tx_start1 <= '0';
        elsif sending_to = "1000" then
            tx_start1 <= '1';
            tx_start2 <= '0';
        else
            tx_start2 <= '0';
            tx_start1 <= '0';            
        end if;         
        
    elsif(my_id = "1000") then
        if sending_to = "0100" then
            tx_start1 <= '1';
            tx_start2 <= '0';
        elsif sending_to = "0010" or sending_to = "0001" then
            tx_start2 <= '1';
            tx_start1 <= '0';
        else
            tx_start2 <= '0';
            tx_start1 <= '0';            
        end if;  
    else  
        tx_start2 <= '0';
        tx_start1 <= '0';      
       
    end if;
end process;



   uart_fpga2:  uart_top
    PORT MAP(
    clk                          => clk, 
    rst                          => reset,
    rx_in                        => rx_in,
    tx_en                        => tx_start1,
    reg_sel                      => reg_sel,
    ps2_clk                      => ps2_clk,
    ps2_data                     => ps2_data,
    data_to_be_displayed_flag    => data_received_flag_fpga3, 
    data_to_be_displayed         => data_received_fpga3,
    my_id                        => my_id, 
    retransmit_1                 => retransmit,
    uart_1_data                  => data_received_fpga2,
    tx_out                       => tx_out,
    h_sync                       => Hsync,
    v_sync                       => Vsync,
    r                            => R,
    g                            => G,
    b                            => B
    );
    
   uart_fpga3:  uart_top_wo
    port map(
    clk                => clk, 
    rst                => reset,
    rx_in              => rx_in_2,
    tx_en              => tx_start2,
    ps2_clk            => ps2_clk,
    ps2_data           => ps2_data,
    reg_sel            => reg_sel,
    tx_out             => tx_out_2,
    ascii_new_out      => data_received_flag_fpga3, 
    ascii_code_out     => data_received_fpga3
    );
    
    test <= data_received_fpga3(7 downto 0);
    test2 <= data_received_fpga2(7 downto 0);
       

    
end Behavioral;
