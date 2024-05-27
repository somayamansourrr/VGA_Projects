module start_display(
    input clk,
    input video_on,
    input [9:0] x, y,
    output reg [11:0] rgb
    );

    // signal declarations
    wire [10:0] rom_addr;           // 11-bit text ROM address
    wire [6:0] ascii_char;          // 7-bit ASCII character code
    wire [3:0] char_row;            // 4-bit row of ASCII character
    wire [2:0] bit_addr;            // column number of ROM data    : reads through each bit of each row
    wire [7:0] rom_data;            // 8-bit row data from text ROM
    wire ascii_bit, ascii_bit_on;     // ROM bit and status signal

    // instantiate ASCII ROM
    start_display_ROM rom(.clk(clk), .addr(rom_addr), .data(rom_data));

    // ASCII ROM interface
    assign rom_addr = {ascii_char, char_row};   // ROM address is ascii code + row
    assign ascii_bit = rom_data[~bit_addr];     // reverse bit order : need to start from left to right (which is bit 7) (bit_wise = ~8'hA1; bit_wise == 8'h5E)

    assign ascii_char = {y[5:4], x[7:3]};   // 7-bit ascii code
    assign char_row = y[3:0];               // row number of ascii character rom
    assign bit_addr = x[2:0];               // column number of ascii character rom


    // "on" region in center of screen
    assign ascii_bit_on = ((x >= 192 && x < 424) && (y >= 224 && y < 240)) ? ascii_bit : 1'b0;

    // rgb multiplexing circuit
    always @*
        if(~video_on)
            rgb = 12'h000;      // blank
        else
            if(ascii_bit_on)
                rgb = 12'h00F;  // blue letters
            else
                rgb = 12'hFFF;  // white background

endmodule