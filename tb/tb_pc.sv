`timescale 1ns/1ps

module tb_pc();
    logic clk;
    logic reset;
    logic StallF;
    logic [31:0] pc_in;
    logic [31:0] pc_out;

    // Instancia del módulo bajo prueba
    pc uut (
        .clk(clk),
        .reset(reset),
        .StallF(StallF),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // Generador de reloj (periodo 10 ns)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Generación de estímulos
    initial begin
        $dumpfile("tb_pc.vcd");
        $dumpvars(0, tb_pc);
        
        // Reset inicial
        reset = 1;
        StallF = 0;
        pc_in = 32'h0000_0000;
        #10;
        
        // Caso 1: Actualización normal
        reset = 0;
        pc_in = 32'h0040_0000;
        #10;
        if (pc_out !== 32'h0040_0000) $error("Error Caso 1: pc_out debería ser 0x00400000");
        
        // Caso 2: Stall activo (no debe actualizarse)
        StallF = 1;
        pc_in = 32'hDEAD_BEEF;
        #10;
        if (pc_out !== 32'h0040_0000) $error("Error Caso 2: pc_out no debería cambiar con StallF=1");
        
        // Caso 3: Reset asíncrono
        reset = 1;
        #5;
        if (pc_out !== 32'h0000_0000) $error("Error Caso 3: pc_out no se reseteó a 0");
        
        $display("¡Todos los tests pasaron!");
        $finish;
    end
endmodule