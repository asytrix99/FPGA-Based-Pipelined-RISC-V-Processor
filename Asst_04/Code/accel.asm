main:
        addi    sp, sp, -256
        sw      ra, 252(sp)
        sw      s0, 248(sp)
        addi    s0, sp, 256
        li      a0, 0
        sw      a0, 244(sp)
        lui     sp, 65552
        addi    sp, sp, 512
        lui     a0, 1048560
        addi    a1, a0, 64
        sw      a1, 240(sp)
        addi    a1, a0, 96
        sw      a1, 236(sp)
        addi    a0, a0, 128
        sw      a0, 232(sp)
        j       .LBB0_1
.LBB0_1:
        lw      a0, 240(sp)
        lw      a0, 0(a0)
        sw      a0, 228(sp)
        li      a0, 0
        sw      a0, 224(sp)
        lw      a0, 228(sp)
        lw      a1, 232(sp)
        sw      a0, 0(a1)
        li      a0, 84
        call    uart_send_char
        li      a0, 61
        sw      a0, 52(sp)
        call    uart_send_char
        li      a0, 255
        sw      a0, 220(sp)
        li      a0, 24
        sw      a0, 216(sp)
        lw      a0, 228(sp)
        lw      a1, 216(sp)
        srl     a0, a0, a1
        lw      a1, 220(sp)
        and     a0, a0, a1
        sw      a0, 212(sp)
        lw      a0, 212(sp)
        call    uart_send_hex_byte
        li      a0, 32
        sw      a0, 48(sp)
        call    uart_send_char
        li      a0, 88
        call    uart_send_char
        lw      a0, 52(sp)
        call    uart_send_char
        lbu     a0, 230(sp)
        sw      a0, 208(sp)
        lw      a0, 208(sp)
        call    uart_send_hex_byte
        lw      a0, 48(sp)
        call    uart_send_char
        li      a0, 89
        call    uart_send_char
        lw      a0, 52(sp)
        call    uart_send_char
        lbu     a0, 229(sp)
        sw      a0, 204(sp)
        lw      a0, 204(sp)
        call    uart_send_hex_byte
        lw      a0, 48(sp)
        call    uart_send_char
        li      a0, 90
        call    uart_send_char
        lw      a0, 52(sp)
        call    uart_send_char
        lbu     a0, 228(sp)
        sw      a0, 200(sp)
        lw      a0, 200(sp)
        call    uart_send_hex_byte
        li      a0, -256
        sw      a0, 196(sp)
        lbu     a0, 208(sp)
        andi    a0, a0, 128
        beqz    a0, .LBB0_3
        j       .LBB0_2
.LBB0_2:
        lw      a0, 208(sp)
        lw      a1, 196(sp)
        or      a0, a0, a1
        sw      a0, 44(sp)
        j       .LBB0_4
.LBB0_3:
        lw      a0, 208(sp)
        sw      a0, 44(sp)
        j       .LBB0_4
.LBB0_4:
        lw      a0, 44(sp)
        sw      a0, 192(sp)
        lbu     a0, 204(sp)
        andi    a0, a0, 128
        beqz    a0, .LBB0_6
        j       .LBB0_5
.LBB0_5:
        lw      a0, 204(sp)
        ori     a0, a0, -256
        sw      a0, 40(sp)
        j       .LBB0_7
.LBB0_6:
        lw      a0, 204(sp)
        sw      a0, 40(sp)
        j       .LBB0_7
.LBB0_7:
        lw      a0, 40(sp)
        sw      a0, 188(sp)
        lbu     a0, 200(sp)
        andi    a0, a0, 128
        beqz    a0, .LBB0_9
        j       .LBB0_8
.LBB0_8:
        lw      a0, 200(sp)
        ori     a0, a0, -256
        sw      a0, 36(sp)
        j       .LBB0_10
.LBB0_9:
        lw      a0, 200(sp)
        sw      a0, 36(sp)
        j       .LBB0_10
.LBB0_10:
        lw      a0, 36(sp)
        sw      a0, 184(sp)
        li      a0, 1
        sw      a0, 180(sp)
        lw      a0, 192(sp)
        srai    a0, a0, 1
        sw      a0, 176(sp)
        lw      a0, 188(sp)
        srai    a0, a0, 1
        sw      a0, 172(sp)
        lw      a0, 184(sp)
        lw      a1, 180(sp)
        sra     a0, a0, a1
        sw      a0, 168(sp)
        lw      a0, 192(sp)
        bgez    a0, .LBB0_12
        j       .LBB0_11
.LBB0_11:
        lw      a1, 192(sp)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, 32(sp)
        j       .LBB0_13
.LBB0_12:
        lw      a0, 192(sp)
        sw      a0, 32(sp)
        j       .LBB0_13
.LBB0_13:
        lw      a0, 32(sp)
        sw      a0, 164(sp)
        lw      a0, 188(sp)
        bgez    a0, .LBB0_15
        j       .LBB0_14
.LBB0_14:
        lw      a1, 188(sp)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, 28(sp)
        j       .LBB0_16
