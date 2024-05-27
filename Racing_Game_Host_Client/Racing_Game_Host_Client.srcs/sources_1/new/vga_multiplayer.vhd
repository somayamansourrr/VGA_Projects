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

entity vga_multiplayer is
Port ( 
    clk_100mhz      : in std_logic;
    data_received_1 : in std_logic_vector (7 downto 0);
    data_received_2 : in std_logic_vector (7 downto 0);
    data_received_3 : in std_logic_vector (7 downto 0);        
    keyboard_char   : in std_logic_vector (6 downto 0);
    player_en_2     : in std_logic;
    player_en_3     : in std_logic;
    player_en_4     : in std_logic;
    start_flag      : in std_logic;
    reset_flag      : in std_logic;
    Hsync           : out std_logic;
    Vsync           : out std_logic;
    R               : out std_logic_vector (3 downto 0);
    G               : out std_logic_vector (3 downto 0);
    B               : out std_logic_vector (3 downto 0)
);
end vga_multiplayer;

architecture Behavioral of vga_multiplayer is

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

signal V         : std_logic:= '1'; 
signal H         : std_logic:= '1';
signal V_flag    : std_logic:='1';
signal H_flag    : std_logic:='1';
signal clk_25mhz :std_logic := '0';
signal clk       :std_logic := '0';
signal counter_v : integer := 1;
signal counter_h : integer := 1;


-- For lane
signal lane_counter: integer:=0;
signal slow_counter: integer:=0;

-- For player cars
signal v_origin_player_1 : integer := 380;
signal h_origin_player_1 : integer := 335;

signal v_origin_player_2 : integer := 380;
signal h_origin_player_2 : integer := 195;

signal v_origin_player_3 : integer := 380;
signal h_origin_player_3 : integer := 265;

signal v_origin_player_4 : integer := 380;
signal h_origin_player_4 : integer := 405;


--Obstacle in 1st lane (on the left)
signal v_origin_obst_car_1 : integer := 480;
signal h_origin_obst_car_1 : integer := 195; 

--Obstacle in 2nd lane (center)
signal v_origin_obst_car_2 : integer := 480;
signal h_origin_obst_car_2 : integer := 265;

--Obstacle in 3rd lane (center)
signal v_origin_obst_car_3 : integer := 480;
signal h_origin_obst_car_3 : integer := 335;

--Obstacle in 45h lane (on the right)
signal v_origin_obst_car_4 : integer := 480;
signal h_origin_obst_car_4 : integer := 405;

signal h_pos_player_1 : integer := 0;
signal v_pos_player_1 : integer := 0;
signal h_pos_player_2 : integer := 0;
signal v_pos_player_2 : integer := 0;
signal h_pos_player_3 : integer := 0;
signal v_pos_player_3 : integer := 0;
signal h_pos_player_4 : integer := 0;
signal v_pos_player_4 : integer := 0;

signal h_pos_obst_car_1 : integer := 0;
signal v_pos_obst_car_1 : integer := 0;
signal h_pos_obst_car_2 : integer := 0;
signal v_pos_obst_car_2 : integer := 0;
signal h_pos_obst_car_3 : integer := 0;
signal v_pos_obst_car_3 : integer := 0;
signal h_pos_obst_car_4 : integer := 0;
signal v_pos_obst_car_4 : integer := 0;

signal mem_offset : std_logic_vector(12 downto 0);
signal sampling_input_rate_v : std_logic := '0';
signal sampling_input_rate_h : std_logic := '0';
signal sampling_obst_car     : std_logic := '0';


signal mem_addr : STD_LOGIC_VECTOR(12 DOWNTO 0):=(others=>'0');
signal dina : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');
signal douta : STD_LOGIC_VECTOR(11 DOWNTO 0):=(others=>'0');

signal rgb_final_display          : std_logic_vector(11 downto 0);
signal rgb_final_display_next     : std_logic_vector(11 downto 0);
signal rgb_score_text             : std_logic_vector(11 downto 0);
signal rgb_score_text_next        : std_logic_vector(11 downto 0);
signal rgb_score                  : std_logic_vector(11 downto 0);
signal rgb_score_next             : std_logic_vector(11 downto 0);
signal rgb_high_score_text        : std_logic_vector(11 downto 0);
signal rgb_high_score_text_next   : std_logic_vector(11 downto 0);
signal rgb_high_score             : std_logic_vector(11 downto 0);
signal rgb_high_score_next        : std_logic_vector(11 downto 0);
signal rgb_start_display          : std_logic_vector(11 downto 0);
signal rgb_start_display_next     : std_logic_vector(11 downto 0);
signal hsync_game                 : std_logic;
signal vsync_game                 : std_logic;

signal slow_count_v               : integer :=0;
signal slow_count_h               : integer :=0;
signal slow_count_obst_car        : integer :=0;


signal rand_obst_car_1            : integer :=0;
signal rand_obst_car_2            : integer :=0;
signal rand_obst_car_3            : integer :=0;
signal rand_obst_car_4            : integer :=0;


signal stopping_counter           :integer :=0;
signal stop_count                 :integer :=0;
signal stop_flag                  :boolean := false;
signal reset_signal               :boolean := false;

-- For color display 
signal green_area                 :boolean := false;
signal white_area                 :boolean := false;
signal grey_area                  :boolean := false;
signal car_player_1               :boolean := false;
signal car_player_2               :boolean := false;
signal car_player_3               :boolean := false;
signal car_player_4               :boolean := false;
signal obst_car_1                 :boolean := false;
signal obst_car_2                 :boolean := false;
signal obst_car_3                 :boolean := false;
signal obst_car_4                 :boolean := false;
signal both_crash                 :boolean := false;
signal high_score_area            :boolean := false;
signal score_area                 :boolean := false;
signal start_display_flag         :boolean := true;

-- For car hitting obstacles
signal player_1_crash_bottom      :boolean := false;
signal player_1_crash_top         :boolean := false;
signal player_1_crash_right       :boolean := false;
signal player_1_crash_left        :boolean := false;
signal player_2_crash_bottom      :boolean := false;
signal player_2_crash_top         :boolean := false;
signal player_2_crash_right       :boolean := false;
signal player_2_crash_left        :boolean := false;
signal player_3_crash_bottom      :boolean := false;
signal player_3_crash_top         :boolean := false;
signal player_3_crash_right       :boolean := false;
signal player_3_crash_left        :boolean := false;
signal player_4_crash_bottom      :boolean := false;
signal player_4_crash_top         :boolean := false;
signal player_4_crash_right       :boolean := false;
signal player_4_crash_left        :boolean := false;
 
signal player_1_crash_player_2_bottom :boolean := false;
signal player_1_crash_player_2_top    :boolean := false;
signal player_1_crash_player_2_right  :boolean := false;
signal player_1_crash_player_2_left   :boolean := false;

signal player_1_crash_player_3_bottom :boolean := false;
signal player_1_crash_player_3_top    :boolean := false;
signal player_1_crash_player_3_right  :boolean := false;
signal player_1_crash_player_3_left   :boolean := false;

signal player_1_crash_player_4_bottom :boolean := false;
signal player_1_crash_player_4_top    :boolean := false;
signal player_1_crash_player_4_right  :boolean := false;
signal player_1_crash_player_4_left   :boolean := false;

signal player_2_crash_player_3_bottom :boolean := false;
signal player_2_crash_player_3_top    :boolean := false;
signal player_2_crash_player_3_right  :boolean := false;
signal player_2_crash_player_3_left   :boolean := false;

signal player_2_crash_player_4_bottom :boolean := false;
signal player_2_crash_player_4_top    :boolean := false;
signal player_2_crash_player_4_right  :boolean := false;
signal player_2_crash_player_4_left   :boolean := false;

signal player_3_crash_player_4_bottom :boolean := false;
signal player_3_crash_player_4_top    :boolean := false;
signal player_3_crash_player_4_right  :boolean := false;
signal player_3_crash_player_4_left   :boolean := false;


