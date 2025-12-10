module address_decoder #(
    parameter ADDR_WIDTH = 16,
    parameter INDEX_BITS = 5,     // 32 lines
    parameter WORD_BITS  = 2,     // 4 palabras
    parameter BYTE_BITS  = 2      // 4 bytes por palabra
)(
    input  logic [ADDR_WIDTH-1:0] addr,

    output logic [5:0]            tag,
    output logic [INDEX_BITS-1:0] index,
    output logic [WORD_BITS-1:0]  word_sel
);

    assign tag      = addr[15 : 10];
    assign index    = addr[9  : 5 ];
    assign word_sel = addr[4  : 3 ];

endmodule
