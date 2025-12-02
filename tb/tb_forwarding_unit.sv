
// sim/tb_forwarding_unit.sv
`timescale 1ns / 1ps

module tb_forwarding_unit;

    // Entradas
    logic [4:0] Rs1E, Rs2E;
    logic [4:0] RdM, RdW;
    logic       RegWriteM, RegWriteW;

    // Salidas
    logic [1:0] ForwardAE, ForwardBE;

    // Instancia del módulo
    forwarding_unit uut (
        .Rs1E(Rs1E), .Rs2E(Rs2E),
        .RdM(RdM), .RdW(RdW),
        .RegWriteM(RegWriteM), .RegWriteW(RegWriteW),
        .ForwardAE(ForwardAE), .ForwardBE(ForwardBE)
    );

    initial begin
        $dumpfile("sim/vcd/tb_forwarding_unit.vcd");
        $dumpvars(0, tb_forwarding_unit);

        // Caso 1: Sin forwarding
        Rs1E = 5'd1; Rs2E = 5'd2;
        RdM  = 5'd0; RdW  = 5'd0;
        RegWriteM = 0; RegWriteW = 0;
        #10;

        // Caso 2: Forward desde MEM a Rs1E
        Rs1E = 5'd5; Rs2E = 5'd2;
        RdM  = 5'd5; RdW  = 5'd0;
        RegWriteM = 1; RegWriteW = 0;
        #10;

        // Caso 3: Forward desde MEM a Rs2E
        Rs1E = 5'd1; Rs2E = 5'd6;
        RdM  = 5'd6; RdW  = 5'd0;
        RegWriteM = 1; RegWriteW = 0;
        #10;

        // Caso 4: Forward desde WB a Rs1E (sin conflicto con MEM)
        Rs1E = 5'd3; Rs2E = 5'd2;
        RdM  = 5'd0; RdW  = 5'd3;
        RegWriteM = 0; RegWriteW = 1;
        #10;

        // Caso 5: Forward desde WB a Rs2E (sin conflicto con MEM)
        Rs1E = 5'd1; Rs2E = 5'd4;
        RdM  = 5'd0; RdW  = 5'd4;
        RegWriteM = 0; RegWriteW = 1;
        #10;

        // Caso 6: RdM y RdW apuntan al mismo destino, se debe priorizar MEM
        Rs1E = 5'd7; Rs2E = 5'd8;
        RdM  = 5'd7; RdW  = 5'd7;
        RegWriteM = 1; RegWriteW = 1;
        #10;

        $display("Testbench finalizado.");
        $finish;
    end

endmodule
