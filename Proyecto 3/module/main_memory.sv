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

  reg [DATA_W-1:0] mem [0:65535]; // 64K palabras (Ojo: enunciado pide 65KB total, esto es 256KB, pero válido para simulación)
  integer i;
  integer wait_cnt;

  initial begin
    for (i=0; i<65536; i=i+1) mem[i] = i[DATA_W-1:0];
  end

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      ready    <= 1'b1;
      done     <= 1'b0;
      wait_cnt <= 0;
      rdata    <= {DATA_W{1'b0}};
    end else begin
      done <= 1'b0;
      if (req && ready) begin
        ready    <= 1'b0;
        wait_cnt <= LATENCY;
      end else if (!ready) begin
        if (wait_cnt==0) begin
          ready <= 1'b1;
          done  <= 1'b1;
          if (we) mem[addr] <= wdata;
          rdata <= mem[addr];
        end else begin
          wait_cnt <= wait_cnt - 1;
        end
      end
    end
  end
endmodule