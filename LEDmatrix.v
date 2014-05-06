module LEDmatrix(reset_n,clk,mat_flat,row,red);
    input           reset_n,clk;
    input   [63:0]  mat_flat;
	output  [7:0]   row;
	output  [7:0]   red;
/*          j
     _ _ _ _ _ _ _ _                 pixel
    |               |                -  -
    |               |              | 3  2 |
    |               |              | 1  0 |
i   |   mat[i][j]   |                -  -
    |               |
    |               |
    |               |
    |_ _ _ _ _ _ _ _|
*/    
/*   0 1 2 3 4 5 6 7 
     _ _ _ _ _ _ _ _             
   0|               |             
   1|               |           
   2|               |             
i  3|   patten[i]   |              
   4|               |
   5|               |
   6|               |
   7|_ _ _ _ _ _ _ _|
*/
    parameter pixel_0  = 4'b1111;
    parameter pixel_1  = 4'b0111;
    parameter pixel_2  = 4'b1011;
    parameter pixel_3  = 4'b1101;
    parameter pixel_4  = 4'b1110;
    parameter pixel_5  = 4'b0011;
    parameter pixel_6  = 4'b0101;
    parameter pixel_7  = 4'b0110;
    parameter pixel_8  = 4'b0001;
    parameter pixel_9  = 4'b0010;
    parameter pixel_10 = 4'b1000;
    parameter pixel_11 = 4'b0000;
    reg     [3:0]   mat[0:3][0:3];
    integer i,j;
    always@(*) begin
        for(i=0;i<4;i=i+1) 
            for(j=0;j<4;j=j+1)
                mat[i][j][3:0] = mat_flat[16*i+4*j+:4];
    end
    reg     [0:7]   pattern[0:7];
    reg     [3:0]   pixel;
    reg     [23:0]  slow_clk,next_slow_clk;
    reg     [7:0]   row,next_row;
    reg     [2:0]   row_count;
    reg     [7:0]   red,next_red;
    always@(*) begin//pattern
        for(i=0;i<4;i=i+1) 
            for(j=0;j<4;j=j+1) begin
                case(mat[i][j])
                    4'b0 : pixel = pixel_0 ;
                    4'b1 : pixel = pixel_1 ;
                    4'b2 : pixel = pixel_2 ;
                    4'b3 : pixel = pixel_3 ;
                    4'b4 : pixel = pixel_4 ;
                    4'b5 : pixel = pixel_5 ;
                    4'b6 : pixel = pixel_6 ;
                    4'b7 : pixel = pixel_7 ;
                    4'b8 : pixel = pixel_8 ;
                    4'b9 : pixel = pixel_9 ;
                    4'b10: pixel = pixel_10;
                    4'b11: pixel = pixel_11;
                    default pixel = 4'b1111; 
                 endcase
                pattern[2*j][2*i+:2] = pixel[3:2];
                pattern[2*j+1][2*i+:2] = pixel[1:0];
            end
    end
    always@(*) begin
        next_row = {row[6:0],row[7]};//shift left
        next_slow_clk = slow_clk +1;
        next_red = pattern[row_count];
    end
    always@(negedge reset_n or posedge clk) begin
        if(!reset_n) begin
            slow_clk <= 0;
            row_count <= 3'd0;
            row <= 8'd1;
            red <= 8'd255;
        end
        else begin
            slow_clk <= next_slow_clk;
            if(next_slow_clk[23]^slow_clk[23]) begin
                row_count <= row_count +3'd1;
                row <= next_row;
            end
            red <= next_red;
        end    
    end
endmodule