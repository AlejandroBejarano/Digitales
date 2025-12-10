//----------------------------------------------------------------------
// File: instruction_memory_tb.sv
// Descripción: Testbench para el módulo instruction_memory
//----------------------------------------------------------------------

`timescale 1ns/1ps

module instruction_memory_tb;

    // Parámetros idénticos a los del módulo bajo prueba
    localparam integer DATA_WIDTH     = 32;
    localparam integer ADDRESS_WIDTH  = 32;
    localparam integer MEM_SIZE       = 256; // 256 palabras

    // Señales de conexión
    logic [ADDRESS_WIDTH-1:0] tb_address;
    wire  [DATA_WIDTH-1:0]    tb_instruction;

    // Instanciación del módulo instruction_memory
    instruction_memory #(
        .DATA_WIDTH    (DATA_WIDTH),
        .ADDRESS_WIDTH (ADDRESS_WIDTH),
        .MEM_SIZE      (MEM_SIZE)
    ) dut (
        .address      (tb_address),
        .instruction  (tb_instruction)
    );

    //**************************************************************
    // 1) Generar fichero VCD para GTKWave
    //**************************************************************
    initial begin
        $dumpfile("instruction_memory_tb.vcd");
        $dumpvars(0, instruction_memory_tb);
    end

    //**************************************************************
    // 2) Procedimiento de estímulo
    //**************************************************************
    initial begin
        // Inicializa la dirección a cero
        tb_address = '0;
        #10;

        $display("---------------------------------------------------------");
        $display(" Direccion (hex) | Index de palabra | Instruccion leída");
        $display("---------------------------------------------------------");

        // Probaremos unas cuantas direcciones alineadas a 4 bytes:
        //  - 0x00000000  → índice 0
        //  - 0x00000004  → índice 1
        //  - 0x00000008  → índice 2
        //  - 0x0000000C  → índice 3
        //  ... hasta algunos valores de prueba
        //
        // Además probaremos el último índice válido: (MEM_SIZE-1)*4
        // y una dirección no alineada para ver qué sucede.

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
        //    (se ignoran bits [1:0], así que lee el mismo índice que si fuera 0x0000_0000)
        tb_address = 32'h0000_0002;
        #5;
        $display("   0x%08h    |      %0d        |  0x%08h  (no alineada)", 
                  tb_address, tb_address[9:2], tb_instruction);

        // 8) Dirección fuera de rango: por ejemplo 0x0000_0400 (índice 0x100 = 256, 
        //    que excede MEM_SIZE-1 = 255). En teoría se accederá a IM[256], que no existe → 'X
        tb_address = 32'h0000_0400;
        #5;
        $display("   0x%08h    |     %0d        |  0x%08h  (fuera de rango probablemente X)", 
                  tb_address, tb_address[9:2], tb_instruction);

        $display("---------------------------------------------------------\n");

        #10;
        $finish;
    end

endmodule
