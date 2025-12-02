

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