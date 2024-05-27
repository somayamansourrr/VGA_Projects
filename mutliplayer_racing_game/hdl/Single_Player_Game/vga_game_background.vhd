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

entity vga_game_background is
Port ( 
    clk_100mhz : in std_logic;
    btnT       : in std_logic;
    btnB       : in std_logic;
    btnL       : in std_logic;
    btnR       : in std_logic;
    btnRST     : in std_logic;
    keyboard_char : in std_logic_vector (6 downto 0);
    Hsync : out std_logic;
    Vsync : out std_logic;
    R : out std_logic_vector (3 downto 0);
    G : out std_logic_vector (3 downto 0);
    B : out std_logic_vector (3 downto 0)
);
end vga_game_background;

architecture Behavioral of vga_game_background is

constant fp_v : natural := 10; 
constant pw_v : natural := 2; 
constant bp_v : natural := 29; 
constant disp_v : natural := 480;

constant fp_h : natural := 16; 
constant pw_h : natural := 96; 
constant bp_h : natural := 48; 
constant disp_h : natural := 640;

-- for car image
constant image_h : natural :=40;
constant image_v : natural :=40;

signal V: std_logic:= '1'; 
signal H: std_logic:= '1';
signal V_flag: std_logic:='1';
signal H_flag: std_logic:='1';
signal clk_25mhz :std_logic := '0';
signal clk       :std_logic := '0';
signal counter_v : integer := 1;
signal counter_h : integer := 1;
-- for lane
signal lane_counter: integer:=0;
signal slow_counter: integer:=0;

-- for car
signal v_origin : integer := 380;
signal h_origin : integer := 300;
--Obstacle in 1st lane (on the left)
signal v_origin_obst_car_1 : integer := 480;
signal h_origin_obst_car_1 : integer := 230; 
--Obstacle in 2nd lane (center)
signal v_origin_obst_car_2 : integer := 480;
signal h_origin_obst_car_2 : integer := 300;
--Obstacle in 3rd lane (on the right)
signal v_origin_obst_car_3 : integer := 480;
signal h_origin_obst_car_3 : integer := 370;

signal h_pos : integer := 0;
signal v_pos : integer := 0;
signal h_pos_obst_car_1 : integer := 0;
signal v_pos_obst_car_1 : integer := 0;
signal h_pos_obst_car_2 : integer := 0;
signal v_pos_obst_car_2 : integer := 0;
signal h_pos_obst_car_3 : integer := 0;
signal v_pos_obst_car_3 : integer := 0;

signal mem_offset : std_logic_vector(12 downto 0);
signal sampling_input_rate_v : std_logic := '0';
signal sampling_input_rate_h : std_logic := '0';

signal sampling_obst_car : std_logic := '0';
signal flag_obst_car_1       : std_logic := '1';
signal flag_obst_car_2       : std_logic := '1';
signal flag_obst_car_3       : std_logic := '1';

signal mem_addr : STD_LOGIC_VECTOR(12 DOWNTO 0):=(others=>'0');
signal dina : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');
signal douta : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');

signal rgb   : std_logic_vector(11 downto 0);
signal rgb_2   : std_logic_vector(11 downto 0);
signal rgb_3   : std_logic_vector(11 downto 0);
signal rgb_next   : std_logic_vector(11 downto 0);
signal rgb_next_2   : std_logic_vector(11 downto 0);
signal rgb_next_3   : std_logic_vector(11 downto 0);
signal hsync_game : std_logic;
signal vsync_game : std_logic;

signal slow_count_v        : integer :=0;
signal slow_count_h        : integer :=0;
signal slow_count_obst_car : integer :=0;


signal rand_obst_car_1    : integer :=0;
signal rand_obst_car_2    : integer :=0;
signal rand_obst_car_3    : integer :=0;

-- for color display 
signal green_area       :boolean := false;
signal white_area       :boolean := false;
signal grey_area        :boolean := false;
signal my_car           :boolean := false;
signal obst_car_1       :boolean := false;
signal obst_car_2       :boolean := false;
signal obst_car_3       :boolean := false;
signal crash_1          :boolean := false;
signal crash_2          :boolean := false;
signal crash_3          :boolean := false;
signal high_score_area  :boolean := false;
signal score_area       :boolean := false;


