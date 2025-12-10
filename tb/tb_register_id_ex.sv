module tb_register_id_ex;

    logic clk;
    logic reset;
    logic FlushE;

    logic [31:0] PCD, PCPlus4D, RD1D, RD2D, ImmExtD;
    logic [4:0] Rs1D, Rs2D, RdD;
    logic RegWriteD, MemWriteD, JumpD, BranchD, ALUSrcD;
    logic [1:0] ResultSrcD;
    logic [2:0] ALUControlD;


    logic [31:0] PCE, PCPlus4E, RD1E, RD2E, ImmExtE;
    logic [4:0] Rs1E, Rs2E, RdE;
    logic RegWriteE, MemWriteE, JumpE, BranchE, ALUSrcE;
    logic [1:0] ResultSrcE;
    logic [2:0] ALUControlE;

    // Instancia del DUT
    register_id_ex dut (
        .clk(clk),
        .reset(reset),
        .FlushE(FlushE),
        .PCD(PCD),
        .PCPlus4D(PCPlus4D),
        .RD1D(RD1D),
        .RD2D(RD2D),
        .ImmExtD(ImmExtD),
        .Rs1D(Rs1D), .Rs2D(Rs2D), .RdD(RdD),
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
        .Rs1E(Rs1E), .Rs2E(Rs2E), .RdE(RdE),
        .RegWriteE(RegWriteE),
        .ResultSrcE(ResultSrcE),
        .MemWriteE(MemWriteE),
        .JumpE(JumpE),
        .BranchE(BranchE),
        .ALUControlE(ALUControlE),
        .ALUSrcE(ALUSrcE)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin

        reset = 1; FlushE = 0;
        PCD = 32'h00000000; PCPlus4D = 32'h00000004;
        RD1D = 32'h11111111; RD2D = 32'h22222222; ImmExtD = 32'h0000ABCD;
        Rs1D = 5'd1; Rs2D = 5'd2; RdD = 5'd3;
        RegWriteD = 0; ResultSrcD = 2'b00; MemWriteD = 0;
        JumpD = 0; BranchD = 0; ALUControlD = 3'b000; ALUSrcD = 0;


        #12;
        reset = 0;

        #10;
        PCD = 32'h10000000; PCPlus4D = 32'h10000004;
        RD1D = 32'hAAAA0001; RD2D = 32'hAAAA0002; ImmExtD = 32'h00001234;
        Rs1D = 5'd8; Rs2D = 5'd9; RdD = 5'd10;
        RegWriteD = 1; ResultSrcD = 2'b01; MemWriteD = 0;
        JumpD = 1; BranchD = 0; ALUControlD = 3'b011; ALUSrcD = 1;

        #10;
        PCD = 32'h10000004; PCPlus4D = 32'h10000008;
        RD1D = 32'hBBBB0001; RD2D = 32'hBBBB0002; ImmExtD = 32'h00005678;
        Rs1D = 5'd12; Rs2D = 5'd13; RdD = 5'd14;
        RegWriteD = 0; ResultSrcD = 2'b10; MemWriteD = 1;
        JumpD = 0; BranchD = 1; ALUControlD = 3'b110; ALUSrcD = 0;

        #10;
        FlushE = 1;

        #10;
        FlushE = 0;

        #10;
        PCD = 32'h20000000; PCPlus4D = 32'h20000004;
        RD1D = 32'hCCCC0001; RD2D = 32'hCCCC0002; ImmExtD = 32'h0000DCBA;
        Rs1D = 5'd16; Rs2D = 5'd17; RdD = 5'd18;
        RegWriteD = 1; ResultSrcD = 2'b11; MemWriteD = 0;
        JumpD = 1; BranchD = 1; ALUControlD = 3'b111; ALUSrcD = 1;

        #10;
        $finish;
    end

    initial begin
        $display("Time | reset | FlushE | PCD | PCPlus4D | RD1D | RD2D | ImmExtD | Rs1D | Rs2D | RdD | RegWriteD | ResultSrcD | MemWriteD | JumpD | BranchD | ALUControlD | ALUSrcD | ...");
        $monitor("%4t | %b | %b | %h | %h | %h | %h | %h | %d | %d | %d | %b | %b | %b | %b | %b | %b | %b | ...", $time, reset, FlushE, PCD, PCPlus4D, RD1D, RD2D, ImmExtD, Rs1D, Rs2D, RdD, RegWriteD, ResultSrcD, MemWriteD, JumpD, BranchD, ALUControlD, ALUSrcD);
    end

    initial begin
        $dumpfile("tb_register_id_ex_waves.vcd");
        $dumpvars(0, tb_register_id_ex);
    end

endmodule
