

// Testbench para el módulo Reg32
// Este testbench verifica el funcionamiento del registro de 32 bits
// con reset y enable. Se simula un reloj, se aplican diferentes
// condiciones de entrada y se monitorean las salidas.

`timescale 1ns / 1ps

module tb_Reg32();
    reg clk, rst, en;                       // señales de reloj, reset y enable
    reg [31:0] din;                        // señal de entrada
    wire [31:0] dout;                      // señal de salida

    // Instancia con conexión explícita, no usar .*
    Reg32 uut (
        .clk(clk),
        .rst(rst),
        .en(en),
        .din(din),
        .dout(dout)
    );

    // Generador de reloj (periodo 10ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Secuencia de pruebas
    initial begin
        rst = 1; en = 0; din = 0;
        #10 rst = 0; en = 1; din = 32'hA5A5A5A5;
        #10 en = 0; din = 32'hDEADBEEF;
        #10 en = 1;
        #10 $finish;
    end

    // Monitor de señales
    initial begin
        $monitor("T=%0t: clk=%b, rst=%b, en=%b, din=0x%h, dout=0x%h",
                 $time, clk, rst, en, din, dout);
    end
endmodule
