module tb_register_if_id;

    // Entradas
    logic clk;
    logic reset;
    logic StallD;
    logic FlushD;
    logic [31:0] PCF;
    logic [31:0] PCPlus4F;
    logic [31:0] RD;

    // Salidas
    logic [31:0] PCD;
    logic [31:0] PCPlus4D;
    logic [31:0] InstrD;

    // Instancia del DUT (Device Under Test)
    register_if_id dut (
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

    // Reloj de 10ns
    initial clk = 0;
    always #5 clk = ~clk;


        // Generar archivo de ondas
    initial begin
        $dumpfile("tb_register_if_id_waves.vcd");
        $dumpvars(0, tb_register_if_id);
    end

    // Estímulos de prueba
    initial begin
        $display("=== Testbench: register_if_id ===");
        // Inicializa entradas
        reset = 1; StallD = 0; FlushD = 0;
        PCF = 32'h00000000; PCPlus4F = 32'h00000004; RD = 32'hAABBCCDD;

        // Reset activo
        #12;
        reset = 0;

        // Avance normal
        #10;
        PCF = 32'h10000000; PCPlus4F = 32'h10000004; RD = 32'h11112222;

        #10;
        PCF = 32'h10000004; PCPlus4F = 32'h10000008; RD = 32'h33334444;

        // Stall (no debe cambiar las salidas)
        #10;
        StallD = 1;
        PCF = 32'h20000000; PCPlus4F = 32'h20000004; RD = 32'hDEADBEEF;

        #10;
        StallD = 0;

        // Flush (debe poner a cero las salidas)
        #10;
        FlushD = 1;

        #10;
        FlushD = 0;

        // Avance normal nuevamente
        #10;
        PCF = 32'h12345678; PCPlus4F = 32'h1234567C; RD = 32'h87654321;

        #10;
        $finish;
    end

    // Para ver las señales en consola
    initial begin
        $monitor("T=%0t | reset=%b StallD=%b FlushD=%b | PCF=%h PCPlus4F=%h RD=%h | PCD=%h PCPlus4D=%h InstrD=%h",
                 $time, reset, StallD, FlushD, PCF, PCPlus4F, RD, PCD, PCPlus4D, InstrD);
    end

endmodule
