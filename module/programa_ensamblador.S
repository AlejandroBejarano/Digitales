#Programa 3 Algoritmo del Máximo Común Divisor

addi a0, zero, 48
addi a1, zero, 18
jal ra, 4
sw a2, 0(zero)
ebrake
beq a0, a1, +12
blt a0, a1, +20
sub a0, a0, a1
jal zero, -12
add t0, zero, a0
add a0, zero, a1
add a1, zero, t0
jal zero, -44
add a2, zero, a0
ret


#Programa 4 Suma de un arreglo de 5 elementos

addi    sp, zero, 256       # sp = 0x100
addi    gp, zero, 5         # gp = 5
addi    a0, zero, 0         # a0 = 0
jal     ra, 4               # salto a PC+8 (PC+4 + 4), guarda PC+4 en ra
sw      zero, 4(sp)         # mem[sp + 4] = 0
ebreak                      # detener ejecución (breakpoint)
lw      s0, 0(sp)           # s0 = mem[sp + 0]
add     a0, a0, s0          # a0 = a0 + s0
addi    sp, sp, 4           # sp = sp + 4
addi    gp, gp, -1          # gp = gp - 1
bne     gp, zero, -8        # si gp != 0, salta 2 instrucciones atrás
ret                         # return (jalr zero, ra, 0)







# Programa1 ensamblador grande
# Colocado en el instruction memory
#

    # Inicialización
    li x1, 0          # Reg cero manual
    li x2, 5
    li x3, 10
    li x4, -3
    li x5, 0xAA
    li x6, 0x55
    li x7, 1
    li x8, 4
    li x9, 0x20       # Dirección base para memoria

loop_start:
    # Operaciones aritméticas
    add x10, x2, x3
    sub x11, x3, x2
    addi x12, x4, 8

    # Lógicos
    and x13, x5, x6
    or  x14, x5, x6
    xor x15, x5, x6

    andi x16, x5, 0x0F
    ori  x17, x6, 0xF0
    xori x18, x6, 0x0F

    # Shifts
    sll x19, x2, x7
    srl x20, x3, x7
    sra x21, x4, x7

    slli x22, x2, 2
    srli x23, x3, 2
    srai x24, x4, 2

    # Comparaciones R
    slt x25, x4, x3
    sltu x26, x4, x3

    # Comparaciones I
    slti x27, x4, 5
    sltiu x28, x4, 5

    # Memoria
    sw x10, 0(x9)     # Guardar en Mem[0x20]
    lw x29, 0(x9)

    # Branches
    beq x2, x2, next1
    bne x2, x3, next2
    blt x4, x3, next3
    bge x3, x2, next4

next1:
    add x30, x1, x1
next2:
    add x30, x2, x2
next3:
    add x30, x3, x3
next4:
    add x30, x4, x4

    # jal test
    jal x31, jump_target

    # Instrucciones para saltar
skip_target:
    add x30, x5, x5

jump_target:
    add x30, x6, x6

    # jalr prueba
    addi x31, x0, 100         # dirección destino (ficticia)
    jalr x0, x31, 0

    # Ciclo infinito (simula programa completo de 256 instrucciones)
fill_loop:
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
    add x0, x0, x0
    jal x0, fill_loop         # loop

    # (Esto se repetirá hasta completar 256 instrucciones)
