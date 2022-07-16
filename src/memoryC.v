`timescale 1ns/1ns
module Data_Memory3 (
    input [31:0] in_Data,
    input [6:0] Ar,Aw,
    input clk,WE,rst,
    output [31:0] o_Data
);
    reg [31:0] Data_Mem [99:0];
    integer i;
    assign o_Data = Data_Mem[Ar];
    always @(posedge clk) begin
        if (rst) begin
            for(i=0;i<100;i=i+1)
                Data_Mem[i] <= 32'd0;
        end else if (WE) begin
            Data_Mem[Aw] <= in_Data; 
        end
    end
    
    
endmodule