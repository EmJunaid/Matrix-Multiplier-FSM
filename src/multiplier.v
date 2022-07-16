`timescale 1ns/1ns
module multiplier (
    input clk,rst,start1,
    input wire [31:0] A,B,
    output reg [31:0] C,
    output invalid,
    output reg Done1   
);

//----------------------------------Datapath-------------------------------------------------------//
    reg [31:0] Am,Bm;
    wire [31:0] wire4,wire5,wire6,wire7;
    reg [31:0]  wire1,wire2,wire3;
    wire flag1,flag2,flag3;
    reg [1:0] sel1,sel2,sel3;
    reg sel4;
    reg [2:0] cs,ns;
    wire [31:0] tmp;
    //wire invalid;

// Registers
    always @(posedge clk) begin
        if(rst) begin
            Am <= 32'd0;
            Bm <= 32'd0;
            C <= 32'd0;
        end    
        else begin
            Am <= wire1;
            Bm <= wire2; 
            C <= wire3;  
        end 
    end

//Muxes

    always @(*) begin
        case(sel1)
            2'b00 : wire1 = Am;
            2'b01 : wire1 = A;
            2'b10 : wire1 = wire4;
            default : wire1 = Am;
        endcase
    end

    always @(*) begin
        case(sel2)
            2'b00 : wire2 = Bm;
            2'b01 : wire2 = B;
            2'b10 : wire2 = wire5;
            default : wire2 = Bm;
        endcase
    end

    always @(*) begin
        case(sel3)
            2'b00 : wire3 = C;
            2'b01 : wire3 = wire6;
            2'b10 : wire3 = 32'd0;
            default : wire3 = C;
        endcase
    end

    assign wire7 = sel4 ? Bm : Am;

// Subtractor

    assign wire4 = Am - 32'd1 ;
    assign wire5 = Bm - 32'd1 ;
    assign wire6 = C + wire7 ;
    assign {invalid,tmp} = C + wire7; //checkng overflow flag

//comparator
    
    assign flag1 = (Am > Bm);
    assign flag2 = (Am > 32'd0);
    assign flag3 = (Bm > 32'd0);
    
//------------------------------FSM----------------------------------------------//
    
    parameter s0 = 4'b0000;
    parameter s1 = 4'b0001;
    parameter s2 = 4'b0010;
    parameter s3 = 4'b0011;
    parameter s4 = 4'b0100;
    parameter s5 = 4'b0101;
    parameter s6 = 4'b0110;
    parameter s7 = 4'b0111;
    parameter s8 = 4'b1000; //Adding new state for invalid flag

    //state reg

    always @(posedge clk) begin
        if(rst) cs <=s0;
        else cs <= ns;  
    end

    //next state logic

    always @(*) begin
        case (cs)
          s0  : ns <= start1? s1:s0;
          s1  : ns <= s2;
          s2  : ns <= flag1 ? s3:s4;
          s3  : ns <= flag3 ?s5:s7;
          s4  : ns <= flag2 ?s6:s7;
          //s5  : ns <= s3;
          s5  : ns <= invalid ? s7:s3;
          //s6  : ns <= s4;
          s6  : ns <= invalid ? s7:s4;
          s7  : ns <= s0;
          s8  : ns <= s7;
            default: ns <= s0;
        endcase
    end
    
    //Output logic

    always @(*) begin
        case (cs)
            s0 : begin
                sel1 <= 2'b00;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 0;
                Done1 <= 0;
            end 
           s1 : begin
                sel1 <= 2'b01;
                sel2 <= 2'b01;
                sel3 <= 2'b10;
                sel4 <= 0;
                Done1 <= 0;
            end 
            s2: begin
                sel1 <= 2'b00;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 0;
                Done1 <= 0;
            end 
            s3 : begin
                sel1 <= 2'b00;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 0;
                Done1 <= 0;
            end 
            s4 : begin
                sel1 <= 2'b00;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 1;
                Done1 <= 0;
            end 
            s5 : begin
                sel1 <= 2'b00;
                sel2 <= 2'b10;
                sel3 <= 2'b01;
                sel4 <= 0;
                Done1 <= 0;
            end 
            s6 : begin
                sel1 <= 2'b10;
                sel2 <= 2'b00;
                sel3 <= 2'b01;
                sel4 <= 1;
                Done1 <= 0;
            end 
            s7 : begin
                sel1 <= 2'b00;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 0;
                Done1 <= 1;
            end
            default: begin
                sel1 <= 2'b00;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 0;
                Done1 <= 0;
            end 
        endcase
    end

endmodule