module LEDmatrix16(
                    iClk,//50MHz
                    iReset_n,
                    iData,
                    oData,
                    oShiftClk,
                    oStoreClk       );

input               iClk;//50MHz
input               iReset_n;
input   [255:0]     iData;
output              oData;
output              oShiftClk;
output              oStoreClk;

reg                 matrix[0:15][0:15];
reg                 oData;
reg                 oShiftClk;
reg                 oStoreClk;
reg     [7:0]       counter_256;

integer i,j;
always@(*) begin
    for(i=0;i<16;i=i+1)
        for(j=0;j<16;j=j+1)
            matrix[i][j] = iData[16*i+j];
    oData = iData[counter_256];
    oShiftClk = iClk;
    oStoreClk = counter_256[2];
end

always@(posedge iClk) begin
    if(!iReset_n) begin
        counter_256 <= 8'd0;
    end
    else begin
        counter_256 <= counter_256 + 8'd1;
    end
end
endmodule