# Proyecto 3: Sistema de jerarquía de memoria entre una memoria principal y una memoria caché
### EL3310 - Diseño de Sistemas Digitales
### Escuela de Ingeniería Electrónica
### Tecnológico de Costa Rica

<br/><br/>

## Objetivos del sistema a desarrollar
Este proyecto consiste en construir un sistema de jerarquía de memoria entre una memoria principal y una memoria caché, con las siguientes características:
erarquía de memoria de dos niveles: la memoria caché y la memoria principal.
• La memoria caché debe ser de 1024 Bytes de datos, mientras que la memoria principal debe ser de 65KiB. La memoria como un todo tendrá 16 bits de direcciones.
• Los bloques de memoria deben ser de 256 bits, la palabra a leer/escribir es de 32 bits y la memoria se puede direccionar por byte.
• La caché implementa mapeo directo.
• Las escrituras pueden hacerse por Write-Through o Write-Back, a gusto de cada grupo.
• La caché debe tener bit de válido (y bit de Dirty si usan Write-Back).
• Debe mostrar una simulación del procesador en SystemVerilog probando caché hits y caché misses. 


Para este proyecto se utilizó como guía el siguiente diagrama:
## Diagrama del Pipelined
![display](Fotos/Diagrama.png)


## Waveform
![display](Fotos/Waveform%20memoria.png)

## Consola

![display](Fotos/Consola%201.png)


## Codigos de consola

### Cpu multiciclo
```
vcs -kdb -sverilog -lca -Mupdate -debug_all +vcs+flush+all +warn=all -timescale=1ns/10ps -full64 \
-P ${VERDI_HOME}/share/PLI/VCS/linux64/novas.tab ${VERDI_HOME}/share/PLI/VCS/linux64/pli.a \
-CFLAGS -DVCS module/*.sv tb/tb_sistema_top.sv 

./simv -gui
```