signal w_video_on       : std_logic;
signal w_x              : std_logic_vector( 9 downto 0);
signal w_y              : std_logic_vector( 9 downto 0);
signal counter          :integer := 0;
signal score            : std_logic_vector(31 downto 0);

signal  dig_1s          : std_logic_vector(3 downto 0);
signal  dig_10s         : std_logic_vector(3 downto 0);
signal  dig_100s        : std_logic_vector(3 downto 0);
signal  dig_1000s       : std_logic_vector(3 downto 0);
signal  dig_10000s      : std_logic_vector(3 downto 0);

constant picture_size : Integer:=image_h*image_v;

component clk_wiz_0 
    port(
    clk_in1: in std_logic;
    clk_out1: out std_logic
    );
end component;

component car is
  PORT (
  clka : IN STD_LOGIC;
  wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
  addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
  dina : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
  douta : OUT STD_LOGIC_VECTOR(11 DOWNTO 0)
);
end component;


component ascii_test is
 port (
    clk :  in  std_logic;
    video_on :  in  std_logic;
    x, y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector( 11 downto 0)
    );
end component;

component high_score_text is
 port (
    clk :  in  std_logic;
    video_on :  in  std_logic;
    x, y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector( 11 downto 0)
    );
end component;

component counter_text is
 port (
    clk :  in  std_logic;
    video_on :  in  std_logic;
    score    : in std_logic_vector(31 downto 0);
    x, y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector( 11 downto 0)
    );
end component;


