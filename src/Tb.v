`timescale 1ns/1ns
module TB (
    input clk,rst,
    input [6:0] Addr1,Addr2,Addr3,
    input [31:0] Data_in,
    input WE,
    output [31:0] data_out0,data_out1
);
    wire [31:0] in_data1,in_data2,datan;
    wire [6:0] addr;
    wire WEn1,Wen2;
    Data_Memory1 A( .in_Data(in_data1), .A(Addr1), .clk(clk), .WE(WEn1), .rst(rst), .o_Data(data_out0));
    Data_Memory2 B( .in_Data(in_data2), .A(Addr2), .clk(clk), .WE(Wen2), .rst(rst), .o_Data(data_out1));
    Data_Memory3 C( .in_Data(Data_in), .Ar(addr), .Aw(Addr3), .clk(clk), .WE(WE), .rst(rst), .o_Data(datan));
endmodule