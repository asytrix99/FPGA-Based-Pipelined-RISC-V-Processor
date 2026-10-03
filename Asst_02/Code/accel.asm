main:
        lui     sp, 65552
        addi    sp, sp, 512
        addi    sp, sp, -224
        sw      ra, 220(sp)
        sw      s0, 216(sp)
        addi    s0, sp, 224
        li      a0, 0
        sw      a0, -12(s0)
        lui     a0, 1048560
        addi    a1, a0, 64
        sw      a1, -16(s0)
        addi    a1, a0, 96
        sw      a1, -20(s0)
        addi    a0, a0, 128
        sw      a0, -24(s0)
        j       .LBB0_1
.LBB0_1:
        lw      a0, -16(s0)
        lw      a0, 0(a0)
        sw      a0, -28(s0)
        li      a0, 0
        sw      a0, -32(s0)
        lw      a0, -28(s0)
        lw      a1, -24(s0)
        sw      a0, 0(a1)
        li      a0, 84
        call    uart_send_char
        li      a0, 61
        sw      a0, -180(s0)
        call    uart_send_char
        li      a0, 255
        sw      a0, -36(s0)
        li      a0, 24
        sw      a0, -40(s0)
        lw      a0, -28(s0)
        lw      a1, -40(s0)
        srl     a0, a0, a1
        lw      a1, -36(s0)
        and     a0, a0, a1
        sw      a0, -44(s0)
        lw      a0, -44(s0)
        call    uart_send_hex_byte
        li      a0, 32
        sw      a0, -184(s0)
        call    uart_send_char
        li      a0, 88
        call    uart_send_char
        lw      a0, -180(s0)
        call    uart_send_char
        lw      a0, -28(s0)
        srli    a0, a0, 16
        andi    a0, a0, 255
        sw      a0, -48(s0)
        lw      a0, -48(s0)
        call    uart_send_hex_byte
        lw      a0, -184(s0)
        call    uart_send_char
        li      a0, 89
        call    uart_send_char
        lw      a0, -180(s0)
        call    uart_send_char
        lw      a0, -28(s0)
        srli    a0, a0, 8
        andi    a0, a0, 255
        sw      a0, -52(s0)
        lw      a0, -52(s0)
        call    uart_send_hex_byte
        lw      a0, -184(s0)
        call    uart_send_char
        li      a0, 90
        call    uart_send_char
        lw      a0, -180(s0)
        call    uart_send_char
        lw      a0, -28(s0)
        andi    a0, a0, 255
        sw      a0, -56(s0)
        lw      a0, -56(s0)
        call    uart_send_hex_byte
        li      a0, -256
        sw      a0, -60(s0)
        lw      a0, -48(s0)
        andi    a0, a0, 128
        beqz    a0, .LBB0_3
        j       .LBB0_2
.LBB0_2:
        lw      a0, -48(s0)
        lw      a1, -60(s0)
        or      a0, a0, a1
        sw      a0, -188(s0)
        j       .LBB0_4
.LBB0_3:
        lw      a0, -48(s0)
        sw      a0, -188(s0)
        j       .LBB0_4
.LBB0_4:
        lw      a0, -188(s0)
        sw      a0, -64(s0)
        lw      a0, -52(s0)
        andi    a0, a0, 128
        beqz    a0, .LBB0_6
        j       .LBB0_5
.LBB0_5:
        lw      a0, -52(s0)
        ori     a0, a0, -256
        sw      a0, -192(s0)
        j       .LBB0_7
.LBB0_6:
        lw      a0, -52(s0)
        sw      a0, -192(s0)
        j       .LBB0_7
.LBB0_7:
        lw      a0, -192(s0)
        sw      a0, -68(s0)
        lw      a0, -56(s0)
        andi    a0, a0, 128
        beqz    a0, .LBB0_9
        j       .LBB0_8
