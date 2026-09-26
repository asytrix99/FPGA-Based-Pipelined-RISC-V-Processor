main:
        lui     sp, 65552
        addi    sp, sp, 512
        addi    sp, sp, -112
        sw      ra, 108(sp)
        sw      s0, 104(sp)
        addi    s0, sp, 112
        li      a0, 0
        sw      a0, -12(s0)
        lui     a0, 1048560
        addi    a1, a0, 64
        sw      a1, -16(s0)
        addi    a0, a0, 128
        sw      a0, -20(s0)
        j       .LBB0_1
.LBB0_1:
        lw      a0, -16(s0)
        lw      a0, 0(a0)
        sw      a0, -24(s0)
        li      a0, 0
        sw      a0, -28(s0)
        lw      a0, -24(s0)
        lw      a1, -20(s0)
        sw      a0, 0(a1)
        li      a0, 84
        call    uart_send_char
        li      a0, 61
        sw      a0, -72(s0)
        call    uart_send_char
        lw      a0, -24(s0)
        srli    a0, a0, 24
        andi    a0, a0, 255
        sw      a0, -32(s0)
        lw      a0, -32(s0)
        call    uart_send_hex_byte
        li      a0, 32
        sw      a0, -76(s0)
        call    uart_send_char
        li      a0, 88
        call    uart_send_char
        lw      a0, -72(s0)
        call    uart_send_char
        lw      a0, -24(s0)
        srli    a0, a0, 16
        andi    a0, a0, 255
        sw      a0, -36(s0)
        lw      a0, -36(s0)
        call    uart_send_hex_byte
        lw      a0, -76(s0)
        call    uart_send_char
        li      a0, 89
        call    uart_send_char
        lw      a0, -72(s0)
        call    uart_send_char
        lw      a0, -24(s0)
        srli    a0, a0, 8
        andi    a0, a0, 255
        sw      a0, -40(s0)
        lw      a0, -40(s0)
        call    uart_send_hex_byte
        lw      a0, -76(s0)
        call    uart_send_char
        li      a0, 90
        call    uart_send_char
        lw      a0, -72(s0)
        call    uart_send_char
        lw      a0, -24(s0)
        andi    a0, a0, 255
        sw      a0, -44(s0)
        lw      a0, -44(s0)
        call    uart_send_hex_byte
        lw      a0, -36(s0)
        andi    a0, a0, 128
        beqz    a0, .LBB0_3
        j       .LBB0_2
.LBB0_2:
        lw      a0, -36(s0)
        ori     a0, a0, -256
        sw      a0, -80(s0)
        j       .LBB0_4
.LBB0_3:
        lw      a0, -36(s0)
        sw      a0, -80(s0)
        j       .LBB0_4
.LBB0_4:
        lw      a0, -80(s0)
        sw      a0, -48(s0)
        lw      a0, -40(s0)
        andi    a0, a0, 128
        beqz    a0, .LBB0_6
        j       .LBB0_5
.LBB0_5:
        lw      a0, -40(s0)
        ori     a0, a0, -256
        sw      a0, -84(s0)
        j       .LBB0_7
.LBB0_6:
        lw      a0, -40(s0)
        sw      a0, -84(s0)
        j       .LBB0_7
.LBB0_7:
        lw      a0, -84(s0)
        sw      a0, -52(s0)
        lw      a0, -44(s0)
        andi    a0, a0, 128
        beqz    a0, .LBB0_9
        j       .LBB0_8
.LBB0_8:
        lw      a0, -44(s0)
        ori     a0, a0, -256
        sw      a0, -88(s0)
        j       .LBB0_10
.LBB0_9:
        lw      a0, -44(s0)
        sw      a0, -88(s0)
        j       .LBB0_10
.LBB0_10:
        lw      a0, -88(s0)
        sw      a0, -56(s0)
        lw      a0, -48(s0)
        bgez    a0, .LBB0_12
        j       .LBB0_11
