module cpu_multiciclo (
    input  logic        clk,
    input  logic        reset,

    // Salidas observables
    output logic [31:0] ResultW,
    output logic [4:0]  RdW,
    output logic        RegWriteW,
    output logic        ZeroE
);

    // ----------------- Señales de control ------------------
    logic [6:0] op;
    logic [2:0] funct3;
    logic [6:0] funct7;

    logic        RegWriteD;
    logic [1:0]  ResultSrcD;
    logic        MemWriteD;
    logic        JumpD;
    logic        BranchD;
    logic [2:0]  ALUControlD;
    logic        ALUSrcD;
    logic [1:0]  ImmSrcD;
    logic       BranchE;
    logic       JumpE;

    logic        PCSrcE;

    // ----------------- Instancia del datapath ------------------
    datapath_mul datapath (
        .clk(clk),
        .reset(reset),
        .ImmSrcD(ImmSrcD),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .RegWriteW_en(RegWriteW),
        .RdW_en(RdW),
        .PCSrcE(PCSrcE),
        .ResultW(ResultW),
        .RdW(RdW),
        .RegWriteW(RegWriteW),
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .ZeroE(ZeroE),
        .BranchE(BranchE),
        .JumpE(JumpE)
    );

    // ----------------- Unidad de control ------------------
    control_unit cu (
        .op(op),
        .funct3(funct3),
        .funct7(funct7),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .ImmSrcD(ImmSrcD)
    );

    // ----------------- Lógica de salto (branch) ------------------
    assign PCSrcE = BranchE & ZeroE | JumpE;

endmodule