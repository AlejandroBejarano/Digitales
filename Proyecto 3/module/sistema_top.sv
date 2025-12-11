module memory_system_top
#(
  parameter ADDR_W = 16,
  parameter DATA_W = 32
)(
  input  wire               clk,
  input  wire               rst,
  
  // Interfaz CPU
  input  wire               cpu_req,
  input  wire               cpu_we,
  input  wire [ADDR_W-1:0]  cpu_addr,
  input  wire [DATA_W-1:0]  cpu_wdata,
  output reg                cpu_ready,
  output reg                cpu_hit,    // Salida del Comparador
  output reg  [DATA_W-1:0]  cpu_rdata
);

  // ----------------------------------------------------
  // 1. Instanciación del Decodificador de Direcciones
  // ----------------------------------------------------
  wire [5:0] tag_cpu;
  wire [4:0] index_cpu;
  wire [2:0] word_cpu;
  
  address decoder_inst (
    .addr(cpu_addr),
    .tag(tag_cpu),
    .index(index_cpu),
    .word_sel(word_cpu)
  );

  // ----------------------------------------------------
  // 2. Cables y lógica interna
  // ----------------------------------------------------
  // Señales de Memoria Principal
  wire              mem_ready, mem_done;
  wire [DATA_W-1:0] mem_rdata;
  reg               mem_req_reg, mem_we_reg;
  reg [ADDR_W-1:0]  mem_addr_reg;
  reg [DATA_W-1:0]  mem_wdata_reg;

  // Señales Cache Storage
  wire [5:0]        tag_stored;
  wire              valid_stored;
  wire [DATA_W-1:0] cache_rdata;
  
  reg               c_we_data;
  reg               c_we_tag;
  reg [DATA_W-1:0]  c_wdata_mux; // MUX para dato de entrada a caché
  reg [2:0]         c_word_mux;  // MUX para seleccionar palabra (CPU vs Refill)

  // ----------------------------------------------------
  // 3. Comparador (El rombo en el diagrama)
  // ----------------------------------------------------
  // Hit = Tags iguales AND Bit Válido es 1
  wire hit_signal = (tag_cpu == tag_stored) && valid_stored;

  // ----------------------------------------------------
  // 4. Instanciación Cache Storage
  // ----------------------------------------------------
  cache cache_mem (
    .clk(clk), .rst(rst),
    .index(index_cpu),       // Siempre usamos el índice de la CPU
    .word_sel(c_word_mux),   // Seleccionado por FSM (acceso normal o refill)
    .we_data(c_we_data),
    .we_tag(c_we_tag),
    .tag_in(tag_cpu),
    .data_in(c_wdata_mux),
    .tag_out(tag_stored),
    .valid_out(valid_stored),
    .data_out(cache_rdata)
  );

  // ----------------------------------------------------
  // 5. Instanciación Main Memory
  // ----------------------------------------------------
  main_memory main_mem (
    .clk(clk), .rst(rst),
    .req(mem_req_reg),
    .we(mem_we_reg),
    .addr(mem_addr_reg),
    .wdata(mem_wdata_reg),
    .ready(mem_ready),
    .done(mem_done),
    .rdata(mem_rdata)
  );

  // ----------------------------------------------------
  // 6. Máquina de Estados (Control Logic)
  // ----------------------------------------------------
  localparam [2:0] S_IDLE=0, S_LOOKUP=1, S_REF_ISSUE=2, S_REF_WAIT=3, S_WR_HIT=4, S_WR_BYP=5;
  reg [2:0] state, nxt_state;
  reg [2:0] ref_cnt, nxt_ref_cnt; // Contador para refill de bloque

  always @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= S_IDLE;
        ref_cnt <= 0;
    end else begin
        state   <= nxt_state;
        ref_cnt <= nxt_ref_cnt;
    end
  end

  // Lógica Combinacional FSM
  always @* begin
    // Valores por defecto
    nxt_state   = state;
    nxt_ref_cnt = ref_cnt;
    
    cpu_ready   = 0;
    cpu_hit     = 0;
    cpu_rdata   = cache_rdata; // Por defecto sacamos dato de caché

    // Control de Memoria
    mem_req_reg   = 0;
    mem_we_reg    = 0;
    mem_addr_reg  = 0; // Se calculará abajo
    mem_wdata_reg = cpu_wdata;

    // Control de Caché
    c_we_data   = 0;
    c_we_tag    = 0;
    c_wdata_mux = cpu_wdata; // Por defecto dato de CPU
    c_word_mux  = word_cpu;  // Por defecto palabra solicitada por CPU

    case (state)
      S_IDLE: begin
        if (cpu_req) nxt_state = S_LOOKUP;
      end

      S_LOOKUP: begin
        if (!cpu_we) begin // --- LECTURA ---
          if (hit_signal) begin
            // HIT: Dato ya está en cache_rdata gracias a word_cpu
            cpu_ready = 1;
            cpu_hit   = 1;
            nxt_state = S_IDLE;
          end else begin
            // MISS: Iniciar Refill desde Memoria Principal
            if (mem_ready) begin
               mem_req_reg  = 1;
               mem_we_reg   = 0;
               // Dirección base del bloque: {Tag, Index, 00000}
               mem_addr_reg = {tag_cpu, index_cpu, 5'b00000};
               nxt_ref_cnt  = 0;
               nxt_state    = S_REF_ISSUE;
            end else begin
               nxt_state    = S_REF_WAIT;
            end
          end
        end else begin    // --- ESCRITURA ---
          // Write-Through: Siempre mandamos a memoria
          mem_req_reg   = 1;
          mem_we_reg    = 1;
          mem_addr_reg  = cpu_addr;
          mem_wdata_reg = cpu_wdata;
          
          if (hit_signal) begin
             // Write Hit: Actualizamos también la caché
             c_we_data   = 1;
             c_wdata_mux = cpu_wdata;
             c_word_mux  = word_cpu;
             nxt_state   = S_WR_HIT;
          end else begin
             // Write Miss: No-Allocate (Solo escribimos en memoria)
             nxt_state   = S_WR_BYP;
          end
        end
      end

      S_REF_WAIT: begin
         // Esperar si la memoria estaba ocupada
         if (mem_ready) begin
            mem_req_reg  = 1;
            mem_we_reg   = 0;
            mem_addr_reg = {tag_cpu, index_cpu, 5'b00000}; 
            nxt_ref_cnt  = 0;
            nxt_state    = S_REF_ISSUE;
         end
      end

      S_REF_ISSUE: begin
         // Estamos trayendo palabras de memoria (Diagrama: linea "Main Memory" -> Data)
         if (mem_done) begin
            // Guardar dato recibido en caché
            c_we_data   = 1;
            c_wdata_mux = mem_rdata; // MUX selecciona dato de Memoria
            c_word_mux  = ref_cnt;   // MUX selecciona palabra basada en contador

            if (ref_cnt == 7) begin // Fin del bloque (8 palabras)
                // Actualizar Tag y Valid
                c_we_tag    = 1;
                
                // Responder a la CPU (reintentar lectura interna en sig ciclo o responder aqui)
                // Para simplificar, respondemos aquí con el dato que la CPU quería:
                cpu_ready = 1;
                cpu_hit   = 0; // Fue miss
                // Truco: Si el contador coincide con la palabra que quería la CPU, el bus
                // cache_rdata aun no tiene el dato nuevo hasta el sig flanco. 
                // Pero podemos pasarlo directo:
                if (word_cpu == 3'd7) cpu_rdata = mem_rdata;
                // Nota: Si word_cpu < 7, el dato ya se guardó en ciclos anteriores y está en cache_rdata
                
                nxt_state = S_IDLE;
            end else begin
                // Pedir siguiente palabra
                nxt_ref_cnt = ref_cnt + 1;
                if (mem_ready) begin
                   mem_req_reg  = 1;
                   mem_we_reg   = 0;
                   mem_addr_reg = {tag_cpu, index_cpu, 5'b00000} + (ref_cnt + 1);
                   nxt_state    = S_REF_ISSUE;
                end else begin
                   nxt_state    = S_REF_WAIT; // Caso raro si mem pierde ready
                end
            end
         end else begin
             // Mantener solicitud si mem_ready (handshake simple)
             if (mem_ready) begin
                 mem_req_reg  = 1;
                 mem_we_reg   = 0;
                 mem_addr_reg = {tag_cpu, index_cpu, 5'b00000} + ref_cnt;
             end
         end
      end

      S_WR_HIT: begin
         if (mem_done) begin
             cpu_ready = 1;
             cpu_hit   = 1;
             nxt_state = S_IDLE;
         end
      end

      S_WR_BYP: begin
         if (mem_done) begin
             cpu_ready = 1;
             cpu_hit   = 0;
             nxt_state = S_IDLE;
         end
      end
    endcase
  end

endmodule