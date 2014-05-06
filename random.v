module random(clk,reset_n_debounced,get,out1,out2);//out1,out2:0~15
    input           clk,reset_n_debounced,get;
    output  [3:0]   out1,out2;
    reg     [3:0]   out1,out2;//hold the value until next "get" pulse
    reg     [3:0]   random1,random2;
    reg             reset_n_debounced_delay;
    
    always@(posedge clk) begin//synchronous reset
        reset_n_debounced_delay <= reset_n_debounced;
        if((reset_n_debounced_delay)&(~reset_n_debounced)) begin
            random1 <= 4'b0001;
        end
        else if((~reset_n_debounced_delay)&(reset_n_debounced)) begin
            random1 <= random1 +4'd1;
            random2 <= 4'b0001;
        end
        else begin
            random1 <= random1 + 4'd1;
            random2 <= random2 + 4'd1;
            if(get) begin
                out1 <= random1;
                out2 <= random2;
            end        
        end    
    end
endmodule