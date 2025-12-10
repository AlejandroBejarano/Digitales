`timescale 1ns/1ps

module tb_reg_bank();

    // señales del banco de registros
    logic clk;
    logic rst;
    logic WE3;
    logic [4:0] A1, A2, A3;
    logic [31:0] WD3;
    logic [31:0] RD1, RD2;

    // instancia del DUT
    Reg_Bank uut (
        .clk(clk),
        .rst(rst),
        .WE3(WE3),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .RD1(RD1),
        .RD2(RD2)
    );

    // reloj: periodo 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // generar archivo de ondas
        $dumpfile("reg_bank_tb.vcd");
        $dumpvars(0, tb_reg_bank);

        // inicializacion
        rst = 1;
        WE3 = 0;
        A1 = 0; A2 = 0; A3 = 0;
        WD3 = 32'h0;

        // esperar unos ciclos con reset
        repeat (2) @(posedge clk);
        rst = 0;
        $display("%0t: Reset desactivado", $time);

        // --------------------------------------------------
        // Escritura en registro 3
        // --------------------------------------------------
        A3 = 5'd3;
        WD3 = 32'hDEADBEEF;
        WE3 = 1;
        @(posedge clk);
        WE3 = 0; // solo un flanco para escribir
        $display("%0t: Escrito 0x%08h en R3", $time, WD3);

        // esperar un ciclo
        @(posedge clk);

        // --------------------------------------------------
        // Escritura en registro 5
        // --------------------------------------------------
        A3 = 5'd5;
        WD3 = 32'h12345678;
        WE3 = 1;
        @(posedge clk);
        WE3 = 0;
        $display("%0t: Escrito 0x%08h en R5", $time, WD3);

        // esperar un ciclo para que los datos estén disponibles
        @(posedge clk);

        // --------------------------------------------------
        // Lecturas: varios casos de ejemplo
        // --------------------------------------------------

        // 1) Leer R3 en RD1 y R5 en RD2
        A1 = 5'd3; A2 = 5'd5;
        @(posedge clk);
        #1; // esperar pequeñas propagaciones
        $display("%0t: Lectura A1=3 -> RD1=0x%08h, A2=5 -> RD2=0x%08h", $time, RD1, RD2);
        if (RD1 !== 32'hDEADBEEF) $error("Lectura incorrecta R3: esperaba 0xDEADBEEF, obtuvo 0x%08h", RD1);
        if (RD2 !== 32'h12345678) $error("Lectura incorrecta R5: esperaba 0x12345678, obtuvo 0x%08h", RD2);

        // 2) Leer R0 (debe ser 0) y R3
        A1 = 5'd0; A2 = 5'd3;
        @(posedge clk);
        #1;
        $display("%0t: Lectura A1=0 -> RD1=0x%08h, A2=3 -> RD2=0x%08h", $time, RD1, RD2);
        if (RD1 !== 32'h0) $error("Lectura incorrecta R0: esperaba 0x0, obtuvo 0x%08h", RD1);
        if (RD2 !== 32'hDEADBEEF) $error("Lectura incorrecta R3: esperaba 0xDEADBEEF, obtuvo 0x%08h", RD2);

        // 3) Leer R5 y R4 (R4 no escrito => 0)
        A1 = 5'd5; A2 = 5'd4;
        @(posedge clk);
        #1;
        $display("%0t: Lectura A1=5 -> RD1=0x%08h, A2=4 -> RD2=0x%08h", $time, RD1, RD2);
        if (RD1 !== 32'h12345678) $error("Lectura incorrecta R5: esperaba 0x12345678, obtuvo 0x%08h", RD1);
        if (RD2 !== 32'h0) $error("Lectura incorrecta R4: esperaba 0x0, obtuvo 0x%08h", RD2);

        // 4) Lectura adicional: R3 en RD1, R5 en RD2 (confirmacion)
        A1 = 5'd3; A2 = 5'd5;
        @(posedge clk);
        #1;
        $display("%0t: Confirmacion final A1=3 -> RD1=0x%08h, A2=5 -> RD2=0x%08h", $time, RD1, RD2);

        $display("Todas las lecturas correctas. Simulacion finalizada.");
        #5;
        $finish;
    end

endmodule


module Reg_Bank_tb();
    logic        clk, rst, WE3;
    logic [4:0]  A1, A2, A3;
    logic [31:0] WD3;
    logic [31:0] RD1, RD2;

    // Instanciar el módulo bajo prueba
    Reg_Bank uut (
        .clk(clk),
        .rst(rst),
        .WE3(WE3),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .RD1(RD1),
        .RD2(RD2)
    );

    // Generador de reloj (periodo 10 unidades)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Secuencia de prueba
    initial begin
        // Inicializar entradas
        rst = 1;
        WE3 = 0;
        A1 = 0;
        A2 = 0;
        A3 = 0;
        WD3 = 0;

        // Reset inicial
        #20; // Esperar 2 ciclos de reloj
        rst = 0;

        // Test 1: Escribir en registro 5 y verificar
        WE3 = 1;
        A3 = 5;
        WD3 = 32'h1234ABCD;
        @(posedge clk); // Escritura ocurre aquí
        WE3 = 0;
        A1 = 5; // Leer registro 5
        #1;
        if (RD1 !== 32'h1234ABCD) $display("Error Test 1");
        else $display("Test 1 OK");

        // Test 2: Intentar escribir en registro 0
        WE3 = 1;
        A3 = 0;
        WD3 = 32'hDEADBEEF;
        @(posedge clk);
        WE3 = 0;
        A1 = 0; // Leer registro 0
        #1;
        if (RD1 !== 32'h0) $display("Error Test 2");
        else $display("Test 2 OK");

        // Test 3: Lectura durante escritura
        WE3 = 1;
        A3 = 3;
        WD3 = 32'h5555AAAA;
        A1 = 3; // Leer durante escritura
        #4;      // Justo antes del flanco de reloj
        if (RD1 !== 32'h0) $display("Error Test 3a");
        else $display("Test 3a OK");
        @(posedge clk);
        #1;      // Después del flanco
        if (RD1 !== 32'h5555AAAA) $display("Error Test 3b");
        else $display("Test 3b OK");

        // Finalizar simulación
        $finish;
    end

    // Generar archivo VCD para GTKWave
    initial begin
        $dumpfile("Reg_Bank_tb.vcd");
        $dumpvars(0, Reg_Bank_tb);
    end
endmodule