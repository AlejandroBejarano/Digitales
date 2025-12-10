module cpu(
    input  logic        clk,
    input  logic        reset,
    output logic [31:0] WB_Result_Out, // Para visualizar resultado final en TB
    output logic [31:0] PC_Out         // Para visualizar PC actual
);

    // ===========================================================================
    // 1. Declaración de Wires (Cables) por Etapa
    // ===========================================================================

    // --- Hazard & Control Wires ---
    logic StallF, StallD, FlushD, FlushE;
    logic [1:0] ForwardAE, ForwardBE;
    logic PCSrcE; // Señal calculada en etapa EX

    // --- Fetch (IF) Wires ---
    logic [31:0] PCF, PCF_Next, PCPlus4F, InstrF;

    // --- Decode (ID) Wires ---
    logic [31:0] InstrD, PCD, PCPlus4D;
    logic [31:0] RD1D, RD2D, ImmExtD;
    logic [31:0] ResultW; // Viene de WB
    // Señales de Control ID
    logic RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
    logic [1:0] ResultSrcD, ImmSrcD;
    logic [2:0] ALUControlD;

    // --- Execute (EX) Wires ---
    logic [31:0] PCE, PCPlus4E, RD1E, RD2E, ImmExtE;
    logic [31:0] PCTargetE, SrcAE, SrcBE, ALUResultE, WriteDataE;
    logic [31:0] MuxSrcBE_Out; // Salida intermedia Mux Forward B
    logic ZeroE;
    logic [4:0] Rs1E, Rs2E, RdE;
    // Señales de Control EX
    logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE;
    logic [1:0] ResultSrcE;
    logic [2:0] ALUControlE;

    // --- Memory (MEM) Wires ---
    logic [31:0] ALUResultM, WriteDataM, PCPlus4M, ReadDataM;
    logic [4:0] RdM;
    // Señales de Control MEM
    logic RegWriteM, MemWriteM;
    logic [1:0] ResultSrcM;

    // --- Write Back (WB) Wires ---
    logic [31:0] ALUResultW, ReadDataW, PCPlus4W;
    logic [4:0] RdW;
    logic RegWriteW;
    logic [1:0] ResultSrcW;

    // ===========================================================================
    // 2. Lógica de Riesgos (Hazard & Forwarding)
    // ===========================================================================

    hazard_unit hu (
        .Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]),
        .RdE(RdE),
        .ResultSrcE(ResultSrcE),
        .PCSrcE(PCSrcE),
        .StallF(StallF), .StallD(StallD),
        .FlushD(FlushD), .FlushE(FlushE)
    );

    forwarding_unit fu (
        .Rs1E(Rs1E), .Rs2E(Rs2E),
        .RdM(RdM), .RdW(RdW),
        .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );

    // ===========================================================================
    // 3. Etapa FETCH (IF)
    // ===========================================================================

    // Mux PC: Selecciona entre PC+4 y PC Objetivo (Saltos)
    mux21 #(32) mux_pc_src (
        .a(PCPlus4F),
        .b(PCTargetE),
        .sel(PCSrcE),
        .f(PCF_Next)
    );

    // Program Counter
    pc #(32) prog_counter (
        .clk(clk), .reset(reset),
        .StallF(StallF),
        .pc_in(PCF_Next),
        .pc_out(PCF)
    );

    // Instruction Memory
    instruction_memory #(32, 32, 256) imem (
        .address(PCF),
        .instruction(InstrF)
    );

    // Adder PC + 4
    adder #(32) pc_adder (
        .in1(PCF), .in2(32'd4),
        .out(PCPlus4F)
    );

    // Registro IF/ID
    register_if_id reg_if_id (
        .clk(clk), .reset(reset),
        .StallD(StallD), .FlushD(FlushD),
        .PCF(PCF), .PCPlus4F(PCPlus4F), .RD(InstrF),
        .PCD(PCD), .PCPlus4D(PCPlus4D), .InstrD(InstrD)
    );

    // ===========================================================================
    // 4. Etapa DECODE (ID)
    // ===========================================================================

    // Control Unit
    control_unit cu (
        .op(InstrD[6:0]), .funct3(InstrD[14:12]), .funct7(InstrD[31:25]),
        .RegWriteD(RegWriteD), .ResultSrcD(ResultSrcD), .MemWriteD(MemWriteD),
        .JumpD(JumpD), .BranchD(BranchD), .ALUControlD(ALUControlD),
        .ALUSrcD(ALUSrcD), .ImmSrcD(ImmSrcD)
    );

    // Register File
    Reg_Bank rf (
        .clk(clk), .rst(reset),
        .WE3(RegWriteW),
        .A1(InstrD[19:15]), .A2(InstrD[24:20]), .A3(RdW),
        .WD3(ResultW),
        .RD1(RD1D), .RD2(RD2D)
    );

    // Immediate Generator
    ImmGen ig (
        .instruction(InstrD), .immSel(ImmSrcD),
        .Imm(ImmExtD)
    );

    // Registro ID/EX
    register_id_ex reg_id_ex (
        .clk(clk), .reset(reset), .FlushE(FlushE),
        // Entradas Control
        .RegWriteD(RegWriteD), .ResultSrcD(ResultSrcD), .MemWriteD(MemWriteD),
        .JumpD(JumpD), .BranchD(BranchD), .ALUControlD(ALUControlD), .ALUSrcD(ALUSrcD),
        // Entradas Datos
        .PCD(PCD), .PCPlus4D(PCPlus4D), .RD1D(RD1D), .RD2D(RD2D), .ImmExtD(ImmExtD),
        .Rs1D(InstrD[19:15]), .Rs2D(InstrD[24:20]), .RdD(InstrD[11:7]),
        .funct3D(InstrD[14:12]), .funct7D(InstrD[31:25]),
        // Salidas Control
        .RegWriteE(RegWriteE), .ResultSrcE(ResultSrcE), .MemWriteE(MemWriteE),
        .JumpE(JumpE), .BranchE(BranchE), .ALUControlE(ALUControlE), .ALUSrcE(ALUSrcE),
        // Salidas Datos
        .PCE(PCE), .PCPlus4E(PCPlus4E), .RD1E(RD1E), .RD2E(RD2E), .ImmExtE(ImmExtE),
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE)
        // Nota: funct3E/7E se declaran pero no se usan en este top especifico, se dejan conectados por integridad del modulo
    );

    // ===========================================================================
    // 5. Etapa EXECUTE (EX)
    // ===========================================================================

    // Lógica del PCSrcE (Branch AND Zero OR Jump)
    assign PCSrcE = (BranchE & ZeroE) | JumpE;

    // Mux 3:1 A (Forwarding para SrcA)
    // 00: RD1E, 01: ResultW, 10: ALUResultM
    mux31 #(32) mux31A (
        .a(RD1E), .b(ResultW), .c(ALUResultM),
        .sel(ForwardAE),
        .f(SrcAE)
    );

    // Mux 3:1 B (Forwarding para Entrada B pre-ALU Mux)
    // 00: RD2E, 01: ResultW, 10: ALUResultM
    mux31 #(32) mux31B (
        .a(RD2E), .b(ResultW), .c(ALUResultM),
        .sel(ForwardBE),
        .f(WriteDataE) // Este dato es el que se escribe en Mem si hay store, y entra al Mux ALU Src
    );

    // Mux 2:1 (ALU Source B: Register/Forward vs Immediate)
    mux21 #(32) mux_alu_src (
        .a(WriteDataE), .b(ImmExtE),
        .sel(ALUSrcE),
        .f(SrcBE)
    );

    // ALU Principal
    ALU alu (
        .operand1(SrcAE), .operand2(SrcBE),
        .ALUControl(ALUControlE),
        .funct3(3'b000), .funct7(7'b0000000), // Asumimos control resuelto en ALUControl
        .result(ALUResultE),
        .zero(ZeroE)
    );

    // Adder para cálculo de saltos (Branch Target)
    adder #(32) branch_adder (
        .in1(PCE), .in2(ImmExtE),
        .out(PCTargetE)
    );

    // Registro EX/MEM
    register_ex_mem reg_ex_mem (
        .clk(clk), .reset(reset),
        // Control
        .RegWriteE(RegWriteE), .ResultSrcE(ResultSrcE), .MemWriteE(MemWriteE),
        // Datos
        .ALUResultE(ALUResultE), .WriteDataE(WriteDataE), .PCPlus4E(PCPlus4E), .RdE(RdE),
        // Salidas
        .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM), .MemWriteM(MemWriteM),
        .ALUResultM(ALUResultM), .WriteDataM(WriteDataM), .PCPlus4M(PCPlus4M), .RdM(RdM)
    );

    // ===========================================================================
    // 6. Etapa MEMORY (MEM)
    // ===========================================================================

    // Data Memory
    data_memory #(32, 32, 256) dmem (
        .clk(clk), .reset(reset),
        .WE(MemWriteM),
        .A(ALUResultM),
        .WD(WriteDataM),
        .RD(ReadDataM)
    );

    // Registro MEM/WB
    register_mem_wb reg_mem_wb (
        .clk(clk), .reset(reset),
        // Entradas
        .RegWriteM(RegWriteM), .ResultSrcM(ResultSrcM),
        .ALUResultM(ALUResultM), .RD(ReadDataM), .PCPlus4M(PCPlus4M), .RdM(RdM),
        // Salidas
        .RegWriteW(RegWriteW), .ResultSrcW(ResultSrcW),
        .ALUResultW(ALUResultW), .ReadDataW(ReadDataW), .PCPlus4W(PCPlus4W), .RdW(RdW)
    );

    // ===========================================================================
    // 7. Etapa WRITE BACK (WB)
    // ===========================================================================

    // Mux Final (Result Source)
    // 00: ALUResultW, 01: ReadDataW, 10: PCPlus4W
    mux31 #(32) mux31C (
        .a(ALUResultW), .b(ReadDataW), .c(PCPlus4W),
        .sel(ResultSrcW),
        .f(ResultW)
    );

    // Asignación de salidas de depuración
    assign WB_Result_Out = ResultW;
    assign PC_Out = PCF;

endmodule