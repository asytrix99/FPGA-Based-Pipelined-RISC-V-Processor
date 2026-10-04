`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/04/2026 03:57:10 PM
// Design Name: 
// Module Name: test_MCycle_self_checking
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


/* // The following prompt was used with Claude Sonnet 5.5 with the following prompt, and the non-self-checking code, as in test_MCycle.v 
I am writing a test bench to test signed, unsigned multiplication and division. I want to make the test self-checking. Please do it in verilog and have a score tracking system with message printing for failed test cases.

The input to MCycle is
 CLK,
 RESET, 
Start which is acsserted to start the computation, 
[1:0] MCycleOp where "00" for signed multiplication, "01" for unsigned multiplication, "10" for signed division, "11" for unsigned division,
[width-1:0] Operand1 which is the Multiplicand / Dividend
[width-1:0] Operand2 which is the Multiplier / Divisor

the output is
[width-1:0] Result1 which is the LSW of Product / Quotient
[width-1:0] Result2 which is the MSW of Product / Remainder
Busy which is set when start is set and clear when result is ready
*/

module test_MCycle(
 
    );
 
    // ------------------------------------------------------------------------
    // CONFIGURATION
    // ------------------------------------------------------------------------
    localparam WIDTH             = 32;     // must match the width of the MCycle instance
    localparam TIMEOUT_CYCLES    = 1000;  // max clocks to wait for Busy to clear
    localparam BUSY_RISE_CYCLES  = 3;     // max clocks allowed for Busy to go high after Start
    localparam NUM_RANDOM        = 500;   // random pairs per run, used only when WIDTH > EXHAUSTIVE_MAX_W
    localparam EXHAUSTIVE_MAX_W  = 6;     // test every operand pair if WIDTH <= this
    localparam MAX_FAIL_PRINTS   = 50;    // limit on printed failure messages (counts are still tracked)
 
    localparam [1:0] OP_MUL_S = 2'b00,
                     OP_MUL_U = 2'b01,
                     OP_DIV_S = 2'b10,
                     OP_DIV_U = 2'b11;
 
    // ------------------------------------------------------------------------
    // DECLARE INPUT SIGNALs
    // ------------------------------------------------------------------------
    reg CLK = 0 ;
    reg RESET = 0 ;
    reg Start = 0 ;
    reg [1:0] MCycleOp = 0 ;
    reg [WIDTH-1:0] Operand1 = 0 ;
    reg [WIDTH-1:0] Operand2 = 0 ;
 
    // DECLARE OUTPUT SIGNALs
    wire [WIDTH-1:0] Result1 ;
    wire [WIDTH-1:0] Result2 ;
    wire Busy ;
 
    // INSTANTIATE DEVICE/UNIT UNDER TEST (DUT/UUT)
    // (If MCycle has a width parameter, set it to WIDTH here, e.g. MCycle #(.width(WIDTH)) dut(...))
    MCycle #(.width(WIDTH)) dut(
        CLK,
        RESET,
        Start,
        MCycleOp,
        Operand1,
        Operand2,
        Result1,
        Result2,
        Busy
        ) ;
 
    // GENERATE CLOCK
    always begin
        #5 CLK = ~CLK ;
    end
 
    // ------------------------------------------------------------------------
    // SCORE TRACKING
    // ------------------------------------------------------------------------
    integer total_tests = 0;
    integer total_pass  = 0;
    integer total_fail  = 0;
    integer op_tests [0:3];
    integer op_pass  [0:3];
    integer op_fail  [0:3];
    integer fail_prints = 0;
    integer k;
 
    // ------------------------------------------------------------------------
    // HELPERS
    // ------------------------------------------------------------------------
    function [8*24-1:0] op_name;
        input [1:0] op;
        begin
            case (op)
                OP_MUL_S: op_name = "SIGNED MULTIPLY";
                OP_MUL_U: op_name = "UNSIGNED MULTIPLY";
                OP_DIV_S: op_name = "SIGNED DIVIDE";
                default : op_name = "UNSIGNED DIVIDE";
            endcase
        end
    endfunction
 
    // Reference model: computes the expected Result1 / Result2
    task compute_expected;
        input  [1:0]       op;
        input  [WIDTH-1:0] a;
        input  [WIDTH-1:0] b;
        output [WIDTH-1:0] e1;
        output [WIDTH-1:0] e2;
        reg signed [2*WIDTH-1:0] sa, sb, sp;
        reg        [2*WIDTH-1:0] up;
        reg signed [WIDTH-1:0]   qa, qb, qq, qr;
        reg        [WIDTH-1:0]   ua, ub, uq, ur;
        begin
            $display("compute_expected: WIDTH=%0d op=%b a=%h b=%h",
                 WIDTH, op, a, b);
            case (op)
                OP_MUL_S: begin
                    sa = {{WIDTH{a[WIDTH-1]}}, a};
                    sb = {{WIDTH{b[WIDTH-1]}}, b};
                    sp = sa * sb;
                    e1 = sp[WIDTH-1:0];
                    e2 = sp[2*WIDTH-1:WIDTH];
                end
                OP_MUL_U: begin
                    up = {{WIDTH{1'b0}}, a} * {{WIDTH{1'b0}}, b};
                    e1 = up[WIDTH-1:0];
                    e2 = up[2*WIDTH-1:WIDTH];
                end
                OP_DIV_S: begin
                    qa = a; qb = b;
                    if ((qa == {1'b1, {(WIDTH-1){1'b0}}}) &&
                        (qb == {WIDTH{1'b1}})) begin
                        // INT_MIN / -1: quotient wraps to INT_MIN
                        qq = qa;
                        qr = {WIDTH{1'b0}};
                    end
                    else begin
                        qq = qa / qb;
                        qr = qa % qb;
                    end  
                    e1 = qq;
                    e2 = qr;
                end
                default: begin // OP_DIV_U
                    ua = a; ub = b;
                    uq = ua / ub;
                    ur = ua % ub;
                    e1 = uq;
                    e2 = ur;
                end
            endcase
        end
    endtask
 
    // Record a pass / fail
    task record;
        input [1:0] op;
        input       pass;
        begin
            total_tests = total_tests + 1;
            op_tests[op] = op_tests[op] + 1;
            if (pass) begin
                total_pass = total_pass + 1;
                op_pass[op] = op_pass[op] + 1;
            end else begin
                total_fail = total_fail + 1;
                op_fail[op] = op_fail[op] + 1;
            end
        end
    endtask
 
    // Print a failure message (signed ops show signed values, unsigned ops show unsigned values)
    task report_fail;
        input [1:0]        op;
        input [WIDTH-1:0]  a;
        input [WIDTH-1:0]  b;
        input [WIDTH-1:0]  e1;
        input [WIDTH-1:0]  e2;
        input [WIDTH-1:0]  g1;
        input [WIDTH-1:0]  g2;
        input [8*40-1:0]   reason;
        begin
            fail_prints = fail_prints + 1;
            if (fail_prints <= MAX_FAIL_PRINTS) begin
                if (op[0] == 1'b0)
                    $display("[FAIL] t=%0t test#%0d %0s (%0s): Op1=%0d (0x%h)  Op2=%0d (0x%h)",
                             $time, total_tests, op_name(op), reason, $signed(a), a, $signed(b), b);
                else
                    $display("[FAIL] t=%0t test#%0d %0s (%0s): Op1=%0d (0x%h)  Op2=%0d (0x%h)",
                             $time, total_tests, op_name(op), reason, a, a, b, b);
                if (op[1] == 1'b0)
                    $display("       Expected: Product LSW(Result1)=0x%h  MSW(Result2)=0x%h", e1, e2);
                else
                    $display("       Expected: Quotient(Result1)=0x%h  Remainder(Result2)=0x%h", e1, e2);
                $display("       Got     : Result1=0x%h  Result2=0x%h", g1, g2);
                if (fail_prints == MAX_FAIL_PRINTS)
                    $display("       (further failure messages suppressed; counts are still tracked)");
            end
        end
    endtask
 
    task do_reset;
        begin
            @(negedge CLK);
            Start = 1'b0;
            RESET = 1'b1;
            repeat (2) @(negedge CLK);
            RESET = 1'b0;
            @(negedge CLK);
        end
    endtask
 
    // Run one operation and check it.
    // Inputs are driven on the falling clock edge. Start is held until Busy clears, then dropped
    // immediately so that no extra operation is started.
    task run_test;
        input [1:0]       op;
        input [WIDTH-1:0] a;
        input [WIDTH-1:0] b;
        reg [WIDTH-1:0] exp1, exp2;
        integer cycles;
        reg     busy_seen;
        reg     timed_out;
        begin
            compute_expected(op, a, b, exp1, exp2);
 
            @(negedge CLK);                 // idle clock between operations
            MCycleOp = op;
            Operand1 = a;
            Operand2 = b;
            Start    = 1'b1;
 
            // 1. Busy must go high shortly after Start
            busy_seen = 1'b0;
            cycles    = 0;
            while (!busy_seen && cycles < BUSY_RISE_CYCLES) begin
                @(negedge CLK);
                cycles = cycles + 1;
                if (Busy === 1'b1) busy_seen = 1'b1;
            end
 
            // 2. Busy must clear within the timeout
            timed_out = 1'b0;
            if (busy_seen) begin
                cycles = 0;
                while (Busy !== 1'b0 && cycles < TIMEOUT_CYCLES) begin
                    @(negedge CLK);
                    cycles = cycles + 1;
                end
                if (Busy !== 1'b0) timed_out = 1'b1;
            end
 
            // 3. Check results (Busy just fell, so results are ready)
            if (!busy_seen) begin
                Start = 1'b0;
                record(op, 1'b0);
                report_fail(op, a, b, exp1, exp2, Result1, Result2, "Busy never asserted");
                do_reset;
            end else if (timed_out) begin
                Start = 1'b0;
                record(op, 1'b0);
                report_fail(op, a, b, exp1, exp2, Result1, Result2, "timeout, Busy stuck high");
                do_reset;
            end else begin
                Start = 1'b0;
                if (Result1 === exp1 && Result2 === exp2) begin
                    record(op, 1'b1);
                end else begin
                    record(op, 1'b0);
                    report_fail(op, a, b, exp1, exp2, Result1, Result2, "wrong result");
                end
            end
        end
    endtask
 
    // Run all four operations for one operand pair
    task run_all_ops;
        input [WIDTH-1:0] a;
        input [WIDTH-1:0] b;
        begin
            if (b != 0) begin   // division by zero (Operand2 == 0) is skipped
                run_test(OP_DIV_S, a, b);
                run_test(OP_DIV_U, a, b);
            end
            run_test(OP_MUL_S, a, b);
            run_test(OP_MUL_U, a, b);
        end
    endtask
 
    // ------------------------------------------------------------------------
    // STIMULI
    // ------------------------------------------------------------------------
    reg [WIDTH-1:0] corner [0:7];
    reg [WIDTH-1:0] ta, tb;
    integer i, j;
 
    initial begin
        for (k = 0; k < 4; k = k + 1) begin
            op_tests[k] = 0;
            op_pass[k]  = 0;
            op_fail[k]  = 0;
        end
 
        corner[0] = 0;                              // 0
        corner[1] = 1;                              // 1
        corner[2] = 2;                              // 2
        corner[3] = 3;                              // 3
        corner[4] = {1'b0, {(WIDTH-1){1'b1}}};      // max positive (signed)
        corner[5] = {1'b1, {(WIDTH-1){1'b0}}};      // most negative (signed) / 2^(W-1) unsigned
        corner[6] = {WIDTH{1'b1}};                  // -1 / max unsigned
        corner[7] = {{(WIDTH-1){1'b1}}, 1'b0};      // -2 / max unsigned - 1
 
        $display("==============================================================");
        $display(" MCycle self-checking testbench  (WIDTH = %0d)", WIDTH);
        $display("==============================================================");
 
        do_reset;
 
        // Phase 1: all combinations of corner-case values
        $display("--- Phase 1: corner cases ---");
        for (i = 0; i < 8; i = i + 1)
            for (j = 0; j < 8; j = j + 1)
                run_all_ops(corner[i], corner[j]);
 
        // Phase 2: exhaustive (small widths) or random (large widths)
        if (WIDTH <= EXHAUSTIVE_MAX_W) begin
            $display("--- Phase 2: exhaustive, all %0d operand pairs ---", (1 << WIDTH) * (1 << WIDTH));
            for (i = 0; i < (1 << WIDTH); i = i + 1)
                for (j = 0; j < (1 << WIDTH); j = j + 1) begin
                    ta = i;
                    tb = j;
                    run_all_ops(ta, tb);
                end
        end else begin
            $display("--- Phase 2: %0d random operand pairs ---", NUM_RANDOM);
            for (i = 0; i < NUM_RANDOM; i = i + 1) begin
                ta = $random;
                tb = $random;
                run_all_ops(ta, tb);
            end
        end
 
        // Summary
        $display("==============================================================");
        $display(" TEST SUMMARY");
        $display("==============================================================");
        $display(" %-20s : %0d run, %0d passed, %0d failed", "SIGNED MULTIPLY",   op_tests[0], op_pass[0], op_fail[0]);
        $display(" %-20s : %0d run, %0d passed, %0d failed", "UNSIGNED MULTIPLY", op_tests[1], op_pass[1], op_fail[1]);
        $display(" %-20s : %0d run, %0d passed, %0d failed", "SIGNED DIVIDE",     op_tests[2], op_pass[2], op_fail[2]);
        $display(" %-20s : %0d run, %0d passed, %0d failed", "UNSIGNED DIVIDE",   op_tests[3], op_pass[3], op_fail[3]);
        $display("--------------------------------------------------------------");
        $display(" TOTAL : %0d run, %0d passed, %0d failed  (score %0d%%)",
                 total_tests, total_pass, total_fail,
                 (total_tests == 0) ? 0 : (total_pass * 100) / total_tests);
        if (total_fail == 0)
            $display(" RESULT: ALL TESTS PASSED");
        else
            $display(" RESULT: %0d TEST(S) FAILED", total_fail);
        $display("==============================================================");
        $finish;
    end
 
endmodule
 
