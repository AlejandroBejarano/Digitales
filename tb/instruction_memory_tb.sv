
`timescale 1ns/1ps

module instruction_memory_tb;

    localparam integer DATA_WIDTH     = 32;
    localparam integer ADDRESS_WIDTH  = 32;
    localparam integer MEM_SIZE       = 256; 

    logic [ADDRESS_WIDTH-1:0] tb_address;
    wire  [DATA_WIDTH-1:0]    tb_instruction;

    instruction_memory #(
        .DATA_WIDTH    (DATA_WIDTH),
        .ADDRESS_WIDTH (ADDRESS_WIDTH),
        .MEM_SIZE      (MEM_SIZE)
    ) dut (
        .address      (tb_address),
        .instruction  (tb_instruction)
    );
*
    initial begin
        $dumpfile("instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);
    end

*
    initial begin
        tb_address = '0;
        #10;

        $display("---------------------------------------------------------");
        $display(" Direccion (hex) | Index de palabra | Instruccion leída");
        $display("---------------------------------------------------------");

        // 1) Dirección 0x0000_0000 (palabra 0)
        tb_address = 32'h0000_0000;
        #5;
        $display("   0x%08h    |      %0d        |  0x%08h", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 2) Dirección 0x0000_0004 (palabra 1)
        tb_address = 32'h0000_0004;
        #5;
        $display("   0x%08h    |      %0d        |  0x%08h", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 3) Dirección 0x0000_0008 (palabra 2)
        tb_address = 32'h0000_0008;
        #5;
        $display("   0x%08h    |      %0d        |  0x%08h", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 4) Dirección 0x0000_000C (palabra 3)
        tb_address = 32'h0000_000C;
        #5;
        $display("   0x%08h    |      %0d        |  0x%08h", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 5) Una dirección intermedia, por ejemplo la palabra 10 → 10*4 = 40 (0x28)
        tb_address = 32'h0000_0028;
        #5;
        $display("   0x%08h    |      %0d        |  0x%08h", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 6) Última posición válida de palabra: (MEM_SIZE-1)*4 = 255*4 = 1020 (0x3FC)
        tb_address = 32'h0000_03FC;
        #5;
        $display("   0x%08h    |     %0d        |  0x%08h", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 7) Dirección no alineada: 0x0000_0002
        tb_address = 32'h0000_0002;
        #5;
        $display("   0x%08h    |      %0d        |  0x%08h  (no alineada)", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 8) Dirección fuera de rango: por ejemplo 0x0000_0400 (índice 0x100 = 256, 
        tb_address = 32'h0000_0400;
        #5;
        $display("   0x%08h    |     %0d        |  0x%08h  (fuera de rango probablemente X)", 
                  tb_address, tb_address[9:2], tb_instruction);

        $display("---------------------------------------------------------\n");

        #10;
        $finish;
    end

endmodule
