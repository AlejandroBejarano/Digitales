# Proyecto 3: Implementación de un procesador multiciclo con pipeline basado en `rv32i`
### EL3310 - Diseño de Sistemas Digitales
### Escuela de Ingeniería Electrónica
### Tecnológico de Costa Rica

<br/><br/>

## Preámbulo

Para el desarrollo de este proyecto 3, usted deberá guiarse por la documentación que se encuentra en el capítulo 2 y 4 del libro *Computer Organization and Design: The Hardware Software Interface, RISC-V edition*.


## Procesador multiciclo con pipeline basado en `rv32i`

Usted desarrollará un procesador multiciclo con pipeline como el que muestra en la siguiente figura.

![Diagrama de bloques para el procesador multiciclo con pipeline](https://github.com/IE-EL3310/proy3-1S2025/blob/main/figs/diagram_pipeline.png?raw=true "Diagrama de bloques de un procesador multiciclo con pipeline basado en `rv32i`")


Para este proyecto usted implementará, además de los bloques básicos que se encuentran en un procesador uniciclo, los siguientes bloques funcionales:
- Registros intermedios entre las etapas
- Unidad de detección de riesgos (_Hazard unit detection_)
- Unidad de adelantamiento (_Forward unit_)
- Comparador a la salida del archivo de registros y sumador en la etapa ID para cálculo de dirección de salto (_target address_)
- Multiplexores (nuevos y modificaciones, según sea necesario)

Para esta implementación, usted debe considerar que su procesador implementa una técnica estática de predicción de saltos con la cual se considera que siempre **los saltos no se toman** (_always not taken_). Asegúrese de que su procesador es capaz de ejecutar un _flush_ en caso de que deba cambiar la dirección de salto.

Recuerde que además que su implementación debe ser capaz de insertar _stalls_ para resolver riesgos de datos, particularmente en el caso de una instrucción que presenta dependencia de datos de la instrucción inmediata anterior y la cual corresponda a una instrucción lw. 

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

## Programas de prueba
Deberá escribir al menos 2 programas, en lenguaje ensamblador, que le permitan estresar su diseño y asegurarse de que todas las instrucciones anteriores están debidamente soportadas. Dichos programas deberán tener algún sentido algorítmico y no ser simplemente una serie de instrucciones que no ejecutan algo con sentido.


## Evaluación
Este proyecto corto se evaluará con la siguiente rúbrica.


| Rubro | % | C | EP | D | NP |
|-------|---|---|----|---|----|
|Desarrollo de procesador | 60 |   |    | X  |    |
|Validación funcional del procesador con programas desarrollados  |10|   |    | X  |    |
|Validación funcional del procesador con programa proveído  |20| X  |    |   |    |
|Uso de repositorio |10| X  |    |   |    |

C: Completo,
EP: En progreso ($\times 0,8$),
D: Deficiente ($\times 0,5$),
NP: No presenta ($\times 0$)

Para el rubro de "Uso de repositorio" se requiere que existan contribuciones de todos los miembros del equipo. El último _commit_ debe registraste antes de las 11:59 pm del miércoles 18 de junio de 2025.


## Diagrama del Pipelined
![display](Fotos/Diagrama_Pipelined.png)


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
iverilog -g2012 -o cpu_tb.vvp     tb/tb_cpu_multiciclo.sv     module/cpu_multiciclo.sv     module/control_unit.sv     module/datapath_mul.sv     module/Hazard_det_unit.sv     module/Forwarding_unit.sv     module/datapath_fetch_decode.sv     module/datapath_execute.sv     module/datapath_mem.sv     module/register_id_ex.sv     module/register_if_id.sv     module/register_mem_wb.sv     module/register_ex_mem.sv     module/pc.sv     module/instruction_memory.sv     module/data_memory.sv     module/ImmGen.sv     module/register_bank.sv     module/ALU.sv     module/adder.sv     module/mux21.sv     module/mux31.sv

vvp cpu_tb.vvp

gtkwave cpu_multiciclo_tb.vcd
```
