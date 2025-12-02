`timescale 1ns / 1ps

module tb_cpu_multiciclo;

    logic clk;
    logic reset;

    wire [31:0] ResultW;
    wire [4:0]  RdW;
    wire        RegWriteW;
    wire        ZeroE;

    // Instancia del CPU
    cpu_multiciclo uut (
        .clk(clk),
        .reset(reset),
        .ResultW(ResultW),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .ZeroE(ZeroE)
    );

    // Generador de reloj: 10ns periodo
    initial clk = 0;
    always #5 clk = ~clk;

    // Inicialización y control de reset
    initial begin
        $display("Iniciando simulación...");
        $dumpfile("cpu_multiciclo_tb.vcd");
        $dumpvars(0, tb_cpu_multiciclo);

        reset = 1;
        #20;
        reset = 0;

        // Simular por suficientes ciclos
        #2000;

        $display("Finalizando simulación...");
        $finish;
    end

endmodule