`include "move_cell.v"
`include "level2pulse.v"
module top_2048(
   clk,
   rst_n,
   
   // input keys
   up_n,
   down_n,
   left_n,
   right_n,
   
   // outputs
   led_row,led_red
);

/*------------------------------*/
/* I/O Ports                    */
/*------------------------------*/
input              clk, rst_n;
input              up_n, down_n, left_n, right_n;

output       [7:0] led_row,led_red;

/*------------------------------*/
/* Regs and Wires               */
/*------------------------------*/
// state regs
reg          [2:0] state, next_state;
reg          [1:0] celli, next_celli,
                   cellj, next_cellj,
                   cellk, next_cellk;

// cell matrix
reg          [3:0] mat       [0:3][0:3],
                   next_mat  [0:3][0:3];
reg                flag      [0:3][0:3],
                   next_flag [0:3][0:3];

// move_cell
wire         [3:0] from_cell     = mat[fromi][fromj];
wire         [3:0] to_cell       = mat[toi][toj];
wire               to_is_marked  = flag[toi][toj];
wire         [3:0] next_from, next_to;
wire               cont, cell_moved;

// level2pulse
wire               up_p, down_p, left_p, right_p;

// regs
reg          [1:0] fromi, fromj, toi, toj;
reg                moved, next_moved;
reg                win, next_win,
                   lose, next_lose,
                   lose_aux, next_lose_aux;
reg         [63:0] mat_flat;
integer i,j;
always@(*)begin
    for(i=0;i<4;i=i+1) 
        for(j=0;j<4;j=j+1)
            mat_flat[16*i+4*j+:4] = mat[i][j][3:0];
end
// wires
wire               game_over = win | lose;
wire               state_mv = (state == S_MV_U | state == S_MV_D) |
                              (state == S_MV_L | state == S_MV_R);

/*------------------------------*/
/* Parameters                   */
/*------------------------------*/
// state parameters
parameter S_INIT = 3'd0;
parameter S_IDLE = 3'd1;
parameter S_MV_U = 3'd2;  // move up
parameter S_MV_D = 3'd3;  // move down
parameter S_MV_L = 3'd4;  // move left
parameter S_MV_R = 3'd5;  // move right
parameter S_GENR = 3'd6;  // generate random 2
parameter S_GMOV = 3'd7;  // game over

integer i, j;  // for loop counters

/*------------------------------*/
/* Module Instantiations        */
/*------------------------------*/
move_cell move_cell0(
   .from(from_cell),
   .to(to_cell),
   .to_is_marked(to_is_marked),
   .next_from(next_from),
   .next_to(next_to),
   .cont(cont),
   .moved(cell_moved)
);
level2pulse level2pulse0(
   .clk(clk),
   .rst_n(rst_n),
   .level(~up_n),
   .pulse(up_p)
);
level2pulse level2pulse1(
   .clk(clk),
   .rst_n(rst_n),
   .level(~down_n),
   .pulse(down_p)
);
level2pulse level2pulse2(
   .clk(clk),
   .rst_n(rst_n),
   .level(~left_n),
   .pulse(left_p)
);
level2pulse level2pulse3(
   .clk(clk),
   .rst_n(rst_n),
   .level(~right_n),
   .pulse(right_p)
);
LEDmatrix led(clk,mat_flat,led_row,led_red);
/*------------------------------*/
/* Combinational Circuits       */
/*------------------------------*/
always @(*) begin  // state
   case (state)
   S_INIT: begin
      // ...
   end
   S_IDLE: begin
      if     (up_p)    next_state = S_MV_U;
      else if(down_p)  next_state = S_MV_D;
      else if(left_p)  next_state = S_MV_L;
      else if(right_p) next_state = S_MV_R;
      else             next_state = state;
   end
   S_MV_U: begin
      if(celli == 2'd3 & cellj == 2'd3 & ~cont)
         next_state = (moved) ? S_GENR : S_IDLE;
      else
         next_state = state;
   end
   S_MV_D: begin
      if(celli == 2'd0 & cellj == 2'd3 & ~cont)
         next_state = (moved) ? S_GENR : S_IDLE;
      else
         next_state = state;
   end
   S_MV_L: begin
      if(celli == 2'd3 & cellj == 2'd3 & ~cont)
         next_state = (moved) ? S_GENR : S_IDLE;
      else
         next_state = state;
   end
   S_MV_R: begin
      if(celli == 2'd3 & cellj == 2'd0 & ~cont)
         next_state = (moved) ? S_GENR : S_IDLE;
      else
         next_state = state;
   end
   S_GENR: begin
      // ...
   end
   S_GMOV: begin
      if(celli == 2'd3 & cellj == 2'd3)
         next_state = S_IDLE;
      else
         next_state = state;
   end
   endcase  // case state
