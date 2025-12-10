`timescale 1ns / 1ps

module ALU_tb();

    logic [31:0] operand1;
    logic [31:0] operand2;
    logic [2:0]  ALUControl;
    logic [2:0]  funct3;
    logic [6:0]  funct7;

    logic [31:0] result;
    logic        zero;

    ALU uut (
        .operand1(operand1),
        .operand2(operand2),
        .ALUControl(ALUControl),
        .funct3(funct3),
        .funct7(funct7),
        .result(result),
        .zero(zero)
    );
    
    initial begin
        operand1 = 32'h00000000;
        operand2 = 32'h00000000;
        ALUControl = 3'b000;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        

        $monitor("Time=%0t ALUControl=%b funct3=%b funct7=%b op1=%h op2=%h result=%h zero=%b", 
                 $time, ALUControl, funct3, funct7, operand1, operand2, result, zero);
        
        #10;
        ALUControl = 3'b000; funct3 = 3'b000; funct7 = 7'b0000000; 
        operand1 = 32'h00000005; operand2 = 32'h00000003;
        #10;
        operand1 = 32'hFFFFFFFF; operand2 = 32'h00000001; 
        
        #10;
        ALUControl = 3'b000; funct3 = 3'b000; funct7 = 7'b0100000; 
        operand1 = 32'h0000000A; operand2 = 32'h00000003;
        #10;
        operand1 = 32'h00000003; operand2 = 32'h0000000A; 
        
        #10;
        ALUControl = 3'b001; // SLL
        operand1 = 32'h00000001; operand2 = 32'h00000004;
        #10;
        operand1 = 32'hF0000000; operand2 = 32'h00000001;

        #10;
        ALUControl = 3'b010; funct3 = 3'b010; // SLT
        operand1 = 32'h00000005; operand2 = 32'h0000000A;
        #10;
        operand1 = 32'hFFFFFFFE; operand2 = 32'h00000001; // -2 < 1
        #10;
        operand1 = 32'h0000000A; operand2 = 32'h00000005;
        
        #10;
        ALUControl = 3'b011; funct3 = 3'b011; 
        operand1 = 32'h00000005; operand2 = 32'h0000000A;
        #10;
        operand1 = 32'hFFFFFFFE; operand2 = 32'h00000001; 
        #10;
        operand1 = 32'h0000000A; operand2 = 32'h00000005;

        #10;
        ALUControl = 3'b100; 
        operand1 = 32'h55555555; operand2 = 32'hAAAAAAAA;
        #10;
        operand1 = 32'h12345678; operand2 = 32'h12345678;
        
        #10;
        ALUControl = 3'b101; funct7 = 7'b0000000; 
        operand1 = 32'h80000000; operand2 = 32'h00000004;
        #10;
        ALUControl = 3'b101; funct7 = 7'b0100000; 
        operand1 = 32'h80000000; operand2 = 32'h00000004;
        #10;
        operand1 = 32'h40000000; operand2 = 32'h00000004;

        #10;
        ALUControl = 3'b110; 
        operand1 = 32'h00001111; operand2 = 32'h11110000;
        #10;
        operand1 = 32'h00000000; operand2 = 32'h00000000;

        #10;
        ALUControl = 3'b111; 
        operand1 = 32'h00001111; operand2 = 32'h11111111;
        #10;
        operand1 = 32'hFFFFFFFF; operand2 = 32'h00000000;

        #10;
        ALUControl = 3'b000; funct3 = 3'b000; funct7 = 7'b0000000; // ADD
        operand1 = 32'h00000000; operand2 = 32'h00000000;
        #10;
        operand1 = 32'h00000001; operand2 = 32'hFFFFFFFF;
        
        #10;
        $finish;
    end
endmodule