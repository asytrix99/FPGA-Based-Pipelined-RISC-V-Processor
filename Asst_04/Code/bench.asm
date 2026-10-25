_start:
        lui     sp, 65556
        j       main

main:
        addi    sp, sp, -112
        sw      ra, 108(sp)
        sw      s0, 104(sp)
        addi    s0, sp, 112
        li      a0, 0
        sw      a0, -12(s0)
        lui     a1, 1048560
        addi    a2, a1, 96
        sw      a2, -16(s0)
        addi    a2, a1, 128
        sw      a2, -20(s0)
        addi    a2, a1, 100
        sw      a2, -24(s0)
        addi    a1, a1, 104
        sw      a1, -28(s0)
        li      a1, -1
        sw      a1, -32(s0)
        sw      a0, -36(s0)
        j       .LBB1_1
.LBB1_1:
        lw      a0, -24(s0)
        lw      a0, 0(a0)
        sw      a0, -40(s0)
        lw      a0, -28(s0)
        lw      a0, 0(a0)
        sw      a0, -44(s0)
        lw      a0, -44(s0)
        lw      a1, -36(s0)
        not     a1, a1
        and     a0, a0, a1
        sw      a0, -48(s0)
        lw      a0, -44(s0)
        sw      a0, -36(s0)
        lw      a0, -40(s0)
        lw      a1, -32(s0)
        bne     a0, a1, .LBB1_3
        j       .LBB1_2
.LBB1_2:
        lw      a0, -48(s0)
        beqz    a0, .LBB1_38
        j       .LBB1_3
.LBB1_3:
        lw      a0, -40(s0)
        sw      a0, -32(s0)
        lw      a0, -40(s0)
        andi    a0, a0, 3
        sw      a0, -52(s0)
        lw      a0, -40(s0)
        slli    a0, a0, 24
        srli    a0, a0, 26
        sw      a0, -56(s0)
        lw      a0, -52(s0)
        li      a1, 3
        bne     a0, a1, .LBB1_5
        j       .LBB1_4
.LBB1_4:
        lw      a0, -56(s0)
        slli    a0, a0, 4
        sw      a0, -56(s0)
        j       .LBB1_13
.LBB1_5:
        lw      a0, -52(s0)
        li      a1, 1
        bne     a0, a1, .LBB1_9
        j       .LBB1_6
.LBB1_6:
        lw      a0, -56(s0)
        li      a1, 25
        bltu    a0, a1, .LBB1_8
        j       .LBB1_7
.LBB1_7:
        li      a0, 24
        sw      a0, -56(s0)
        j       .LBB1_8
.LBB1_8:
        j       .LBB1_12
.LBB1_9:
        lw      a0, -56(s0)
        li      a1, 40
        bltu    a0, a1, .LBB1_11
        j       .LBB1_10
.LBB1_10:
        li      a0, 39
        sw      a0, -56(s0)
        j       .LBB1_11
.LBB1_11:
        j       .LBB1_12
.LBB1_12:
        j       .LBB1_13
.LBB1_13:
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        sw      a0, -72(s0)
        lw      a0, -52(s0)
        bnez    a0, .LBB1_15
        j       .LBB1_14
.LBB1_14:
        lw      a0, -56(s0)
        call    fib_iter
        sw      a0, -60(s0)
        j       .LBB1_22
.LBB1_15:
        lw      a0, -52(s0)
        li      a1, 1
        bne     a0, a1, .LBB1_17
        j       .LBB1_16
.LBB1_16:
        lw      a0, -56(s0)
        call    fib_rec
        sw      a0, -60(s0)
        j       .LBB1_21
.LBB1_17:
        lw      a0, -52(s0)
        li      a1, 2
        bne     a0, a1, .LBB1_19
        j       .LBB1_18
.LBB1_18:
        lw      a0, -56(s0)
        call    fib_table
        sw      a0, -60(s0)
        j       .LBB1_20
.LBB1_19:
        lw      a0, -56(s0)
        call    count_primes
        sw      a0, -60(s0)
        j       .LBB1_20
.LBB1_20:
        j       .LBB1_21
.LBB1_21:
        j       .LBB1_22
.LBB1_22:
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        lw      a1, -72(s0)
        sub     a0, a0, a1
        sw      a0, -76(s0)
        lw      a0, -52(s0)
        li      a1, 3
        bne     a0, a1, .LBB1_24
        j       .LBB1_23
.LBB1_23:
        lw      a0, -56(s0)
        call    sieve_count
        lw      a1, -60(s0)
        xor     a0, a0, a1
        seqz    a0, a0
        sw      a0, -68(s0)
        j       .LBB1_31