.LBB0_8:
        lw      a0, -56(s0)
        ori     a0, a0, -256
        sw      a0, -196(s0)
        j       .LBB0_10
.LBB0_9:
        lw      a0, -56(s0)
        sw      a0, -196(s0)
        j       .LBB0_10
.LBB0_10:
        lw      a0, -196(s0)
        sw      a0, -72(s0)
        li      a0, 1
        sw      a0, -76(s0)
        lw      a0, -64(s0)
        srai    a0, a0, 1
        sw      a0, -80(s0)
        lw      a0, -68(s0)
        srai    a0, a0, 1
        sw      a0, -84(s0)
        lw      a0, -72(s0)
        lw      a1, -76(s0)
        sra     a0, a0, a1
        sw      a0, -88(s0)
        lw      a0, -64(s0)
        bgez    a0, .LBB0_12
        j       .LBB0_11
.LBB0_11:
        lw      a1, -64(s0)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, -200(s0)
        j       .LBB0_13
.LBB0_12:
        lw      a0, -64(s0)
        sw      a0, -200(s0)
        j       .LBB0_13
.LBB0_13:
        lw      a0, -200(s0)
        sw      a0, -92(s0)
        lw      a0, -68(s0)
        bgez    a0, .LBB0_15
        j       .LBB0_14
.LBB0_14:
        lw      a1, -68(s0)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, -204(s0)
        j       .LBB0_16
.LBB0_15:
        lw      a0, -68(s0)
        sw      a0, -204(s0)
        j       .LBB0_16
.LBB0_16:
        lw      a0, -204(s0)
        sw      a0, -96(s0)
        lw      a0, -72(s0)
        bgez    a0, .LBB0_18
        j       .LBB0_17
.LBB0_17:
        lw      a1, -72(s0)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, -208(s0)
        j       .LBB0_19
.LBB0_18:
        lw      a0, -72(s0)
        sw      a0, -208(s0)
        j       .LBB0_19
.LBB0_19:
        lw      a0, -208(s0)
        sw      a0, -100(s0)
        lw      a0, -92(s0)
        lw      a1, -96(s0)
        add     a0, a0, a1
        lw      a1, -100(s0)
        add     a0, a0, a1
        sw      a0, -32(s0)
        li      a0, 32
        call    uart_send_char
        li      a0, 77
        call    uart_send_char
        li      a0, 61
        call    uart_send_char
        lw      a0, -32(s0)
        call    uart_send_hex_halfword
        lw      a0, -92(s0)
        sw      a0, -104(s0)
        li      a0, 88
        sw      a0, -108(s0)
        lw      a1, -96(s0)
        lw      a0, -104(s0)
        bgeu    a0, a1, .LBB0_21
        j       .LBB0_20
.LBB0_20:
        lw      a0, -96(s0)
        sw      a0, -104(s0)
        li      a0, 89
        sw      a0, -108(s0)
        j       .LBB0_21
.LBB0_21:
        lw      a1, -100(s0)
        lw      a0, -104(s0)
        bgeu    a0, a1, .LBB0_23
        j       .LBB0_22
.LBB0_22:
        lw      a0, -100(s0)
        sw      a0, -104(s0)
        li      a0, 90
        sw      a0, -108(s0)
        j       .LBB0_23
