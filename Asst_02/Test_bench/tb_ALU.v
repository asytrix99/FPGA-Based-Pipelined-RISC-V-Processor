`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2026 02:22:39
// Design Name: 
// Module Name: tb_ALU
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


module tb_ALU(

    );

    reg [31:0] Src_A;
    reg [31:0] Src_B;
    reg [3:0] ALUControl;

    wire [31:0] ALUResult;
    wire [2:0] ALUFlags; // {eq, lt, ltu}

    integer errors = 0;

    ALU dut (
        .Src_A(Src_A),
        .Src_B(Src_B),
        .ALUControl(ALUControl),
        .ALUResult(ALUResult),
        .ALUFlags(ALUFlags)
    );

    // ALUResult
    task check_result;
        input [127:0] name;
        input [31:0] test_A;
        input [31:0] test_B;
        input [3:0]  test_ALUControl;
        input [31:0] expected_Result;
        begin
            Src_A = test_A;
            Src_B = test_B;
            ALUControl = test_ALUControl;
            #1;

            if (ALUResult !== expected_Result) begin
                errors = errors + 1;
                $display("FAIL [%0s] A=%h B=%h ALUControl=%b", name, test_A, test_B, test_ALUControl);
                $display("   expected ALUResult=%h, got=%h", expected_Result, ALUResult);
            end
        end
    endtask

    // ALUFlags
    task check_flags;
        input [127:0] name;
        input [31:0] test_A;
        input [31:0] test_B;
        input expected_eq;
        input expected_lt;
        input expected_ltu;
        reg [2:0] expected_Flags;
        begin
            expected_Flags = {expected_eq, expected_lt, expected_ltu};

            Src_A = test_A;
            Src_B = test_B;
            ALUControl = 4'b0001; // sub
            #1;

            if (ALUFlags !== expected_Flags) begin
                errors = errors + 1;
                $display("FAIL [%0s] A=%h B=%h (sub)", name, test_A, test_B);
                $display("   expected eq=%b lt=%b ltu=%b, got eq=%b lt=%b ltu=%b",
                          expected_eq, expected_lt, expected_ltu,
                          ALUFlags[2], ALUFlags[1], ALUFlags[0]);
            end
        end
    endtask


    initial begin

        // ALUResult

        // add
        check_result("add basic", 32'd5, 32'd3, 4'b0000, 32'd8);
        check_result("add wraparound", 32'hFFFFFFFF, 32'd1, 4'b0000, 32'd0); // unsigned overflow wraps to 0
        // sub
        check_result("sub basic", 32'd5, 32'd3, 4'b0001, 32'd2); // 5 - 3 = 2
        check_result("sub negative", 32'd3, 32'd5, 4'b0001, 32'hFFFFFFFE); // 3 - 5 = -2 
        check_result("sub equal", 32'd10, 32'd10, 4'b0001, 32'd0); // 10 - 10 = 0
        // and
        check_result("and", 32'hF0F0F0F0, 32'h0F0F0F0F, 4'b1110, 32'h00000000);
        // or
        check_result("or", 32'hF0F0F0F0, 32'h0F0F0F0F, 4'b1100, 32'hFFFFFFFF);
        // xor
        check_result("xor", 32'hFF00FF00, 32'h00FF00FF, 4'b1000, 32'hFFFFFFFF);
        // sll
        check_result("sll", 32'h00000001, 32'd3, 4'b0010, 32'h00000008); // 1 << 3 = 8
        // srl
        check_result("srl", 32'h80000000, 32'd4, 4'b1010, 32'h08000000);
        // sra
        check_result("sra", 32'h80000000, 32'd4, 4'b1011, 32'hF8000000);
        // slt
        check_result("slt (-1 < 1)", 32'hFFFFFFFF, 32'd1, 4'b0100, 32'd1); // signed: -1 < 1 -> return 1
        check_result("slt (1 < -1)", 32'd1, 32'hFFFFFFFF, 4'b0100, 32'd0); // signed: 1 < -1 -> return 0
        // sltu
        check_result("sltu (big < 1)", 32'hFFFFFFFF, 32'd1, 4'b0110, 32'd0); // unsigned: huge < 1 -> return 0
        check_result("sltu (1 < big)", 32'd1, 32'hFFFFFFFF, 4'b0110, 32'd1); // unsigned: 1 < huge -> return 1

        // ALUFlags
        check_flags("5 vs 3", 32'd5, 32'd3, 1'b0, 1'b0, 1'b0); // A > B
        check_flags("3 vs 5", 32'd3, 32'd5, 1'b0, 1'b1, 1'b1); // A < B
        check_flags("10 vs 10", 32'd10, 32'd10, 1'b1, 1'b0, 1'b0); // A == B
        // ref Decoder.v case 2 -> INT_MIN - 1: N=0, V=1 -> A-B = INT_MIN-1 > 0 -> overflow
        check_flags("INT_MIN vs 1", 32'h80000000, 32'd1, 1'b0, 1'b1, 1'b0);
        // normal A < B returns 1 so uses unsigned version
        check_flags("1 vs -1(bits)", 32'd1, 32'hFFFFFFFF, 1'b0, 1'b0, 1'b1);


        if (errors == 0)
            $display("All ALU tests passed.");
        else
            $display("%0d ALU test(s) FAILED.", errors);

        $display("ALU simulation done.");
        $finish;
    end
endmodule