.LBB1_24:
        lw      a0, -56(s0)
        call    fib_iter
        sw      a0, -64(s0)
        lw      a0, -56(s0)
        call    fib_table
        lw      a1, -64(s0)
        li      a2, 0
        sw      a2, -88(s0)
        bne     a0, a1, .LBB1_26
        j       .LBB1_25
.LBB1_25:
        lw      a0, -60(s0)
        lw      a1, -64(s0)
        xor     a0, a0, a1
        seqz    a0, a0
        sw      a0, -88(s0)
        j       .LBB1_26
.LBB1_26:
        lw      a0, -88(s0)
        andi    a0, a0, 1
        sw      a0, -68(s0)
        lw      a1, -56(s0)
        li      a0, 24
        bltu    a0, a1, .LBB1_30
        j       .LBB1_27
.LBB1_27:
        lw      a0, -68(s0)
        li      a1, 0
        sw      a1, -92(s0)
        beqz    a0, .LBB1_29
        j       .LBB1_28
.LBB1_28:
        lw      a0, -56(s0)
        call    fib_rec
        lw      a1, -64(s0)
        xor     a0, a0, a1
        seqz    a0, a0
        sw      a0, -92(s0)
        j       .LBB1_29
.LBB1_29:
        lw      a0, -92(s0)
        andi    a0, a0, 1
        sw      a0, -68(s0)
        j       .LBB1_30
.LBB1_30:
        j       .LBB1_31
.LBB1_31:
        lw      a0, -76(s0)
        li      a1, 40
        mul     a0, a0, a1
        sw      a0, -80(s0)
        lw      a0, -80(s0)
        lui     a1, 67109
        addi    a1, a1, -557
        mulhu   a0, a0, a1
        srli    a0, a0, 6
        sw      a0, -84(s0)
        lw      a0, -68(s0)
        snez    a1, a0
        lw      a0, -52(s0)
        slli    a0, a0, 2
        sub     a0, a0, a1
        addi    a0, a0, 2
        lw      a1, -16(s0)
        sw      a0, 0(a1)
        lbu     a0, -39(s0)
        andi    a0, a0, 128
        beqz    a0, .LBB1_33
        j       .LBB1_32
.LBB1_32:
        lw      a0, -84(s0)
        call    to_bcd
        lw      a1, -20(s0)
        sw      a0, 0(a1)
        j       .LBB1_34
.LBB1_33:
        lw      a0, -60(s0)
        call    to_bcd
        lw      a1, -20(s0)
        sw      a0, 0(a1)
        j       .LBB1_34
.LBB1_34:
        lw      a0, -52(s0)
        call    send_workload_name
        li      a0, 32
        sw      a0, -96(s0)
        call    uart_send_char
        li      a0, 78
        sw      a0, -104(s0)
        call    uart_send_char
        li      a0, 61
        sw      a0, -100(s0)
        call    uart_send_char
        lw      a0, -56(s0)
        call    uart_send_dec
        lw      a0, -96(s0)
        call    uart_send_char
        li      a0, 82
        call    uart_send_char
        lw      a0, -100(s0)
        call    uart_send_char
        lw      a0, -60(s0)
        call    uart_send_dec
        lw      a0, -96(s0)
        call    uart_send_char
        li      a0, 67
        sw      a0, -108(s0)
        call    uart_send_char
        li      a0, 89
        call    uart_send_char
        lw      a0, -108(s0)
        call    uart_send_char
        lw      a0, -100(s0)
        call    uart_send_char
        lw      a0, -76(s0)
        call    uart_send_dec
        lw      a0, -96(s0)
        call    uart_send_char
        lw      a0, -104(s0)
        call    uart_send_char
        li      a0, 83
        call    uart_send_char
        lw      a0, -100(s0)
        call    uart_send_char
        lw      a0, -80(s0)
        call    uart_send_dec
        lw      a0, -96(s0)
        call    uart_send_char
        lw      a0, -68(s0)
        beqz    a0, .LBB1_36
        j       .LBB1_35
.LBB1_35:
        li      a0, 80
        call    uart_send_char
        li      a0, 65
        call    uart_send_char
        li      a0, 83
        sw      a0, -112(s0)
        call    uart_send_char
        lw      a0, -112(s0)
        call    uart_send_char
        j       .LBB1_37
.LBB1_36:
        li      a0, 70
        call    uart_send_char
        li      a0, 65
        call    uart_send_char
        li      a0, 73
        call    uart_send_char
        li      a0, 76
        call    uart_send_char
        j       .LBB1_37
.LBB1_37:
        li      a0, 13
        call    uart_send_char
        li      a0, 10
        call    uart_send_char
        j       .LBB1_38
