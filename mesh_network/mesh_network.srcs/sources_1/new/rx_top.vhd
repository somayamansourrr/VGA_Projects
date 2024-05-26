library IEEE;
library work;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.constants.ALL;
use work.uart_constants.ALL;


-- takes ascii codes from ps2_keyboard_to_ascii and makes an array with current displayed characters on screen
-- the array is sent to the display module to be displayed


entity rx_top is
      Port (
        clk                        : in  std_logic;
        reset                      : in  std_logic;
        rx_in                      : in  std_logic;
        data_to_be_displayed_flag  : in  std_logic;
        data_to_be_displayed       : in  std_logic_vector(8 downto 0);
        my_id                      : in  std_logic_vector(3 downto 0);
        retransmit                 : out std_logic_vector(1 downto 0);
        uart_1_data                : out std_logic_vector(8 downto 0);
        h_sync                     : out std_logic;                   --h_sync    
        v_sync                     : out std_logic;                   --v_sync
        r, g, b                    : out std_logic_vector(3 downto 0) --pixel color  
        );
end rx_top;

architecture Behavioral of rx_top is

component uart_rx is
  Port (
    clk         : in std_logic;
    uart_clk    : in std_logic;
    rst         : in std_logic;
    rx_in       : in std_logic;
    data        : out std_logic_vector(8 downto 0);
    data_new    : out std_logic    
    );
end component;


component Display is
    port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;                           --reset
        chars : in t_chars ; 
        countchx : in integer range 0 to H_CHARS-1;
        countchy : in integer range 0 to V_CHARS-1;                           
        h_sync : out STD_LOGIC;                         --h_sync    
        v_sync : out STD_LOGIC;                         --v_sync
        r, g, b : out STD_LOGIC_VECTOR(3 downto 0)      --pixel color  
    );
end component;

signal chars : t_chars;
signal countcharx : integer range 0 to H_CHARS-1 := 0;
signal countchary : integer range 0 to V_CHARS-1 := 0;
signal ascii_new : std_logic := '0';
signal ascii_code : std_logic_vector(8 downto 0) := "000000000";
signal past_ascii_new : std_logic := '0';
signal past_ascii_new_2 : std_logic := '0';

signal display_fpga : std_logic_vector(6 downto 0);

signal count : integer range 0 to BIT_TIME-1;
signal uart_clk : std_logic; -- 1 when count is 0 and 0 otherwise

signal dest_direct: std_logic;
signal dest_direct_2: std_logic_vector(1 downto 0);

begin

dest_direct_2 <= "00" when data_to_be_displayed_flag='0' else
                 "01" when ((data_to_be_displayed(1 downto 0) = "00" and data_to_be_displayed_flag='1') and my_id = "0001")  
                 or((data_to_be_displayed(1 downto 0) = "01" and data_to_be_displayed_flag='1') and my_id = "0010")  
                 or((data_to_be_displayed(1 downto 0) = "10" and data_to_be_displayed_flag='1') and my_id = "0100")  
                 or((data_to_be_displayed(1 downto 0) = "11" and data_to_be_displayed_flag='1') and my_id = "1000") else 
                 "10";
               
dest_direct <= '0' when ((ascii_code(1 downto 0) = "00" and (ascii_new = '1')) and my_id = "0001") else 
               '0' when ((ascii_code(1 downto 0) = "01" and (ascii_new = '1')) and my_id = "0010") else 
               '0' when ((ascii_code(1 downto 0) = "10" and (ascii_new = '1')) and my_id = "0100") else 
               '0' when ((ascii_code(1 downto 0) = "11" and (ascii_new = '1')) and my_id = "1000") else 
               '1';               

retransmit <= dest_direct_2;
 
display_fpga <= data_to_be_displayed(8 downto 2) when data_to_be_displayed_flag='1' else ascii_code(8 downto 2);
uart_1_data  <= ascii_code;

uart_rx_0: uart_rx  
    port map(
        clk=>clk,
        uart_clk=>uart_clk,
        rst=>reset,
        rx_in=>rx_in,
        data=>ascii_code,
        data_new=>ascii_new);   
        
display_0: Display 
    port map(
        clk=>clk,
        reset=>reset,
        chars=>chars,
        countchx=>countcharx,
        countchy=>countchary,
        h_sync=>h_sync,
        v_sync=>v_sync,
        r=>r,
        g=>g,
        b=>b);
        
    process(clk)
    begin
        if(rising_edge(clk))then
            if ((((past_ascii_new = '0') and (ascii_new = '1') and dest_direct='0') or (past_ascii_new_2='0' and data_to_be_displayed_flag='1' and dest_direct_2="01")))  then
                if(ascii_code = "0001000") then    --delete
                    if(countcharx > 0) then
                        countcharx<=countcharx-1;
                    elsif(countchary>0) then
                        countchary<=countchary-1;
                        countcharx<=H_CHARS-1;  
                    end if;
                         
                else
                    chars(countcharx,countchary)<=  display_fpga;
                    countcharx<=countcharx+1;
                    if(countcharx=H_CHARS-1)then
                        countchary<=countchary+1;
                        countcharx<=0;
                    end if;
                end if;             
            end if;
            past_ascii_new <= ascii_new;
            past_ascii_new_2 <= data_to_be_displayed_flag;
            
        end if;   
    end process;
    
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