signal w_video_on       : std_logic;
signal w_x              : std_logic_vector( 9 downto 0);
signal w_y              : std_logic_vector( 9 downto 0);

signal score            : std_logic_vector(31 downto 0);
signal score_2          : std_logic_vector(31 downto 0);
signal score_3          : std_logic_vector(31 downto 0);
signal score_4          : std_logic_vector(31 downto 0);
signal score_2_stored   : std_logic_vector(31 downto 0);
signal high_score_value : std_logic_vector(31 downto 0):=(others=>'0');
signal counter          :integer := 0;
signal counter_score_2  :integer := 0;
signal counter_score_3  :integer := 0;
signal counter_score_4  :integer := 0;

signal move_up_1          : std_logic := '0';
signal move_down_1        : std_logic := '0';
signal move_left_1        : std_logic := '0';
signal move_right_1       : std_logic := '0';
signal move_up_2          : std_logic := '0';
signal move_down_2        : std_logic := '0';
signal move_left_2        : std_logic := '0';
signal move_right_2       : std_logic := '0';
signal move_up_3          : std_logic := '0';
signal move_down_3        : std_logic := '0';
signal move_left_3        : std_logic := '0';
signal move_right_3       : std_logic := '0';



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


component final_display  is
 port (
    clk          :  in  std_logic;
    video_on     :  in  std_logic;
    x, y         : in std_logic_vector(9 downto 0);
    score_1      : in std_logic_vector(31 downto 0);
    score_2      : in std_logic_vector(31 downto 0);
    score_1_flag : in std_logic;
    score_2_flag : in std_logic;
    score_3_flag : in std_logic;
    score_4_flag : in std_logic;
    rgb          : out std_logic_vector( 11 downto 0)
    );
end component;

component score_text is
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


component stored_counter_text is
 port (
    clk      : in std_logic;
    video_on : in std_logic;
    score    : in std_logic_vector(31 downto 0);
    x, y     : in std_logic_vector(9 downto 0);
    rgb      : out std_logic_vector( 11 downto 0)
    );
end component;

component start_display is
 port (
    clk :  in  std_logic;
    video_on :  in  std_logic;
    x, y : in std_logic_vector(9 downto 0);
    rgb : out std_logic_vector( 11 downto 0)
    );
end component;


begin

move_up_1    <= '1' when (data_received_1 = x"77" or data_received_1 = x"57") else '0';
move_down_1  <= '1' when (data_received_1 = x"73" or data_received_1 = x"53") else '0';
move_left_1  <= '1' when (data_received_1 = x"61" or data_received_1 = x"41") else '0';
move_right_1 <= '1' when (data_received_1 = x"64" or data_received_1 = x"44") else '0';

move_up_2    <= '1' when (data_received_2 = x"77" or data_received_2 = x"57") else '0';
move_down_2  <= '1' when (data_received_2 = x"73" or data_received_2 = x"53") else '0';
move_left_2  <= '1' when (data_received_2 = x"61" or data_received_2 = x"41") else '0';
move_right_2 <= '1' when (data_received_2 = x"64" or data_received_2 = x"44") else '0';