.LBB1_38:
        lui     a0, 305
        addi    a0, a0, 720
        call    delay
        j       .LBB1_1

fib_iter:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -12(s0)
        li      a0, 0
        sw      a0, -16(s0)
        li      a1, 1
        sw      a1, -20(s0)
        sw      a0, -24(s0)
        j       .LBB2_1
.LBB2_1:
        lw      a0, -24(s0)
        lw      a1, -12(s0)
        bgeu    a0, a1, .LBB2_4
        j       .LBB2_2
.LBB2_2:
        lw      a0, -16(s0)
        lw      a1, -20(s0)
        add     a0, a0, a1
        sw      a0, -28(s0)
        lw      a0, -20(s0)
        sw      a0, -16(s0)
        lw      a0, -28(s0)
        sw      a0, -20(s0)
        j       .LBB2_3
.LBB2_3:
        lw      a0, -24(s0)
        addi    a0, a0, 1
        sw      a0, -24(s0)
        j       .LBB2_1
.LBB2_4:
        lw      a0, -16(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

fib_rec:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -16(s0)
        lw      a1, -16(s0)
        li      a0, 1
        bltu    a0, a1, .LBB3_2
        j       .LBB3_1
.LBB3_1:
        lw      a0, -16(s0)
        sw      a0, -12(s0)
        j       .LBB3_3
.LBB3_2:
        lw      a0, -16(s0)
        addi    a0, a0, -1
        call    fib_rec
        sw      a0, -20(s0)
        lw      a0, -16(s0)
        addi    a0, a0, -2
        call    fib_rec
        mv      a1, a0
        lw      a0, -20(s0)
        add     a0, a0, a1
        sw      a0, -12(s0)
        j       .LBB3_3
.LBB3_3:
        lw      a0, -12(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

fib_table:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -12(s0)
        lui     a0, %hi(table)
        addi    a0, a0, %lo(table)
        sw      a0, -16(s0)
        lw      a1, -16(s0)
        li      a0, 0
        sw      a0, 0(a1)
        lw      a1, -16(s0)
        li      a0, 1
        sw      a0, 4(a1)
        li      a0, 2
        sw      a0, -20(s0)
        j       .LBB4_1
.LBB4_1:
        lw      a1, -20(s0)
        lw      a0, -12(s0)
        bltu    a0, a1, .LBB4_4
        j       .LBB4_2
.LBB4_2:
        lw      a0, -16(s0)
        lw      a1, -20(s0)
        slli    a1, a1, 2
        add     a1, a1, a0
        lw      a0, -4(a1)
        lw      a2, -8(a1)
        add     a0, a0, a2
        sw      a0, 0(a1)
        j       .LBB4_3
.LBB4_3:
        lw      a0, -20(s0)
        addi    a0, a0, 1
        sw      a0, -20(s0)
        j       .LBB4_1
.LBB4_4:
        lw      a0, -16(s0)
        lw      a1, -12(s0)
        slli    a1, a1, 2
        add     a0, a0, a1
        lw      a0, 0(a0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

count_primes:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -12(s0)
        li      a0, 0
        sw      a0, -16(s0)
        li      a0, 2
        sw      a0, -20(s0)
        j       .LBB5_1
.LBB5_1:
        lw      a1, -20(s0)
        lw      a0, -12(s0)
        bltu    a0, a1, .LBB5_10
        j       .LBB5_2
.LBB5_2:
        li      a0, 1
        sw      a0, -24(s0)
        li      a0, 2
        sw      a0, -28(s0)
        j       .LBB5_3
.LBB5_3:
        lw      a0, -28(s0)
        mul     a1, a0, a0
        lw      a0, -20(s0)
        bltu    a0, a1, .LBB5_8
        j       .LBB5_4
.LBB5_4:
        lw      a0, -20(s0)
        lw      a1, -28(s0)
        remu    a0, a0, a1
        bnez    a0, .LBB5_6
        j       .LBB5_5
.LBB5_5:
        li      a0, 0
        sw      a0, -24(s0)
        j       .LBB5_8
.LBB5_6:
        j       .LBB5_7
.LBB5_7:
        lw      a0, -28(s0)
        addi    a0, a0, 1
        sw      a0, -28(s0)
        j       .LBB5_3
.LBB5_8:
        lw      a0, -16(s0)
        lw      a1, -24(s0)
        add     a0, a0, a1
        sw      a0, -16(s0)
        j       .LBB5_9
.LBB5_9:
        lw      a0, -20(s0)
        addi    a0, a0, 1
        sw      a0, -20(s0)
        j       .LBB5_1
.LBB5_10:
        lw      a0, -16(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

sieve_count:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -12(s0)
        li      a0, 0
        sw      a0, -16(s0)
        j       .LBB6_1
.LBB6_1:
        lw      a1, -16(s0)
        lw      a0, -12(s0)
        bltu    a0, a1, .LBB6_4
        j       .LBB6_2
.LBB6_2:
        lw      a0, -16(s0)
        slli    a1, a0, 2
        lui     a0, %hi(sieve)
        addi    a0, a0, %lo(sieve)
        add     a1, a1, a0
        li      a0, 0
        sw      a0, 0(a1)
        j       .LBB6_3
.LBB6_3:
        lw      a0, -16(s0)
        addi    a0, a0, 1
        sw      a0, -16(s0)
        j       .LBB6_1
.LBB6_4:
        li      a0, 2
        sw      a0, -20(s0)
        j       .LBB6_5
.LBB6_5:
        lw      a0, -20(s0)
        mul     a1, a0, a0
        lw      a0, -12(s0)
        bltu    a0, a1, .LBB6_14
        j       .LBB6_6
.LBB6_6:
        lw      a0, -20(s0)
        slli    a1, a0, 2
        lui     a0, %hi(sieve)
        addi    a0, a0, %lo(sieve)
        add     a0, a0, a1
        lw      a0, 0(a0)
        bnez    a0, .LBB6_12
        j       .LBB6_7
.LBB6_7:
        lw      a0, -20(s0)
        mul     a0, a0, a0
        sw      a0, -24(s0)
        j       .LBB6_8
.LBB6_8:
        lw      a1, -24(s0)
        lw      a0, -12(s0)
        bltu    a0, a1, .LBB6_11
        j       .LBB6_9
.LBB6_9:
        lw      a0, -24(s0)
        slli    a1, a0, 2
        lui     a0, %hi(sieve)
        addi    a0, a0, %lo(sieve)
        add     a1, a1, a0
        li      a0, 1
        sw      a0, 0(a1)
        j       .LBB6_10
.LBB6_10:
        lw      a1, -20(s0)
        lw      a0, -24(s0)
        add     a0, a0, a1
        sw      a0, -24(s0)
        j       .LBB6_8
.LBB6_11:
        j       .LBB6_12
.LBB6_12:
        j       .LBB6_13
.LBB6_13:
        lw      a0, -20(s0)
        addi    a0, a0, 1
        sw      a0, -20(s0)
        j       .LBB6_5
.LBB6_14:
        li      a0, 0
        sw      a0, -28(s0)
        li      a0, 2
        sw      a0, -32(s0)
        j       .LBB6_15
.LBB6_15:
        lw      a1, -32(s0)
        lw      a0, -12(s0)
        bltu    a0, a1, .LBB6_20
        j       .LBB6_16
.LBB6_16:
        lw      a0, -32(s0)
        slli    a1, a0, 2
        lui     a0, %hi(sieve)
        addi    a0, a0, %lo(sieve)
        add     a0, a0, a1
        lw      a0, 0(a0)
        bnez    a0, .LBB6_18
        j       .LBB6_17
.LBB6_17:
        lw      a0, -28(s0)
        addi    a0, a0, 1
        sw      a0, -28(s0)
        j       .LBB6_18
.LBB6_18:
        j       .LBB6_19
.LBB6_19:
        lw      a0, -32(s0)
        addi    a0, a0, 1
        sw      a0, -32(s0)
        j       .LBB6_15
.LBB6_20:
        lw      a0, -28(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

to_bcd:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -12(s0)
        li      a0, 0
        sw      a0, -16(s0)
        sw      a0, -20(s0)
        j       .LBB7_1
.LBB7_1:
        lw      a1, -20(s0)
        li      a0, 31
        bltu    a0, a1, .LBB7_4
        j       .LBB7_2
.LBB7_2:
        lw      a0, -12(s0)
        lui     a1, 838861
        addi    a1, a1, -819
        mulhu   a2, a0, a1
        srli    a2, a2, 3
        li      a3, 10
        mul     a2, a2, a3
        sub     a0, a0, a2
        lw      a2, -20(s0)
        sll     a2, a0, a2
        lw      a0, -16(s0)
        or      a0, a0, a2
        sw      a0, -16(s0)
        lw      a0, -12(s0)
        mulhu   a0, a0, a1
        srli    a0, a0, 3
        sw      a0, -12(s0)
        j       .LBB7_3
.LBB7_3:
        lw      a0, -20(s0)
        addi    a0, a0, 4
        sw      a0, -20(s0)
        j       .LBB7_1
.LBB7_4:
        lw      a0, -16(s0)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

send_workload_name:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        lw      a0, -12(s0)
        bnez    a0, .LBB8_2
        j       .LBB8_1
.LBB8_1:
        li      a0, 70
        call    uart_send_char
        li      a0, 73
        sw      a0, -16(s0)
        call    uart_send_char
        li      a0, 66
        call    uart_send_char
        lw      a0, -16(s0)
        call    uart_send_char
        j       .LBB8_9
.LBB8_2:
        lw      a0, -12(s0)
        li      a1, 1
        bne     a0, a1, .LBB8_4
        j       .LBB8_3
.LBB8_3:
        li      a0, 70
        call    uart_send_char
        li      a0, 73
        call    uart_send_char
        li      a0, 66
        call    uart_send_char
        li      a0, 82
        call    uart_send_char
        j       .LBB8_8
.LBB8_4:
        lw      a0, -12(s0)
        li      a1, 2
        bne     a0, a1, .LBB8_6
        j       .LBB8_5
.LBB8_5:
        li      a0, 70
        call    uart_send_char
        li      a0, 73
        call    uart_send_char
        li      a0, 66
        call    uart_send_char
        li      a0, 84
        call    uart_send_char
        j       .LBB8_7
.LBB8_6:
        li      a0, 80
        call    uart_send_char
        li      a0, 82
        call    uart_send_char
        li      a0, 73
        call    uart_send_char
        li      a0, 77
        call    uart_send_char
        j       .LBB8_7
.LBB8_7:
        j       .LBB8_8
.LBB8_8:
        j       .LBB8_9
.LBB8_9:
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

uart_send_char:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        j       .LBB9_1
.LBB9_1:
        lui     a0, %hi(UART_TX_ready_ADDR)
        lw      a0, %lo(UART_TX_ready_ADDR)(a0)
        lw      a0, 0(a0)
        bnez    a0, .LBB9_3
        j       .LBB9_2
.LBB9_2:
        j       .LBB9_1
.LBB9_3:
        lw      a0, -12(s0)
        lui     a1, %hi(UART_TX_ADDR)
        lw      a1, %lo(UART_TX_ADDR)(a1)
        sw      a0, 0(a1)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

uart_send_dec:
        addi    sp, sp, -64
        sw      ra, 60(sp)
        sw      s0, 56(sp)
        addi    s0, sp, 64
        sw      a0, -12(s0)
        li      a0, 0
        sw      a0, -56(s0)
        j       .LBB10_1
.LBB10_1:
        lw      a0, -12(s0)
        lui     a1, 838861
        addi    a1, a1, -819
        mulhu   a2, a0, a1
        srli    a2, a2, 3
        li      a3, 10
        mul     a2, a2, a3
        sub     a0, a0, a2
        lw      a2, -56(s0)
        slli    a3, a2, 2
        addi    a2, s0, -52
        add     a2, a2, a3
        sw      a0, 0(a2)
        lw      a0, -12(s0)
        mulhu   a0, a0, a1
        srli    a0, a0, 3
        sw      a0, -12(s0)
        lw      a0, -56(s0)
        addi    a0, a0, 1
        sw      a0, -56(s0)
        j       .LBB10_2
.LBB10_2:
        lw      a0, -12(s0)
        bnez    a0, .LBB10_1
        j       .LBB10_3
.LBB10_3:
        j       .LBB10_4
.LBB10_4:
        lw      a0, -56(s0)
        beqz    a0, .LBB10_6
        j       .LBB10_5
.LBB10_5:
        lw      a0, -56(s0)
        addi    a0, a0, -1
        sw      a0, -56(s0)
        lw      a0, -56(s0)
        slli    a1, a0, 2
        addi    a0, s0, -52
        add     a0, a0, a1
        lw      a0, 0(a0)
        addi    a0, a0, 48
        call    uart_send_char
        j       .LBB10_4
.LBB10_6:
        lw      ra, 60(sp)
        lw      s0, 56(sp)
        addi    sp, sp, 64
        ret

delay:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        sw      a0, -16(s0)
        j       .LBB11_1
.LBB11_1:
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        lw      a1, -16(s0)
        sub     a0, a0, a1
        lw      a1, -12(s0)
        bgeu    a0, a1, .LBB11_3
        j       .LBB11_2
.LBB11_2:
        j       .LBB11_1
.LBB11_3:
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

.data
CYCLECOUNT_ADDR:
        .word   4294901920

UART_TX_ready_ADDR:
        .word   4294901768

UART_TX_ADDR:
        .word   4294901772

table:
        .space   160

sieve:
        .space   4096