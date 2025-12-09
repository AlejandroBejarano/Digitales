module datapath_execute (
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  ForwardAE,
    input  logic [1:0]  ForwardBE,
    input  logic [2:0]  ALUControlE,

    // Entradas desde ID/EX
    input  logic [31:0] RD1E,
    input  logic [31:0] RD2E,
    input  logic [31:0] ImmExtE,
    input  logic [31:0] PCE,
    input  logic [31:0] PCPlus4E,
    input  logic [4:0]  Rs1E, Rs2E, RdE,
    input  logic        RegWriteE,
    input  logic [1:0]  ResultSrcE,
    input  logic        MemWriteE,
    input  logic [2:0]  funct3E,
    input  logic [6:0]  funct7E,


    // Entradas para reenvío (forwarding)
    input  logic [31:0] ResultW,

    // Salidas hacia etapa MEM
    output logic [31:0] ALUResultM,
    output logic [31:0] WriteDataM,
    output logic [31:0] PCPlus4M,
    output logic [4:0]  RdM,
    output logic        RegWriteM,
    output logic [1:0]  ResultSrcM,
    output logic        MemWriteM,

    // Salida de dirección de salto hacia etapa IF
    output logic [31:0] PCTargetE,
    output logic        ZeroE
);

    logic [31:0] SrcAE, SrcM312, SrcBE;

    // MUX31 para SrcAE
    mux31 mux_forwardA (
        .a(RD1E),
        .b(ResultW),
        .c(ALUResultM),
        .sel(ForwardAE),
        .f(SrcAE)
    );

    // MUX31 para SrcM312 (previo a MUX21)
    mux31 mux_forwardB (
        .a(RD2E),
        .b(ResultW),
        .c(ALUResultM),
        .sel(ForwardBE),
        .f(SrcM312)
    );

    // MUX21 para seleccionar entre SrcM312 y ImmExtE
    mux21 mux_alu_srcB (
        .a(SrcM312),
        .b(ImmExtE),
        .sel(ALUSrcE),
        .f(SrcBE)
    );

    // ALU
    logic [31:0] ALUResultE;
    ALU alu_inst (
        .operand1(SrcAE),
        .operand2(SrcBE),
        .funct3(funct3E),
        .funct7(funct7E),
        .ALUControl(ALUControlE),
        .zero(ZeroE),
        .result(ALUResultE)
    );

    // Adder para dirección de salto
    adder pc_target_adder (
        .in1(PCE),
        .in2(ImmExtE),
        .out(PCTargetE)
    );

    // Registro EX/MEM
    register_ex_mem reg_ex_mem_inst (
        .clk(clk),
        .reset(reset),
        .ALUResultE(ALUResultE),
        .WriteDataE(SrcM312),  // WriteDataE <- RD2E modificado por forwarding
        .PCPlus4E(PCPlus4E),
        .RdE(RdE),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM)
    );

endmodule
