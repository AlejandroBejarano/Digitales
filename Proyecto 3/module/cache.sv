module cache #(
    parameter LINES = 32,
    parameter TAG_BITS = 6,
    parameter BLOCK_BITS = 256,
    parameter USE_DIRTY = 1
)(
    input  logic clk,
    input  logic reset,

    // From address decoder
    input  logic [TAG_BITS-1:0]  tag_in,
    input  logic [$clog2(LINES)-1:0] index,
    input  logic [1:0] word_sel,

    // Write-enable
    input  logic write_en,
    input  logic [31:0] write_data,

    // For hits/misses
    output logic hit,
    output logic [31:0] read_word,

    // Whole block for write-back
    output logic [BLOCK_BITS-1:0] block_out,

    // New block to write into cache
    input  logic [BLOCK_BITS-1:0] block_in,
    input  logic load_line
);

    typedef struct packed {
        logic              valid;
        logic              dirty;
        logic [TAG_BITS-1:0] tag;
        logic [BLOCK_BITS-1:0] block;
    } line_t;

    line_t cache_mem [0:LINES-1];

    // Tag comparison
    assign hit = cache_mem[index].valid &&
                 (cache_mem[index].tag == tag_in);

    // Select word from block
    always_comb begin
        unique case(word_sel)
            2'd0: read_word = cache_mem[index].block[31:0];
            2'd1: read_word = cache_mem[index].block[63:32];
            2'd2: read_word = cache_mem[index].block[95:64];
            2'd3: read_word = cache_mem[index].block[127:96];
            default: read_word = 32'h0;
        endcase
    end

    assign block_out = cache_mem[index].block;

    // Writing
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < LINES; i++) begin
                cache_mem[i].valid <= 0;
                cache_mem[i].dirty <= 0;
                cache_mem[i].tag   <= 0;
                cache_mem[i].block <= 0;
            end
        end
        else begin
            if (load_line) begin
                cache_mem[index].block <= block_in;
                cache_mem[index].tag   <= tag_in;
                cache_mem[index].valid <= 1;
                cache_mem[index].dirty <= 0;
            end

            if (write_en && hit) begin
                cache_mem[index].dirty <= 1;
                case(word_sel)
                    2'd0: cache_mem[index].block[31:0]   <= write_data;
                    2'd1: cache_mem[index].block[63:32]  <= write_data;
                    2'd2: cache_mem[index].block[95:64]  <= write_data;
                    2'd3: cache_mem[index].block[127:96] <= write_data;
                endcase
            end
        end
    end

endmodule
