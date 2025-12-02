

`timescale 1ns/1ns

module pc_tb();
    parameter N = 32;
    logic clk;
    logic reset;
    logic [N-1:0] pc_in;
    logic [N-1:0] pc_out;

    // Instanciar el módulo pc
    pc #(.N(N)) uut (
        .clk(clk),
        .reset(reset),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Generador de reloj (periodo 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Generar archivo de ondas
    initial begin
        $dumpfile("pc_waves.vcd");
        $dumpvars(0, pc_tb);
    end


    // Inicializar señales y pruebas
    initial begin
        $monitor("Time = %0t ns | clk = %b | reset = %b | pc_in = 0x%h | pc_out = 0x%h", 
                 $time, clk, reset, pc_in, pc_out);

        // Inicializar valores
        reset = 1;
        pc_in = 32'h00000000;
        #10;

        // Desactivar reset y probar actualización
        reset = 0;
        pc_in = 32'h00400000;  // Ejemplo de dirección
        #10;

        // Cambiar pc_in
        pc_in = 32'h00400004;
        #10;

        // Activar reset durante la operación
        reset = 1;
        #10;


        // Finalizar simulación
        $finish;
    end
endmodule

