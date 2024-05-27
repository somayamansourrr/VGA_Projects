module highest_score(
    input [31:0] score1,score2,score3,score4,
    output reg [2:0] highest_player,
    output reg [31:0] highest_score_value 
    );
   
    always @*
        if(score1 > score2 > score3 >score4) begin
            highest_score_value <= score1;
            highest_player <= 3'b001;
        end 
        else if(score2 > score1 > score3 >score4) begin
            highest_score_value <= score2;
            highest_player <= 3'b010;
        end 
        else if(score3 > score1 > score2 >score4) begin
            highest_score_value <= score2;
            highest_player <= 3'b011;
        end 
        else if(score4 > score1 > score2 >score3) begin
            highest_score_value <= score4;
            highest_player <= 3'b100;
        end 
   
endmodule