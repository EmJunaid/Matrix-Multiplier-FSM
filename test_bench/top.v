`timescale 1ns/1ns
module top_TB ();

    reg clk,rst,startt;
    wire [6:0] Adr_A,Adr_B,Adr_C;
    wire [31:0] Data_C;
    wire WE_C,Done_t;
    wire [31:0] data_A,data_B;
    wire reslut_is_invalid;


    TB BBB( .clk(clk), .rst(rst), .Addr1(Adr_A), .Addr2(Adr_B), .Addr3(Adr_C), .Data_in(Data_C), .WE(WE_C), .data_out0(data_A), .data_out1(data_B));
    matmul AAA(.clk(clk), .rst(rst), .start(startt), .data1(data_A), .data2(data_B), .result(Data_C), .invalidmm(reslut_is_invalid), .Addr1(Adr_A), .Addr2(Adr_B), .Addr3(Adr_C), .Done(Done_t), .WE(WE_C));

    initial clk=0;
    always #5 clk = ~clk;

    initial begin
        rst=1;
        #50
        rst=0;
        startt=1;
        #50
        startt=0;
       
    end
    
endmodule