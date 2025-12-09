module datapath_fetch_decode (
    input  logic        clk,
    input  logic        reset,
    input  logic        StallF,
    input  logic        FlushD,
    input  logic        StallD,
    input  logic        PCSrcE,
    input  logic [31:0] PCTargetE,
    input  logic        FlushE,
    input  logic        RegWriteW,
    input  logic [4:0]  RdW,
    input  logic [31:0] ResultW,

    // Señales de control desde unidad de control
    input  logic        RegWriteD,
    input  logic [1:0]  ResultSrcD,
    input  logic        MemWriteD,
    input  logic        JumpD,
    input  logic        BranchD,
    input  logic [2:0]  ALUControlD,
    input  logic        ALUSrcD,
    input  logic [1:0]  ImmSrcD,

    // Salidas hacia EX
    output logic [31:0] RD1E,
    output logic [31:0] RD2E,
    output logic [31:0] ImmExtE,
    output logic [31:0] PCE,
    output logic [31:0] PCPlus4E,
    output logic [4:0]  Rs1E, Rs2E, RdE,
    output logic        RegWriteE,
    output logic [1:0]  ResultSrcE,
    output logic        MemWriteE,
    output logic        JumpE,
    output logic        BranchE,
    output logic [2:0]  ALUControlE,
    output logic        ALUSrcE,
    output logic [2:0]  funct3E,
    output logic [6:0]  funct7E,
    output logic [6:0]  op,
    output logic [31:0] InstrD
);

    // Interconexión entre etapas
    logic [31:0] PCD, PCPlus4D;

    // --- FETCH ---
    logic [31:0] PCF, PCF_next;
    logic [31:0] PCPlus4F;
    logic [31:0] RD;

    mux21 mux_pc_next (
        .a(PCPlus4F),
        .b(PCTargetE),
        .sel(PCSrcE),
        .f(PCF_next)
    );

    pc pc_reg (
        .clk(clk),
        .reset(reset),
        .StallF(StallF),
        .pc_in(PCF_next),
        .pc_out(PCF)
    );

    instruction_memory instr_mem (
        .address(PCF),
        .instruction(RD)
    );

    adder pc_adder (
        .in1(PCF),
        .in2(32'd4),
        .out(PCPlus4F)
    );

    register_if_id reg_if_id (
        .clk(clk),
        .reset(reset),
        .StallD(StallD),
        .FlushD(FlushD),
        .PCF(PCF),
        .PCPlus4F(PCPlus4F),
        .RD(RD),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .InstrD(InstrD)
    );

    // --- DECODE ---
    logic [4:0] Rs1D, Rs2D, RdD;
    logic [31:0] RD1D, RD2D;
    logic [31:0] ImmExtD;

    assign Rs1D = InstrD[19:15];
    assign Rs2D = InstrD[24:20];
    assign RdD  = InstrD[11:7];
    assign funct3D = InstrD[14:12];
    assign funct7D = InstrD[31:25];
    assign op = InstrD[6:0]; // opcode: bits [6:0]

    Reg_Bank reg_bank_inst (
        .clk(clk),
        .rst(reset),
        .WE3(RegWriteW),
        .A1(Rs1D),
        .A2(Rs2D),
        .A3(RdW),
        .WD3(ResultW),
        .RD1(RD1D),
        .RD2(RD2D)
    );

    ImmGen immgen_inst (
        .instruction(InstrD),
        .immSel(ImmSrcD),
        .Imm(ImmExtD)
    );

    register_id_ex reg_id_ex_inst (
        .clk(clk),
        .reset(reset),
        .FlushE(FlushE),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .ImmExtD(ImmExtD),
        .Rs1D(Rs1D),
        .Rs2D(Rs2D),
        .RdD(RdD),
        .funct3D(funct3E),
        .funct7D(funct7E),
        .RegWriteD(RegWriteD),
        .ResultSrcD(ResultSrcD),
        .MemWriteD(MemWriteD),
        .JumpD(JumpD),
        .BranchD(BranchD),
        .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD),
        .PCE(PCE),
        .PCPlus4E(PCPlus4E),
        .RD1E(RD1E),
        .RD2E(RD2E),
        .ImmExtE(ImmExtE),
        .Rs1E(Rs1E),
        .Rs2E(Rs2E),
        .RdE(RdE),
        .funct3E(funct3E),
        .funct7E(funct7E),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE)
    );

endmodule