move_up_3    <= '1' when (data_received_3 = x"77" or data_received_3 = x"57") else '0';
move_down_3  <= '1' when (data_received_3 = x"73" or data_received_3 = x"53") else '0';
move_left_3  <= '1' when (data_received_3 = x"61" or data_received_3 = x"41") else '0';
move_right_3 <= '1' when (data_received_3 = x"64" or data_received_3 = x"44") else '0';

 w_video_on <= v_flag and h_flag;
 w_x <=  std_logic_vector(to_unsigned(counter_h, w_x'length)); 
 w_y <=  std_logic_vector(to_unsigned(counter_v, w_y'length)); 
 
 
pixel_array: car 
    Port map (
    clka  => clk_25mhz, 
    wea   => "0",
    addra => mem_addr,
    dina  => dina, 
    douta => douta
    );
        
clk_wizard: clk_wiz_0 
    port map(
    clk_in1  => clk_100mhz,
    clk_out1 => clk_25mhz
    );


start_screen: start_display
  port map (
  clk      => clk_100mhz, 
  video_on => w_video_on,
  x        => w_x,
  y        => w_y,
  rgb      => rgb_start_display_next
  );
 
game_over: final_display
  port map (
  clk          => clk_100mhz, 
  video_on     => w_video_on,
  x            => w_x,
  y            => w_y,
  score_1      => score,
  score_2      => score_2_stored,
  score_1_flag => '1',
  score_2_flag => '1',
  score_3_flag => '0',
  score_4_flag => '0',
  rgb          => rgb_final_display_next
  );
    
current_score: score_text
  port map (
  clk      => clk_100mhz, 
  video_on => w_video_on,
  x        => w_x,
  y        => w_y,
  rgb      => rgb_score_text_next
);
  
   score_value: counter_text
  port map (clk => clk_100mhz, 
  video_on => w_video_on,
  score => score,
  x => w_x,
  y => w_y,
  rgb => rgb_score_next);
  
  high_score: high_score_text
  port map (clk => clk_100mhz, 
  video_on => w_video_on,
  x => w_x,
  y => w_y,
  rgb => rgb_high_score_text_next);
  
  
  constant_score_value: stored_counter_text
  port map (clk => clk_100mhz, 
  video_on => w_video_on,
  score => high_score_value,
  x => w_x,
  y => w_y,
  rgb => rgb_high_score_next);
  
  
process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
    rgb_final_display   <= rgb_final_display_next;
    rgb_score_text      <= rgb_score_text_next;
    rgb_score           <= rgb_score_next;
    rgb_high_score      <= rgb_high_score_next;
    rgb_high_score_text <= rgb_high_score_text_next;
    rgb_start_display   <= rgb_start_display_next;
end if;
end process;  

  
stopping_condition: process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
     if( score > high_score_value) then
        high_score_value <=  score;
        score_2_stored <= score_2;
     else
        score_2_stored <= score_2;
     end if;
     if(reset_signal) then
        stop_flag        <= false;
        stop_count       <= 0;
        stopping_counter <= 0;
     end if;
     
    if(stop_count = 3) then 
         stop_flag <= true;
    end if;
    
    if(stopping_counter = 1000000000) then --1000000000
       stop_count <= stop_count + 1;

        stopping_counter <= 0;
    elsif(not start_display_flag) then
        stopping_counter <= stopping_counter + 1;
    end if;
end if;
end process;

Vsync<=V;
Hsync<= H;

score_count_player1:process(clk_100mhz)
begin
if rising_edge(clk_100mhz) then
    if((not start_display_flag) and (not player_1_crash_bottom) and (not player_1_crash_player_2_bottom) and (not player_1_crash_player_3_bottom)and (not player_1_crash_player_4_bottom)) then
        counter <= counter + 1;
    end if;
    
    if(keyboard_char = x"20" and stop_flag) then
     score <= x"00000000";
    else
        if (counter = 100000000 and not stop_flag) then
         score <= std_logic_vector(unsigned(score) + 1);
         counter <= 0;
       end if;
     end if;
end if;
end process;

score_count_player2:process(clk_100mhz)
begin
if rising_edge(clk_100mhz) then
    if((not start_display_flag) and (not player_2_crash_bottom) and (not player_1_crash_player_2_top) and  (not player_2_crash_player_3_bottom) and (not player_2_crash_player_4_bottom)) then
        counter_score_2 <= counter_score_2 + 1;
    end if;
    
    if(keyboard_char = x"20" and stop_flag) then
     score_2 <= x"00000000";
    else
        if (counter_score_2 = 100000000 and not stop_flag) then
         score_2 <= std_logic_vector(unsigned(score_2) + 1);
         counter_score_2 <= 0;
       end if;
     end if;
end if;
end process;

score_count_player3:process(clk_100mhz)
begin
if rising_edge(clk_100mhz) then
    if((not start_display_flag) and (not player_3_crash_bottom) and (not player_1_crash_player_3_top) and  (not player_2_crash_player_3_top) and (not player_3_crash_player_4_bottom)) then
        counter_score_3 <= counter_score_3 + 1;
    end if;
    
    if(keyboard_char = x"20" and stop_flag) then
     score_3 <= x"00000000";
    else
        if (counter_score_3 = 100000000 and not stop_flag) then
         score_3 <= std_logic_vector(unsigned(score_3) + 1);
         counter_score_3 <= 0;
       end if;
     end if;
end if;
end process;

score_count_player4:process(clk_100mhz)
begin
if rising_edge(clk_100mhz) then
    if((not start_display_flag) and (not player_4_crash_bottom) and (not player_1_crash_player_4_top) and  (not player_2_crash_player_4_top) and (not player_3_crash_player_4_top)) then
        counter_score_4 <= counter_score_4 + 1;
    end if;
    
    if(keyboard_char = x"20" and stop_flag) then
     score_4 <= x"00000000";
    else
        if (counter_score_4 = 100000000 and not stop_flag) then
         score_4 <= std_logic_vector(unsigned(score_4) + 1);
         counter_score_4 <= 0;
       end if;
     end if;
end if;
end process;

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
    if(counter_h>=h_origin_player_1) then
        h_pos_player_1 <= counter_h - h_origin_player_1;
    end if;
    if(counter_v>=v_origin_player_1) then
        v_pos_player_1 <= counter_v - v_origin_player_1;
    end if;
    
    if(counter_h>=h_origin_player_2) then
        h_pos_player_2 <= counter_h - h_origin_player_2;
    end if;
    if(counter_v>=v_origin_player_2) then
        v_pos_player_2 <= counter_v - v_origin_player_2;
    end if;
    
    if(counter_h>=h_origin_player_3) then
        h_pos_player_3 <= counter_h - h_origin_player_3;
    end if;
    if(counter_v>=v_origin_player_3) then
        v_pos_player_3 <= counter_v - v_origin_player_3;
    end if;
    
    if(counter_h>=h_origin_player_4) then
        h_pos_player_4 <= counter_h - h_origin_player_4;
    end if;
    if(counter_v>=v_origin_player_4) then
        v_pos_player_4 <= counter_v - v_origin_player_4;
    end if;
    
    if(counter_h>=h_origin_obst_car_4) then
        h_pos_obst_car_4 <= counter_h - h_origin_obst_car_4;
    end if;
    if(counter_v>=v_origin_obst_car_4) then
        v_pos_obst_car_4 <= counter_v - v_origin_obst_car_4;
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
    green_area      <= false;
    white_area      <= false;
    grey_area       <= false;
    car_player_1    <= false;
    car_player_2    <= false;
    car_player_3    <= false;
    car_player_4    <= false;    
    obst_car_4      <= false;   
    obst_car_3      <= false;
    obst_car_2      <= false;
    obst_car_1      <= false;
    high_score_area <= false;
    score_area      <= false;

    if(counter_h >= 20 and  counter_h <= 155 and counter_v >= 48 and counter_v <64) then  
       high_score_area <= true;
    end if;
    
        if(counter_h >= 20 and  counter_h <= 125 and counter_v >= 64 and counter_v <81) then  
       score_area <= true;
    end if;
    if(counter_h<175 or counter_h>465) then
       green_area <= true;
    end if;
    if((counter_h<185 and counter_h >175) or (counter_h <465 and counter_h>455)) then
        white_area <= true;
    end if;
        
    if(counter_h >185 and counter_h <455) then
        grey_area <= true;
    end if;
    
    if((counter_h < 255 and counter_h > 245) or (counter_h > 315 and counter_h < 325) or (counter_h > 385 and counter_h < 395)) then
        if(lane_counter>48) then
            if(counter_v>0 and counter_v<(lane_counter-48))  then
                white_area <= true;           
            end if;
        end if;
        if((counter_v>0+lane_counter and counter_v<48+lane_counter) or (counter_v>96+lane_counter and counter_v<144+lane_counter) or (counter_v>192+lane_counter and counter_v<240+lane_counter) or (counter_v>288+lane_counter and counter_v<336+lane_counter) or (counter_v>384+lane_counter and counter_v<432+lane_counter)) then
            white_area <= true;           
        end if;
     end if;
    
    if (counter_h> h_origin_player_1 and counter_h < image_h +h_origin_player_1 and counter_v > v_origin_player_1 and counter_v < image_v + v_origin_player_1 )then 
        car_player_1 <= true; 
    end if;   
    if (counter_h> h_origin_player_2 and counter_h < image_h +h_origin_player_2 and counter_v > v_origin_player_2 and counter_v < image_v + v_origin_player_2 )then 
        car_player_2 <= true; 
    end if;
    if (counter_h> h_origin_player_3 and counter_h < image_h +h_origin_player_3 and counter_v > v_origin_player_3 and counter_v < image_v + v_origin_player_3 )then 
        car_player_3 <= true; 
    end if; 
    if (counter_h> h_origin_player_4 and counter_h < image_h +h_origin_player_4 and counter_v > v_origin_player_4 and counter_v < image_v + v_origin_player_4 )then 
        car_player_4 <= true; 
    end if;     
         
    
    if (counter_h> h_origin_obst_car_4 and counter_h < image_h +h_origin_obst_car_4 and counter_v > v_origin_obst_car_4 and counter_v < image_v + v_origin_obst_car_4)then 
        obst_car_4 <= true;
    end if;      
    if (counter_h> h_origin_obst_car_3 and counter_h < image_h +h_origin_obst_car_3 and counter_v > v_origin_obst_car_3 and counter_v < image_v + v_origin_obst_car_3)then 
        obst_car_3 <= true;
    end if;
    if (counter_h> h_origin_obst_car_2 and counter_h < image_h +h_origin_obst_car_2 and counter_v > v_origin_obst_car_2 and counter_v < image_v + v_origin_obst_car_2)then 
        obst_car_2 <= true;
    end if;
    if (counter_h> h_origin_obst_car_1 and counter_h < image_h +h_origin_obst_car_1 and counter_v > v_origin_obst_car_1 and counter_v < image_v + v_origin_obst_car_1)then 
        obst_car_1 <= true;
    end if;       

    
    --Car hitting conditions
    if((v_origin_player_1 = v_origin_obst_car_1 + image_v  and h_origin_player_1 < h_origin_obst_car_1 + image_h and h_origin_player_1 + image_h >= h_origin_obst_car_1) or (v_origin_player_1 = v_origin_obst_car_2 + image_v and h_origin_player_1 + image_h >= h_origin_obst_car_2 and h_origin_player_1 < h_origin_obst_car_2 + image_h) or (v_origin_player_1 = v_origin_obst_car_3 + image_v and h_origin_player_1 + image_h >= h_origin_obst_car_3 and h_origin_player_1 < h_origin_obst_car_3 + image_h) or (v_origin_player_1 = v_origin_obst_car_4 + image_v and h_origin_player_1 + image_h >= h_origin_obst_car_4 and h_origin_player_1 < h_origin_obst_car_4 + image_h)) then
        player_1_crash_bottom <= true;
    else player_1_crash_bottom <= false;
    end if;

    if((v_origin_player_1 + image_v  = v_origin_obst_car_1 and h_origin_player_1 < h_origin_obst_car_1 + image_h and h_origin_player_1 + image_h >= h_origin_obst_car_1) or (v_origin_player_1 + image_v = v_origin_obst_car_2 and h_origin_player_1 + image_h >= h_origin_obst_car_2 and h_origin_player_1 < h_origin_obst_car_2 + image_h) or (v_origin_player_1 + image_v = v_origin_obst_car_3 and h_origin_player_1 + image_h >= h_origin_obst_car_3 and h_origin_player_1 < h_origin_obst_car_3 + image_h) or (v_origin_player_1 + image_v = v_origin_obst_car_4 and h_origin_player_1 + image_h >= h_origin_obst_car_4 and h_origin_player_1 < h_origin_obst_car_4 + image_h)) then
        player_1_crash_top <= true;
    else player_1_crash_top <= false;    
    end if;
    
    if((h_origin_player_1 = h_origin_obst_car_1 + image_h and v_origin_player_1 + image_v >= v_origin_obst_car_1 and v_origin_player_1 <= v_origin_obst_car_1 + image_v) or (h_origin_player_1 = h_origin_obst_car_2 +image_h and v_origin_player_1 + image_v >= v_origin_obst_car_2 and v_origin_player_1 <= v_origin_obst_car_2 + image_v) or (h_origin_player_1 = h_origin_obst_car_3 +image_h and v_origin_player_1 + image_v >= v_origin_obst_car_3 and v_origin_player_1 <= v_origin_obst_car_3 + image_v)) then
        player_1_crash_left <= true;
    else player_1_crash_left <= false;    
    end if;
    
    if ((h_origin_player_1 + image_h = h_origin_obst_car_2 and v_origin_player_1 + image_v >= v_origin_obst_car_2 and v_origin_player_1 <= v_origin_obst_car_2 + image_v) or (h_origin_player_1 + image_h = h_origin_obst_car_3 and v_origin_player_1 + image_v >= v_origin_obst_car_3 and v_origin_player_1 <= v_origin_obst_car_3 + image_v) or (h_origin_player_1 + image_h = h_origin_obst_car_4 and v_origin_player_1 + image_v >= v_origin_obst_car_4 and v_origin_player_1 <= v_origin_obst_car_4 + image_v)) then
        player_1_crash_right <= true;
    else player_1_crash_right <= false;    
    end if;
    
    
    
    if((v_origin_player_2 = v_origin_obst_car_1 + image_v  and h_origin_player_2 < h_origin_obst_car_1 + image_h and h_origin_player_2 + image_h >= h_origin_obst_car_1) or (v_origin_player_2 = v_origin_obst_car_2 + image_v and h_origin_player_2 + image_h >= h_origin_obst_car_2 and h_origin_player_2 < h_origin_obst_car_2 + image_h) or (v_origin_player_2 = v_origin_obst_car_3 + image_v and h_origin_player_2 + image_h >= h_origin_obst_car_3 and h_origin_player_2 < h_origin_obst_car_3 + image_h) or (v_origin_player_2 = v_origin_obst_car_4 + image_v and h_origin_player_2 + image_h >= h_origin_obst_car_4 and h_origin_player_2 < h_origin_obst_car_4 + image_h)) then
        player_2_crash_bottom <= true;
    else player_2_crash_bottom <= false;
    end if;

    if((v_origin_player_2 + image_v = v_origin_obst_car_1 and h_origin_player_2 < h_origin_obst_car_1 + image_h and h_origin_player_2 + image_h >= h_origin_obst_car_1) or (v_origin_player_2 + image_v = v_origin_obst_car_2 and h_origin_player_2 + image_h >= h_origin_obst_car_2 and h_origin_player_2 < h_origin_obst_car_2 + image_h) or (v_origin_player_2 + image_v = v_origin_obst_car_3 and h_origin_player_2 + image_h >= h_origin_obst_car_3 and h_origin_player_2 < h_origin_obst_car_3 + image_h) or (v_origin_player_2 + image_v = v_origin_obst_car_4 and h_origin_player_2 + image_h >= h_origin_obst_car_4 and h_origin_player_2 < h_origin_obst_car_4 + image_h)) then
        player_2_crash_top <= true;
    else player_2_crash_top <= false;    
    end if;
    
    if((h_origin_player_2 = h_origin_obst_car_1 + image_h and v_origin_player_2 + image_v >= v_origin_obst_car_1 and v_origin_player_2 <= v_origin_obst_car_1 + image_v) or (h_origin_player_2 = h_origin_obst_car_2 +image_h and v_origin_player_2 + image_v >= v_origin_obst_car_2 and v_origin_player_2 <= v_origin_obst_car_2 + image_v) or (h_origin_player_2 = h_origin_obst_car_3 +image_h and v_origin_player_2 + image_v >= v_origin_obst_car_3 and v_origin_player_2 <= v_origin_obst_car_3 + image_v)) then
        player_2_crash_left <= true;
    else player_2_crash_left <= false;    
    end if;
    
    if ((h_origin_player_2 + image_h = h_origin_obst_car_2 and v_origin_player_2 + image_v >= v_origin_obst_car_2 and v_origin_player_2 <= v_origin_obst_car_2 + image_v) or (h_origin_player_2 + image_h = h_origin_obst_car_3 and v_origin_player_2 + image_v >= v_origin_obst_car_3 and v_origin_player_2 <= v_origin_obst_car_3 + image_v) or (h_origin_player_2 + image_h = h_origin_obst_car_4 and v_origin_player_2 + image_v >= v_origin_obst_car_4 and v_origin_player_2 <= v_origin_obst_car_4 + image_v)) then
        player_2_crash_right <= true;
    else player_2_crash_right <= false;    
    end if;  
    
    
    
    if((v_origin_player_3 = v_origin_obst_car_1 + image_v  and h_origin_player_3 < h_origin_obst_car_1 + image_h and h_origin_player_3 + image_h >= h_origin_obst_car_1) or (v_origin_player_3 = v_origin_obst_car_2 + image_v and h_origin_player_3 + image_h >= h_origin_obst_car_2 and h_origin_player_3 < h_origin_obst_car_2 + image_h) or (v_origin_player_3 = v_origin_obst_car_3 + image_v and h_origin_player_3 + image_h >= h_origin_obst_car_3 and h_origin_player_3 < h_origin_obst_car_3 + image_h) or (v_origin_player_3 = v_origin_obst_car_4 + image_v and h_origin_player_3 + image_h >= h_origin_obst_car_4 and h_origin_player_3 < h_origin_obst_car_4 + image_h)) then
        player_3_crash_bottom <= true;
    else player_3_crash_bottom <= false;
    end if;

    if((v_origin_player_3 + image_v = v_origin_obst_car_1 and h_origin_player_3 < h_origin_obst_car_1 + image_h and h_origin_player_3 + image_h >= h_origin_obst_car_1) or (v_origin_player_3 + image_v = v_origin_obst_car_2 and h_origin_player_3 + image_h >= h_origin_obst_car_2 and h_origin_player_3 < h_origin_obst_car_2 + image_h) or (v_origin_player_3 + image_v = v_origin_obst_car_3 and h_origin_player_3 + image_h >= h_origin_obst_car_3 and h_origin_player_3 < h_origin_obst_car_3 + image_h) or (v_origin_player_3 + image_v = v_origin_obst_car_4 and h_origin_player_3 + image_h >= h_origin_obst_car_4 and h_origin_player_3 < h_origin_obst_car_4 + image_h)) then
        player_3_crash_top <= true;
    else player_3_crash_top <= false;    
    end if;
    
    if((h_origin_player_3 = h_origin_obst_car_1 + image_h and v_origin_player_3 + image_v >= v_origin_obst_car_1 and v_origin_player_3 <= v_origin_obst_car_1 + image_v) or (h_origin_player_3 = h_origin_obst_car_2 +image_h and v_origin_player_3 + image_v >= v_origin_obst_car_2 and v_origin_player_3 <= v_origin_obst_car_2 + image_v) or (h_origin_player_3 = h_origin_obst_car_3 +image_h and v_origin_player_3 + image_v >= v_origin_obst_car_3 and v_origin_player_3 <= v_origin_obst_car_3 + image_v)) then
        player_3_crash_left <= true;
    else player_3_crash_left <= false;    
    end if;
    
    if ((h_origin_player_3 + image_h = h_origin_obst_car_2 and v_origin_player_3 + image_v >= v_origin_obst_car_2 and v_origin_player_3 <= v_origin_obst_car_2 + image_v) or (h_origin_player_3 + image_h = h_origin_obst_car_3 and v_origin_player_3 + image_v >= v_origin_obst_car_3 and v_origin_player_3 <= v_origin_obst_car_3 + image_v) or (h_origin_player_3 + image_h = h_origin_obst_car_4 and v_origin_player_3 + image_v >= v_origin_obst_car_4 and v_origin_player_3 <= v_origin_obst_car_4 + image_v)) then
        player_3_crash_right <= true;
    else player_3_crash_right <= false;    
    end if; 
    
    
    
    if((v_origin_player_4 = v_origin_obst_car_1 + image_v  and h_origin_player_4 < h_origin_obst_car_1 + image_h and h_origin_player_4 + image_h >= h_origin_obst_car_1) or (v_origin_player_4 = v_origin_obst_car_2 + image_v and h_origin_player_4 + image_h >= h_origin_obst_car_2 and h_origin_player_4 < h_origin_obst_car_2 + image_h) or (v_origin_player_4 = v_origin_obst_car_3 + image_v and h_origin_player_4 + image_h >= h_origin_obst_car_3 and h_origin_player_4 < h_origin_obst_car_3 + image_h) or (v_origin_player_4 = v_origin_obst_car_4 + image_v and h_origin_player_4 + image_h >= h_origin_obst_car_4 and h_origin_player_4 < h_origin_obst_car_4 + image_h)) then
        player_4_crash_bottom <= true;
    else player_4_crash_bottom <= false;
    end if;

    if((v_origin_player_4 + image_v = v_origin_obst_car_1 and h_origin_player_4 < h_origin_obst_car_1 + image_h and h_origin_player_4 + image_h >= h_origin_obst_car_1) or (v_origin_player_4 + image_v = v_origin_obst_car_2 and h_origin_player_4 + image_h >= h_origin_obst_car_2 and h_origin_player_4 < h_origin_obst_car_2 + image_h) or (v_origin_player_4 + image_v = v_origin_obst_car_3 and h_origin_player_4 + image_h >= h_origin_obst_car_3 and h_origin_player_4 < h_origin_obst_car_3 + image_h) or (v_origin_player_4 + image_v = v_origin_obst_car_4 and h_origin_player_4 + image_h >= h_origin_obst_car_4 and h_origin_player_4 < h_origin_obst_car_4 + image_h)) then
        player_4_crash_top <= true;
    else player_4_crash_top <= false;    
    end if;
    
    if((h_origin_player_4 = h_origin_obst_car_1 + image_h and v_origin_player_4 + image_v >= v_origin_obst_car_1 and v_origin_player_4 <= v_origin_obst_car_1 + image_v) or (h_origin_player_4 = h_origin_obst_car_2 +image_h and v_origin_player_4 + image_v >= v_origin_obst_car_2 and v_origin_player_4 <= v_origin_obst_car_2 + image_v) or (h_origin_player_4 = h_origin_obst_car_3 +image_h and v_origin_player_4 + image_v >= v_origin_obst_car_3 and v_origin_player_4 <= v_origin_obst_car_3 + image_v)) then
        player_4_crash_left <= true;
    else player_4_crash_left <= false;    
    end if;
    
    if ((h_origin_player_4 + image_h = h_origin_obst_car_2 and v_origin_player_4 + image_v >= v_origin_obst_car_2 and v_origin_player_4 <= v_origin_obst_car_2 + image_v) or (h_origin_player_4 + image_h = h_origin_obst_car_3 and v_origin_player_4 + image_v >= v_origin_obst_car_3 and v_origin_player_4 <= v_origin_obst_car_3 + image_v) or (h_origin_player_4 + image_h = h_origin_obst_car_4 and v_origin_player_4 + image_v >= v_origin_obst_car_4 and v_origin_player_4 <= v_origin_obst_car_4 + image_v)) then
        player_4_crash_right <= true;
    else player_4_crash_right <= false;    
    end if;         
    
    
    -- Player 1 hits player 2 / Player 2 hits player 1
    if((v_origin_player_1 <= v_origin_player_2 + image_v and v_origin_player_1 > v_origin_player_2  and h_origin_player_1 < h_origin_player_2 + image_h and h_origin_player_1 + image_h >= h_origin_player_2)) then
        player_1_crash_player_2_bottom <= true;
    else player_1_crash_player_2_bottom <= false;
    end if;

    if((v_origin_player_1 + image_v  >= v_origin_player_2 and v_origin_player_1 + image_v  < v_origin_player_2 + image_v and h_origin_player_1 < h_origin_player_2 + image_h and h_origin_player_1 + image_h >= h_origin_player_2)) then
        player_1_crash_player_2_top <= true;
    else player_1_crash_player_2_top <= false;    
    end if;
    
    if((h_origin_player_1  <= h_origin_player_2 + image_h and h_origin_player_1 > h_origin_player_2  and v_origin_player_1 + image_v >= v_origin_player_2 and v_origin_player_1 <= v_origin_player_2 + image_v)) then
        player_1_crash_player_2_left <= true;
    else player_1_crash_player_2_left <= false;    
    end if;
    
    if ((h_origin_player_1 + image_h >= h_origin_player_2 and h_origin_player_1 + image_h < h_origin_player_2 + image_h and v_origin_player_1 + image_v >= v_origin_player_2 and v_origin_player_1 <= v_origin_player_2 + image_v)) then
        player_1_crash_player_2_right <= true;
    else player_1_crash_player_2_right <= false;    
    end if; 
    
     
    -- Player 1 hits player 3 / Player 3 hits player 1
     if((v_origin_player_1 <= v_origin_player_3 + image_v and v_origin_player_1 > v_origin_player_3  and h_origin_player_1 < h_origin_player_3 + image_h and h_origin_player_1 + image_h >= h_origin_player_3)) then
        player_1_crash_player_3_bottom <= true;
    else player_1_crash_player_3_bottom <= false;
    end if;

    if((v_origin_player_1 + image_v  >= v_origin_player_3 and v_origin_player_1 + image_v  < v_origin_player_3 + image_v and h_origin_player_1 < h_origin_player_3 + image_h and h_origin_player_1 + image_h >= h_origin_player_3)) then
        player_1_crash_player_3_top <= true;
    else player_1_crash_player_3_top <= false;    
    end if;
    
    if((h_origin_player_1  <= h_origin_player_3 + image_h and h_origin_player_1 > h_origin_player_3  and v_origin_player_1 + image_v >= v_origin_player_3 and v_origin_player_1 <= v_origin_player_3 + image_v)) then
        player_1_crash_player_3_left <= true;
    else player_1_crash_player_3_left <= false;    
    end if;
    
    if ((h_origin_player_1 + image_h >= h_origin_player_3 and h_origin_player_1 + image_h < h_origin_player_3 + image_h and v_origin_player_1 + image_v >= v_origin_player_3 and v_origin_player_1 <= v_origin_player_3 + image_v)) then
        player_1_crash_player_3_right <= true;
    else player_1_crash_player_3_right <= false;    
    end if; 
     
    -- Player 1 hits player 4 / Player 4 hits player 1
     if((v_origin_player_1 <= v_origin_player_4 + image_v and v_origin_player_1 > v_origin_player_4  and h_origin_player_1 < h_origin_player_4 + image_h and h_origin_player_1 + image_h >= h_origin_player_4)) then
        player_1_crash_player_4_bottom <= true;
    else player_1_crash_player_4_bottom <= false;
    end if;

    if((v_origin_player_1 + image_v  >= v_origin_player_4 and v_origin_player_1 + image_v  < v_origin_player_4 + image_v and h_origin_player_1 < h_origin_player_4 + image_h and h_origin_player_1 + image_h >= h_origin_player_4)) then
        player_1_crash_player_4_top <= true;
    else player_1_crash_player_4_top <= false;    
    end if;
    
    if((h_origin_player_1  <= h_origin_player_4 + image_h and h_origin_player_1 > h_origin_player_4  and v_origin_player_1 + image_v >= v_origin_player_4 and v_origin_player_1 <= v_origin_player_4 + image_v)) then
        player_1_crash_player_4_left <= true;
    else player_1_crash_player_4_left <= false;    
    end if;
    
    if ((h_origin_player_1 + image_h >= h_origin_player_4 and h_origin_player_1 + image_h < h_origin_player_4 + image_h and v_origin_player_1 + image_v >= v_origin_player_4 and v_origin_player_1 <= v_origin_player_4 + image_v)) then
        player_1_crash_player_4_right <= true;
    else player_1_crash_player_4_right <= false;    
    end if;  
    
    -- Player 2 hits player 3 / Player 3 hits player 2
    if((v_origin_player_3 <= v_origin_player_2 + image_v and v_origin_player_3 > v_origin_player_2  and h_origin_player_3 < h_origin_player_2 + image_h and h_origin_player_3 + image_h >= h_origin_player_2)) then
        player_2_crash_player_3_bottom <= true;
    else player_2_crash_player_3_bottom <= false;
    end if;

    if((v_origin_player_3 + image_v  >= v_origin_player_2 and v_origin_player_3 + image_v  < v_origin_player_2 + image_v and h_origin_player_3 < h_origin_player_2 + image_h and h_origin_player_3 + image_h >= h_origin_player_2)) then
        player_2_crash_player_3_top <= true;
    else player_2_crash_player_3_top <= false;    
    end if;
    
    if((h_origin_player_3  <= h_origin_player_2 + image_h and h_origin_player_3 > h_origin_player_2  and v_origin_player_3 + image_v >= v_origin_player_2 and v_origin_player_3 <= v_origin_player_2 + image_v)) then
        player_2_crash_player_3_left <= true;
    else player_2_crash_player_3_left <= false;    
    end if;
    
    if ((h_origin_player_3 + image_h >= h_origin_player_2 and h_origin_player_3 + image_h < h_origin_player_2 + image_h and v_origin_player_3 + image_v >= v_origin_player_2 and v_origin_player_3 <= v_origin_player_2 + image_v)) then
        player_2_crash_player_3_right <= true;
    else player_2_crash_player_3_right <= false;    
    end if;
      
    -- Player 2 hits player 4 / Player 4 hits player 2    
    if((v_origin_player_4 <= v_origin_player_2 + image_v and v_origin_player_4 > v_origin_player_2  and h_origin_player_4 < h_origin_player_2 + image_h and h_origin_player_4 + image_h >= h_origin_player_2)) then
        player_2_crash_player_4_bottom <= true;
    else player_2_crash_player_4_bottom <= false;
    end if;
    
    if((v_origin_player_4 + image_v  >= v_origin_player_2 and v_origin_player_4 + image_v  < v_origin_player_2 + image_v and h_origin_player_4 < h_origin_player_2 + image_h and h_origin_player_4 + image_h >= h_origin_player_2)) then
        player_2_crash_player_4_top <= true;
    else player_2_crash_player_4_top <= false;    
    end if;
    
    if((h_origin_player_4  <= h_origin_player_2 + image_h and h_origin_player_4 > h_origin_player_2  and v_origin_player_4 + image_v >= v_origin_player_2 and v_origin_player_4 <= v_origin_player_2 + image_v)) then
        player_2_crash_player_4_left <= true;
    else player_2_crash_player_4_left <= false;    
    end if;
    
    if ((h_origin_player_4 + image_h >= h_origin_player_2 and h_origin_player_4 + image_h < h_origin_player_2 + image_h and v_origin_player_4 + image_v >= v_origin_player_2 and v_origin_player_4 <= v_origin_player_2 + image_v)) then
        player_2_crash_player_4_right <= true;
    else player_2_crash_player_4_right <= false;    
    end if;  
    
    -- Player 4 hits player 3 / Player 3 hits player 4    
    if((v_origin_player_3 <= v_origin_player_4 + image_v and v_origin_player_3 > v_origin_player_4  and h_origin_player_3 < h_origin_player_4 + image_h and h_origin_player_3 + image_h >= h_origin_player_4)) then
        player_3_crash_player_4_bottom <= true;
    else player_3_crash_player_4_bottom <= false;
    end if;
   

    if((v_origin_player_3 + image_v  >= v_origin_player_4 and v_origin_player_3 + image_v  < v_origin_player_4 + image_v and h_origin_player_3 < h_origin_player_4 + image_h and h_origin_player_3 + image_h >= h_origin_player_4)) then
        player_3_crash_player_4_top <= true;
    else player_3_crash_player_4_top <= false;    
    end if;
    
    if((h_origin_player_3  <= h_origin_player_4 + image_h and h_origin_player_3 > h_origin_player_4  and v_origin_player_3 + image_v >= v_origin_player_4 and v_origin_player_3 <= v_origin_player_4 + image_v)) then
        player_3_crash_player_4_left <= true;
    else player_3_crash_player_4_left <= false;    
    end if;
    
    if((h_origin_player_3 + image_h >= h_origin_player_4 and h_origin_player_3 + image_h < h_origin_player_4 + image_h and v_origin_player_3 + image_v >= v_origin_player_4 and v_origin_player_3 <= v_origin_player_4 + image_v)) then
        player_3_crash_player_4_right <= true;
    else player_3_crash_player_4_right <= false;    
    end if;                    
    
    if(keyboard_char = x"20") then
     start_display_flag <= false;
    end if;
    
   end if;
end process;

display:process(clk_25mhz)
begin
if rising_edge(clk_25mhz) then
   if(H_flag='1' and V_flag='1') then 
      if(start_display_flag) then
        R <= rgb_start_display(11 downto 8);
        B <= rgb_start_display(7 downto 4);
        G <= rgb_start_display(3 downto 0);      
      elsif(stop_flag)then 
        R <= rgb_final_display(11 downto 8);
        B <= rgb_final_display(7 downto 4);
        G <= rgb_final_display(3 downto 0);
      elsif(score_area) then 
        R <= rgb_score_text(11 downto 8)or rgb_score(11 downto 8);
        B <= rgb_score_text(7 downto 4) or rgb_score(7 downto 4);
        G <= rgb_score_text(3 downto 0) or rgb_score(3 downto 0);
      elsif(high_score_area) then 
        R <= rgb_high_score_text(11 downto 8) or rgb_high_score(11 downto 8);
        B <= rgb_high_score_text(7 downto 4)  or rgb_high_score(7 downto 4);
        G <= rgb_high_score_text(3 downto 0)  or rgb_high_score(3 downto 0);
      elsif(green_area) then
        R <= "0001";
        B <= "0011";
        G <= "1010";         
      elsif(car_player_1) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos_player_1 - 1) + image_v*(v_pos_player_1-1), mem_offset'length));                                    
        R <= douta(11 downto 8);
        B <= douta(3 downto 0);
        G <= douta(7 downto 4); 
      elsif(car_player_2) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos_player_2 - 1) + image_v*(v_pos_player_2-1), mem_offset'length));                                    
        R <= douta(3 downto 0);
        B <= douta(11 downto 8);
        G <= douta(7 downto 4);   
      elsif(car_player_3) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos_player_3 - 1) + image_v*(v_pos_player_3-1), mem_offset'length));                                    
        R <= douta(11 downto 8);
        B <= douta(3 downto 0);
        G <= douta(7 downto 4); 
      elsif(car_player_4) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos_player_4 - 1) + image_v*(v_pos_player_4-1), mem_offset'length));                                    
        R <= douta(3 downto 0);
        B <= douta(11 downto 8);
        G <= douta(7 downto 4);                  
      elsif(obst_car_4) then
        mem_addr <= std_logic_vector(to_unsigned((h_pos_obst_car_4 - 1) + image_v*(v_pos_obst_car_4-1), mem_offset'length));                                    
        R <= douta(7 downto 4);
        B <= douta(3 downto 0);
        G <= douta(11 downto 8);           
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
         elsif(slow_count_obst_car = 800) then 
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
     elsif(slow_count_h = 500*disp_v) then 
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

Player_1_Car: process(sampling_input_rate_v,clk_25mhz,sampling_input_rate_h) -- this should take a different clock 
begin
if rising_edge(clk_25mhz) then 

  if (sampling_input_rate_v = '1') then
    reset_signal      <= false; 
    
    if(player_1_crash_bottom or player_1_crash_player_2_bottom or player_1_crash_player_3_bottom or player_1_crash_player_4_bottom) then
        v_origin_player_1 <= v_origin_player_1;
    elsif(keyboard_char = x"77" or keyboard_char = x"57") then -- top
        if(v_origin_player_1 = 1 + image_v) then
            v_origin_player_1 <= v_origin_player_1;
        else
            v_origin_player_1 <= v_origin_player_1 - 1;
        end if;
    end if;
    
    if(keyboard_char = x"73" or keyboard_char = x"53") then -- bottom
        if(v_origin_player_1 = disp_v - image_v or player_1_crash_top or player_1_crash_player_2_top or player_1_crash_player_3_top or player_1_crash_player_4_top) then
            v_origin_player_1 <= v_origin_player_1;
        else
            v_origin_player_1 <= v_origin_player_1 + 1;
        end if;
    end if;
  end if;
  if (sampling_input_rate_h = '1') then
    
      if((keyboard_char = x"64" or keyboard_char = x"44") and h_origin_player_1 + image_h <455) then -- right
        if(player_1_crash_right or player_1_crash_player_2_right or player_1_crash_player_3_right or player_1_crash_player_4_right)then
           h_origin_player_1 <= h_origin_player_1;
         else
           h_origin_player_1 <= h_origin_player_1 + 1;
         end if;
       end if;
    if((keyboard_char = x"61" or keyboard_char = x"41") and h_origin_player_1 > 185 ) then -- Left
        if(player_1_crash_left or player_1_crash_player_2_left or player_1_crash_player_3_left or player_1_crash_player_4_left) then 
            h_origin_player_1 <= h_origin_player_1; 
        else
            h_origin_player_1 <= h_origin_player_1 -1;
        end if;
    end if;
   end if;
    if(keyboard_char = x"20" and stop_flag) then
        reset_signal      <= true;   
        h_origin_player_1 <= 335;
        v_origin_player_1 <= 380;
    end if; 
end if;
end process;

Player_2_Car: process(sampling_input_rate_v,clk_25mhz,sampling_input_rate_h) -- this should take a different clock 
begin
if rising_edge(clk_25mhz) then
  if (sampling_input_rate_v = '1') then
  
      if(player_2_crash_bottom or player_1_crash_player_2_top or player_2_crash_player_3_bottom or player_2_crash_player_4_bottom) then
        v_origin_player_2 <= v_origin_player_2;      
      elsif(move_up_1 = '1') then -- top
            if(v_origin_player_2 = 1 + image_v) then
               v_origin_player_2 <= v_origin_player_2;
            else
                v_origin_player_2 <= v_origin_player_2 - 1;
            end if;
        end if;
        
        if(move_down_1 = '1') then -- bottom
            if(v_origin_player_2 = disp_v-image_v-10 or player_2_crash_top or player_1_crash_player_2_bottom or player_2_crash_player_3_top or player_2_crash_player_4_top) then
                v_origin_player_2 <= v_origin_player_2;
            else
                v_origin_player_2 <= v_origin_player_2 + 1;
            end if;
        end if;
     end if;
     
  if (sampling_input_rate_h = '1') then
          if(move_right_1 = '1' and h_origin_player_2 + image_h <455) then -- right
            if(player_2_crash_right or player_1_crash_player_2_left or player_2_crash_player_3_right or player_2_crash_player_4_right)then
                h_origin_player_2 <= h_origin_player_2;
             else
               h_origin_player_2 <= h_origin_player_2 + 1;
             end if;
           end if;
        if(move_left_1 = '1' and h_origin_player_2 > 185 ) then -- Left
            if(player_2_crash_left or player_1_crash_player_2_right or player_2_crash_player_3_left or player_2_crash_player_4_left) then 
           h_origin_player_2 <= h_origin_player_2;
            else
                h_origin_player_2 <= h_origin_player_2 -1;
            end if;
        end if;
   end if;
   
   if(keyboard_char = x"20" and stop_flag) then
        h_origin_player_2 <= 195;
        v_origin_player_2 <= 380;
    end if; 
end if;
end process;

Player_3_Car: process(sampling_input_rate_v,clk_25mhz,sampling_input_rate_h) -- this should take a different clock 
begin
if rising_edge(clk_25mhz) then
  if (sampling_input_rate_v = '1') then
  
      if(player_3_crash_bottom or player_1_crash_player_3_top or player_2_crash_player_3_top or player_3_crash_player_4_bottom) then
        v_origin_player_3 <= v_origin_player_3;      
      elsif(move_up_2 = '1') then -- top
            if(v_origin_player_3 = 1 + image_v) then
               v_origin_player_3 <= v_origin_player_3;
            else
                v_origin_player_3 <= v_origin_player_3 - 1;
            end if;
        end if;
        
        if(move_down_3 = '1') then -- bottom
            if(v_origin_player_3 = disp_v-image_v-10 or player_3_crash_top or player_1_crash_player_3_bottom or player_2_crash_player_3_bottom or player_3_crash_player_4_top) then
                v_origin_player_3 <= v_origin_player_3;
            else
                v_origin_player_3 <= v_origin_player_3 + 1;
            end if;
        end if;
     end if;
     
  if (sampling_input_rate_h = '1') then
          if(move_right_2 = '1' and h_origin_player_3 + image_h <455) then -- right
            if(player_3_crash_right or player_1_crash_player_3_left or player_2_crash_player_3_left or player_3_crash_player_4_right)then
                h_origin_player_3 <= h_origin_player_3;
             else
               h_origin_player_3 <= h_origin_player_3 + 1;
             end if;
           end if;
        if(move_left_2 = '1' and h_origin_player_2 > 185 ) then -- Left
            if(player_3_crash_left or player_1_crash_player_3_right or player_2_crash_player_3_right or player_3_crash_player_4_left) then 
           h_origin_player_3 <= h_origin_player_3;
            else
                h_origin_player_3 <= h_origin_player_3 -1;
            end if;
        end if;
   end if;
   
   if(keyboard_char = x"20" and stop_flag) then
        h_origin_player_3 <= 265;
        v_origin_player_3 <= 380;
    end if; 
end if;
end process;

Player_4_Car: process(sampling_input_rate_v,clk_25mhz,sampling_input_rate_h) -- this should take a different clock 
begin
if rising_edge(clk_25mhz) then
  if (sampling_input_rate_v = '1') then
  
      if(player_4_crash_bottom or player_1_crash_player_4_top or player_2_crash_player_4_top or player_3_crash_player_4_top) then
        v_origin_player_4 <= v_origin_player_4;     
      elsif(move_up_3 = '1') then -- top
            if(v_origin_player_4 = 1 + image_v) then
               v_origin_player_4 <= v_origin_player_4;
            else
                v_origin_player_4 <= v_origin_player_4 - 1;
            end if;
        end if;
        
        if(move_down_3 = '1') then -- bottom
            if(v_origin_player_4 = disp_v-image_v-10 or player_4_crash_top or player_1_crash_player_4_bottom or player_2_crash_player_4_bottom or player_3_crash_player_4_bottom) then
                v_origin_player_4 <= v_origin_player_4;
            else
                v_origin_player_4 <= v_origin_player_4 + 1;
            end if;
        end if;
     end if;
     
  if (sampling_input_rate_h = '1') then
          if(move_right_3 = '1' and h_origin_player_4 + image_h <455) then -- right
            if(player_4_crash_right or player_1_crash_player_4_left or player_2_crash_player_4_left or player_3_crash_player_4_left)then
                h_origin_player_4 <= h_origin_player_4;
             else
               h_origin_player_4 <= h_origin_player_4 + 1;
             end if;
           end if;
        if(move_left_3 = '1' and h_origin_player_4 > 185 ) then -- Left
            if(player_4_crash_left or player_1_crash_player_4_right or player_2_crash_player_4_right or player_3_crash_player_4_right) then 
           h_origin_player_4 <= h_origin_player_4;
            else
                h_origin_player_4 <= h_origin_player_4 -1;
            end if;
        end if;
   end if;
   
   if(keyboard_char = x"20" and stop_flag) then
        h_origin_player_4 <= 480;
        v_origin_player_4 <= 380;
    end if; 
end if;
end process;

obstacle_cars: process(clk_25mhz,slow_count_obst_car) -- this should take a different clock 
begin
if rising_edge(clk_25mhz) then 
   if(keyboard_char = x"20" and stop_flag) then
        v_origin_obst_car_1 <= 480;
        v_origin_obst_car_2 <= 480;
        v_origin_obst_car_3 <= 480;
        v_origin_obst_car_4 <= 480;
        rand_obst_car_4 <= 0;
        rand_obst_car_3 <= 0;
        rand_obst_car_2 <= 0;
        rand_obst_car_1 <= 0;
   else if (sampling_obst_car = '1' and not start_display_flag) then
  
    if(v_origin_obst_car_4 = disp_v) then
         rand_obst_car_4 <= rand_obst_car_4 + 1;
        if(rand_obst_car_4 = 40) then 
            v_origin_obst_car_4 <= 0; 
            rand_obst_car_4 <= 0;
        end if;
    else
        if(player_1_crash_bottom and (v_origin_player_1 = v_origin_obst_car_4 + image_v  and h_origin_player_1 < h_origin_obst_car_4 + image_h and h_origin_player_1 + image_h >= h_origin_obst_car_4) ) then
            v_origin_obst_car_4 <= v_origin_obst_car_4;
        elsif(player_2_crash_bottom and (v_origin_player_2 = v_origin_obst_car_4 + image_v  and h_origin_player_2 < h_origin_obst_car_4 + image_h and h_origin_player_2 + image_h >= h_origin_obst_car_4) ) then
            v_origin_obst_car_4 <= v_origin_obst_car_4;
        elsif(player_3_crash_bottom and (v_origin_player_3 = v_origin_obst_car_4 + image_v  and h_origin_player_3 < h_origin_obst_car_4 + image_h and h_origin_player_3 + image_h >= h_origin_obst_car_4) ) then
            v_origin_obst_car_4 <= v_origin_obst_car_4;
        elsif(player_4_crash_bottom and (v_origin_player_4 = v_origin_obst_car_4 + image_v  and h_origin_player_4 < h_origin_obst_car_4 + image_h and h_origin_player_4 + image_h >= h_origin_obst_car_4) ) then
            v_origin_obst_car_4 <= v_origin_obst_car_4;                        
        else
          v_origin_obst_car_4 <= v_origin_obst_car_4 + 1;
        end if;        
        
    end if;
    
    if(v_origin_obst_car_3 = disp_v) then
         rand_obst_car_3 <= rand_obst_car_3 + 1;
        if(rand_obst_car_3 = 13) then 
            v_origin_obst_car_3 <= 0; 
            rand_obst_car_3 <= 0;
        end if;
    else
         if(player_1_crash_bottom and (v_origin_player_1 = v_origin_obst_car_3 + image_v  and h_origin_player_1 < h_origin_obst_car_3 + image_h and h_origin_player_1 + image_h >= h_origin_obst_car_3) ) then
            v_origin_obst_car_3 <= v_origin_obst_car_3;
        elsif(player_2_crash_bottom and (v_origin_player_2 = v_origin_obst_car_3 + image_v  and h_origin_player_2 < h_origin_obst_car_3 + image_h and h_origin_player_2 + image_h >= h_origin_obst_car_3) ) then
            v_origin_obst_car_3 <= v_origin_obst_car_3;
        elsif(player_3_crash_bottom and (v_origin_player_3 = v_origin_obst_car_3 + image_v  and h_origin_player_3 < h_origin_obst_car_3 + image_h and h_origin_player_3 + image_h >= h_origin_obst_car_3) ) then
            v_origin_obst_car_3 <= v_origin_obst_car_3;
        elsif(player_4_crash_bottom and (v_origin_player_4 = v_origin_obst_car_3 + image_v  and h_origin_player_4 < h_origin_obst_car_3 + image_h and h_origin_player_4 + image_h >= h_origin_obst_car_3) ) then
            v_origin_obst_car_3 <= v_origin_obst_car_3;                        
        else
          v_origin_obst_car_3 <= v_origin_obst_car_3 + 1;
        end if;        
    end if;

    if(v_origin_obst_car_2 = disp_v) then
       rand_obst_car_2 <= rand_obst_car_2 + 1;
       if(rand_obst_car_2 > 43 and ((v_origin_obst_car_3>350 and v_origin_obst_car_3< 480) or (v_origin_obst_car_1>350 and v_origin_obst_car_1<480))) then 
            v_origin_obst_car_2 <= 0; 
            rand_obst_car_2 <= 0;
        end if;
    else
        if(player_1_crash_bottom and (v_origin_player_1 = v_origin_obst_car_2 + image_v  and h_origin_player_1 < h_origin_obst_car_2 + image_h and h_origin_player_1 + image_h >= h_origin_obst_car_2) ) then
            v_origin_obst_car_2 <= v_origin_obst_car_2;
        elsif(player_2_crash_bottom and (v_origin_player_2 = v_origin_obst_car_2 + image_v  and h_origin_player_2 < h_origin_obst_car_2 + image_h and h_origin_player_2 + image_h >= h_origin_obst_car_2) ) then
            v_origin_obst_car_2 <= v_origin_obst_car_2;
        elsif(player_3_crash_bottom and (v_origin_player_3 = v_origin_obst_car_2 + image_v  and h_origin_player_3 < h_origin_obst_car_2 + image_h and h_origin_player_3 + image_h >= h_origin_obst_car_2) ) then
            v_origin_obst_car_2 <= v_origin_obst_car_2;
        elsif(player_4_crash_bottom and (v_origin_player_4 = v_origin_obst_car_2 + image_v  and h_origin_player_4 < h_origin_obst_car_2 + image_h and h_origin_player_4 + image_h >= h_origin_obst_car_2) ) then
            v_origin_obst_car_2 <= v_origin_obst_car_2;                        
        else
            v_origin_obst_car_2 <= v_origin_obst_car_2 + 1;
        end if;
    end if;


    if(v_origin_obst_car_1 = disp_v) then
      rand_obst_car_1 <= rand_obst_car_1 + 1;
       if(rand_obst_car_1 = 58) then 
            v_origin_obst_car_1 <= 0; 
            rand_obst_car_1 <= 0;
       end if;
    else
    
       if(player_1_crash_bottom and (v_origin_player_1 = v_origin_obst_car_1 + image_v  and h_origin_player_1 < h_origin_obst_car_1 + image_h and h_origin_player_1 + image_h >= h_origin_obst_car_1)) then
            v_origin_obst_car_1 <= v_origin_obst_car_1;
        elsif(player_2_crash_bottom and (v_origin_player_2 = v_origin_obst_car_1 + image_v  and h_origin_player_2 < h_origin_obst_car_1 + image_h and h_origin_player_2 + image_h >= h_origin_obst_car_1)) then
            v_origin_obst_car_1 <= v_origin_obst_car_1;
        elsif(player_3_crash_bottom and (v_origin_player_3 = v_origin_obst_car_1 + image_v  and h_origin_player_3 < h_origin_obst_car_1 + image_h and h_origin_player_3 + image_h >= h_origin_obst_car_1)) then
            v_origin_obst_car_1 <= v_origin_obst_car_1;
        elsif(player_4_crash_bottom and (v_origin_player_4 = v_origin_obst_car_1 + image_v  and h_origin_player_4 < h_origin_obst_car_1 + image_h and h_origin_player_4 + image_h >= h_origin_obst_car_1)) then
            v_origin_obst_car_1 <= v_origin_obst_car_1;                        
        else
            v_origin_obst_car_1 <= v_origin_obst_car_1 + 1;
        end if;
    end if;
    
  end if; 
end if;
  end if;
end process;


end Behavioral;