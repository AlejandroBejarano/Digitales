// Testbench para cache_storage
`timescale 1ns/1ps

module tb_cache;
    // Parámetros
    localparam DATA_W = 32;
    localparam INDEX_W = 5;
    localparam TAG_W = 6;
    localparam WORDS_PER_BLOCK = 8;
    localparam LINES = (1 << INDEX_W);

    // Señales
    reg clk, rst;
    reg [INDEX_W-1:0] index;
    reg [2:0] word_sel;
    reg we_data, we_tag;
    reg [TAG_W-1:0] tag_in;
    reg [DATA_W-1:0] data_in;
    wire [TAG_W-1:0] tag_out;
    wire valid_out;
    wire [DATA_W-1:0] data_out;

    // Instancia del DUT
    cache_storage #(
        .DATA_W(DATA_W),
        .INDEX_W(INDEX_W),
        .TAG_W(TAG_W),
        .WORDS_PER_BLOCK(WORDS_PER_BLOCK)
    ) dut (
        .clk(clk),
        .rst(rst),
        .index(index),
        .word_sel(word_sel),
        .we_data(we_data),
        .we_tag(we_tag),
        .tag_in(tag_in),
        .data_in(data_in),
        .tag_out(tag_out),
        .valid_out(valid_out),
        .data_out(data_out)
    );

    // Reloj
    always #5 clk = ~clk;

    // Pruebas
    initial begin
        $dumpfile("tb_cache.vcd");
        $dumpvars(0, tb_cache);
        clk = 0; rst = 1;
        index = 0; word_sel = 0; we_data = 0; we_tag = 0; tag_in = 0; data_in = 0;
        #12;
        rst = 0;
        // Escritura de tag y dato en línea 3, palabra 2
        index = 3; word_sel = 2; tag_in = 6'b101010; data_in = 32'hDEADBEEF;
        we_tag = 1; we_data = 1;
        #10;
        we_tag = 0; we_data = 0;
        // Lectura de la misma línea y palabra
        #10;
        // Escritura de otro dato en la misma línea, palabra 5
        word_sel = 5; data_in = 32'hCAFEBABE; we_data = 1;
        #10;
        we_data = 0;
        // Lectura de la palabra 5
        #10;
        // Escritura de tag en otra línea
        index = 10; word_sel = 0; tag_in = 6'b111100; we_tag = 1;
        #10;
        we_tag = 0;
        // Lectura de línea 10
        #10;
        $finish;
    end
endmodule
