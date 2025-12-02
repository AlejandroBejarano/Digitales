module datapath_mem (
    input  logic        clk,
    input  logic        reset,

    // Entradas desde EX/MEM
    input  logic        RegWriteM,
    input  logic [1:0]  ResultSrcM,
    input  logic        MemWriteM,
    input  logic [31:0] ALUResultM,
    input  logic [31:0] WriteDataM,
    input  logic [31:0] PCPlus4M,
    input  logic [4:0]  RdM,

    // Salidas hacia WB
    output logic        RegWriteW,
    output logic [1:0]  ResultSrcW,
    output logic [31:0] ALUResultW,
    output logic [31:0] ReadDataW,
    output logic [31:0] PCPlus4W,
    output logic [4:0]  RdW
);

    // Lectura desde memoria de datos
    logic [31:0] RD;

    // Instancia de memoria de datos
    data_memory mem_data (
        .clk(clk),
        .reset(reset),
        .WE(MemWriteM),
        .A(ALUResultM),
        .WD(WriteDataM),
        .RD(RD)
    );

    // Registro MEM/WB
    register_mem_wb reg_mem_wb (
        .clk(clk),
        .reset(reset),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .ALUResultM(ALUResultM),
        .RD(RD),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW),
        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .PCPlus4W(PCPlus4W),
        .RdW(RdW)
    );

endmodule
