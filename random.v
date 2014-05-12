module random(clk,reset_n_debounced,out1,out2);//out1,out2:0~15
    input           clk,reset_n_debounced;
    output  [3:0]   out1,out2;
    wire    [3:0]   out1,out2;
    reg     [7:0]   random;
    reg             reset_n_debounced_delay;
    
    assign          out1 = {random[7],random[5],random[3],random[1]};
    assign          out2 = {random[6],random[4],random[2],random[0]};
    always@(posedge clk) begin//synchronous reset
        reset_n_debounced_delay <= reset_n_debounced;
        if((reset_n_debounced_delay)&(~reset_n_debounced)) begin
            random <= 4'b0001;
        end
        else begin
            random <= random + 4'd1;
        end    
    end
endmodule