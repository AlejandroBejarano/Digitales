module datapath_mul (
    input  logic        clk,
    input  logic        reset,
    input  logic [1:0]  ImmSrcD,
    input  logic        RegWriteD,
    input  logic [1:0]  ResultSrcD,
    input  logic        MemWriteD,
    input  logic        JumpD,
    input  logic        BranchD,
    input  logic [2:0]  ALUControlD,
    input  logic        ALUSrcD,
    input  logic        RegWriteW_en,
    input  logic [4:0]  RdW_en, // No se utiliza internamente
    input  logic        PCSrcE,

    output logic [31:0] ResultW,
    output logic [4:0]  RdW,
    output logic        RegWriteW,
    output logic [6:0]  op,
    output logic [2:0]  funct3,
    output logic [6:0]  funct7,
    output logic        ZeroE, 
    output logic        BranchE,
    output logic        JumpE
);
    // Señales de Decode
    logic [31:0] InstrD;

    // Señales internas ETAPA DE EXECUTE
    logic [31:0] RD1E, RD2E, ImmExtE, PCE, PCPlus4E;
    logic [4:0] Rs1E, Rs2E, RdE;
    logic RegWriteE, MemWriteE;
    logic [1:0] ResultSrcE;
    logic [31:0] PCTargetE;

    // Señales internas de ETAPA MEM
    logic [31:0] ALUResultM, WriteDataM, PCPlus4M;
    logic [4:0] RdM;
    logic RegWriteM, MemWriteM;
    logic [1:0] ResultSrcM;

    // Señales internas de ETAPA WB
    logic [31:0] ALUResultW, ReadDataW, PCPlus4W;
    logic [1:0] ResultSrcW_int;

    // Señales de ETAPA DECODE
    logic [4:0] Rs1D, Rs2D;

    // FORWARDING UNIT
    logic [1:0] ForwardAE, ForwardBE;

    // HAZARD UNIT
    logic StallF, StallD, FlushD, FlushE;

    //Para señales de control etapa EXECUTE
    logic [2:0]  ALUControlE;
    logic ALUSrcE;

    // Hazard Unit
    hazard_unit hazard_unit_inst (
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdE(RdE),
        .ResultSrcE(ResultSrcE),
        .PCSrcE(PCSrcE),
        .StallF(StallF),
        .StallD(StallD),
        .FlushD(FlushD),
        .FlushE(FlushE)
    );

    // Forwarding Unit
    forwarding_unit forwarding_unit_inst (
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdM(RdM),
        .RdW(RdW),
        .RegWriteM(RegWriteM),
        .RegWriteW(RegWriteW),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE)
    );

    // Datapath principal
    datapath_fetch_decode fetch_decode (
        .clk(clk),
        .reset(reset),
        .StallF(StallF),
        .FlushD(FlushD),
        .StallD(StallD),
        .PCSrcE(PCSrcE),
        .PCTargetE(PCTargetE),
        .FlushE(FlushE),
        .ImmSrcD(ImmSrcD),
        .RegWriteW(RegWriteW),
        .RdW(RdW),
        .ResultW(ResultW),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .ImmExtE(ImmExtE),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .funct3E(funct3),
        .funct7E(funct7),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE),
        .InstrD(InstrD)
    );

    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];

    assign op     = InstrD[6:0];       // opcode: bits [6:0]


    datapath_execute execute (
        .clk(clk),
        .reset(reset),
        .ForwardAE(ForwardAE),
        .ForwardBE(ForwardBE),
        .ALUControlE(ALUControlE),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .ImmExtE(ImmExtE),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .funct3E(funct3),
        .funct7E(funct7),
        .ResultW(ResultW),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .PCTargetE(PCTargetE),
        .ZeroE(ZeroE)
    );

    datapath_mem mem_stage (
        .clk(clk),
        .reset(reset),
        .RegWriteM(RegWriteM),
        .ResultSrcM(ResultSrcM),
        .MemWriteM(MemWriteM),
        .ALUResultM(ALUResultM),
        .WriteDataM(WriteDataM),
        .PCPlus4M(PCPlus4M),
        .RdM(RdM),
        .RegWriteW(RegWriteW),
        .ResultSrcW(ResultSrcW_int),
        .ALUResultW(ALUResultW),
        .ReadDataW(ReadDataW),
        .PCPlus4W(PCPlus4W),
        .RdW(RdW)
    );

    mux31 mux_result_wb (
        .a(ALUResultW),
        .b(ReadDataW),
        .c(PCPlus4W),
        .sel(ResultSrcW_int),
        .f(ResultW)
    );

endmodule