// Testbench para memory_system_top
`timescale 1ns/1ps

module tb_sistema_top;
    localparam ADDR_W = 16;
    localparam DATA_W = 32;

    reg clk, rst;
    reg cpu_req, cpu_we;
    reg [ADDR_W-1:0] cpu_addr;
    reg [DATA_W-1:0] cpu_wdata;
    wire cpu_ready, cpu_hit;
    wire [DATA_W-1:0] cpu_rdata;

    // Instancia del DUT
    memory_system_top #(
        .ADDR_W(ADDR_W),
        .DATA_W(DATA_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .cpu_req(cpu_req),
        .cpu_we(cpu_we),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_ready(cpu_ready),
        .cpu_hit(cpu_hit),
        .cpu_rdata(cpu_rdata)
    );

    // Reloj
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_sistema_top.vcd");
        $dumpvars(0, tb_sistema_top);
        clk = 0; rst = 1; cpu_req = 0; cpu_we = 0; cpu_addr = 0; cpu_wdata = 0;
        #12;
        rst = 0;
        // Lectura de dirección 0x0010 (debe ser miss y refill)
        cpu_addr = 16'h0010; cpu_req = 1; cpu_we = 0;
        #10; cpu_req = 0;
        wait(cpu_ready);
        #10;
        // Escritura en dirección 0x0010 (debe ser hit)
        cpu_addr = 16'h0010; cpu_wdata = 32'h12345678; cpu_req = 1; cpu_we = 1;
        #10; cpu_req = 0;
        wait(cpu_ready);
        #10;
        // Lectura de dirección 0x0010 (debe ser hit)
        cpu_addr = 16'h0010; cpu_req = 1; cpu_we = 0;
        #10; cpu_req = 0;
        wait(cpu_ready);
        #10;
        // Lectura de dirección 0x0100 (debe ser miss y refill)
        cpu_addr = 16'h0100; cpu_req = 1; cpu_we = 0;
        #10; cpu_req = 0;
        wait(cpu_ready);
        #10;
        $finish;
    end
endmodule
