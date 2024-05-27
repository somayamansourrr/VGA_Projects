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


entity vga_moving_image is
Port ( 
    clk_100mhz : in std_logic;
    --reset      : in std_logic;
    btnT       : in std_logic;
    btnB       : in std_logic;
    btnL       : in std_logic;
    btnR       : in std_logic;
    btnRST     : in std_logic;
    Hsync : out std_logic;
    Vsync : out std_logic;
    R : out std_logic_vector (3 downto 0);
    G : out std_logic_vector (3 downto 0);
    B : out std_logic_vector (3 downto 0)
);
end vga_moving_image;

architecture Behavioral of vga_moving_image is

constant fp_v : natural := 10; 
constant pw_v : natural := 2; 
constant bp_v : natural := 29; 
constant disp_v : natural := 480;

constant fp_h : natural := 16; 
constant pw_h : natural := 96; 
constant bp_h : natural := 48; 
constant disp_h : natural := 640;

constant image_h : natural :=300;
constant image_v : natural :=300;

signal V: std_logic:= '1'; 
signal H: std_logic:= '1';
signal V_flag: std_logic:='1';
signal H_flag: std_logic:='1';
signal clk_25mhz :std_logic := '0';

signal v_origin : integer := 0;
signal v_offset : integer := 0;
signal h_origin : integer := 0;
signal h_offset : integer := 0;
signal h_pos : integer := 0;
signal v_pos : integer := 0;
signal mem_offset : std_logic_vector(16 downto 0);
signal sampling_input_rate : std_logic := '0';

signal mem_addr : STD_LOGIC_VECTOR(16 DOWNTO 0):=(others=>'0');
signal mem_addr_prv : STD_LOGIC_VECTOR(16 DOWNTO 0):=(others=>'0');
signal dina : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');
signal douta : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');

signal slow_count : integer :=0;

signal counter_v : integer := 1;
signal counter_h : integer := 1;
signal R_L_flag : std_logic;
signal T_B_flag : std_logic;

type state_type is (IDLE,DISP_REG, OFFSET);
signal current_state: state_type := IDLE;

constant picture_size : Integer:=90000;

component clk_wiz_0 
port(
clk_in1: in std_logic;
clk_out1: out std_logic
);
end component;

component blk_mem_gen_0 is
  PORT (
  clka : IN STD_LOGIC;
  wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  addra : IN STD_LOGIC_VECTOR(16 DOWNTO 0);
  dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
  douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
);
end component;


begin

pixel_array: blk_mem_gen_0 
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

v_offset <= disp_v - v_origin;
h_offset <= disp_h - h_origin;
mem_offset <= std_logic_vector(to_unsigned((v_offset) *300, mem_offset'length));

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
         if(slow_count = 0) then 
            sampling_input_rate <= '0';
            slow_count <= slow_count + 1;            
         elsif(slow_count = 300) then 
            sampling_input_rate <= '1';
            slow_count <= 0;
         else
            slow_count <= slow_count + 1;
         end if;
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

moving_controller: process(sampling_input_rate,clk_25mhz) -- this should take a different clock 
begin
if (sampling_input_rate = '1') and rising_edge(clk_25mhz) then 
    if(btnT = '1') then -- top
        T_B_flag <='1';
        R_L_flag<='0';
        if(v_origin <= 0) then
           v_origin <= disp_v;
        else
            v_origin <= v_origin - 1;
        end if;
    end if;
    if(btnB = '1') then -- bottom
        T_B_flag <='1';
        R_L_flag<='0';
        if(v_origin = disp_v) then
            v_origin <= 0;
        else
            v_origin <= v_origin + 1;
        end if;
    end if;
    if(btnR = '1') then -- right
        T_B_flag <='0';
        R_L_flag<='1';
        if(h_origin = disp_h)then
            h_origin <= 0;
         else
            h_origin <= h_origin + 1;
         end if;
    end if;
    if(btnL = '1') then -- Left
        T_B_flag <='0';
        R_L_flag<='1';  
        if(h_origin <= 0) then 
            h_origin <= disp_h; 
        else
            h_origin <= h_origin -1;
        end if;
    end if;
    if(btnRST = '1') then
        h_origin <= 0;
        v_origin <= 0;
    end if; 
end if;
end process;

pixel_generator: process(clk_25mhz) 
begin 
if rising_edge(clk_25mhz) then
     if(V_flag = '1' and H_flag = '1') then  
        if(counter_h>=h_origin) then
            h_pos <= counter_h - h_origin;
        elsif(counter_h<image_h-h_offset) then
            h_pos <= counter_h - h_origin + disp_h;
        end if;
        if(counter_v>=v_origin) then
            v_pos <= counter_v - v_origin;
        elsif(counter_v<image_v-v_offset) then
            v_pos <= counter_v - v_origin + disp_v;
        end if;
        
         if((v_offset > 300 and h_offset > 300)) then --Image not cut
             if( counter_v >= v_origin and counter_v < image_v + v_origin and counter_h>= h_origin and counter_h < image_h +h_origin)then   
                mem_addr <= std_logic_vector(to_unsigned((h_pos - 1) + 300*(v_pos-1), mem_offset'length));                                    
                R <= douta(3 downto 0);
                B <= douta(11 downto 8);
                G <= douta(7 downto 4);
              else 
                R <= "0000";
                B <= "0000";
                G <= "0000";
               end if; 
          else 
            if(v_offset>300) then  --image cut horizontally but not vertically
                if((counter_v>= v_origin and counter_v<image_v+v_origin) and (counter_h>= h_origin or counter_h<image_h-h_offset )) then
                    mem_addr <= std_logic_vector(to_unsigned((h_pos - 1) + 300*(v_pos-1), mem_offset'length));                                    
                    R <= douta(3 downto 0);
                    B <= douta(11 downto 8);
                    G <= douta(7 downto 4);
                 else 
                    R <= "0000";
                    B <= "0000";
                    G <= "0000";
                end if;
            elsif(h_offset>300) then --image cut vertically but not horizontally
                if((counter_h>= h_origin and counter_h<image_h+h_origin) and (counter_v>= v_origin or counter_v<image_v-v_offset )) then
                    mem_addr <= std_logic_vector(to_unsigned((h_pos - 1) + 300*(v_pos-1), mem_offset'length));                                    
                    R <= douta(3 downto 0);
                    B <= douta(11 downto 8);
                    G <= douta(7 downto 4);
                 else 
                    R <= "0000";
                    B <= "0000";
                    G <= "0000";
                end if;
            else   --image cut both hotizentally and vertically
                if((counter_h>= h_origin or counter_h<image_h-h_offset) and (counter_v>= v_origin or counter_v<image_v-v_offset )) then
                    mem_addr <= std_logic_vector(to_unsigned((h_pos - 1) + 300*(v_pos-1), mem_offset'length));                                    
                    R <= douta(3 downto 0);
                    B <= douta(11 downto 8);
                    G <= douta(7 downto 4);
                 else 
                    R <= "0000";
                    B <= "0000";
                    G <= "0000";
                end if;
            end if;      
          end if;   

    end if;
end if;
end process;

end Behavioral;