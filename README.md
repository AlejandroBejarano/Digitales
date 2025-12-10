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


Para este proyecto se utilizó como guía el siguiente diagrama de un procesador con pipeline.
## Diagrama del Pipelined
![display](Fotos/Diagrama_Pipelined.png)


## Codigos de consola

### Cpu multiciclo
```
vcs -kdb -sverilog -lca -Mupdate -debug_all +vcs+flush+all +warn=all -timescale=1ns/10ps -full64 \
-P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab ${VERDI_HOME}/share/PLI/VCS/linux64/pli.a \
-CFLAGS -DVCS module/*.sv tb/tb_cpu.sv 

./simv -gui
```
