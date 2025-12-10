`timescale 1ns/1ps

module tb_address_decoder;

    // Parámetros del módulo
    localparam ADDR_WIDTH = 16;
    localparam INDEX_BITS = 5;
    localparam WORD_BITS  = 2;

    // Señales del DUT
    logic [ADDR_WIDTH-1:0] addr;
    logic [5:0]            tag;
    logic [INDEX_BITS-1:0] index;
    logic [WORD_BITS-1:0]  word_sel;

    // Instancia del módulo
    address_decoder #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .INDEX_BITS(INDEX_BITS),
        .WORD_BITS(WORD_BITS)
    ) dut (
        .addr(addr),
        .tag(tag),
        .index(index),
        .word_sel(word_sel)
    );

    initial begin
        $display("=== Testbench Address Decoder ===");

        // Prueba 1
        addr = 16'hA3F2;  
        #10;
        $display("ADDR = %h | tag=%b index=%b word_sel=%b",
                 addr, tag, index, word_sel);

        // Prueba 2
        addr = 16'b1111000001110011;
        #10;
        $display("ADDR = %b | tag=%b index=%b word_sel=%b",
                 addr, tag, index, word_sel);

        // Prueba 3
        addr = 16'h1234;
        #10;
        $display("ADDR = %h | tag=%b index=%b word_sel=%b",
                 addr, tag, index, word_sel);

        // Prueba 4 — valores extremos
        addr = 16'hFFFF;
        #10;
        $display("ADDR = %h | tag=%b index=%b word_sel=%b",
                 addr, tag, index, word_sel);

        addr = 16'h0000;
        #10;
        $display("ADDR = %h | tag=%b index=%b word_sel=%b",
                 addr, tag, index, word_sel);

        $display("=== Fin del testbench ===");
        $finish;
    end

endmodule
