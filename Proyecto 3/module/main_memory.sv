module main_memory #(
    parameter MEM_BYTES = 65536,
    parameter BLOCK_BYTES = 32
)(
    input  logic clk,
    input  logic read_block_en,
    input  logic write_block_en,

    input  logic [$clog2(MEM_BYTES)-1:0] addr,
    input  logic [256-1:0] write_block,

    output logic [256-1:0] read_block
);

    logic [7:0] mem [0:MEM_BYTES-1];

    always_comb begin
        if (read_block_en) begin
            for (int i = 0; i < BLOCK_BYTES; i++)
                read_block[i*8 +: 8] = mem[addr + i];
        end
        else begin
            read_block = '0;
        end
    end

    always_ff @(posedge clk) begin
        if (write_block_en) begin
            for (int i = 0; i < BLOCK_BYTES; i++)
                mem[addr + i] <= write_block[i*8 +: 8];
        end
    end

endmodule
