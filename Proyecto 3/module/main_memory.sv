module main_memory
#(
  parameter integer ADDR_W  = 16,
 -18,7 +15,7 @@ module main_memory
  output reg  [DATA_W-1:0]    rdata
);

  reg [DATA_W-1:0] mem [0:65535];
  reg [DATA_W-1:0] mem [0:65535]; // 64K palabras (Ojo: enunciado pide 65KB total, esto es 256KB, pero válido para simulación)
  integer i;
  integer wait_cnt;

 -34,7 +31,6 @@ module main_memory
      rdata    <= {DATA_W{1'b0}};
    end else begin
      done <= 1'b0;

      if (req && ready) begin
        ready    <= 1'b0;
        wait_cnt <= LATENCY;
@@ -50,246 +46,4 @@ module main_memory
      end
    end
  end
endmodule


// ===========================================================
// CACHE: Direct-mapped 1KiB, bloque 32B (8 palabras)
// WRITE-THROUGH + NO-WRITE-ALLOCATE
// ===========================================================
module cache
#(
  parameter integer ADDR_W          = 16,
  parameter integer DATA_W          = 32,
  parameter integer BLOCK_BYTES     = 32,   // 32B
  parameter integer WORDS_PER_BLOCK = 8,    // 8 x 4B
  parameter integer INDEX_W         = 5     // 32 lines
)(
  input  wire                 clk,
  input  wire                 rst,

  // CPU
  input  wire                 cpu_req,
  input  wire                 cpu_we,
  input  wire [ADDR_W-1:0]    cpu_addr,
  input  wire [DATA_W-1:0]    cpu_wdata,
  output reg                  cpu_ready,
  output reg                  cpu_hit,
  output reg  [DATA_W-1:0]    cpu_rdata,

  // MEM
  output reg                  mem_req,
  output reg                  mem_we,
  output reg  [ADDR_W-1:0]    mem_addr,
  output reg  [DATA_W-1:0]    mem_wdata,
  input  wire                 mem_ready,
  input  wire                 mem_done,
  input  wire [DATA_W-1:0]    mem_rdata
);

  // Derivados
  localparam integer OFFSET_W = 5;                          // 32B = 2^5
  localparam integer TAG_W    = ADDR_W-INDEX_W-OFFSET_W;
  localparam integer LINES    = (1<<INDEX_W);

  // Campos de dirección (formas 100% compatibles)
  wire [TAG_W-1:0]   a_tag   = cpu_addr[ADDR_W-1 : INDEX_W+OFFSET_W];
  wire [INDEX_W-1:0] a_index = cpu_addr[INDEX_W+OFFSET_W-1 : OFFSET_W];
  wire [2:0]         a_word  = cpu_addr[4:2]; // 0..7

  // Arrays
  reg [TAG_W-1:0]  tag_array   [0:LINES-1];
  reg              valid_array [0:LINES-1];
  reg [DATA_W-1:0] data_array  [0:LINES-1][0:WORDS_PER_BLOCK-1];

  // FSM (codificación explícita)
  localparam [2:0] S_IDLE=3'd0, S_LOOKUP=3'd1, S_REF_ISSUE=3'd2,
                   S_REF_WAIT=3'd3, S_WR_HIT=3'd4, S_WR_BYP=3'd5;
  reg [2:0] state, nxt;
  reg [2:0] ref_cnt, ref_cnt_nxt;

  // Señales
  wire hit_now = valid_array[a_index] && (tag_array[a_index]==a_tag);

  // ---------------------------------------------------------
  // REGISTROS
  // ---------------------------------------------------------
  integer li, wi;
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      state       <= S_IDLE;
      ref_cnt     <= 3'd0;

      cpu_ready   <= 1'b0;
      cpu_hit     <= 1'b0;
      cpu_rdata   <= {DATA_W{1'b0}};

      mem_req     <= 1'b0;
      mem_we      <= 1'b0;
      mem_addr    <= {ADDR_W{1'b0}};
      mem_wdata   <= {DATA_W{1'b0}};

      for (li=0; li<LINES; li=li+1) begin
        valid_array[li] <= 1'b0;
        tag_array[li]   <= {TAG_W{1'b0}};
        for (wi=0; wi<WORDS_PER_BLOCK; wi=wi+1)
          data_array[li][wi] <= {DATA_W{1'b0}};
      end
    end else begin
      state   <= nxt;
      ref_cnt <= ref_cnt_nxt;

      // WRITE HIT: actualizar palabra en la línea
      if (state==S_LOOKUP && cpu_req && cpu_we && hit_now) begin
        data_array[a_index][a_word] <= cpu_wdata;
      end

      // REFILL: almacenar palabra recibida
      if (state==S_REF_ISSUE && mem_done) begin
        data_array[a_index][ref_cnt] <= mem_rdata;
      end

      // Fin de refill: validar línea y tag
      if (state==S_REF_ISSUE && mem_done && (ref_cnt==WORDS_PER_BLOCK-1)) begin
        tag_array[a_index]   <= a_tag;
        valid_array[a_index] <= 1'b1;
      end
    end
  end

  // ---------------------------------------------------------
  // COMBINACIONAL
  // ---------------------------------------------------------
  always @* begin
    // defaults
    nxt         = state;
    ref_cnt_nxt = ref_cnt;

    cpu_ready   = 1'b0;
    cpu_hit     = 1'b0;
    // mantener último valor de rdata salvo cuando entregamos
    cpu_rdata   = cpu_rdata;

    mem_req     = 1'b0;
    mem_we      = 1'b0;
    mem_addr    = mem_addr;
    mem_wdata   = mem_wdata;

    case (state)

      // -----------------------------------------------
      S_IDLE: begin
        if (cpu_req) nxt = S_LOOKUP;
      end

      // -----------------------------------------------
      S_LOOKUP: begin
        if (!cpu_we) begin
          // READ
          if (hit_now) begin
            cpu_ready = 1'b1;
            cpu_hit   = 1'b1;
            cpu_rdata = data_array[a_index][a_word];
            nxt       = S_IDLE;
          end else begin
            // MISS → pedir bloque (palabra 0)
            if (mem_ready) begin
              mem_req     = 1'b1;
              mem_we      = 1'b0;
              mem_addr    = {a_tag, a_index, 5'b0};
              ref_cnt_nxt = 3'd0;
              nxt         = S_REF_ISSUE;
            end else begin
              // esperar a que memoria esté lista
              nxt = S_REF_WAIT;
            end
          end
        end else begin
          // WRITE
          if (hit_now) begin
            // write-through
            mem_req   = 1'b1;
            mem_we    = 1'b1;
            mem_addr  = cpu_addr;
            mem_wdata = cpu_wdata;
            nxt       = S_WR_HIT;
          end else begin
            // write miss → bypass (no-allocate)
            mem_req   = 1'b1;
            mem_we    = 1'b1;
            mem_addr  = cpu_addr;
            mem_wdata = cpu_wdata;
            nxt       = S_WR_BYP;
          end
        end
      end

      // -----------------------------------------------
      // Esperar a que la RAM acepte (para primera palabra)
      S_REF_WAIT: begin
        if (mem_ready) begin
          mem_req     = 1'b1;
          mem_we      = 1'b0;
          mem_addr    = {a_tag, a_index, 5'b0};
          ref_cnt_nxt = 3'd0;
          nxt         = S_REF_ISSUE;
        end
      end

      // -----------------------------------------------
      // Ir pidiendo palabras del bloque; cada done trae una
      S_REF_ISSUE: begin
        // solicitud de la palabra actual ya se hizo en el ciclo de entrada
        if (mem_done) begin
          if (ref_cnt==WORDS_PER_BLOCK-1) begin
            // bloque completo
            cpu_ready = 1'b1;     // respondemos a la lectura original
            cpu_hit   = 1'b0;     // MISS
            cpu_rdata = data_array[a_index][a_word];
            nxt       = S_IDLE;
          end else begin
            // preparar siguiente palabra
            ref_cnt_nxt = ref_cnt + 3'd1;
            if (mem_ready) begin
              mem_req  = 1'b1;
              mem_we   = 1'b0;
              // dirección palabra siguiente del bloque
              mem_addr = {a_tag, a_index, 5'b0} + (ref_cnt + 3'd1);
              nxt      = S_REF_ISSUE; // seguimos en emisión
            end else begin
              nxt      = S_REF_WAIT;
            end
          end
        end else begin
          // mantener la última solicitud activa si mem_ready ya está en 1
          if (mem_ready) begin
            mem_req  = 1'b1;
            mem_we   = 1'b0;
            mem_addr = {a_tag, a_index, 5'b0} + ref_cnt;
          end
        end
      end

      // -----------------------------------------------
      S_WR_HIT: begin
        if (mem_done) begin
          cpu_ready = 1'b1;
          cpu_hit   = 1'b1;
          nxt       = S_IDLE;
        end
      end

      S_WR_BYP: begin
        if (mem_done) begin
          cpu_ready = 1'b1;
          cpu_hit   = 1'b0;
          nxt       = S_IDLE;
        end
      end

      default: begin
        nxt = S_IDLE;
      end
    endcase
  end
endmodule