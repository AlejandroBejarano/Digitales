`timescale 1ns / 1ps

module tb_cpu;

    // Señales del Testbench
    logic clk;
    logic reset;
    logic [31:0] WB_Result_Out;
    logic [31:0] PC_Out;

    // Instancia del procesador Top
    cpu uut (
        .clk(clk),
        .reset(reset),
        .WB_Result_Out(WB_Result_Out),
        .PC_Out(PC_Out)
    );

    // Generación de Reloj (Periodo = 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Secuencia de prueba
    initial begin
        // Generar archivo de ondas VCD
        $dumpfile("cpu_multiciclo_tb.vcd");
        $dumpvars(0, tb_cpu);

        // Inicialización
        reset = 1;
        $display("Iniciando simulacion...");
        
        // Esperar unos ciclos en reset
        #20;
        reset = 0;
        $display("Reset liberado. CPU corriendo.");

        // Correr simulación por un tiempo determinado
        // Ajusta este valor según la duración de tu programa
        #500; 

        $display("Simulacion finalizada.");
        $stop;
    end

    // Monitor: Imprime info cada vez que cambia el reloj (Flanco de bajada para ver resultados estables)
    always @(negedge clk) begin
        if (!reset) begin
            $display("Time: %0t | PC: %h | WB Result: %h", 
                     $time, PC_Out, WB_Result_Out);
        end
    end

endmodule