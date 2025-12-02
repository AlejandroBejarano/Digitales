module data_memory #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,
    parameter MEM_SIZE   = 256
)(
    input  logic                  clk,
    input  logic                  reset,
    input  logic                  WE,             // Señal de escritura (MemWriteM)
    input  logic [ADDR_WIDTH-1:0] A,              // Dirección de acceso
    input  logic [DATA_WIDTH-1:0] WD,             // Dato a escribir
    output logic [DATA_WIDTH-1:0] RD              // Dato leído
);

    // Memoria de datos
    logic [DATA_WIDTH-1:0] mem [0:MEM_SIZE-1];

    // Inicialización
    initial begin
        foreach (mem[i]) mem[i] = 32'h00000000;
        // $readmemh("datos_iniciales.hex", mem);
    end

    // Escritura sincrónica
    always_ff @(posedge clk) begin
        if (WE) begin
            mem[A[9:2]] <= WD;
        end
    end

    // Lectura asíncrona
    assign RD = mem[A[9:2]];

endmodule