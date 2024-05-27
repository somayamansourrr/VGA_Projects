`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/07/2024 12:46:54 PM
// Design Name: 
// Module Name: counter_text
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module counter_text(
input clk,
 input video_on,
 input [31:0] score,
 input [9:0] x, y,
 output reg [11:0] rgb
 );
    
    // signal declarations
    wire [10:0] rom_addr;           // 11-bit text ROM address
    reg  [6:0] ascii_char;           // 7-bit ASCII character code
    reg  [3:0] char_row;             // 4-bit row of ASCII character
    reg  [2:0] bit_addr;             // column number of ROM data
    wire [7:0] rom_data;            // 8-bit row data from text ROM
    wire ascii_bit;                 // ROM bit and status signal
    wire [3:0] dig_1s, dig_10s,dig_100s,dig_1000s,dig_10000s;
    wire [6:0] char_addr_s10000,char_addr_s1000,char_addr_s100,char_addr_s10,char_addr_s1;
    wire S10000_on,S1000_on,S100_on,S10_on,S1_on, space_on,space_1_on,space_2_on;
    
    // Space = 8 x 16
    localparam space_X_L = 72;
    localparam space_X_R = 79;
    localparam space_Y_T = 64;
    localparam space_Y_B = 80;
    
    
    // 10000 Digit section = 8 x 16
    localparam S10000_X_L = 80;
    localparam S10000_X_R = 87;
    localparam S10000_Y_T = 64;
    localparam S10000_Y_B = 80;
    
    // 1000 Digit section = 8 x 16
    localparam S1000_X_L = 88;
    localparam S1000_X_R = 95;
    localparam S1000_Y_T = 64;
    localparam S1000_Y_B = 80;
    
   // 100 Digit section = 8 x 16
    localparam S100_X_L = 96;
    localparam S100_X_R = 103;
    localparam S100_Y_T = 64;
    localparam S100_Y_B = 80;
    
    // 10 Digit section = 8 x 16
    localparam S10_X_L = 104;
    localparam S10_X_R = 111;
    localparam S10_Y_T = 64;
    localparam S10_Y_B = 80;
    
    // 1s Digit section = 8 x 16
    localparam S1_X_L = 112;
    localparam S1_X_R = 119;
    localparam S1_Y_T = 64;
    localparam S1_Y_B = 80;
    
     // Space section = 8 x 16
    localparam space_1_X_L = 120;
    localparam space_1_X_R = 127;
    localparam space_1_Y_T = 64;
    localparam space_1_Y_B = 80;
    
    // Space section = 8 x 16
    localparam space_2_X_L = 128;
    localparam space_2_X_R = 135;
    localparam space_2_Y_T = 64;
    localparam space_2_Y_B = 80;
    
    
    
    // instantiate ASCII ROM
    ascii_rom_counter rom(.clk(clk), .addr(rom_addr), .data(rom_data));
      
    // ASCII ROM interface
    assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
    assign ascii_bit = rom_data[~bit_addr];     // reverse bit order
    
        
    assign space_on   = (space_X_L   <= x) && (x <= space_X_R  ) &&
                        (space_Y_T   <= y) && (y <= space_Y_B  );  
    assign space_1_on = (space_1_X_L <= x) && (x <= space_1_X_R) &&
                        (space_1_Y_T <= y) && (y <= space_1_Y_B);  
    assign space_2_on = (space_2_X_L <= x) && (x <= space_2_X_R) &&
                        (space_2_Y_T <= y) && (y <= space_2_Y_B);  
    assign S10000_on  = (S10000_X_L  <= x) && (x <= S10000_X_R ) &&
                        (S10000_Y_T  <= y) && (y <= S10000_Y_B );    
    assign S1000_on   = (S1000_X_L   <= x) && (x <= S1000_X_R  ) &&
                        (S1000_Y_T   <= y) && (y <= S1000_Y_B  );
    assign S100_on    = (S100_X_L    <= x) && (x <= S100_X_R   ) &&
                        (S100_Y_T    <= y) && (y <= S100_Y_B   );         
    assign S10_on     = (S10_X_L     <= x) && (x <= S10_X_R    ) &&
                        (S10_Y_T     <= y) && (y <= S10_Y_B    );
    assign S1_on      = (S1_X_L      <= x) && (x <= S1_X_R     ) &&
                        (S1_Y_T      <= y) && (y <= S1_Y_B    );
                             
    
    assign dig_10000s  = score / 10000;
    assign dig_1000s   = (score % 10000) / 1000;
    assign dig_100s    = (score % 1000) / 100;
    assign dig_10s     = (score % 100) / 10;
    assign dig_1s      = score % 10;
    
    assign char_addr_s10000 = {3'b011,dig_10000s};
    assign char_addr_s1000  = {3'b011,dig_1000s};
    assign char_addr_s100   = {3'b011,dig_100s};
    assign char_addr_s10    = {3'b011,dig_10s};
    assign char_addr_s1     = {3'b011,dig_1s};
                    
    // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // blank
        else begin 
            char_row = y[3:0];
            bit_addr = x[2:0];
            
            if(S10000_on) begin
                ascii_char = char_addr_s10000;
                if(ascii_bit)
                    rgb = 12'hFFF;     // white
                else 
                    rgb =12'h13a;                     
            end
            else if(S1000_on) begin
                ascii_char = char_addr_s1000;
                if(ascii_bit)
                    rgb = 12'hFFF;     // white
                else 
                    rgb =12'h13a;                     
            end
            else if(S100_on) begin
                ascii_char = char_addr_s100;
                if(ascii_bit)
                    rgb = 12'hFFF;     // white
                else 
                    rgb =12'h13a;                     
            end
            else if(S10_on) begin
                ascii_char = char_addr_s10;
                if(ascii_bit)
                    rgb = 12'hFFF;     // white
                else 
                    rgb =12'h13a;                     
            end
            else if(S1_on) begin
                ascii_char = char_addr_s1;
                if(ascii_bit)
                    rgb = 12'hFFF;     // white
                else 
                    rgb =12'h13a;                     
            end
            else 
                rgb =12'h13a;  
           end 
    
endmodule
