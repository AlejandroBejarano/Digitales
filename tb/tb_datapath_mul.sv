`timescale 1ns / 1ps

module tb_datapath_mul();

    logic clk, reset;
    logic [31:0] ResultW;
    logic [4:0]  RdW;
    logic        RegWriteW;
    logic [1:0]  ImmSrcD;
    logic        RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
    logic [2:0]  ALUControlD;
    logic [1:0]  ResultSrcD;
    logic [4:0]  RdW_en;
    logic        RegWriteW_en;
    logic        PCSrcE;
    logic        ZeroE, BranchE, JumpE;
    logic [6:0]  op;
    logic [2:0]  funct3;
    logic [6:0]  funct7;

    datapath_mul uut (
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
        .RegWriteW_en(RegWriteW_en),
        .RdW_en(RdW_en),
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

    // Reloj
    always #5 clk = ~clk;

    initial begin
        $dumpfile("cpu_tb.vcd");
        $dumpvars(0, tb_datapath_mul);
        clk = 0;
        reset = 1;
        RegWriteD = 0;
        MemWriteD = 0;
        JumpD = 0;
        BranchD = 0;
        ALUSrcD = 0;
        ALUControlD = 3'b000;
        ResultSrcD = 2'b00;
        ImmSrcD = 2'b00;
        RdW_en = 5'b00000;
        RegWriteW_en = 0;
        PCSrcE = 0;

        // Reset
        #10 reset = 0;

        // Esperar suficiente tiempo para ejecutar el programa
        #500;


        $finish;
    end

endmodule
