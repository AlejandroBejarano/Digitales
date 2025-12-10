`timescale 1ns/1ps
module tb;

  reg         clk=0, rst=1;
  reg         cpu_req=0, cpu_we=0;
  reg  [15:0] cpu_addr=16'h0000;
  reg  [31:0] cpu_wdata=32'h0;
  wire        cpu_ready, cpu_hit;
  wire [31:0] cpu_rdata;

  wire        mem_req, mem_we, mem_ready, mem_done;
  wire [15:0] mem_addr;
  wire [31:0] mem_wdata, mem_rdata;

  // DUTs
  cache DUT(
    .clk(clk), .rst(rst),
    .cpu_req(cpu_req), .cpu_we(cpu_we),
    .cpu_addr(cpu_addr), .cpu_wdata(cpu_wdata),
    .cpu_ready(cpu_ready), .cpu_hit(cpu_hit), .cpu_rdata(cpu_rdata),
    .mem_req(mem_req), .mem_we(mem_we), .mem_addr(mem_addr),
    .mem_wdata(mem_wdata), .mem_ready(mem_ready), .mem_done(mem_done),
    .mem_rdata(mem_rdata)
  );

  main_memory MEM(
    .clk(clk), .rst(rst),
    .req(mem_req), .we(mem_we), .addr(mem_addr), .wdata(mem_wdata),
    .ready(mem_ready), .done(mem_done), .rdata(mem_rdata)
  );

  // Clock
  always #5 clk = ~clk;

  // VCD para EPWave
  initial begin
    $dumpfile("waves.vcd");
    $dumpvars(0, tb);
    $dumpvars(0, tb.DUT);
    $dumpvars(0, tb.MEM);
  end

  // Helpers
  task READ(input [15:0] A);
    begin
      @(posedge clk);
      cpu_addr = A; cpu_we = 0; cpu_req = 1;
      @(posedge clk);
      cpu_req = 0;
      wait(cpu_ready);
      $display("[%0t] READ  @%h -> %h  (%s)",
               $time, A, cpu_rdata, cpu_hit ? "HIT":"MISS");
    end
  endtask

  task WRITE(input [15:0] A, input [31:0] D);
    begin
      @(posedge clk);
      cpu_addr = A; cpu_wdata = D; cpu_we = 1; cpu_req = 1;
      @(posedge clk);
      cpu_req = 0;
      wait(cpu_ready);
      $display("[%0t] WRITE @%h = %h  (%s)",
               $time, A, D, cpu_hit ? "HIT":"MISS");
      cpu_we = 0;
    end
  endtask

  // Estímulos
  initial begin
    repeat(3) @(posedge clk);
    rst = 0;

    // MISS -> REFILL -> HIT
    READ(16'h1000);   // miss
    READ(16'h1000);   // hit

    // Conflicto de índice (tag distinto, mismo índice)
    READ(16'h1800);   // miss (puede expulsar 0x1000)
    READ(16'h1000);   // miss (si fue expulsada)
    READ(16'h1000);   // hit

    // Write-through
    WRITE(16'h1004, 32'hDEADBEEF); // hit si la línea está
    READ (16'h1004);               // debería leer DEADBEEF (hit)

    // Write miss (no-allocate)
    WRITE(16'h2000, 32'hAAAAAAAA); // miss y NO llena caché
    READ (16'h2000);               // miss; ahora se rellena

    #50 $finish;
  end

endmodule