.LBB0_15:
        lw      a0, 188(sp)
        sw      a0, 28(sp)
        j       .LBB0_16
.LBB0_16:
        lw      a0, 28(sp)
        sw      a0, 160(sp)
        lw      a0, 184(sp)
        bgez    a0, .LBB0_18
        j       .LBB0_17
.LBB0_17:
        lw      a1, 184(sp)
        li      a0, 0
        sub     a0, a0, a1
        sw      a0, 24(sp)
        j       .LBB0_19
.LBB0_18:
        lw      a0, 184(sp)
        sw      a0, 24(sp)
        j       .LBB0_19
.LBB0_19:
        lw      a0, 24(sp)
        sw      a0, 156(sp)
        lw      a0, 164(sp)
        lw      a1, 160(sp)
        add     a0, a0, a1
        lw      a1, 156(sp)
        add     a0, a0, a1
        sw      a0, 224(sp)
        li      a0, 32
        call    uart_send_char
        li      a0, 77
        call    uart_send_char
        li      a0, 61
        call    uart_send_char
        lw      a0, 224(sp)
        call    uart_send_hex_halfword
        lw      a0, 164(sp)
        sw      a0, 152(sp)
        li      a0, 88
        sw      a0, 148(sp)
        lw      a1, 160(sp)
        lw      a0, 152(sp)
        bgeu    a0, a1, .LBB0_21
        j       .LBB0_20
.LBB0_20:
        lw      a0, 160(sp)
        sw      a0, 152(sp)
        li      a0, 89
        sw      a0, 148(sp)
        j       .LBB0_21
.LBB0_21:
        lw      a1, 156(sp)
        lw      a0, 152(sp)
        bgeu    a0, a1, .LBB0_23
        j       .LBB0_22
.LBB0_22:
        lw      a0, 156(sp)
        sw      a0, 152(sp)
        li      a0, 90
        sw      a0, 148(sp)
        j       .LBB0_23
.LBB0_23:
        li      a0, 32
        sw      a0, 16(sp)
        call    uart_send_char
        li      a0, 65
        call    uart_send_char
        li      a0, 61
        sw      a0, 20(sp)
        call    uart_send_char
        lw      a0, 148(sp)
        call    uart_send_char
        lw      a0, 16(sp)
        call    uart_send_char
        li      a0, 83
        call    uart_send_char
        lw      a0, 20(sp)
        call    uart_send_char
        li      a0, 60
        sw      a0, 144(sp)
        lw      a0, 224(sp)
        sltiu   a0, a0, 20
        sw      a0, 140(sp)
        lw      a0, 224(sp)
        lw      a1, 144(sp)
        sltu    a0, a0, a1
        sw      a0, 136(sp)
        lw      a0, 192(sp)
        lw      a1, 188(sp)
        slt     a0, a0, a1
        sw      a0, 132(sp)
        lw      a0, 192(sp)
        slti    a0, a0, 10
        sw      a0, 128(sp)
        lw      a0, 140(sp)
        lw      a1, 136(sp)
        slli    a1, a1, 1
        or      a0, a0, a1
        lw      a1, 132(sp)
        slli    a1, a1, 2
        or      a0, a0, a1
        lw      a1, 128(sp)
        slli    a1, a1, 3
        or      a0, a0, a1
        lw      a1, 236(sp)
        sw      a0, 0(a1)
        lw      a1, 224(sp)
        li      a0, 19
        bltu    a0, a1, .LBB0_25
        j       .LBB0_24
.LBB0_24:
        li      a0, 76
        call    uart_send_char
        j       .LBB0_29
