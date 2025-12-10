module main_memory
#(
  parameter integer ADDR_W  = 16,
  parameter integer DATA_W  = 32,
  parameter integer LATENCY = 8
)(
  input  logic                 clk,
  input  logic                 rst,
  input  logic                 req,
  input  logic                 we,
  input  logic [ADDR_W-1:0]    addr,
  input  logic [DATA_W-1:0]    wdata,
  output reg                  ready,
  output reg                  done,
  output reg  [DATA_W-1:0]    rdata
);

  reg [DATA_W-1:0] mem [0:65535]; // 64K palabras
  integer i;
  integer wait_cnt;

  // Registros internos para "capturar" la transacción al inicio
  reg [ADDR_W-1:0] saved_addr;
  reg [DATA_W-1:0] saved_wdata;
  reg              saved_we;

  initial begin
    for (i=0; i<65536; i=i+1) mem[i] = i[DATA_W-1:0];
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ready    <= 1'b1;
      done     <= 1'b0;
      wait_cnt <= 0;
      rdata    <= {DATA_W{1'b0}};
      saved_addr <= {ADDR_W{1'b0}};
      saved_wdata <= {DATA_W{1'b0}};
      saved_we <= 1'b0;
    end else begin
      done <= 1'b0;
      if (req && ready) begin
        // Inicio de transacción: capturamos addr/we/wdata aquí
        ready    <= 1'b0;
        wait_cnt <= LATENCY;
        saved_addr  <= addr;
        saved_wdata <= wdata;
        saved_we    <= we;
      end else if (!ready) begin
        if (wait_cnt==0) begin
          ready <= 1'b1;
          done  <= 1'b1;
          if (saved_we) mem[saved_addr] <= saved_wdata;
          rdata <= mem[saved_addr];
        end else begin
          wait_cnt <= wait_cnt - 1;
        end
      end
    end
  end
endmodule