.LBB0_11:
        lw      a1, -48(s0)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, -92(s0)
        j       .LBB0_13
.LBB0_12:
        lw      a0, -48(s0)
        sw      a0, -92(s0)
        j       .LBB0_13
.LBB0_13:
        lw      a0, -92(s0)
        sw      a0, -60(s0)
        lw      a0, -52(s0)
        bgez    a0, .LBB0_15
        j       .LBB0_14
.LBB0_14:
        lw      a1, -52(s0)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, -96(s0)
        j       .LBB0_16
.LBB0_15:
        lw      a0, -52(s0)
        sw      a0, -96(s0)
        j       .LBB0_16
.LBB0_16:
        lw      a0, -96(s0)
        sw      a0, -64(s0)
        lw      a0, -56(s0)
        bgez    a0, .LBB0_18
        j       .LBB0_17
.LBB0_17:
        lw      a1, -56(s0)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, -100(s0)
        j       .LBB0_19
.LBB0_18:
        lw      a0, -56(s0)
        sw      a0, -100(s0)
        j       .LBB0_19
.LBB0_19:
        lw      a0, -100(s0)
        sw      a0, -68(s0)
        lw      a0, -60(s0)
        lw      a1, -64(s0)
        add     a0, a0, a1
        lw      a1, -68(s0)
        add     a0, a0, a1
        sw      a0, -28(s0)
        li      a0, 32
        call    uart_send_char
        li      a0, 77
        call    uart_send_char
        li      a0, 61
        call    uart_send_char
        lw      a0, -28(s0)
        call    uart_send_hex_word
        li      a0, 13
        call    uart_send_char
        li      a0, 10
        call    uart_send_char
        lui     a0, 244
        addi    a0, a0, 576
        call    delay
        j       .LBB0_1

uart_send_char:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        j       .LBB1_1
.LBB1_1:
        lui     a0, %hi(UART_TX_ready_ADDR)
        lw      a0, %lo(UART_TX_ready_ADDR)(a0)
        lw      a0, 0(a0)
        bnez    a0, .LBB1_3
        j       .LBB1_2
.LBB1_2:
        j       .LBB1_1
.LBB1_3:
        lw      a0, -12(s0)
        lui     a1, %hi(UART_TX_ADDR)
        lw      a1, %lo(UART_TX_ADDR)(a1)
        sw      a0, 0(a1)
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

uart_send_hex_byte:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        lw      a0, -12(s0)
        slli    a0, a0, 24
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, -12(s0)
        andi    a0, a0, 15
        call    uart_send_hex_digit
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

uart_send_hex_word:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        lw      a0, -12(s0)
        slli    a0, a0, 16
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, -12(s0)
        slli    a0, a0, 20
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, -12(s0)
        slli    a0, a0, 24
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, -12(s0)
        andi    a0, a0, 15
        call    uart_send_hex_digit
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
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
        j       .LBB4_1
.LBB4_1:
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        lw      a1, -16(s0)
        lw      a2, -12(s0)
        add     a1, a1, a2
        bgeu    a0, a1, .LBB4_3
        j       .LBB4_2
.LBB4_2:
        j       .LBB4_1
.LBB4_3:
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

uart_send_hex_digit:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        lw      a1, -12(s0)
        li      a0, 9
        bltu    a0, a1, .LBB5_2
        j       .LBB5_1
.LBB5_1:
        lw      a0, -12(s0)
        addi    a0, a0, 48
        call    uart_send_char
        j       .LBB5_3
.LBB5_2:
        lw      a0, -12(s0)
        addi    a0, a0, 55
        call    uart_send_char
        j       .LBB5_3
.LBB5_3:
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret
        
.data	# The only line that needs to be added manually
CYCLECOUNT_ADDR:
        .word   4294901920

UART_TX_ready_ADDR:
        .word   4294901768

UART_TX_ADDR:
        .word   4294901772