.LBB0_25:
        lw      a0, 136(sp)
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
        lw      a0, 192(sp)
        mul     a1, a0, a0
        mulh    a0, a0, a0
        lw      a3, 188(sp)
        mul     a2, a3, a3
        mulh    a3, a3, a3
        add     a0, a0, a3
        add     a2, a2, a1
        sltu    a1, a2, a1
        add     a0, a0, a1
        lw      a1, 184(sp)
        mulh    a3, a1, a1
        mul     a1, a1, a1
        add     a1, a1, a2
        sltu    a2, a1, a2
        add     a0, a0, a3
        add     a0, a0, a2
        sw      a1, 120(sp)
        sw      a0, 124(sp)
        li      a0, 3
        sw      a0, 116(sp)
        lw      a1, 120(sp)
        lw      a2, 116(sp)
        div     a1, a1, a2
        sw      a1, 112(sp)
        sw      a0, 108(sp)
        lw      a0, 224(sp)
        lw      a1, 108(sp)
        divu    a0, a0, a1
        sw      a0, 104(sp)
        li      a0, 32
        sw      a0, 0(sp)
        call    uart_send_char
        li      a0, 77
        call    uart_send_char
        li      a0, 65
        sw      a0, 4(sp)
        call    uart_send_char
        li      a0, 71
        sw      a0, 8(sp)
        call    uart_send_char
        li      a0, 61
        sw      a0, 12(sp)
        call    uart_send_char
        lw      a0, 112(sp)
        call    uart_send_hex_halfword
        lw      a0, 0(sp)
        call    uart_send_char
        lw      a0, 4(sp)
        call    uart_send_char
        li      a0, 86
        call    uart_send_char
        lw      a0, 8(sp)
        call    uart_send_char
        lw      a0, 12(sp)
        call    uart_send_char
        lw      a0, 104(sp)
        call    uart_send_hex_halfword
        lw      a1, 228(sp)
        lw      a2, 176(sp)
        lw      a3, 172(sp)
        lw      a4, 168(sp)
        addi    a0, sp, 80
        call    make_packet
        lw      a0, 100(sp)
        sw      a0, 76(sp)
        lw      a0, 96(sp)
        sw      a0, 72(sp)
        lw      a0, 92(sp)
        sw      a0, 68(sp)
        lw      a0, 88(sp)
        sw      a0, 64(sp)
        lw      a0, 84(sp)
        sw      a0, 60(sp)
        lw      a0, 80(sp)
        sw      a0, 56(sp)
        addi    a0, sp, 56
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
        sw      a0, 4(sp)
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
        lw      a0, 4(sp)
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
        sw      a0, 4(sp)
        lw      a0, 4(sp)
        slli    a0, a0, 24
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, 4(sp)
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
        sw      a0, 4(sp)
        lw      a0, 4(sp)
        slli    a0, a0, 16
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, 4(sp)
        slli    a0, a0, 20
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, 4(sp)
        slli    a0, a0, 24
        srli    a0, a0, 28
        call    uart_send_hex_digit
        lw      a0, 4(sp)
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
        sw      a1, 12(sp)
        mv      a1, a0
        lw      a0, 12(sp)
        sw      a1, 36(sp)
        sw      a0, 32(sp)
        sw      a2, 28(sp)
        sw      a3, 24(sp)
        sw      a4, 20(sp)
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
        sw      a0, 16(sp)
        lw      a0, 32(sp)
        lw      a2, 16(sp)
        srl     a0, a0, a2
        lw      a2, 32(sp)
        srli    a3, a2, 16
        xor     a0, a0, a3
        srli    a3, a2, 8
        xor     a0, a0, a3
        xor     a0, a0, a2
        zext.b  a0, a0
        xori    a0, a0, 103
        sw      a0, 4(a1)
        lw      a0, 32(sp)
        sw      a0, 8(a1)
        lw      a0, 28(sp)
        sw      a0, 12(a1)
        lw      a0, 24(sp)
        sw      a0, 16(a1)
        lw      a0, 20(sp)
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
        sw      a0, 16(sp)
        sw      a0, 20(sp)
        lw      a0, 0(a0)
        call    uart_send_byte
        lw      a0, 16(sp)
        lw      a0, 4(a0)
        call    uart_send_byte
        li      a0, 0
        sw      a0, 12(sp)
        call    uart_send_byte
        lw      a0, 12(sp)
        call    uart_send_byte
        lw      a0, 16(sp)
        lw      a0, 8(a0)
        call    uart_send_u32
        lw      a0, 16(sp)
        lw      a0, 12(a0)
        call    uart_send_u32
        lw      a0, 16(sp)
        lw      a0, 16(a0)
        call    uart_send_u32
        lw      a0, 16(sp)
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
        sw      a0, 4(sp)
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        sw      a0, 0(sp)
        j       .LBB6_1
.LBB6_1:
        lui     a0, %hi(CYCLECOUNT_ADDR)
        lw      a0, %lo(CYCLECOUNT_ADDR)(a0)
        lw      a0, 0(a0)
        lw      a1, 0(sp)
        lw      a2, 4(sp)
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
        sw      a0, 20(sp)
        li      a0, 255
        sw      a0, 16(sp)
        lw      a0, 20(sp)
        lw      a1, 16(sp)
        and     a0, a0, a1
        sw      a0, 12(sp)
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
        lw      a0, 12(sp)
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
        sw      a0, 4(sp)
        lw      a1, 4(sp)
        li      a0, 9
        bltu    a0, a1, .LBB8_2
        j       .LBB8_1
.LBB8_1:
        lw      a0, 4(sp)
        addi    a0, a0, 48
        call    uart_send_char
        j       .LBB8_3
.LBB8_2:
        lw      a0, 4(sp)
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
        sw      a0, 20(sp)
        li      a0, 24
        sw      a0, 16(sp)
        li      a0, 16
        sw      a0, 12(sp)
        li      a0, 8
        sw      a0, 8(sp)
        li      a0, 255
        sw      a0, 4(sp)
        lw      a0, 20(sp)
        lw      a1, 16(sp)
        srl     a0, a0, a1
        lw      a1, 4(sp)
        and     a0, a0, a1
        call    uart_send_byte
        lw      a0, 20(sp)
        lw      a1, 12(sp)
        srl     a0, a0, a1
        lw      a1, 4(sp)
        and     a0, a0, a1
        call    uart_send_byte
        lw      a0, 20(sp)
        lw      a1, 8(sp)
        srl     a0, a0, a1
        lw      a1, 4(sp)
        and     a0, a0, a1
        call    uart_send_byte
        lw      a0, 20(sp)
        lw      a1, 4(sp)
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
