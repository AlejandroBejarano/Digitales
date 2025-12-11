module address
#(
    parameter ADDR_W   = 16,
    parameter INDEX_W  = 5,
    parameter OFFSET_W = 5   // 32 Bytes por bloque = 5 bits offset
)(
    input  wire [ADDR_W-1:0]  addr,
    output wire [5:0]         tag,     // 16 - 5 - 5 = 6 bits
    output wire [INDEX_W-1:0] index,   // 5 bits (32 líneas)
    output wire [2:0]         word_sel // Selecciona la palabra de 32b dentro del bloque
);

    // Mapeo según el diagrama: [ Tag | Line | Word/Byte ]
    assign tag      = addr[ADDR_W-1 : INDEX_W+OFFSET_W];
    assign index    = addr[INDEX_W+OFFSET_W-1 : OFFSET_W];
    // Los bits [4:2] seleccionan la palabra (32 bits), los bits [1:0] son para byte
    assign word_sel = addr[4:2]; 

endmodule