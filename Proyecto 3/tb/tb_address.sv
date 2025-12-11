`timescale 1ns/1ps

module tb_address;
    // Parámetros del módulo
    localparam ADDR_W   = 16;
    localparam INDEX_W  = 5;
    localparam OFFSET_W = 5;

    // Entradas y salidas
    reg  [ADDR_W-1:0] addr;
    wire [5:0]        tag;
    wire [INDEX_W-1:0] index;
    wire [2:0]        word_sel;

    address #(
        .ADDR_W(ADDR_W),
        .INDEX_W(INDEX_W),
        .OFFSET_W(OFFSET_W)
    ) dut (
        .addr(addr),
        .tag(tag),
        .index(index),
        .word_sel(word_sel)
    );

    // Inicialización y pruebas
    initial begin
        $dumpfile("tb_address.vcd");
        $dumpvars(0, tb_address);
        
        // Prueba 1
        addr = 16'hABCD;
        #10;
        // Prueba 2
        addr = 16'h1234;
        #10;
        // Prueba 3
        addr = 16'hFFFF;
        #10;
        // Prueba 4
        addr = 16'h0000;
        #10;
        // Prueba 5
        addr = 16'h5555;
        #10;
        $finish;
    end
endmodule
