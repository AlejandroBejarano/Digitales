
module hazard_unit (
    input  logic [4:0]  Rs1D, Rs2D,   // Registros fuente en ID
    input  logic [4:0]  RdE,          // Registro destino en EX
    input  logic [1:0]  ResultSrcE,   // Determina si es un lw (ResultSrcE == 2'b01)
    input  logic        PCSrcE,       // Indica si se tomó un salto real (branch o jump)
    output logic        StallF,       // Stall para IF
    output logic        StallD,       // Stall para ID
    output logic        FlushD,       // Flush para IF/ID
    output logic        FlushE        // Flush para ID/EX
);
    logic lwStall;

    // Detectar si la instrucción en EX es un lw que causa una dependencia
    assign lwStall = (ResultSrcE == 2'b01) && 
                     ((RdE != 0) && ((RdE == Rs1D) || (RdE == Rs2D)));

    // Stall por dependencia con lw
    assign StallF = lwStall;
    assign StallD = lwStall;
    // Flush por lw hazard o por branch/jump efectivo
    assign FlushE = lwStall || PCSrcE;
    // Flush del registro IF/ID solo si hay branch/jump efectivo
    assign FlushD = PCSrcE;

endmodule