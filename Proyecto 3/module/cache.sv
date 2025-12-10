module cache_storage
#(
    parameter DATA_W = 32,
    parameter INDEX_W = 5,
    parameter TAG_W = 6,
    parameter WORDS_PER_BLOCK = 8
)(
    input  wire               clk,
    input  wire               rst,
    // Lectura / Escritura
    input  wire [INDEX_W-1:0] index,       // "Line" en el diagrama
    input  wire [2:0]         word_sel,    // "Word" en el diagrama
    input  wire               we_data,     // Habilitador escritura de Datos
    input  wire               we_tag,      // Habilitador escritura de Tag/Valid
    input  wire [TAG_W-1:0]   tag_in,      // Tag a escribir
    input  wire [DATA_W-1:0]  data_in,     // Dato a escribir
    
    // Salidas
    output wire [TAG_W-1:0]   tag_out,     // Tag leído
    output wire               valid_out,   // Bit de validez
    output wire [DATA_W-1:0]  data_out     // Dato leído
);

    localparam LINES = (1 << INDEX_W);

    // Arrays de almacenamiento
    reg [TAG_W-1:0]  tag_array   [0:LINES-1];
    reg              valid_array [0:LINES-1];
    reg [DATA_W-1:0] data_array  [0:LINES-1][0:WORDS_PER_BLOCK-1];

    integer i, w;

    // Inicialización
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i=0; i<LINES; i=i+1) begin
                valid_array[i] <= 1'b0;
                tag_array[i]   <= {TAG_W{1'b0}};
                for (w=0; w<WORDS_PER_BLOCK; w=w+1) 
                    data_array[i][w] <= {DATA_W{1'b0}};
            end
        end else begin
            // Escritura de Tags y Valid
            if (we_tag) begin
                tag_array[index]   <= tag_in;
                valid_array[index] <= 1'b1; 
            end
            // Escritura de Datos (Write Hit o Refill)
            if (we_data) begin
                data_array[index][word_sel] <= data_in;
            end
        end
    end

    // Lectura asíncrona (Mapeo Directo)
    assign tag_out   = tag_array[index];
    assign valid_out = valid_array[index];
    assign data_out  = data_array[index][word_sel];

endmodule