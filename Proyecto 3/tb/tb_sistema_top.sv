// Testbench para memory_system_top (Versión Corregida y Focalizada)
`timescale 1ns/1ps

module tb_jerarquia_simple;
    // Parámetros
    localparam ADDR_W = 16;
    localparam DATA_W = 32;
    localparam CLK_PERIOD = 10; // 10ns periodo, 5ns flanco

    // Señales de la Interfaz CPU
    reg clk, rst;
    reg cpu_req, cpu_we;
    reg [ADDR_W-1:0] cpu_addr;
    reg [DATA_W-1:0] cpu_wdata;
    wire cpu_ready, cpu_hit;
    wire [DATA_W-1:0] cpu_rdata;

    // Instancia del DUT (Device Under Test)
    memory_system_top #(
        .ADDR_W(ADDR_W),
        .DATA_W(DATA_W)
    ) dut (
        .clk(clk),
        .rst(rst),
        .cpu_req(cpu_req),
        .cpu_we(cpu_we),
        .cpu_addr(cpu_addr),
        .cpu_wdata(cpu_wdata),
        .cpu_ready(cpu_ready),
        .cpu_hit(cpu_hit),
        .cpu_rdata(cpu_rdata)
    );

    // Reloj
    always #(CLK_PERIOD/2) clk = ~clk;

    // Tareas para simplificar el testbench
    task reset_cpu;
        begin
            cpu_req = 0;
            cpu_we = 0;
            cpu_addr = 0;
            cpu_wdata = 0;
        end
    endtask
    
    // TAREA CORREGIDA: Se añade 'endtask'
    task wait_cycles;
        input integer cycles;
        begin
            repeat (cycles) @(posedge clk);
        end
    endtask // <<-- ¡AQUÍ ESTÁ LA CORRECCIÓN!
    
    // TAREA CORREGIDA: Se evita el uso de 'logic' en la declaración de puertos (compatibilidad iverilog)
    task request_cpu(
        input  [ADDR_W-1:0] addr,
        input  [DATA_W-1:0] wdata,
        input               we,
        output [DATA_W-1:0] rdata,
        output              hit
    );
        begin
            $display("T=%0t | Peticion: %s en 0x%h", $time, we ? "ESCRITURA" : "LECTURA", addr);
            cpu_addr = addr;
            cpu_wdata = wdata;
            cpu_we = we;
            cpu_req = 1;
            
            @(posedge clk); // 1. Ciclo de look-up
            cpu_req = 0;
            
            // 2. Esperar respuesta (Hit es rápido, Miss/Write es lento)
            wait(cpu_ready);
            @(posedge clk); // Esperar un ciclo adicional para estabilización

            rdata = cpu_rdata;
            hit = cpu_hit;
            $display("T=%0t | Respuesta: Ready=%b, Hit=%b, Data=0x%h", $time, cpu_ready, cpu_hit, cpu_rdata);
        end
    endtask // <<-- ¡AQUÍ ESTÁ LA CORRECCIÓN!

    // Secuencia de Pruebas
    initial begin
        logic [DATA_W-1:0] read_data;
        logic hit_status;

        $dumpfile("tb_jerarquia_simple.vcd");
        $dumpvars(0, tb_jerarquia_simple);

        clk = 0; rst = 1; reset_cpu;
        #15;
        rst = 0;
        $display("\n--- INICIO DE SIMULACIÓN ---");

        // ----------------------------------------------------
        // 1. LECTURA: Cold Miss (Dirección 0x0008, Palabra 2 del Bloque 0)
        // Valor esperado: 0x00000008 (Asumiendo inicialización i=data)
        // ----------------------------------------------------
        $display("\n[ESCENARIO 1: COLD MISS]");
        request_cpu(16'h0008, 0, 0, read_data, hit_status);
        if (hit_status == 0) 
            $display("-> PASS: Miss detectado. Iniciando Refill...");
        else 
            $display("-> FAIL: Cold Miss no se detectó.");

        wait_cycles(2);

        // ----------------------------------------------------
        // 2. LECTURA: Cache Hit (Misma direccion)
        // Valor esperado: Rápido y Hit=1
        // ----------------------------------------------------
        $display("\n[ESCENARIO 2: CACHE HIT]");
        request_cpu(16'h0008, 0, 0, read_data, hit_status);
        if (hit_status == 1 && read_data == 32'h00000008) 
            $display("-> PASS: Cache Hit y dato correcto.");
        else 
            $display("-> FAIL: Cache Hit falló o se leyó dato incorrecto.");

        wait_cycles(2);
        
        // ----------------------------------------------------
        // 3. ESCRITURA: Write Hit (Actualiza caché y memoria, Write-Through)
        // Escribimos un valor nuevo en 0x0008
        // ----------------------------------------------------
        $display("\n[ESCENARIO 3: WRITE HIT (Write-Through)]");
        request_cpu(16'h0008, 32'hAABBCCDD, 1, read_data, hit_status);
        if (hit_status == 1) 
            $display("-> PASS: Write Hit detectado. Esperando fin de escritura en Memoria.");
        else 
            $display("-> FAIL: Write Hit falló.");
            
        wait_cycles(2);
        
        // ----------------------------------------------------
        // 4. LECTURA: Confirma el dato escrito (debe ser Hit)
        // ----------------------------------------------------
        $display("\n[ESCENARIO 4: LECTURA CONFIRMACIÓN]");
        request_cpu(16'h0008, 0, 0, read_data, hit_status);
        if (hit_status == 1 && read_data == 32'hAABBCCDD) 
            $display("-> PASS: Lectura confirma nuevo dato escrito (0xAABBCCDD).");
        else 
            $display("-> FAIL: Lectura no confirmó el dato escrito.");
            
        wait_cycles(2);

        // ----------------------------------------------------
        // 5. LECTURA: Miss por Conflicto/Compulsorio (Índice Diferente)
        // Dirección 0x0040 (Índice = 1)
        // ----------------------------------------------------
        $display("\n[ESCENARIO 5: COLD MISS #2 (Índice Diferente)]");
        request_cpu(16'h0040, 0, 0, read_data, hit_status);
        if (hit_status == 0 && read_data == 32'h00000040) 
            $display("-> PASS: Miss en nueva línea detectado y dato correcto (0x0040) leido.");
        else 
            $display("-> FAIL: Cold Miss en línea nueva falló.");

        wait_cycles(2);
        
        $finish;
    end

endmodule

