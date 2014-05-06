// Level-to-Pulse Converter
module level2pulse(
   clk,
   rst_n,
   level,
   pulse
);

// I/O ports
input          clk, rst_n;
input          level;
output         pulse;

// regs and wires
reg            pulse;
//reg            pulse, next_pulse;  // output reg
reg            state, next_state;

// combinational circuits
always @(*) begin
   case(state)
   1'b0: begin
      if(level) begin
         next_state = 1'b1;
         //next_pulse = 1'b1;
         pulse = 1'b1;
      end
      else begin
         next_state = 1'b0;
         //next_pulse = 1'b0;
         pulse = 1'b0;
      end
   end
   1'b1:begin
      if(level) begin
         next_state = 1'b1;
         //next_pulse = 1'b0;
         pulse = 1'b0;
      end
      else begin
         next_state = 1'b0;
         //next_pulse = 1'b0;
         pulse = 1'b0;
      end
   end
   endcase
end

// sequential circuits
always @(posedge clk or negedge rst_n) begin
   if(~rst_n) begin
      state <= 1'b0;
      //pulse <= 1'b0;
   end
   else begin
      state <= next_state;
      //pulse <= next_pulse;
   end
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

module edgedetector(clk,in,pos_in,neg_in);
	input		clk, in;
	output		pos_in, neg_in;
	reg			pos_in, next_pos_in;
	reg			neg_in, next_neg_in;
	reg		 	temp;

	always@(*)begin
		next_pos_in = (~temp)&in;
		next_neg_in = (~temp)|in;
	end
	always@(posedge clk) begin
		temp <= in;
		pos_in <= next_pos_in;
		neg_in <= next_neg_in;
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