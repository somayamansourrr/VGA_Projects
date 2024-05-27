`timescale 1ns / 1ps
// Reference book: "FPGA Prototyping by Verilog Examples"
//                    "Xilinx Spartan-3 Version"
// Authored by: Pong P. Chu
// Published by: Wiley, 2008
// Adapted for use on Basys 3 FPGA with Xilinx Artix-7
// by: David J. Marion aka FPGA Dude

module final_display(
    input clk,
    input video_on,
    input [9:0] x, y,
    input [31:0] score_1, score_2, score_3, score_4,
    input score_1_flag,score_2_flag,score_3_flag,score_4_flag,
    output reg [11:0] rgb
    );
    
    // signal declarations
    wire [10:0] rom_addr;           // 11-bit text ROM address
    reg  [6:0] ascii_char;          // 7-bit ASCII character code
    reg  [3:0] char_row;            // 4-bit row of ASCII character
    reg  [2:0] bit_addr;            // column number of ROM data    : reads through each bit of each row
    wire [7:0] rom_data;            // 8-bit row data from text ROM
    wire ascii_bit, ascii_bit_on;     // ROM bit and status signal
    wire first_place_on,second_place_on,third_place_on,fourth_place_on;
    wire first_player_on,second_player_on,third_player_on,fourth_player_on;
    wire player1_value_on,player2_value_on,player3_value_on,player4_value_on;
    wire [6:0] char_addr_s10000,char_addr_s1000,char_addr_s100,char_addr_s10,char_addr_s1;
    wire [6:0] char_addr_s20000,char_addr_s2000,char_addr_s200,char_addr_s20,char_addr_s2;
    wire [6:0] char_addr_s30000,char_addr_s3000,char_addr_s300,char_addr_s30,char_addr_s3;
    wire [6:0] char_addr_s40000,char_addr_s4000,char_addr_s400,char_addr_s40,char_addr_s4;
    wire [3:0] dig_1s, dig_10s,dig_100s,dig_1000s,dig_10000s;
    wire [3:0] dig_2s, dig_20s,dig_200s,dig_2000s,dig_20000s;
    wire [3:0] dig_3s, dig_30s,dig_300s,dig_3000s,dig_30000s;
    wire [3:0] dig_4s, dig_40s,dig_400s,dig_4000s,dig_40000s;
    wire S10000_on,S1000_on,S100_on,S10_on,S1_on;
    wire S20000_on,S2000_on,S200_on,S20_on,S2_on;
    wire S30000_on,S3000_on,S300_on,S30_on,S3_on;
    wire S40000_on,S4000_on,S400_on,S40_on,S4_on;
    wire [31:0] first_score, second_score, third_score,fourth_score;
    wire [3:0]first_place, second_place, third_place, fourth_place;
    reg score1_off = 1'b1;
    reg score2_off = 1'b1;
    reg score3_off = 1'b1;
    reg score4_off = 1'b1;   
    
    // firstplace Digit
    localparam first_place_X_L = 240;
    localparam first_place_X_R = 247; 
    localparam first_place_Y_T = 128;
    localparam first_place_Y_B = 144;
    
    // secondplace Digit
    localparam second_place_X_L = 240;
    localparam second_place_X_R = 247;
    localparam second_place_Y_T = 160;
    localparam second_place_Y_B = 176;
    
    // thirdplace Digit
    localparam third_place_X_L = 240;
    localparam third_place_X_R = 247;
    localparam third_place_Y_T = 192;
    localparam third_place_Y_B = 208;
    
    // fourthplace Digit
    localparam fourth_place_X_L = 240;
    localparam fourth_place_X_R = 247;
    localparam fourth_place_Y_T = 224;
    localparam fourth_place_Y_B = 240;
    
    // PLAYER
    localparam player1_X_L = 256;
    localparam player1_X_R = 303;
    localparam player1_Y_T = 128;
    localparam player1_Y_B = 144;
    
     // PLAYER
    localparam player2_X_L = 256;
    localparam player2_X_R = 303;
    localparam player2_Y_T = 160;
    localparam player2_Y_B = 176;
    
    // PLAYER
    localparam player3_X_L = 256;
    localparam player3_X_R = 303;
    localparam player3_Y_T = 192;
    localparam player3_Y_B = 208;
    
   // PLAYER
    localparam player4_X_L = 256;
    localparam player4_X_R = 303;
    localparam player4_Y_T = 224;
    localparam player4_Y_B = 240;
    
    // PLAYER number
    localparam player1_value_X_L = 304;
    localparam player1_value_X_R = 311;
    localparam player1_value_Y_T = 128;
    localparam player1_value_Y_B = 144;
    
     // PLAYER number
    localparam player2_value_X_L = 304;
    localparam player2_value_X_R = 311;
    localparam player2_value_Y_T = 160;
    localparam player2_value_Y_B = 176;
    
    // PLAYER number
    localparam player3_value_X_L = 304;
    localparam player3_value_X_R = 311;
    localparam player3_value_Y_T = 192;
    localparam player3_value_Y_B = 208;
    
   // PLAYER number
    localparam player4_value_X_L = 304;
    localparam player4_value_X_R = 311;
    localparam player4_value_Y_T = 224;
    localparam player4_value_Y_B = 240;
    
    
    // score_1 digit
    localparam S10000_X_L = 320;
    localparam S10000_X_R = 327;
    localparam S10000_Y_T = 128;
    localparam S10000_Y_B = 144;
    
    // score_1 digit
    localparam S1000_X_L = 328;
    localparam S1000_X_R = 335;
    localparam S1000_Y_T = 128;
    localparam S1000_Y_B = 144;
    
    // score_1 digit
    localparam S100_X_L = 336;
    localparam S100_X_R = 343;
    localparam S100_Y_T = 128;
    localparam S100_Y_B = 144;
    
    // score_1 digit
    localparam S10_X_L = 344;
    localparam S10_X_R = 351;
    localparam S10_Y_T = 128;
    localparam S10_Y_B = 144;
    
    // score_1 digit
    localparam S1_X_L = 352;
    localparam S1_X_R = 359;
    localparam S1_Y_T = 128;
    localparam S1_Y_B = 144;
    
    
     // score_2 digit
    localparam S20000_X_L = 320;
    localparam S20000_X_R = 327;
    localparam S20000_Y_T = 160;
    localparam S20000_Y_B = 176;
    
    // score_2 digit
    localparam S2000_X_L = 328;
    localparam S2000_X_R = 335;
    localparam S2000_Y_T = 160;
    localparam S2000_Y_B = 176;
    
    // score_2 digit
    localparam S200_X_L = 336;
    localparam S200_X_R = 343;
    localparam S200_Y_T = 160;
    localparam S200_Y_B = 176;
    
    // score_2 digit
    localparam S20_X_L = 344;
    localparam S20_X_R = 351;
    localparam S20_Y_T = 160;
    localparam S20_Y_B = 176;
    
    // score_2 digit
    localparam S2_X_L = 352;
    localparam S2_X_R = 359;
    localparam S2_Y_T = 160;
    localparam S2_Y_B = 176;
    
    // score_3 digit
    localparam S30000_X_L = 320;
    localparam S30000_X_R = 327;
    localparam S30000_Y_T = 192;
    localparam S30000_Y_B = 208;
    
    // score_3 digit
    localparam S3000_X_L = 328;
    localparam S3000_X_R = 335;
    localparam S3000_Y_T = 192;
    localparam S3000_Y_B = 208;
    
    // score_3 digit
    localparam S300_X_L = 336;
    localparam S300_X_R = 343;
    localparam S300_Y_T = 192;
    localparam S300_Y_B = 208;
    
    // score_3 digit
    localparam S30_X_L = 344;
    localparam S30_X_R = 351;
    localparam S30_Y_T = 192;
    localparam S30_Y_B = 208;
    
    // score_3 digit
    localparam S3_X_L = 352;
    localparam S3_X_R = 359;
    localparam S3_Y_T = 192;
    localparam S3_Y_B = 208;
    
    // score_4 digit
    localparam S40000_X_L = 320;
    localparam S40000_X_R = 327;
    localparam S40000_Y_T = 224;
    localparam S40000_Y_B = 240;
    
    // score_4 digit
    localparam S4000_X_L = 328;
    localparam S4000_X_R = 335;
    localparam S4000_Y_T = 224;
    localparam S4000_Y_B = 240;
    
    // score_4 digit
    localparam S400_X_L = 336;
    localparam S400_X_R = 343;
    localparam S400_Y_T = 224;
    localparam S400_Y_B = 240;
    
    // score_4 digit
    localparam S40_X_L = 344;
    localparam S40_X_R = 351;
    localparam S40_Y_T = 224;
    localparam S40_Y_B = 240;
    
    // score_4 digit
    localparam S4_X_L = 352;
    localparam S4_X_R = 359;
    localparam S4_Y_T = 224;
    localparam S4_Y_B = 240;
    
    
    
    // instantiate ASCII ROM
    ascii_rom rom(.clk(clk), .addr(rom_addr), .data(rom_data));
      
    // ASCII ROM interface
    assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
    assign ascii_bit = rom_data[~bit_addr];     // reverse bit order : need to start from left to right (which is bit 7) (bit_wise = ~8'hA1; bit_wise == 8'h5E)
 
    
    assign first_place_on  =  (first_place_X_L  <= x) && (x <= first_place_X_R ) &&
                              (first_place_Y_T  <= y) && (y <= first_place_Y_B );    
    assign second_place_on =  (second_place_X_L <= x) && (x <= second_place_X_R ) &&
                              (second_place_Y_T <= y) && (y <= second_place_Y_B );
    assign third_place_on  =  (third_place_X_L  <= x) && (x <= third_place_X_R ) &&
                              (third_place_Y_T  <= y) && (y <= third_place_Y_B );         
    assign fourth_place_on =  (fourth_place_X_L <= x) && (x <= fourth_place_X_R ) &&
                              (fourth_place_Y_T <= y) && (y <= fourth_place_Y_B );
                             
    assign first_player_on  = (player1_X_L  <= x) && (x <= player1_X_R ) &&
                              (player1_Y_T  <= y) && (y <= player1_Y_B );    
    assign second_player_on = (player2_X_L  <= x) && (x <= player2_X_R ) &&
                              (player2_Y_T  <= y) && (y <= player2_Y_B );
    assign third_player_on  = (player3_X_L  <= x) && (x <= player3_X_R ) &&
                              (player3_Y_T  <= y) && (y <= player3_Y_B );         
    assign fourth_player_on = (player4_X_L  <= x) && (x <= player4_X_R ) &&
                              (player4_Y_T  <= y) && (y <= player4_Y_B );
   
    assign player1_value_on = (player1_value_X_L  <= x) && (x <= player1_value_X_R ) &&
                              (player1_value_Y_T  <= y) && (y <= player1_value_Y_B );    
    assign player2_value_on = (player2_value_X_L  <= x) && (x <= player2_value_X_R ) &&
                              (player2_value_Y_T  <= y) && (y <= player2_value_Y_B );
    assign player3_value_on = (player3_value_X_L  <= x) && (x <= player3_value_X_R ) &&
                              (player3_value_Y_T  <= y) && (y <= player3_value_Y_B );         
    assign player4_value_on = (player4_value_X_L  <= x) && (x <= player4_value_X_R ) &&
                              (player4_value_Y_T  <= y) && (y <= player4_value_Y_B );
                              
    assign S10000_on        = (S10000_X_L  <= x) && (x <= S10000_X_R ) &&
                              (S10000_Y_T  <= y) && (y <= S10000_Y_B );    
    assign S1000_on         = (S1000_X_L   <= x) && (x <= S1000_X_R ) &&
                              (S1000_Y_T   <= y) && (y <= S1000_Y_B );
    assign S100_on          = (S100_X_L    <= x) && (x <= S100_X_R ) &&
                              (S100_Y_T    <= y) && (y <= S100_Y_B );         
    assign S10_on           = (S10_X_L     <= x) && (x <= S10_X_R ) &&
                              (S10_Y_T     <= y) && (y <= S10_Y_B );
    assign S1_on            = (S1_X_L      <= x) && (x <= S1_X_R ) &&
                              (S1_Y_T      <= y) && (y <= S1_Y_B );
    
    assign S20000_on        = (S20000_X_L  <= x) && (x <= S20000_X_R ) &&
                              (S20000_Y_T  <= y) && (y <= S20000_Y_B );    
    assign S2000_on         = (S2000_X_L   <= x) && (x <= S2000_X_R ) &&
                              (S2000_Y_T   <= y) && (y <= S2000_Y_B );
    assign S200_on          = (S200_X_L    <= x) && (x <= S200_X_R ) &&
                              (S200_Y_T    <= y) && (y <= S200_Y_B );         
    assign S20_on           = (S20_X_L     <= x) && (x <= S20_X_R ) &&
                              (S20_Y_T     <= y) && (y <= S20_Y_B );
    assign S2_on            = (S2_X_L      <= x) && (x <= S2_X_R ) &&
                              (S2_Y_T      <= y) && (y <= S2_Y_B );
  
    assign S30000_on        = (S30000_X_L  <= x) && (x <= S30000_X_R ) &&
                              (S30000_Y_T  <= y) && (y <= S30000_Y_B );    
    assign S3000_on         = (S3000_X_L   <= x) && (x <= S3000_X_R ) &&
                              (S3000_Y_T   <= y) && (y <= S3000_Y_B );
    assign S300_on          = (S300_X_L    <= x) && (x <= S300_X_R ) &&
                              (S300_Y_T    <= y) && (y <= S300_Y_B );         
    assign S30_on           = (S30_X_L     <= x) && (x <= S30_X_R ) &&
                              (S30_Y_T     <= y) && (y <= S30_Y_B );
    assign S3_on            = (S3_X_L      <= x) && (x <= S3_X_R ) &&
                              (S3_Y_T      <= y) && (y <= S3_Y_B );
                              
     
    assign S40000_on        = (S40000_X_L  <= x) && (x <= S40000_X_R ) &&
                              (S40000_Y_T  <= y) && (y <= S40000_Y_B );    
    assign S4000_on         = (S4000_X_L   <= x) && (x <= S4000_X_R ) &&
                              (S4000_Y_T   <= y) && (y <= S4000_Y_B );
    assign S400_on          = (S400_X_L    <= x) && (x <= S400_X_R ) &&
                              (S400_Y_T    <= y) && (y <= S400_Y_B );         
    assign S40_on           = (S40_X_L     <= x) && (x <= S40_X_R ) &&
                              (S40_Y_T     <= y) && (y <= S40_Y_B );
    assign S4_on            = (S4_X_L      <= x) && (x <= S4_X_R ) &&
                              (S4_Y_T      <= y) && (y <= S4_Y_B );

                              
    assign dig_10000s  =  first_score / 10000;
    assign dig_1000s   = (first_score % 10000) / 1000;
    assign dig_100s    = (first_score % 1000) / 100;
    assign dig_10s     = (first_score % 100) / 10;
    assign dig_1s      =  first_score % 10;
    
    assign dig_20000s  =  second_score / 10000;
    assign dig_2000s   = (second_score % 10000) / 1000;
    assign dig_200s    = (second_score % 1000) / 100;
    assign dig_20s     = (second_score % 100) / 10;
    assign dig_2s      =  second_score % 10;
    
    assign dig_30000s  =  third_score / 10000;
    assign dig_3000s   = (third_score % 10000) / 1000;
    assign dig_300s    = (third_score % 1000) / 100;
    assign dig_30s     = (third_score % 100) / 10;
    assign dig_3s      =  third_score % 10;
    
    assign dig_40000s  =  fourth_score / 10000;
    assign dig_4000s   = (fourth_score % 10000) / 1000;
    assign dig_400s    = (fourth_score % 1000) / 100;
    assign dig_40s     = (fourth_score % 100) / 10;
    assign dig_4s      =  fourth_score % 10;
    
    assign char_addr_s10000 = {3'b011,dig_10000s};
    assign char_addr_s1000  = {3'b011,dig_1000s};
    assign char_addr_s100   = {3'b011,dig_100s};
    assign char_addr_s10    = {3'b011,dig_10s};
    assign char_addr_s1     = {3'b011,dig_1s};
    
    assign char_addr_s20000 = {3'b011,dig_20000s};
    assign char_addr_s2000  = {3'b011,dig_2000s};
    assign char_addr_s200   = {3'b011,dig_200s};
    assign char_addr_s20    = {3'b011,dig_20s};
    assign char_addr_s2     = {3'b011,dig_2s};
   
    assign char_addr_s30000 = {3'b011,dig_30000s};
    assign char_addr_s3000  = {3'b011,dig_3000s};
    assign char_addr_s300   = {3'b011,dig_300s};
    assign char_addr_s30    = {3'b011,dig_30s};
    assign char_addr_s3     = {3'b011,dig_3s};
    
    assign char_addr_s40000 = {3'b011,dig_40000s};
    assign char_addr_s4000  = {3'b011,dig_4000s};
    assign char_addr_s400   = {3'b011,dig_400s};
    assign char_addr_s40    = {3'b011,dig_40s};
    assign char_addr_s4     = {3'b011,dig_4s};
                             
    
    assign first_score  = (score_1 > score_2) ? score_1:score_2;
    assign second_score = (score_1 > score_2) ? score_2:score_1;
    assign first_place  = (score_1 > score_2) ? 4'b0001:4'b0010;
    assign second_place = (score_1 > score_2) ? 4'b0010:4'b0001;

//    assign second_score = score_2;
//    assign third_score  = score_3;
//    assign fourth_score = score_4;
    
        // Instantiate the highest_score module
//    highest_score highest_score_first_inst (
//        .score1(score_1),
//        .score2(score_2),
//        .score3(score_3),
//        .score4(score_4),
//        .highest_player(first_place),
//        .highest(first_score)
//    );
    
//     highest_score highest_score_second_inst (
//        .score1(score_1),
//        .score2(score_2),
//        .score3(score_3),
//        .score4(score_4),
//        .highest_player(second_place),
//        .highest(second_score)
//    );
    
//     highest_score highest_score_third_inst (
//        .score1(score_1),
//        .score2(score_2),
//        .score3(score_3),
//        .score4(score_4),
//        .highest_player(third_place),
//        .highest(third_score)
//    );
    
//    highest_score highest_score_fourth_inst (
//        .score1(score_1),
//        .score2(score_2),
//        .score3(score_3),
//        .score4(score_4),
//        .highest_player(fourth_place),
//        .highest(fourth_score)
//    );
  
    always @*
        if(first_place == 3'b001) begin
            score1_off = 1'b0;
        end 
        else if(first_place == 3'b010) begin
            score2_off = 1'b0;
        end 
        else if(first_place == 3'b011) begin
            score3_off = 1'b0;
        end
        else if(first_place == 3'b100) begin
            score4_off = 1'b0;
        end  
            
  // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // blank
        else begin 
            char_row = y[3:0];
            bit_addr = x[2:0];
            
            
            if(first_place_on & score_1_flag) begin
                ascii_char = {3'b011,4'b0001};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(second_place_on & score_2_flag) begin
                ascii_char = {3'b011,4'b0010};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(third_place_on & score_3_flag) begin
                ascii_char = {3'b011,4'b0011};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(fourth_place_on & score_4_flag) begin
                ascii_char = {3'b011,4'b0100};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(first_player_on & score_1_flag) begin
                ascii_char = {3'b001,x[6:3]};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(second_player_on & score_2_flag) begin
                ascii_char = {3'b001,x[6:3]};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(third_player_on & score_3_flag) begin
                ascii_char = {3'b001,x[6:3]};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(fourth_player_on & score_4_flag) begin
                ascii_char = {3'b001,x[6:3]};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(player1_value_on & score_1_flag) begin
                ascii_char = {3'b011,first_place};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(player2_value_on & score_2_flag) begin
                ascii_char = {3'b011,second_place};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(player3_value_on & score_3_flag) begin
                ascii_char = {3'b011, third_place};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(player4_value_on & score_4_flag) begin
                ascii_char = {3'b011,fourth_place};
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S10000_on & score_1_flag) begin
                ascii_char = char_addr_s10000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S1000_on & score_1_flag) begin
                ascii_char = char_addr_s1000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S100_on & score_1_flag) begin
                ascii_char = char_addr_s100;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S10_on & score_1_flag) begin
                ascii_char = char_addr_s10;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S1_on & score_1_flag) begin
                ascii_char = char_addr_s1;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S20000_on & score_2_flag) begin
                ascii_char = char_addr_s20000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S2000_on & score_2_flag) begin
                ascii_char = char_addr_s2000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S200_on & score_2_flag) begin
                ascii_char = char_addr_s200;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S20_on & score_2_flag) begin
                ascii_char = char_addr_s20;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S2_on & score_2_flag) begin
                ascii_char = char_addr_s2;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S30000_on & score_3_flag) begin
                ascii_char = char_addr_s30000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S3000_on & score_3_flag) begin
                ascii_char = char_addr_s1000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S300_on & score_3_flag) begin
                ascii_char = char_addr_s300;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S30_on & score_3_flag) begin
                ascii_char = char_addr_s30;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S3_on & score_3_flag) begin
                ascii_char = char_addr_s3;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S40000_on & score_4_flag) begin
                ascii_char = char_addr_s40000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S4000_on & score_4_flag) begin
                ascii_char = char_addr_s4000;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S400_on & score_4_flag) begin
                ascii_char = char_addr_s400;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S40_on & score_4_flag) begin
                ascii_char = char_addr_s40;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else if(S4_on & score_4_flag) begin
                ascii_char = char_addr_s4;
                if(ascii_bit)
                    rgb = 12'h13a;     // white
                else 
                    rgb = 12'hFFF;
            end
            else 
                rgb =12'hFFF;  
           end 
    
   
endmodule