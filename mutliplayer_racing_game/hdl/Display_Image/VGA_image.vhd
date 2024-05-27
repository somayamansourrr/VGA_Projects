----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.02.2024 09:16:24
-- Design Name: 
-- Module Name: vga_top - Behavioral
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
use IEEE.NUMERIC_STD.ALL;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_image is
Port ( 
    clk_100mhz : in std_logic;
    Hsync : out std_logic;
    Vsync : out std_logic;
    R : out std_logic_vector (3 downto 0);
    G : out std_logic_vector (3 downto 0);
    B : out std_logic_vector (3 downto 0)
);
end VGA_image;

architecture Behavioral of VGA_image is

constant fp_v : natural := 10; 
constant pw_v : natural := 2; 
constant bp_v : natural := 29; 
constant disp_v : natural := 480;

constant fp_h : natural := 16; 
constant pw_h : natural := 96; 
constant bp_h : natural := 48; 
constant disp_h : natural := 640;

signal V: std_logic:= '1'; 
signal H: std_logic:= '1';
signal V_flag: std_logic:='1';
signal H_flag: std_logic:='1';
signal clk_25mhz :std_logic := '0';

signal mem_addr : STD_LOGIC_VECTOR(16 DOWNTO 0):=(others=>'0');
signal mem_addr_prv : STD_LOGIC_VECTOR(16 DOWNTO 0):=(others=>'0');
signal dina : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');
signal douta : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');

signal counter_v : integer := 1;
signal counter_h : integer := 1;
signal counter: integer := 1;

constant picture_size : Integer:=90000;

component clk_wiz_0 
port(
clk_in1: in std_logic;
clk_out1: out std_logic
);
end component;

component Image_300x300 is
  PORT (
  clka : IN STD_LOGIC;
  wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
  douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
);
end component;


begin

pixel_array: Image_300x300 
    Port map (
    clka=> clk_25mhz, 
    wea=> "0",
    addra=> mem_addr,
    dina=> dina, 
    douta=> douta);
 
 
clk: clk_wiz_0 
port map(
clk_in1 => clk_100mhz,
clk_out1 =>  clk_25mhz
);
    
Vsync<=V;
Hsync<=H;

vertical: process(clk_25mhz) 
begin
if rising_edge(clk_25mhz) then
    if(counter_v = disp_v ) then
        V_flag <= '0';
    end if;
    
    if(counter_v = fp_v + disp_v) then
        V<='0'; 
    end if;
    
    if(counter_v = fp_v + pw_v + disp_v ) then
         V<='1';
    end if;
    
    if(counter_v = fp_v + pw_v + bp_v + disp_v) then
        V_flag <= '1';
    end if;
    
end if;
end process;

horizontal: process(clk_25mhz) 
begin
if rising_edge(clk_25mhz) then
    counter_h<=counter_h+1;

    if(counter_h = disp_h ) then
        H_flag <= '0';
    end if;
    
    if(counter_h = fp_h + disp_h) then
        H<='0'; 
    end if;
    
    if(counter_h = fp_h + pw_h + disp_h ) then
         H<='1';
    end if;
    
    if(counter_h = fp_h + pw_h + bp_h + disp_h) then
        counter_h<=1;
        H_flag <= '1';
        if(counter_v = fp_v + pw_v + bp_v + disp_v) then
            counter_v <= 1;
        else 
            counter_v<=counter_v+1;
        end if;
    end if;
    
end if;
end process;

pixel_generator: process(clk_25mhz) 
begin 
if rising_edge(clk_25mhz) then
     if(V_flag = '1' and H_flag = '1') then  
         if( unsigned(mem_addr) <= 300*counter_v and counter_v <= 300) then   
            mem_addr <= std_logic_vector (unsigned(mem_addr)+1);
            mem_addr_prv <= mem_addr;
            R <= douta(3 downto 0);
            B <= douta(11 downto 8);
            G <= douta(7 downto 4);
          else 
            R <= "0000";
            B <= "0000";
            G <= "0000";
           end if;
    elsif(mem_addr >= picture_size) then
          mem_addr <= (others => '0');
          mem_addr_prv <=(others => '0');
          R <= "0000";
          B <= "0000";
          G <= "0000";
     elsif(V_flag = '1' and H_flag = '0') then 
            mem_addr <= mem_addr_prv;
            R <= "0000";
            B <= "0000";
            G <= "0000";
   end if;
end if;
end process;

end Behavioral;