

`timescale 1ns/1ps

module memoria_datos_tb;

    // -----------------------------------------------------------
    // 1) Parámetros idénticos a los del módulo bajo prueba
    // -----------------------------------------------------------
    localparam integer Ancho_Dato      = 32;
    localparam integer Ancho_Direccion = 32;
    localparam integer Tamanio_Mem     = 256;

    // -----------------------------------------------------------
    // 2) Señales de prueba (stimulus) y observación (response)
    // -----------------------------------------------------------
    logic clk;
    logic escritura_habilitada;
    logic lectura_habilitada;
    logic [Ancho_Direccion-1:0] direccion;
    logic [Ancho_Dato-1:0]      dato_escritura;
    wire  [Ancho_Dato-1:0]      dato_lectura;

    // -----------------------------------------------------------
    // 3) Instanciación del módulo memoria_datos
    // -----------------------------------------------------------
    memoria_datos #(
        .Ancho_Dato      (Ancho_Dato),
        .Ancho_Direccion (Ancho_Direccion),
        .Tamanio_Mem     (Tamanio_Mem)
    ) dut (
        .clk                   (clk),
        .escritura_habilitada  (escritura_habilitada),
        .lectura_habilitada    (lectura_habilitada),
        .direccion             (direccion),
        .dato_escritura        (dato_escritura),
        .dato_lectura          (dato_lectura)
    );

    // -----------------------------------------------------------
    // 4) Generar fichero VCD para GTKWave
    // -----------------------------------------------------------
    initial begin
        $dumpfile("memoria_datos_tb.vcd");
        $dumpvars(0, memoria_datos_tb);
    end

    // -----------------------------------------------------------
    // 5) Generación de reloj (período 10 ns)
    // -----------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // cada 5 ns invierte clk → período 10 ns
    end

    // -----------------------------------------------------------
    // 6) Proceso de estímulo: escribir y luego leer datos
    // -----------------------------------------------------------
    initial begin
        // ----------------------------
        // 6.1) Inicializar señales
        // ----------------------------
        escritura_habilitada = 0;
        lectura_habilitada   = 0;
        direccion            = '0;
        dato_escritura       = '0;

        // Esperamos dos ciclos de reloj para estabilizar
        #20;

        $display("---------------------------------------------------------------");
        $display("  Tiempo | Escribir | Direccion | Dato_Escritura | Dato_Lectura");
        $display("---------------------------------------------------------------");

        // ----------------------------
        // 6.2) Escritura de algunos valores
        // ----------------------------
        // (a) Escribimos 32'hDEADBEEF en la dirección 0x00000000
        @(posedge clk);
        escritura_habilitada = 1;
        direccion            = 32'h0000_0000;  // índice = 0
        #10; 
        dato_escritura       = 32'hDEAD_BEEF;
        #10; // Dejamos estable por unos instantes
        @(posedge clk);
        escritura_habilitada = 0;  // deshabilitamos escritura

        // (b) Escribimos 32'hCAFEBABE en la dirección 0x00000004 (índice = 1)
        @(posedge clk);
        escritura_habilitada = 1;
        direccion            = 32'h0000_0004;  // índice = 1
        #10; 
        dato_escritura       = 32'hCAFE_BABE;
        #10;
        @(posedge clk);
        escritura_habilitada = 0;

        // (c) Escribimos 32'h12345678 en la dirección 0x00000010 (índice = 4)
        @(posedge clk);
        escritura_habilitada = 1;
        direccion            = 32'h0000_0010;  // índice = 4 (0x10 >> 2 = 4)
        #10; 
        dato_escritura       = 32'h1234_5678;
        #10;
        @(posedge clk);
        escritura_habilitada = 0;

        // (d) Intentamos escribir en posición 255 (0x3FC) con valor 0xABCDEF01
        @(posedge clk);
        escritura_habilitada = 1;
        direccion            = 32'h0000_03FC;  // índice = 255
        #10; 
        dato_escritura       = 32'hABCD_EF01;
        #10;
        @(posedge clk);
        escritura_habilitada = 0;

        // Esperamos un ciclo antes de empezar a leer
        #10;

        // ----------------------------
        // 6.3) Lectura de las direcciones escritas
        // ----------------------------
        lectura_habilitada = 1;

        // (a) Leer en índice = 0 (0x00000000)
        direccion = 32'h0000_0000;
        #2; // pequeño retardo para que el dato aparezca en salida combinacional
        $display("%8t |   Read   |  0x%08h |       0x%08h |    0x%08h",
                 $time, direccion, 32'hDEAD_BEEF, dato_lectura);

        // (b) Leer en índice = 1 (0x00000004)
        direccion = 32'h0000_0004;
        #2;
        $display("%8t |   Read   |  0x%08h |       0x%08h |    0x%08h",
                 $time, direccion, 32'hCAFE_BABE, dato_lectura);

        // (c) Leer en índice = 4 (0x00000010)
        direccion = 32'h0000_0010;
        #2;
        $display("%8t |   Read   |  0x%08h |       0x%08h |    0x%08h",
                 $time, direccion, 32'h1234_5678, dato_lectura);

        // (d) Leer en índice = 255 (0x000003FC)
        direccion = 32'h0000_03FC;
        #2;
        $display("%8t |   Read   |  0x%08h |       0x%08h |    0x%08h",
                 $time, direccion, 32'hABCD_EF01, dato_lectura);

        // (e) Leer dirección sin habilitar lectura
        lectura_habilitada = 0;
        direccion          = 32'h0000_0000; 
        #2;
        $display("%8t |   ReadDis | 0x%08h |   xxxxxxxx    |    0x%08h",
                 $time, direccion, dato_lectura);

        // Fin de simulación
        $display("---------------------------------------------------------------");
        #10;
        $finish;
    end

endmodule