.LBB0_23:
        li      a0, 32
        sw      a0, -216(s0)
        call    uart_send_char
        li      a0, 65
        call    uart_send_char
        li      a0, 61
        sw      a0, -212(s0)
        call    uart_send_char
        lw      a0, -108(s0)
        call    uart_send_char
        lw      a0, -216(s0)
        call    uart_send_char
        li      a0, 83
        call    uart_send_char
        lw      a0, -212(s0)
        call    uart_send_char
        li      a0, 60
        sw      a0, -112(s0)
        lw      a0, -32(s0)
        sltiu   a0, a0, 20
        sw      a0, -116(s0)
        lw      a0, -32(s0)
        lw      a1, -112(s0)
        sltu    a0, a0, a1
        sw      a0, -120(s0)
        lw      a0, -64(s0)
        lw      a1, -68(s0)
        slt     a0, a0, a1
        sw      a0, -124(s0)
        lw      a0, -64(s0)
        slti    a0, a0, 10
        sw      a0, -128(s0)
        lw      a0, -116(s0)
        lw      a1, -120(s0)
        slli    a1, a1, 1
        or      a0, a0, a1
        lw      a1, -124(s0)
        slli    a1, a1, 2
        or      a0, a0, a1
        lw      a1, -128(s0)
        slli    a1, a1, 3
        or      a0, a0, a1
        lw      a1, -20(s0)
        sw      a0, 0(a1)
        lw      a1, -32(s0)
        li      a0, 19
        bltu    a0, a1, .LBB0_25
        j       .LBB0_24
.LBB0_24:
        li      a0, 76
        call    uart_send_char
        j       .LBB0_29
.LBB0_25:
        lw      a0, -120(s0)
        beqz    a0, .LBB0_27
        j       .LBB0_26
.LBB0_26:
        li      a0, 77
        call    uart_send_char
        j       .LBB0_28
.LBB0_27:
        li      a0, 72
        call    uart_send_char
        j       .LBB0_28
.LBB0_28:
        j       .LBB0_29
.LBB0_29:
        lw      a1, -28(s0)
        lw      a2, -80(s0)
        lw      a3, -84(s0)
        lw      a4, -88(s0)
        addi    a0, s0, -152
        call    make_packet
        lw      a0, -132(s0)
        sw      a0, -156(s0)
        lw      a0, -136(s0)
        sw      a0, -160(s0)
        lw      a0, -140(s0)
        sw      a0, -164(s0)
        lw      a0, -144(s0)
        sw      a0, -168(s0)
        lw      a0, -148(s0)
        sw      a0, -172(s0)
        lw      a0, -152(s0)
        sw      a0, -176(s0)
        addi    a0, s0, -176
        call    uart_send_packet
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

uart_send_hex_halfword:
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

make_packet:
        addi    sp, sp, -48
        sw      ra, 44(sp)
        sw      s0, 40(sp)
        addi    s0, sp, 48
        sw      a1, -36(s0)
        mv      a1, a0
        lw      a0, -36(s0)
        sw      a1, -12(s0)
        sw      a0, -16(s0)
        sw      a2, -20(s0)
        sw      a3, -24(s0)
        sw      a4, -28(s0)
        li      a0, 0
        sw      a0, 20(a1)
        sw      a0, 16(a1)
        sw      a0, 12(a1)
        sw      a0, 8(a1)
        sw      a0, 4(a1)
        sw      a0, 0(a1)
        li      a0, 103
        sw      a0, 0(a1)
        li      a0, 24
        sw      a0, -32(s0)
        lw      a0, -16(s0)
        lw      a2, -32(s0)
        srl     a0, a0, a2
        lw      a2, -16(s0)
        srli    a3, a2, 16
        xor     a0, a0, a3
        srli    a3, a2, 8
        xor     a0, a0, a3
        xor     a0, a0, a2
        andi    a0, a0, 255
        xori    a0, a0, 103
        sw      a0, 4(a1)
        lw      a0, -16(s0)
        sw      a0, 8(a1)
        lw      a0, -20(s0)
        sw      a0, 12(a1)
        lw      a0, -24(s0)
        sw      a0, 16(a1)
        lw      a0, -28(s0)
        sw      a0, 20(a1)
        lw      ra, 44(sp)
        lw      s0, 40(sp)
        addi    sp, sp, 48
        ret

