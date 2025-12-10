`timescale 1ns/1ps

module Reg_Bank_tb;

    logic        clk;
    logic        WE3;
    logic [4:0]  A1, A2, A3;
    logic [31:0] WD3;
    logic [31:0] RD1, RD2;

    // Instancia del módulo
    Reg_Bank uut (
        .clk(clk),
        .WE3(WE3),
        .A1(A1),
        .A2(A2),
        .A3(A3),
        .WD3(WD3),
        .RD1(RD1),
        .RD2(RD2)
    );

    // Reloj
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $display("=== INICIO DEL TEST ===");

        // -----------------------------------
        // ESCRITURA EN VARIOS REGISTROS
        // -----------------------------------

        // Escribir en x3 = 0xAAAA1111
        WE3 = 1;
        A3  = 3;
        WD3 = 32'hAAAA1111;
        @(posedge clk);

        // Escribir en x5 = 0x12345678
        A3  = 5;
        WD3 = 32'h12345678;
        @(posedge clk);

        // Escribir en x7 = 0xDEADBEEF
        A3  = 7;
        WD3 = 32'hDEADBEEF;
        @(posedge clk);

        WE3 = 0; // terminar escritura

        // -----------------------------------
        // PRUEBAS DE LECTURA
        // -----------------------------------

        // Leer x3 y x5
        A1 = 3;
        A2 = 5;
        #2;
        $display("RD1=x3=%h  RD2=x5=%h", RD1, RD2);        

        // Leer x7 y x3
        A1 = 7;
        A2 = 3;
        #2;
        $display("RD1=x7=%h  RD2=x3=%h", RD1, RD2);

        // Leer x5 y x7
        A1 = 5;
        A2 = 7;
        #2;
        $display("RD1=x5=%h  RD2=x7=%h", RD1, RD2);

        // Leer x0 = siempre 0
        A1 = 0;
        A2 = 3;
        #2;
        $display("RD1=x0=%h  RD2=x3=%h", RD1, RD2);

        $display("=== FIN DEL TEST ===");
        #10;
        $finish;
    end

endmodule
