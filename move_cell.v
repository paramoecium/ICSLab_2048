// Move the "from" cell to the "to" cell.
// Purely combinational circuits.
module move_cell(
   from,
   to,
   to_is_marked,
   next_from,
   next_to,
   cont,  // continue
   moved
);

/*------------------------------*/
/* I/O Ports                    */
/*------------------------------*/
input      [3:0] from,
                 to;
input            to_is_marked;
output reg [3:0] next_from,
                 next_to;
output reg       cont,
                 moved;

/*------------------------------*/
/* Combinational Circuits       */
/*------------------------------*/
always @(*) begin
   if(from == 4'b0 | to_is_marked) begin
      next_from = from;
      next_to   = to;
      cont      = 1'b0;
      moved     = 1'b0;
   end
   else if(to == 4'b0) begin
      next_from = 4'b0;
      next_to   = from;
      cont      = 1'b1;
      moved     = 1'b1;
   end
   else if(from == to) begin
      next_from = 4'b0;
      next_to   = to + 1'b1;
      cont      = 1'b0;
      moved     = 1'b1;
   end
   else begin
      next_from = from;
      next_to   = to;
      cont      = 1'b0;
      moved     = 1'b0;
   end
end

endmodule
