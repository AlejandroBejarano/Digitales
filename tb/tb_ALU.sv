`timescale 1ns / 1ps

module ALU_tb();
    // Señales de entrada
    logic [31:0] operand1;
    logic [31:0] operand2;
    logic [2:0]  ALUControl;
    logic [2:0]  funct3;
    logic [6:0]  funct7;
    
    // Señales de salida
    logic [31:0] result;
    logic        zero;
    
    // Instancia del módulo ALU
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
        // Inicializar entradas
        operand1 = 32'h00000000;
        operand2 = 32'h00000000;
        ALUControl = 3'b000;
        funct3 = 3'b000;
        funct7 = 7'b0000000;
        
        // Monitorear cambios
        $monitor("Time=%0t ALUControl=%b funct3=%b funct7=%b op1=%h op2=%h result=%h zero=%b", 
                 $time, ALUControl, funct3, funct7, operand1, operand2, result, zero);
        
        // Pruebas para cada operación
        
        // 1. Pruebas para operaciones aritméticas (ALUControl = 3'b000)
        #10;
        ALUControl = 3'b000; funct3 = 3'b000; funct7 = 7'b0000000; // ADD
        operand1 = 32'h00000005; operand2 = 32'h00000003;
        #10;
        operand1 = 32'hFFFFFFFF; operand2 = 32'h00000001; // Prueba de desbordamiento
        
        #10;
        ALUControl = 3'b000; funct3 = 3'b000; funct7 = 7'b0100000; // SUB
        operand1 = 32'h0000000A; operand2 = 32'h00000003;
        #10;
        operand1 = 32'h00000003; operand2 = 32'h0000000A; // Resultado negativo
        
        // 2. Pruebas para desplazamiento izquierdo (ALUControl = 3'b001)
        #10;
        ALUControl = 3'b001; // SLL
        operand1 = 32'h00000001; operand2 = 32'h00000004;
        #10;
        operand1 = 32'hF0000000; operand2 = 32'h00000001;
        
        // 3. Pruebas para comparación signed (ALUControl = 3'b010)
        #10;
        ALUControl = 3'b010; funct3 = 3'b010; // SLT
        operand1 = 32'h00000005; operand2 = 32'h0000000A;
        #10;
        operand1 = 32'hFFFFFFFE; operand2 = 32'h00000001; // -2 < 1
        #10;
        operand1 = 32'h0000000A; operand2 = 32'h00000005;
        
        // 4. Pruebas para comparación unsigned (ALUControl = 3'b011)
        #10;
        ALUControl = 3'b011; funct3 = 3'b011; // SLTU
        operand1 = 32'h00000005; operand2 = 32'h0000000A;
        #10;
        operand1 = 32'hFFFFFFFE; operand2 = 32'h00000001; // 0xFFFFFFFE > 0x00000001
        #10;
        operand1 = 32'h0000000A; operand2 = 32'h00000005;
        
        // 5. Pruebas para XOR (ALUControl = 3'b100)
        #10;
        ALUControl = 3'b100; // XOR
        operand1 = 32'h55555555; operand2 = 32'hAAAAAAAA;
        #10;
        operand1 = 32'h12345678; operand2 = 32'h12345678;
        
        // 6. Pruebas para desplazamiento derecho (ALUControl = 3'b101)
        #10;
        ALUControl = 3'b101; funct7 = 7'b0000000; // SRL
        operand1 = 32'h80000000; operand2 = 32'h00000004;
        #10;
        ALUControl = 3'b101; funct7 = 7'b0100000; // SRA
        operand1 = 32'h80000000; operand2 = 32'h00000004;
        #10;
        operand1 = 32'h40000000; operand2 = 32'h00000004;
        
        // 7. Pruebas para OR (ALUControl = 3'b110)
        #10;
        ALUControl = 3'b110; // OR
        operand1 = 32'h00001111; operand2 = 32'h11110000;
        #10;
        operand1 = 32'h00000000; operand2 = 32'h00000000;
        
        // 8. Pruebas para AND (ALUControl = 3'b111)
        #10;
        ALUControl = 3'b111; // AND
        operand1 = 32'h00001111; operand2 = 32'h11111111;
        #10;
        operand1 = 32'hFFFFFFFF; operand2 = 32'h00000000;
        
        // 9. Pruebas adicionales para zero flag
        #10;
        ALUControl = 3'b000; funct3 = 3'b000; funct7 = 7'b0000000; // ADD
        operand1 = 32'h00000000; operand2 = 32'h00000000;
        #10;
        operand1 = 32'h00000001; operand2 = 32'hFFFFFFFF;
        
        #10;
        $finish;
    end
endmodule