// Top Module for 2048 Game
//
//   Related files:
//     move_cell.v
//     random.v
//     key.v
//     LEDmatrix.v
//
module top_2048(
   clk,
   rst_n,
   
   // input keys
   up_key,
   down_key,
   left_key,
   right_key,
   
   // outputs
   led_row,
   led_red
   
   // ...
);

/*------------------------------*/
/* I/O Ports                    */
/*------------------------------*/
input              clk, rst_n;
input              up_key, down_key, left_key, right_key;

output       [7:0] led_row, led_red;

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
wire         [3:0] from_cell;
wire         [3:0] to_cell;
wire               to_is_marked;
wire         [3:0] next_from, next_to;
wire               cont, cell_moved;

// random
wire         [3:0] rand1, rand2;

// key_edgedetector
wire               up_n, down_n, left_n, right_n;
wire               up_p, down_p, left_p, right_p;

// LEDmatrix
reg         [63:0] mat_flat;

// regs
reg          [1:0] fromi, fromj, toi, toj;
reg                moved, next_moved;
reg                win, next_win,
                   lose, next_lose,
                   lose_aux, next_lose_aux;

// wires
wire               rst_n_db;  // debounced rst_n
wire               game_over = win | lose;
wire               state_mv;
wire         [3:0] pos1, pos2,
                   num1, num2;

assign from_cell     = mat[fromi][fromj];
assign to_cell       = mat[toi][toj];
assign to_is_marked  = flag[toi][toj];

assign up_p    = ~up_n;
assign down_p  = ~down_n;
assign left_p  = ~left_n;
assign right_p = ~right_n;

assign pos1 = rand1;
assign pos2 = (rand1 == rand2) ? rand2 + 1'b1 : rand2;
assign num1 = (|rand2[2:0]) ? 4'd1 : 4'd2;
assign num2 = (|rand1[2:0]) ? 4'd1 : 4'd2;

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
random random0(
   .clk(clk),
   .reset_n_debounced(rst_n_db),
   .out1(rand1),
   .out2(rand2)
);
key_debouncer key_debouncer0(
   .clk(clk),
   .in(rst_n),
   .debounced_in(rst_n_db)
);
key_edgedetector key_edge0(
   .clk(clk),
   .in(up_key),
   .pos_in(),  // not used
   .neg_in(up_n)
);
key_edgedetector key_edge1(
   .clk(clk),
   .in(down_key),
   .pos_in(),  // not used
   .neg_in(down_n)
);
key_edgedetector key_edge2(
   .clk(clk),
   .in(left_key),
   .pos_in(),  // not used
   .neg_in(left_n)
);
key_edgedetector key_edge3(
   .clk(clk),
   .in(right_key),
   .pos_in(),  // not used
   .neg_in(right_n)
);
LEDmatrix led(
   .reset(rst_n_db),
   .clk(clk),
   .mat_flat(mat_flat),
   .row(led_row),
   .red(led_red)
);

/*------------------------------*/
/* Combinational Circuits       */
/*------------------------------*/
always @(*) begin  // state
   case (state)
   S_INIT: begin  // 1 cycle
      next_state = S_IDLE;
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
      if(mat[pos1[3:2]][pos1[1:0]] == 4'b0)
         next_state = S_GMOV;
      else
         next_state = state;
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
         next_celli = 2'd1;
         next_cellj = 2'b0;
      end
      else if(down_p) begin
         next_celli = 2'd2;
         next_cellj = 2'b0;
      end
      else if(left_p) begin
         next_celli = 2'b0;
         next_cellj = 2'd1;
      end
      else if(right_p) begin
         next_celli = 2'b0;
         next_cellj = 2'd2;
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
      else begin  // continue
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
      else begin  // continue
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
      else begin  // continue
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
      else begin  // continue
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
   if(state == S_INIT) begin
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1) begin
            if(i == pos1[3:2] & j == pos1[1:0])
               next_mat[i][j] = num1;
            else if(i == pos2[3:2] & j == pos2[1:0])
               next_mat[i][j] = num2;
            else
               next_mat[i][j] = mat[i][j];
         end
   end
   else if(state_mv) begin
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
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1) begin
            if(i == pos1[3:2] & j == pos1[1:0])
               next_mat[i][j] = (mat[i][j] == 4'b0) ? num1 : mat[i][j];
            else
               next_mat[i][j] = mat[i][j];
         end
   end
   else
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1)
            next_mat[i][j] = mat[i][j];
end  // mat

always @(*) begin  // flag
   if(state_mv)
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1) begin
            if(i == toi & j == toj)
               next_flag[i][j] = cell_moved & ~cont;
            else
               next_flag[i][j] = flag[i][j];
         end
   else
      for(i = 0; i < 4; i = i + 1)
         for(j = 0; j < 4; j = j + 1)
            next_flag[i][j] = 1'b0;
end  // flag

always @(*) begin  // moved
   if(state_mv)
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

always @(*) begin
   for(i = 0; i < 4; i = i + 1)
      for(j = 0; j < 4; j = j + 1)
         mat_flat[(16*i+4*j)+:4] = mat[i][j];
end

assign state_mv = (state == S_MV_U | state == S_MV_D) |
                  (state == S_MV_L | state == S_MV_R);


/*------------------------------*/
/* Sequential Circuits          */
/*------------------------------*/
always @(posedge clk or negedge rst_n_db) begin
   if(~rst_n_db) begin
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


module key_edgedetector(clk,in,pos_in,neg_in);
	input		clk, in;
	output		pos_in, neg_in;
	reg			pos_in, next_pos_in;
	reg			neg_in, next_neg_in;
	reg		 	temp;
    wire debounced_in;
    key_debouncer kd1(clk,in,debounced_in);
	always@(*)begin
		next_pos_in = (~temp)&debounced_in;
		next_neg_in = (~temp)|debounced_in;
	end
	always@(posedge clk) begin
		temp <= debounced_in;
		pos_in <= next_pos_in;
		neg_in <= next_neg_in;
	end
endmodule

module key_debouncer(clk,in,debounced_in);
	input in;
	input clk;
	output debounced_in;
	
	reg [2:0] 	temp;
	wire		debounced_in = (|temp)?1'b1:1'b0;

	always@(posedge clk) begin
		temp[2] <= temp[1];
		temp[1] <= temp[0];
		temp[0] <= in;
	end
endmodule

module key_holder(clk,in,out,reset);
    input clk,in,reset;
    output out;
    
    wire pos_in,neg_in;
    reg value_holder;
	 wire out = value_holder;
    key_edgedetector ked(clk,in,pos_in,neg_in);
    
    always@(posedge clk or negedge reset) begin
        if(!reset)begin
            value_holder <= ~in;//invert the key value
        end
        else begin
            value_holder <= (pos_in)?~value_holder:value_holder;
        end
    end
endmodule