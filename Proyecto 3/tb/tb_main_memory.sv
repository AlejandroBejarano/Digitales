`timescale 1ns/1ps

module tb_main_memory;
    localparam ADDR_W = 16;
    localparam DATA_W = 32;
    localparam LATENCY = 8;

    reg clk, rst, req, we;
    reg [ADDR_W-1:0] addr;
    reg [DATA_W-1:0] wdata;
    wire ready, done;
    wire [DATA_W-1:0] rdata;

    main_memory #(
        .ADDR_W(ADDR_W),
        .DATA_W(DATA_W),
        .LATENCY(LATENCY)
    ) dut (
        .clk(clk),
        .rst(rst),
        .req(req),
        .we(we),
        .addr(addr),
        .wdata(wdata),
        .ready(ready),
        .done(done),
        .rdata(rdata)
    );

    // Reloj
    always #5 clk = ~clk;

    initial begin
        $dumpfile("tb_main_memory.vcd");
        $dumpvars(0, tb_main_memory);
        clk = 0; rst = 1; req = 0; we = 0; addr = 0; wdata = 0;
        #12;
        rst = 0;
        // Lectura de dirección 100
        addr = 16'd100; req = 1; we = 0;
        #10;
        req = 0;
        wait(done);
        #10;
        // Escritura en dirección 200
        addr = 16'd200; wdata = 32'hA5A5A5A5; req = 1; we = 1;
        #10;
        req = 0;
        wait(done);
        #10;
        // Lectura de dirección 200
        addr = 16'd200; req = 1; we = 0;
        #10;
        req = 0;
        wait(done);
        #10;
        $finish;
    end
endmodule
