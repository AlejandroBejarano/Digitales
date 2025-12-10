# Proyecto 2: Implementación de un procesador multiciclo con pipeline basado en `rv32i`
### EL3310 - Diseño de Sistemas Digitales
### Escuela de Ingeniería Electrónica
### Tecnológico de Costa Rica

<br/><br/>

## Procesador multiciclo con pipeline
Este proyecto consiste en construir un microprocesador en SystemVerilog. El procesador 
debe tener las siguientes características:
- Microprocesador multiciclo de 5 etapas con pipeline. 
- Debe incluir unidad de detección de riesgos (Riesgos de Datos y Riegos de Control) 
y unidad de adelantamiento. 
- El procesador debe ser capaz de correr todas las instrucciones del estándar RV32I 
(menos las FENCE, PAUSE, ECALL, EBREAK). 
- Debe mostrar una simulación del procesador en SystemVerilog corriendo un 
programa de su gusto. La presentación puede ser virtual o presencial, con cita al 
correo (Asunto: Presentación Proyecto 2). La entrega del código puede ser en un 
repositorio en github o en .zip al TEC Digital. 


Usted desarrollará un procesador multiciclo con pipeline como el que muestra en la siguiente figura.

![Mi imagen](Fotos/image.png)"Diagrama de bloques de un procesador multiciclo con pipeline basado en `rv32i`"


Usted deberá implementar las siguientes instrucciones del [_greencard_](https://tecdigital.tec.ac.cr/dotlrn/classes/E/EL3310/S-1-2025.CA.EL3310.2/file-storage/view/materiales%2Fgreencard.pdf):

```asm
lw
sw
sll, slli, srl, srli, sra, srai
add, addi, sub
xor, xori, or, ori, and, andi
beq, bne, blt, bge
slt, slti, sltu, sltui
jal, jalr
```



## Diagrama del Pipelined
![display](Fotos/Diagrama_Pipelined.png)


## Waveform
![display](figs/Waveform%20cpu.png)

![display](figs/Waveform%20cpu%20wb.png)

```
#Programa 1
    addi x1, x0, 5        # x1 = 5
    addi x2, x0, 3        # x2 = 3
    add  x3, x1, x2       # x3 = x1 + x2 = 8
    .
    .
    .
```
En las figuras se observa tanto en la ALU y etapa de wb en la salida del módulo de cpu, los valores de "salida" de las primeras instrucciones que se ejecutan.

## Codigos de consola

### Hazard unit

```
iverilog -g2012 -o sim/hazard_testbench sim/tb_hazard_unit.sv src/Hazard_det_unit.sv

vvp sim/hazard_testbench

gtkwave sim/vcd/tb_hazard_unit.vcd
```

### Forwarding unit

```
iverilog -g2012 -o sim/forward_testbench sim/tb_forwarding_unit.sv src/Forwarding_unit.sv

vvp sim/forward_testbench

gtkwave sim/vcd/tb_forwarding_unit.vcd
```

### Cpu multiciclo
```
vcs -kdb -sverilog -lca -Mupdate -debug_all +vcs+flush+all +warn=all -timescale=1ns/10ps -full64 \
-P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab ${VERDI_HOME}/share/PLI/VCS/linux64/pli.a \
-CFLAGS -DVCS module/*.sv tb/tb_cpu.sv 

vvp cpu_tb.vvp

gtkwave cpu_multiciclo_tb.vcd
```
