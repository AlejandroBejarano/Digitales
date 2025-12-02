
// sim/tb_hazard_unit.sv
`timescale 1ns / 1ps

module tb_hazard_unit;

    // Entradas
    logic [4:0] Rs1D, Rs2D;
    logic [4:0] RdE;
    logic [1:0] ResultSrcE;
    logic       PCSrcE;

    // Salidas
    logic       StallF, StallD, FlushD, FlushE;

    // Instancia del módulo bajo prueba
    hazard_unit uut (
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

    // Proceso de prueba
    initial begin
        $dumpfile("sim/vcd/tb_hazard_unit.vcd");
        $dumpvars(0, tb_hazard_unit);

        // Caso 1: Sin hazard, sin salto
        Rs1D = 5'd1; Rs2D = 5'd2; RdE = 5'd3; ResultSrcE = 2'b00; PCSrcE = 0;
        #10;

        // Caso 2: lw hazard por Rs1D
        Rs1D = 5'd5; Rs2D = 5'd0; RdE = 5'd5; ResultSrcE = 2'b01; PCSrcE = 0;
        #10;

        // Caso 3: lw hazard por Rs2D
        Rs1D = 5'd0; Rs2D = 5'd8; RdE = 5'd8; ResultSrcE = 2'b01; PCSrcE = 0;
        #10;

        // Caso 4: lw hazard con RdE = 0 (x0)
        Rs1D = 5'd1; Rs2D = 5'd2; RdE = 5'd0; ResultSrcE = 2'b01; PCSrcE = 0;
        #10;

        // Caso 5: Salto tomado (PCSrcE = 1)
        Rs1D = 5'd3; Rs2D = 5'd4; RdE = 5'd9; ResultSrcE = 2'b00; PCSrcE = 1;
        #10;

        // Caso 6: lw hazard + salto tomado
        Rs1D = 5'd9; Rs2D = 5'd4; RdE = 5'd9; ResultSrcE = 2'b01; PCSrcE = 1;
        #10;

        $display("Testbench finalizado.");
        $finish;
    end

endmodule
