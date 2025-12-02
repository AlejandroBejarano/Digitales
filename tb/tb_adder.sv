`timescale 1ns/1ps

module adder_tb;

    // Parámetro para el ancho del sumador
    parameter N = 32;

    // Señales para conectar al DUT (Device Under Test)
    logic [N-1:0] in1;
    logic [N-1:0] in2;
    logic [N-1:0] out;

    // Instanciación del módulo adder
    adder #(N) dut (
        .in1(in1),
        .in2(in2),
        .out(out)
    );

    // Generar archivo de ondas
    initial begin
        $dumpfile("tb_adder_waves.vcd");
        $dumpvars(0, tb_adder);
    end

    // Procedimiento inicial para el test
    initial begin
        // Prueba 1
        in1 = 32'h0000_0001;
        in2 = 32'h0000_0002;
        #1; // Espera 1 ns
        $display("Prueba 1: %h + %h = %h", in1, in2, out);

        // Prueba 2
        in1 = 32'hFFFF_FFFF;
        in2 = 32'h0000_0001;
        #1;
        $display("Prueba 2: %h + %h = %h", in1, in2, out);

        // Prueba 3
        in1 = 32'h1234_5678;
        in2 = 32'h8765_4321;
        #1;
        $display("Prueba 3: %h + %h = %h", in1, in2, out);

        // Prueba 4 (ambos ceros)
        in1 = 0;
        in2 = 0;
        #1;
        $display("Prueba 4: %h + %h = %h", in1, in2, out);

        // Prueba 5 (negativos usando representación en complemento a 2)
        in1 = -5;
        in2 = 8;
        #1;
        $display("Prueba 5: %0d + %0d = %0d", in1, in2, out);

        // Finaliza la simulación
        $finish;
    end

endmodule
