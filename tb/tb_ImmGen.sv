


`timescale 1ns / 1ps

module ImmGen_tb;

    logic [1:0] immSel;
    logic [31:0] instruction;
    logic [31:0] Imm;

    // Instanciar el módulo bajo prueba
    ImmGen imm (
        .instruction(instruction),
        .immSel(immSel),
        .Imm(Imm)
    );

    // Generar archivo VCD para GTKWave
    initial begin
        $dumpfile("ImmGen_waves.vcd");
        $dumpvars(0, ImmGen_tb);
    end

    // Estímulos y visualización
    initial begin
        // Test case 1: I-Type (valor positivo máximo: 0x7FF)
        instruction = 32'h7FF00000; // [31:20] = 12'h7FF (signo positivo)
        immSel = 2'b00;
        #10;
        $display("I-Type (Pos): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 2: I-Type (valor negativo máximo: 0x800)
        instruction = 32'h80000000; // [31:20] = 12'h800 (signo negativo)
        immSel = 2'b00;
        #10;
        $display("I-Type (Neg): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 3: S-Type (valor positivo: 0x00 + 0x1F = 0x1F)
        instruction = 32'h0070A223; // [31:25]=7'h00, [11:7]=5'h1F
        immSel = 2'b01;
        #10;
        $display("S-Type (Pos): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 4: S-Type (valor negativo: 0x7F + 0x1F = 0xFFF)
        instruction = 32'h7F000F80; // [31:25]=7'h7F, [11:7]=5'h1F
        immSel = 2'b01;
        #10;
        $display("S-Type (Neg): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 5: B-Type (offset positivo: 0x7FE)
        instruction = 32'h3F000F00; // [31]=0, [7]=0, [30:25]=6'h3F, [11:8]=4'hF
        immSel = 2'b10;
        #10;
        $display("B-Type (Pos): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 6: B-Type (offset negativo: -0x1000)
        instruction = 32'h80000080; // [31]=1, [7]=0, [30:25]=6'h00, [11:8]=4'h0
        immSel = 2'b10;
        #10;
        $display("B-Type (Neg): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 7: J-Type (offset positivo: 0x7FFFFE)
        instruction = 32'h007FF0EF; // [31]=0, [19:12]=8'h7F, [20]=1, [30:21]=10'h3FF
        immSel = 2'b11;
        #10;
        $display("J-Type (Pos): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 8: J-Type (offset negativo: -0x1000)
        instruction = 32'hFFFFF00F; // [31]=1, [19:12]=8'hFF, [20]=0, [30:21]=10'h3FF
        immSel = 2'b11;
        #10;
        $display("J-Type (Neg): Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        // Test case 9: Default (immSel inválido)
        immSel = 2'b10; // Valor válido, pero forzamos un caso no manejado
        #10;
        $display("Default: Instr=0x%h, immSel=%b, Imm=0x%h", instruction, immSel, Imm);

        $finish;
    end

endmodule