end  // state

always @(*) begin  // celli, cellj, cellk
   case (state)
   S_IDLE: begin
      next_cellk = 2'b0;
      if(up_p) begin
         next_celli = 2'b1;
         next_cellj = 2'b0;
      end
      else if(down_p) begin
         next_celli = 2'b2;
         next_cellj = 2'b0;
      end
      else if(left_p) begin
         next_celli = 2'b0;
         next_cellj = 2'b1;
      end
      else if(right_p) begin
         next_celli = 2'b0;
         next_cellj = 2'b2;
      end
      else begin
         next_celli = 2'b0;
         next_cellj = 2'b0;
      end
   end
   S_MV_U: begin
      if(toi == 2'b0 | ~cont) begin
         next_celli = (cellj == 2'd3) ? celli + 1'b1 : celli;
         next_cellj = (cellj == 2'd3) ? 2'b0 : cellj + 1'b1;
         next_cellk = 2'b0;
      end
      else  // continue
         next_celli = celli;
         next_cellj = cellj;
         next_cellk = cellk + 1'b1;
      end
   end
   S_MV_D: begin
      if(toi == 2'd3 | ~cont) begin
         next_celli = (cellj == 2'd3) ? celli - 1'b1 : celli;
         next_cellj = (cellj == 2'd3) ? 2'b0 : cellj + 1'b1;
         next_cellk = 2'b0;
      end
      else  // continue
         next_celli = celli;
         next_cellj = cellj;
         next_cellk = cellk + 1'b1;
      end
   end
   S_MV_L: begin
      if(toj == 2'b0 | ~cont) begin
         next_celli = (cellj == 2'd3) ? celli + 1'b1 : celli;
         next_cellj = (cellj == 2'd3) ? 2'd1 : cellj + 1'b1;
         next_cellk = 2'b0;
      end
      else  // continue
         next_celli = celli;
         next_cellj = cellj;
         next_cellk = cellk + 1'b1;
      end
   end
   S_MV_R: begin
      if(toj == 2'd3 | ~cont) begin
         next_celli = (cellj == 2'd0) ? celli + 1'b1 : celli;
         next_cellj = (cellj == 2'd0) ? 2'd2 : cellj - 1'b1;
         next_cellk = 2'b0;
      end
      else  // continue
         next_celli = celli;
         next_cellj = cellj;
         next_cellk = cellk + 1'b1;
      end
   end
   S_GMOV: begin
      next_celli = (cellj == 2'd3) ? celli + 1'b1 : celli;
      next_cellj = (cellj == 2'd3) ? 2'b0 : cellj + 1'b1;
      next_cellk = 2'b0;
   end
   default: begin
      next_celli = 2'b0;
      next_cellj = 2'b0;
      next_cellk = 2'b0;
   end
   endcase  // case state
end  // celli, cellj, cellk

always @(*) begin  // fromi, fromj, toi, toj
   case (state)
   S_MV_U: begin
      fromi = celli - cellk;
      fromj = cellj;
      toi   = celli - cellk - 1'b1;
      toj   = cellj;
   end
   S_MV_D: begin
      fromi = celli + cellk;
      fromj = cellj;
      toi   = celli + cellk + 1'b1;
      toj   = cellj;
   end
   S_MV_L: begin
      fromi = celli;
      fromj = cellj - cellk;
      toi   = celli;
      toj   = cellj - cellk - 1'b1;
   end
   S_MV_R: begin
      fromi = celli;
      fromj = cellj + cellk;
      toi   = celli;
      toj   = cellj + cellk + 1'b1;
   end
   default: begin
      fromi = 2'b0;
      fromj = 2'b0;
      toi   = 2'b0;
      toj   = 2'b0;
   end
   endcase  // case state
end  // fromi, fromj, toi, toj

always @(*) begin  // mat
   if((state_mv) begin
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1) begin
               if(i == fromi & j == fromj)
                  next_mat[i][j] = next_from;
               else if(i == toi & j == toj)
                  next_mat[i][j] = next_to;
               else
                  next_mat[i][j] = mat[i][j];
            end
   end
   else if(state == S_GENR) begin
      // ...
   end
   else
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1)
            next_mat[i][j] = mat[i][j];
end  // mat

always @(*) begin  // flag
   if((state_mv)
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1) begin
            if(i == toi & j == toj)
               next_flag[i][j] = moved & ~cont;
            else
               next_flag[i][j] = flag[i][j];
         end
   else
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1)
            next_flag[i][j] = 1'b0;
end  // flag

always @(*) begin  // moved
   if((state_mv)
      if(cell_moved)
         next_moved = 1'b1;
      else
         next_moved = moved;
   else
      next_moved = 1'b0;
end  // moved

always @(*) begin  // win, lose
   if(state == S_GMOV) begin
      // win
      if(mat[celli][cellj] == 4'd11)
         next_win = 1'b1;
      else
         next_win = win;
      
      // lose
      if(celli == 2'd3 & cellj == 2'd3) begin
         next_lose = lose_aux & (mat[celli][cellj] != 4'b0);
         next_lose_aux = 1'b1;
      end
      else begin
         next_lose = lose;
         if(celli == 2'd3)
            next_lose_aux = (mat[celli][cellj] == mat[celli][cellj+1'b1] |
                             mat[celli][cellj] == 4'b0) ?
                            1'b0 : lose_aux;
         else if(cellj == 2'd3)
            next_lose_aux = (mat[celli][cellj] == mat[celli+1'b1][cellj] |
                             mat[celli][cellj] == 4'b0) ?
                            1'b0 : lose_aux;
         else
            next_lose_aux = (mat[celli][cellj] == mat[celli+1'b1][cellj] |
                             mat[celli][cellj] == mat[celli][cellj+1'b1] |
                             mat[celli][cellj] == 4'b0) ?
                            1'b0 : lose_aux;
      end
   end
   else begin
      next_win = win;
      next_lose = lose;
      next_lose_aux = 1'b1;
   end
end  // win, lose


/*------------------------------*/
/* Sequential Circuits          */
/*------------------------------*/
always @(posedge clk or negedge rst_n) begin
   if(~rst_n) begin
      state      <= S_INIT;
      celli      <= 1'b0;
      cellj      <= 1'b0;
      cellk      <= 1'b0;
      moved      <= 1'b0;
      win        <= 1'b0;
      lose       <= 1'b0;
      lose_aux   <= 1'b1;
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1) begin
            mat[i][j]  <= 4'b0;
            flag[i][j] <= 1'b0;
         end
   end
   else begin
      state      <= next_state;
      celli      <= next_celli;
      cellj      <= next_cellj;
      cellk      <= next_cellk;
      moved      <= next_moved;
      win        <= next_win;
      lose       <= next_lose;
      lose_aux   <= next_lose_aux;
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1) begin
            mat[i][j]  <= next_mat[i][j];
            flag[i][j] <= next_flag[i][j];
         end
   end
end


endmodule
