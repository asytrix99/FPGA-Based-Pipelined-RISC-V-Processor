`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/26/2026 11:55:18 PM
// Design Name: 
// Module Name: test_Wrapper
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_Wrapper #(
    parameter N_LEDs_OUT = 8,
    parameter N_DIPs = 16,
    parameter N_PBs = 3 )();

    // Wrapper inputs
    reg [N_DIPs-1:0] DIP = 0;
    reg [N_PBs-1:0]  PB = 0;
    reg UART_TX_ready = 1;
    reg [7:0] UART_RX = 0;
    reg UART_RX_valid = 0;
    reg [31:0] ACCEL_Data = 32'h3405FD7F;
    reg ACCEL_DReady = 1;
    reg RESET = 0;
    reg CLK = 0;

    // Wrapper outputs
    wire [N_LEDs_OUT-1:0] LED_OUT;
    wire [6:0] LED_PC;
    wire [31:0] SEVENSEGHEX;
    wire [7:0] UART_TX;
    wire UART_TX_valid;
    wire UART_RX_ack;
    wire OLED_Write;
    wire [6:0] OLED_Col;
    wire [5:0] OLED_Row;
    wire [23:0] OLED_Data;

    // Instantiate the same Wrapper used by the real design
    Wrapper dut (
        DIP,
        PB,
        LED_OUT,
        LED_PC,
        SEVENSEGHEX,
        UART_TX,
        UART_TX_ready,
        UART_TX_valid,
        UART_RX,
        UART_RX_valid,
        UART_RX_ack,
        OLED_Write,
        OLED_Col,
        OLED_Row,
        OLED_Data,
        ACCEL_Data,
        ACCEL_DReady,
        RESET,
        CLK
    );

    // 100 MHz clock, 10 ns per cycle
    always #5 CLK = ~CLK;

    // Expected first UART line from ACCEL_Data = 0x3405FD7F:
    // T=34 X=05 Y=FD Z=7F M=0087
    reg [7:0] expected [0:28];
    integer uart_index = 0;
    integer errors = 0;

    initial begin
    expected[ 0] = "T";
    expected[ 1] = "=";
    expected[ 2] = "3";
    expected[ 3] = "4";
    expected[ 4] = " ";
    expected[ 5] = "X";
    expected[ 6] = "=";
    expected[ 7] = "0";
    expected[ 8] = "5";
    expected[ 9] = " ";
    expected[10] = "Y";
    expected[11] = "=";
    expected[12] = "F";
    expected[13] = "D";
    expected[14] = " ";
    expected[15] = "Z";
    expected[16] = "=";
    expected[17] = "7";
    expected[18] = "F";
    expected[19] = " ";
    expected[20] = "M";
    expected[21] = "=";
    expected[22] = "0";
    expected[23] = "0";
    expected[24] = "8";
    expected[25] = "7";
    expected[26] = 8'h0D;
    expected[27] = 8'h0A;
    end

    // Reset and fixed external stimulus
    initial begin
        RESET = 1;
        #20;
        RESET = 0;
    end

    // Capture each CPU UART write on the rising edge of UART_TX_valid.
    always @(posedge UART_TX_valid) begin
        if (!RESET) begin
            if (uart_index <= 27) begin
                if (UART_TX !== expected[uart_index]) begin
                    $display("FAIL UART[%0d]: expected 0x%02h ('%c'), got 0x%02h ('%c') at %0t", uart_index, expected[uart_index], expected[uart_index], UART_TX, UART_TX, $time);
                    errors = errors + 1;
                end
                else begin
                    $display("UART[%0d] OK: 0x%02h ('%c')", uart_index, UART_TX, UART_TX);
                end

                uart_index = uart_index + 1;

                if (uart_index == 28) begin
                    if (SEVENSEGHEX !== 32'h3405FD7F) begin
                        $display("FAIL SEVENSEGHEX: expected 3405FD7F, got %08h", SEVENSEGHEX);
                        errors = errors + 1;
                    end

                    if (errors == 0) begin
                        $display("============================================================");
                        $display("TEST PASSED");
                        $display("UART: T=34 X=05 Y=FD Z=7F M=0087");
                        $display("SEVENSEGHEX: 3405FD7F");
                        $display("============================================================");
                    end
                    else begin
                        $display("============================================================");
                        $display("FAIL: accel.asm completed with %0d mismatch(es)", errors);
                        $display("============================================================");
                    end
                    $finish;
                end
            end
        end
    end

endmodule