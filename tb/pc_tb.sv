`timescale 1ns/1ps

module tb_pc();
    parameter N = 32;

    // señales
    logic clk;
    logic reset;
    logic StallF;
    logic [N-1:0] pc_in;
    logic [N-1:0] pc_out;

    // instancia del DUT
    pc #(.N(N)) uut (
        .clk(clk),
        .reset(reset),
        .StallF(StallF),
        .pc_in(pc_in),
        .pc_out(pc_out)
    );

    // reloj: periodo 10 ns
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // generar archivo de ondas
        $dumpfile("pc_tb.vcd");
        $dumpvars(0, tb_pc);

        // inicializacion
        reset = 1;
        StallF = 0;
        pc_in = '0;

        // mantener reset por 2 ciclos
        repeat (2) @(posedge clk);
        reset = 0;
        $display("%0t: Reset desactivado", $time);

        // primer valor de pc_in, sin stall -> pc_out debe seguir pc_in
        pc_in = 32'h00000010;
        StallF = 0;
        @(posedge clk);
        #1;
        $display("%0t: pc_in=0x%08h, pc_out=0x%08h (esperado igual)", $time, pc_in, pc_out);
        if (pc_out !== pc_in) $error("ERROR: pc_out no siguio a pc_in cuando StallF=0");

        // probar stall: cambiar pc_in pero activar StallF -> pc_out debe quedarse en el valor anterior
        pc_in = 32'h00000020;
        StallF = 1;
        @(posedge clk);
        #1;
        $display("%0t: Stall activo, pc_in=0x%08h, pc_out=0x%08h (esperado sin cambio)", $time, pc_in, pc_out);
        if (pc_out === 32'h00000020) $error("ERROR: pc_out cambió durante StallF=1");

        // liberar stall: ahora pc_out debe actualizarse al nuevo pc_in
        StallF = 0;
        @(posedge clk);
        #1;
        $display("%0t: Stall liberado, pc_in=0x%08h, pc_out=0x%08h (esperado igual)", $time, pc_in, pc_out);
        if (pc_out !== pc_in) $error("ERROR: pc_out no actualizó después de liberar StallF");

        // probar reset asincrono: forzar reset y comprobar pc_out = 0
        #3;
        reset = 1; // posedge reset asynchronous trigger
        @(posedge clk);
        #1;
        $display("%0t: Reset activado, pc_out=0x%08h (esperado 0)", $time, pc_out);
        if (pc_out !== '0) $error("ERROR: pc_out no se puso a 0 tras reset");

        // terminar
        #5;
        $display("Simulación finalizada correctamente.");
        $finish;
    end

endmodule