uart_send_packet:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -16(s0)
        sw      a0, -12(s0)
        lw      a0, 0(a0)
        call    uart_send_byte
        lw      a0, -16(s0)
        lw      a0, 4(a0)
        call    uart_send_byte
        li      a0, 0
        sw      a0, -20(s0)
        call    uart_send_byte
        lw      a0, -20(s0)
        call    uart_send_byte
        lw      a0, -16(s0)
        lw      a0, 8(a0)
        call    uart_send_u32
        lw      a0, -16(s0)
        lw      a0, 12(a0)
        call    uart_send_u32
        lw      a0, -16(s0)
        lw      a0, 16(a0)
        call    uart_send_u32
        lw      a0, -16(s0)
        lw      a0, 20(a0)
        call    uart_send_u32
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
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
        j       .LBB6_1
.LBB6_1:
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        lw      a1, -16(s0)
        lw      a2, -12(s0)
        add     a1, a1, a2
        bgeu    a0, a1, .LBB6_3
        j       .LBB6_2
.LBB6_2:
        j       .LBB6_1
.LBB6_3:
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

uart_send_byte:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -12(s0)
        li      a0, 255
        sw      a0, -16(s0)
        lw      a0, -12(s0)
        lw      a1, -16(s0)
        and     a0, a0, a1
        sw      a0, -20(s0)
        j       .LBB7_1
.LBB7_1:
        lui     a0, %hi(UART_TX_ready_ADDR)
        lw      a0, %lo(UART_TX_ready_ADDR)(a0)
        lw      a0, 0(a0)
        bnez    a0, .LBB7_3
        j       .LBB7_2
.LBB7_2:
        j       .LBB7_1
.LBB7_3:
        lw      a0, -20(s0)
        lui     a1, %hi(UART_TX_ADDR)
        lw      a1, %lo(UART_TX_ADDR)(a1)
        sw      a0, 0(a1)
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

uart_send_hex_digit:
        addi    sp, sp, -16
        sw      ra, 12(sp)
        sw      s0, 8(sp)
        addi    s0, sp, 16
        sw      a0, -12(s0)
        lw      a1, -12(s0)
        li      a0, 9
        bltu    a0, a1, .LBB8_2
        j       .LBB8_1
.LBB8_1:
        lw      a0, -12(s0)
        addi    a0, a0, 48
        call    uart_send_char
        j       .LBB8_3
.LBB8_2:
        lw      a0, -12(s0)
        addi    a0, a0, 55
        call    uart_send_char
        j       .LBB8_3
.LBB8_3:
        lw      ra, 12(sp)
        lw      s0, 8(sp)
        addi    sp, sp, 16
        ret

uart_send_u32:
        addi    sp, sp, -32
        sw      ra, 28(sp)
        sw      s0, 24(sp)
        addi    s0, sp, 32
        sw      a0, -12(s0)
        li      a0, 24
        sw      a0, -16(s0)
        li      a0, 16
        sw      a0, -20(s0)
        li      a0, 8
        sw      a0, -24(s0)
        li      a0, 255
        sw      a0, -28(s0)
        lw      a0, -12(s0)
        lw      a1, -16(s0)
        srl     a0, a0, a1
        lw      a1, -28(s0)
        and     a0, a0, a1
        call    uart_send_byte
        lw      a0, -12(s0)
        lw      a1, -20(s0)
        srl     a0, a0, a1
        lw      a1, -28(s0)
        and     a0, a0, a1
        call    uart_send_byte
        lw      a0, -12(s0)
        lw      a1, -24(s0)
        srl     a0, a0, a1
        lw      a1, -28(s0)
        and     a0, a0, a1
        call    uart_send_byte
        lw      a0, -12(s0)
        lw      a1, -28(s0)
        and     a0, a0, a1
        call    uart_send_byte
        lw      ra, 28(sp)
        lw      s0, 24(sp)
        addi    sp, sp, 32
        ret

.data
CYCLECOUNT_ADDR:
        .word   4294901920

UART_TX_ready_ADDR:
        .word   4294901768

UART_TX_ADDR:
        .word   4294901772
