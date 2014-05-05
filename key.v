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
	 wire out = value_holder;
    reg value_holder;
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