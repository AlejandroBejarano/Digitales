`timescale 1ns/1ps

module tb_data_memory();
    logic clk;
    logic reset;
    logic WE;
    logic [31:0] A;
    logic [31:0] WD;
    logic [31:0] RD;

    // Instancia del módulo bajo prueba
    data_memory #(
        .DATA_WIDTH(32),
        .ADDR_WIDTH(32),
        .MEM_SIZE(256)
    ) uut (
        .clk(clk),
        .reset(reset),
        .WE(WE),
        .A(A),
        .WD(WD),
        .RD(RD)
    );

    // Generador de reloj (periodo 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Generación de estímulos
    initial begin
        $dumpfile("tb_data_memory.vcd");
        $dumpvars(0, tb_data_memory);
        
        // Inicialización
        reset = 1;
        WE = 0;
        A = 32'h0000_0000;
        WD = 32'h0000_0000;
        #10;
        
        // Caso 1: Escritura y lectura básica
        reset = 0;
        WE = 1;
        A = 32'h0000_0010;  // Dirección 0x10
        WD = 32'hCAFE_BABE;
        #10;
        WE = 0;
        #5;
        if (RD !== 32'hCAFE_BABE) $error("Error Caso 1: Lectura incorrecta en 0x10");
        
        // Caso 2: Escritura en dirección no alineada (debería ignorar bits [1:0])
        WE = 1;
        A = 32'h0000_0013;  // Dirección 0x13 (equivale a 0x10)
        WD = 32'hDEAD_BEEF;
        #10;
        WE = 0;
        A = 32'h0000_0010;
        #5;
        if (RD !== 32'hDEAD_BEEF) $error("Error Caso 2: Escritura no alineada falló");
        
        // Caso 3: Reset limpia la memoria
        reset = 1;
        #10;
        reset = 0;
        A = 32'h0000_0010;
        #5;
        if (RD !== 32'h0000_0000) $error("Error Caso 3: Reset no limpió la memoria");
        
        $display("¡Todos los tests pasaron!");
        $finish;
    end
endmodule