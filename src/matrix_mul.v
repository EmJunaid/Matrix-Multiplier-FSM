`timescale 1ns/1ns
module matmul (
    input clk,rst,start,
    input wire [31:0] data1,data2,
    output reg [31:0] result,
    output invalidmm,
    output [6:0] Addr1, Addr2, Addr3,
    output reg Done, WE
);
//----------------------------------Datapath-------------------------------------------------------//
    reg [31:0] C,C1,C2;
    reg [6:0] i,wire15,wire7,it,k ;
    wire [31:0] wire1,wire2,wire4,wire6,wire17,mm;
    reg [31:0]  wire5,wire16,wire3;
    wire flag1,flag2,flag3;
    reg [1:0] sel4,sel5,sel7,sel10,sel3,sel2;
    reg sel1,sel6,sel8,sel9,sel11;
    reg [3:0] cs,ns;
    reg start1;
    wire Done1,invalid1;
    wire [31:0] tmpm;
    wire [6:0] wire8,wire18,wire12,wire11,wire13;
    wire [7:0] wire10,wire9;
    reg [7:0] j,wire14;

// Registers
    always @(posedge clk) begin
        if(rst) begin
            C <= 32'd0;
            C1 <= 32'd0;
            C2 <= 32'd0;
            i <= 32'd0;
            j <= 8'd0;
            k <= 7'd0;
 //           sum <= 32'd0;
            result <= 32'd0;
            it <= 7'd0;
            //Addr1 <= 32'd0;
            //Addr2 <= 32'd0;
            //Addr3 <= 32'd0;
        end    
        else begin
            C <= wire1;
            C1 <= wire3;
            C2 <= wire5;
            i <= wire7;
            j <= wire9;
            k <= wire11;
            //sum <= wire16;
            result <= wire16; 
            it <= wire18; 
            //Addr1 <= wire8;
            //Addr2 <= wire10;
            //Addr3 <= wire12;
        end 
    end

    assign Addr1 = wire8;
    assign Addr2 = wire10[6:0];
    assign Addr3 = wire12;
    //assign result = wire16;
//Muxes

    always @(*) begin
        case(sel5)
            2'b00 : wire15 = 7'd0;
            2'b01 : wire15 = 7'd1;
            2'b10 : wire15 = -10;//-9;
            2'b11 : wire15 = 7'd10;
            default : wire15 = 7'd0;
        endcase
    end

    always @(*) begin
        case(sel7)
            2'b00 : wire14 = 8'd0;
            2'b01 : wire14 = 8'd10;
            2'b10 : wire14 = -99;//-89;
            2'b11 : wire14 = -10;
            default : wire14 = 8'd0;
        endcase
    end

    always @(*) begin
        case(sel10)
            2'b00 : wire16 = result;//sum;
            2'b01 : wire16 = wire17;
            2'b10 : wire16 = 32'd0;
            default : wire16 = 32'd0;
        endcase
    end

    always @(*) begin
        case(sel3)
            2'b00 : wire5 = C2;
            2'b01 : wire5 = wire6;
            2'b10 : wire5 = 32'd0;
            default : wire5 = 32'd0;
        endcase
    end

    always @(*) begin
        case(sel2)
            2'b00 : wire3 = C1;
            2'b01 : wire3 = wire4;
            2'b10 : wire3 = 32'd0;
            default : wire3 = 32'd0;
        endcase
    end

    always @(*) begin
        case(sel4)
            2'b00 : wire7 = i;
            2'b01 : wire7 = wire8;
            2'b10 : wire7 = it;
            default : wire7 = 7'd0;
        endcase
    end

    assign wire1 = sel1 ? wire2 : C;
    //assign wire3 = sel2 ? wire4 : C1;
    //assign wire5 = sel3 ? wire6 : C2;
    //assign wire7 = sel4 ? wire8 : i;
    assign wire9 = sel6 ? wire10 : j;
    assign wire11 = sel8 ? wire12 : k;
    assign wire13 = sel9 ? 7'd1 : 7'd0;
    assign wire18 = sel11 ? wire8 : it;

// Adders

    assign wire2 = C + 32'd1 ;
    assign wire4 = C1 + 32'd1 ;
    assign wire6 = C2 + 32'd1 ;
    assign wire8 = i + wire15 ;
    assign wire10 = j + wire14 ;
    assign wire12 = k + wire13 ;
    assign wire17 = result + mm; //sum + mm ;
    assign {invalidmm,tmpm} = result + mm; // Adding overflow flag

//comparator
    
    assign flag1 = (10 > C);
    assign flag2 = (10 > C1);
    assign flag3 = (10 > C2);
    
//Multiplier

    multiplier mmm(.clk(clk),.rst(rst),.start1(start1),.A(data1),.B(data2),.C(mm), .invalid(invalid1), .Done1(Done1));

//------------------------------FSM----------------------------------------------//
    
    parameter s0 = 4'b0000;
    parameter s1 = 4'b0001;
    parameter s2 = 4'b0010;
    parameter s3 = 4'b0011;
    parameter s4 = 4'b0100;
    parameter s5 = 4'b0101;
    parameter s6 = 4'b0110;
    parameter s7 = 4'b0111;
    parameter s8 = 4'b1000;
    parameter s9 = 4'b1001;

//state reg

    always @(posedge clk) begin
        if(rst) cs <=s0;
        else cs <= ns;  
    end

//next state logic

    always @(*) begin
        case (cs)
          s0  : ns <= start?s1:s0;
          s1  : ns <= flag1 ? s2:s8;
          s2  : ns <= flag2 ? s3:s7;
          //s3  : ns <= flag3 ? s4:s6;
          s3  : ns <= flag3 ? s9:s6;
          s4  : ns <= Done1 ? s5:s4;
          s5  : ns <= s3;
          s6  : ns <= s2;
          s7  : ns <= s1;
          s8  : ns <= s8;
          s9  : ns <= (invalidmm | invalid1 ) ? s8:s4;
            default: ns <= s0;
        endcase
    end
    
    //Output logic

    always @(*) begin
        case (cs)
            s0 : begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 0;
                WE <= 0;
            end 
           s1 : begin
                sel1 <= 1;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 0;
                WE <= 0;
            end 
            s2: begin
                sel1 <= 0;
                sel2 <= 2'b01;
                sel3 <= 2'b00;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 0;
                WE <= 0;
            end 
            s3 : begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b01;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 0;
                WE <= 1;
            end 
            s4 : begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                start1 <= 1;
                Done  <= 0;
                sel11 <= 0;
                WE <= 0;
            end 
            s5 : begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 2'b01;
                sel5 <= 2'b01;
                sel6 <= 1;
                sel7 <= 2'b01;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b01;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 1;
                WE <= 0;
            end 
            s6 : begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b10;
                sel4 <= 2'b01;
                sel5 <= 2'b10;
                sel6 <= 1;
                sel7 <= 2'b10;
                sel8 <= 1;//0
                sel9 <= 1;//0
                sel10 <= 2'b10;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 0;
                WE <= 0;
            end 
            s7 : begin
                sel1 <= 0;
                sel2 <= 2'b10;
                sel3 <= 2'b00;
                sel4 <= 2'b10;
                sel5 <= 2'b11;
                sel6 <= 1;//0;
                sel7 <= 2'b11;//2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 0;
                WE <= 0;
            end
            s8  : begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                Done  <= 1;
                start1 <= 0;
                sel11 <= 0;
                WE <= 0;
            end
            s9  : begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                Done  <= 0;
                start1 <= 0;
                sel11 <= 0;
                WE <= 0;
            end
            default: begin
                sel1 <= 0;
                sel2 <= 2'b00;
                sel3 <= 2'b00;
                sel4 <= 2'b00;
                sel5 <= 2'b00;
                sel6 <= 0;
                sel7 <= 2'b00;
                sel8 <= 0;
                sel9 <= 0;
                sel10 <= 2'b00;
                start1 <= 0;
                Done  <= 0;
                sel11 <= 0;
                WE <= 0;
            end 
        endcase
    end

endmodule