begin
 w_video_on <= v_flag and h_flag;
 w_x <=  std_logic_vector(to_unsigned(counter_h, w_x'length)); 
 w_y <=  std_logic_vector(to_unsigned(counter_v, w_y'length)); 

process(clk_100mhz)
begin
if rising_edge(clk_100mhz) then
    counter <= counter + 1;
    if (counter = 100000000) then
     score <= std_logic_vector(unsigned(score) + 1);
     counter <= 0;
   end if;
end if;
end process;
   
process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
    rgb <= rgb_next;
    rgb_2 <= rgb_next_2;
    rgb_3 <= rgb_next_3;
end if;
end process;
 
 game_over: ascii_test
  port map (clk => clk_100mhz, 
  video_on => w_video_on,
  x => w_x,
  y => w_y,
  rgb => rgb_next);
    
 high_score: high_score_text
  port map (clk => clk_100mhz, 
  video_on => w_video_on,
  x => w_x,
  y => w_y,
  rgb => rgb_next_2);
  
 score_value: counter_text
  port map (clk => clk_100mhz, 
  video_on => w_video_on,
  score => score,
  x => w_x,
  y => w_y,
  rgb => rgb_next_3);


pixel_array: car 
    Port map (
    clka=> clk_25mhz, 
    wea=> "0",
    addra=> mem_addr,
    dina=> dina, 
    douta=> douta);
        
clk_wizard: clk_wiz_0 
    port map(
    clk_in1 => clk_100mhz,
    clk_out1 =>  clk_25mhz
);


Vsync<=V;
Hsync<= H;

moving_background: process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
    if(counter_v = disp_v ) then
        if(slow_counter=1000) then
            if(lane_counter=96) then
                lane_counter <= 0;
            else
                lane_counter<= lane_counter+1;
            end if;
            slow_counter<=0;
        else slow_counter<= slow_counter+1;
        end if;
    end if;
end if;
end process;

offset_addresses: process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
    if(counter_h>=h_origin) then
        h_pos <= counter_h - h_origin;
    end if;
    if(counter_v>=v_origin) then
        v_pos <= counter_v - v_origin;
    end if;
    
    if(counter_h>=h_origin_obst_car_3) then
        h_pos_obst_car_3 <= counter_h - h_origin_obst_car_3;
    end if;
    if(counter_v>=v_origin_obst_car_3) then
        v_pos_obst_car_3 <= counter_v - v_origin_obst_car_3;
    end if; 
    
    if(counter_h>=h_origin_obst_car_2) then
        h_pos_obst_car_2 <= counter_h - h_origin_obst_car_2;
    end if;
    if(counter_v>=v_origin_obst_car_2) then
        v_pos_obst_car_2 <= counter_v - v_origin_obst_car_2;
    end if; 
    
    if(counter_h>=h_origin_obst_car_1) then
        h_pos_obst_car_1 <= counter_h - h_origin_obst_car_1;
    end if;
    if(counter_v>=v_origin_obst_car_1) then
        v_pos_obst_car_1 <= counter_v - v_origin_obst_car_1;
    end if;
end if;
end process;

background:process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
    green_area    <= false;
    white_area    <= false;
    grey_area     <= false;
    my_car        <= false;
    obst_car_3    <= false;
    obst_car_2    <= false;
    obst_car_1    <= false;
    high_score_area <= false;
    score_area       <= false;
    if(keyboard_char = x"20") then
        crash_3 <= false;
        crash_2 <= false;
        crash_1 <= false;
    end if;
    if(  counter_h >= 20 and  counter_h < 100) then  
        high_score_area <= true;
    end if;
    if(counter_h<210 or counter_h>430) then
       green_area <= true;
    end if;
    if((counter_h<220 and counter_h >210) or (counter_h <430 and counter_h>420)) then
        white_area <= true;
    end if;
    if (counter_h> h_origin and counter_h < image_h +h_origin and counter_v > v_origin and counter_v < image_v + v_origin )then 
        my_car <= true; 
    end if;    
    if (counter_h> h_origin_obst_car_3 and counter_h < image_h +h_origin_obst_car_3 and counter_v > v_origin_obst_car_3 and counter_v < image_v + v_origin_obst_car_3 and flag_obst_car_3 ='1' )then 
        obst_car_3 <= true;
    end if;
    if (counter_h> h_origin_obst_car_2 and counter_h < image_h +h_origin_obst_car_2 and counter_v > v_origin_obst_car_2 and counter_v < image_v + v_origin_obst_car_2 and flag_obst_car_2 ='1' )then 
        obst_car_2 <= true;
    end if;
    if (counter_h> h_origin_obst_car_1 and counter_h < image_h +h_origin_obst_car_1 and counter_v > v_origin_obst_car_1 and counter_v < image_v + v_origin_obst_car_1 and flag_obst_car_1 ='1' )then 
        obst_car_1 <= true;
    end if;       
    if((counter_h <290 and counter_h>280) or (counter_h>350 and counter_h<360)) then
        if(lane_counter>48) then
            if(counter_v>0 and counter_v<(lane_counter-48))  then
                white_area <= true;           
            end if;
        end if;
        if((counter_v>0+lane_counter and counter_v<48+lane_counter) or (counter_v>96+lane_counter and counter_v<144+lane_counter) or (counter_v>192+lane_counter and counter_v<240+lane_counter) or (counter_v>288+lane_counter and counter_v<336+lane_counter) or (counter_v>384+lane_counter and counter_v<432+lane_counter)) then
            white_area <= true;           
        end if;
     end if;
    if((v_origin = v_origin_obst_car_3 + image_v and h_origin + image_h > h_origin_obst_car_3 and h_origin <= h_origin_obst_car_3 + image_h)or (h_origin + image_h = h_origin_obst_car_3 and v_origin + image_v >= v_origin_obst_car_3 and v_origin <= v_origin_obst_car_3 + image_v) or(v_origin + image_v = v_origin_obst_car_3 and h_origin + image_h > h_origin_obst_car_3 and h_origin <= h_origin_obst_car_3 + image_h)) then 
        crash_3 <= true;
    end if;
    if((v_origin = v_origin_obst_car_1 + image_v and h_origin < h_origin_obst_car_1 + image_h and h_origin + image_h >= h_origin_obst_car_1) or (h_origin = h_origin_obst_car_1 +image_h and v_origin+ image_v >= v_origin_obst_car_1 and v_origin <= v_origin_obst_car_1+image_v) or (v_origin + image_v = v_origin_obst_car_1 and h_origin < h_origin_obst_car_1 + image_h and h_origin + image_h >= h_origin_obst_car_1)) then 
        crash_1 <= true;
    end if;
    if((v_origin = v_origin_obst_car_2 + image_v and h_origin + image_h > h_origin_obst_car_2 and h_origin <= h_origin_obst_car_2 + image_h) or ( (h_origin + image_h = h_origin_obst_car_2 or h_origin = h_origin_obst_car_2 +image_h) and v_origin + image_v >= v_origin_obst_car_2 and v_origin <= v_origin_obst_car_2 + image_v) or (v_origin + image_v = v_origin_obst_car_2 and h_origin + image_h > h_origin_obst_car_2 and h_origin <= h_origin_obst_car_2 + image_h)) then 
        crash_2 <= true;
    end if;
    if(counter_h >220 and counter_h <420) then
        grey_area <= true;
    end if;
   end if;
end process;

display:process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
   if(H_flag='1' and V_flag='1') then 
      if(crash_3 or crash_2 or crash_1)then 
        R<=rgb(11 downto 8);
        B<=rgb(7 downto 4);
        G<=rgb(3 downto 0);
      elsif(high_score_area) then 
        R<=rgb_2(11 downto 8)or rgb_3(11 downto 8);
        B<=rgb_2(7 downto 4) or rgb_3(7 downto 4);
        G<=rgb_2(3 downto 0) or  rgb_3(3 downto 0);
      elsif(green_area) then
        R <= "0001";
        B <= "0011";
        G <= "1010";
      elsif(my_car) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos - 1) + image_v*(v_pos-1), mem_offset'length));                                    
        R <= douta(11 downto 8);
        B <= douta(3 downto 0);
        G <= douta(7 downto 4);
      elsif(obst_car_3) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos_obst_car_3 - 1) + image_v*(v_pos_obst_car_3-1), mem_offset'length));                                    
        R <= douta(3 downto 0);
        B <= douta(11 downto 8);
        G <= douta(7 downto 4);
      elsif(obst_car_2) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos_obst_car_2 - 1) + image_v*(v_pos_obst_car_2-1), mem_offset'length));                                    
        R <= douta(7 downto 4);
        B <= douta(11 downto 8);
        G <= douta(3 downto 0);       
      elsif (obst_car_1)then 
        mem_addr <= std_logic_vector(to_unsigned((h_pos_obst_car_1 - 1) + image_v*(v_pos_obst_car_1-1), mem_offset'length));                                    
        R <= douta(3 downto 0);
        B <= douta(7 downto 4);
        G <= douta(11 downto 8);   
      elsif(white_area) then
        R<="1111";
        B<="1111";
        G<="1111";
      elsif(grey_area)then
        R<="1000";
        B<="1000";
        G<="1000";
     end if;
     else
        R<="0000";
        B<="0000";
        G<="0000";  
     end if;
end if;
end process;



vertical: process(clk_25mhz) 
begin
if rising_edge(clk_25mhz) then
   sampling_obst_car <= '0';
    if(counter_v = disp_v ) then
        V_flag <= '0';
    end if;
    
    if(counter_v = fp_v + disp_v) then
        V<='0'; 
    end if;
    
    if(counter_v = fp_v + pw_v + disp_v ) then
         if(slow_count_obst_car = 0) then 
            sampling_obst_car <= '1';
            slow_count_obst_car <= slow_count_obst_car + 1;            
         elsif(slow_count_obst_car = 1000) then 
            slow_count_obst_car <= 0;
         else
            slow_count_obst_car <= slow_count_obst_car + 1;
         end if;
         V<='1';
    end if;
    
    if(counter_v = fp_v + pw_v + bp_v + disp_v) then
        V_flag <= '1';
    end if;
    
end if;
end process;

slow: process(clk_25mhz) 
begin
if rising_edge(clk_25mhz) then
    if(slow_count_h = 0) then 
        sampling_input_rate_h <= '1';
        slow_count_h <= slow_count_h + 1;            
     elsif(slow_count_h = 500*disp_h) then 
        slow_count_h <= 0;
     else
        sampling_input_rate_h <= '0';
        slow_count_h <= slow_count_h + 1;
     end if;
     
     if(slow_count_v = 0) then 
        sampling_input_rate_v <= '1';
        slow_count_v <= slow_count_v + 1;            
     elsif(slow_count_v = 500*disp_v) then 
        slow_count_v <= 0;
     else
        sampling_input_rate_v <= '0';
        slow_count_v <= slow_count_v + 1;
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

moving_controller: process(sampling_input_rate_v,clk_25mhz,sampling_input_rate_h) -- this should take a different clock 
begin
if rising_edge(clk_25mhz) then 
  if (sampling_input_rate_v = '1') then
    if(keyboard_char = x"77" or keyboard_char = x"57") then -- top
        if(v_origin = 1 + image_v) then
           v_origin <= v_origin;
        else
            v_origin <= v_origin - 1;
        end if;
    end if;
    if(keyboard_char = x"73" or keyboard_char = x"53") then -- bottom
        if(v_origin = disp_v-image_v) then
            v_origin <= v_origin;
        else
            v_origin <= v_origin + 1;
        end if;
    end if;
  end if;
  if (sampling_input_rate_h = '1') then
      if((keyboard_char = x"64" or keyboard_char = x"44") and h_origin + image_h <420) then -- right
        if(h_origin = disp_h)then
           h_origin <= 0;
         else
           h_origin <= h_origin + 1;
         end if;
       end if;
    if((keyboard_char = x"61" or keyboard_char = x"41") and h_origin > 220 ) then -- Left
        if(h_origin <= 0) then 
            h_origin <= disp_h; 
        else
            h_origin <= h_origin -1;
        end if;
    end if;
   end if;
    if(keyboard_char = x"20") then
        h_origin <= 295;
        v_origin <= 380;
    end if; 
end if;
end process;

crash_car_1: process(clk_25mhz,slow_count_obst_car) -- this should take a different clock 
begin
if rising_edge(clk_25mhz) then 
   if(keyboard_char = x"20") then
        v_origin_obst_car_1 <= 480;
        v_origin_obst_car_2 <= 480;
        v_origin_obst_car_3 <= 480;
        rand_obst_car_3 <= 0;
        rand_obst_car_2 <= 0;
        rand_obst_car_1 <= 0;
   else 
  if (sampling_obst_car = '1') then
    if(v_origin_obst_car_3 = disp_v) then
         rand_obst_car_3 <= rand_obst_car_3 + 1;
        if(rand_obst_car_3 = 13) then 
            v_origin_obst_car_3 <= 0; 
            rand_obst_car_3 <= 0;
        end if;
    else
          v_origin_obst_car_3 <= v_origin_obst_car_3 + 1;
    end if;

    if(v_origin_obst_car_2 = disp_v) then
       rand_obst_car_2 <= rand_obst_car_2 + 1;
       if(rand_obst_car_2 > 43 and ((v_origin_obst_car_3>350 and v_origin_obst_car_3< 480) or (v_origin_obst_car_1>350 and v_origin_obst_car_1<480))) then 
            v_origin_obst_car_2 <= 0; 
            rand_obst_car_2 <= 0;
        end if;
    else
        v_origin_obst_car_2 <= v_origin_obst_car_2 + 1;
    end if;

    
    if(v_origin_obst_car_1 = disp_v) then
      rand_obst_car_1 <= rand_obst_car_1 + 1;
       if(rand_obst_car_1 = 58) then 
            v_origin_obst_car_1 <= 0; 
            rand_obst_car_1 <= 0;
       end if;
    else
        v_origin_obst_car_1 <= v_origin_obst_car_1 + 1;
    end if;
  end if; 
    end if;
  end if;
end process;


end Behavioral;