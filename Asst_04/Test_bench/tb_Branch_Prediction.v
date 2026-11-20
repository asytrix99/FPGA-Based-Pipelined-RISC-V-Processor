`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/31/2026 12:21:32 AM
// Design Name: 
// Module Name: tb_Branch_Prediction
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


module tb_Branch_Prediction(

    );
    parameter INDEX_BITS = 6;
    localparam ENTRIES = 1 << INDEX_BITS;
    localparam [31:0] A = 32'h0040_0000;
    localparam [31:0] B = A + 4;             // Different index
    localparam [31:0] TARGET_A = 32'h0040_0100;
    localparam [31:0] TARGET_B = 32'h0040_0200;
    
    reg CLK;
    reg RESET;
    reg [31:0] PC_F;
    reg [31:0] PC_E;
    reg [1:0] PCSrc_E;
    reg [31:0] BTA_E;
    reg Update_E;
    wire [31:0] PrBTA_F;
    integer checks;
    integer errors;
    integer i;
    
    Branch_Prediction #(.INDEX_BITS(INDEX_BITS)) dut (
        CLK, RESET, PC_F, PC_E,
        PCSrc_E, BTA_E, Update_E,
        PrBTA_F
    );
    
    always #5 CLK = ~CLK;
   
    task train;
        input [31:0] pc;
        input [1:0] PCSrc;
        input [31:0] target;
        begin
            @(negedge CLK);
            PC_E = pc;
            PCSrc_E = PCSrc;
            BTA_E = target;
            Update_E = 1'b1;
            @(posedge CLK);
            #1;
            @(negedge CLK);
            Update_E = 1'b0;
        end
    endtask
    
    task check_prediction;
        input [31:0] pc;
        input [31:0] expected;
        input [8*96-1:0] label;
        begin
            PC_F = pc;
            #1;
            checks = checks + 1;
            if (PrBTA_F !== expected) begin
                errors = errors + 1;
                $display("FAIL: %0s: PC=%h expected=%h actual=%h",
                         label, pc, expected, PrBTA_F);
            end else
                $display("PASS: %0s", label);
        end
    endtask
    
    
    task check_BHT;
        input [31:0] pc;
        input [1:0] expected;
        input [8*96-1:0] label;
        integer index;
        begin
            index = (pc >> 2) & (ENTRIES - 1);
            checks = checks + 1;
            if (dut.BHT[index] !== expected) begin
                errors = errors + 1;
                $display("FAIL: %0s: expected BHT=%b actual=%b",
                         label, expected, dut.BHT[index]);
            end else
                $display("PASS: %0s", label);
        end
    endtask
    
    initial begin
        CLK = 0;
        RESET = 1;
        PC_F = A;
        PC_E = 0;
        PCSrc_E = 0;
        BTA_E = 0;
        Update_E = 0;
        checks = 0;
        errors = 0;
        
        repeat (2) @(posedge CLK);
        RESET = 0;
        
        // Check prediction for taken
        train(A, 2'b01, TARGET_A);
        check_BHT(A, 2'b01, "First taken outcome reach 01");
        check_prediction(A, A+4, "01 predicts not taken");
        train(A, 2'b01, TARGET_A);
        check_BHT(A, 2'b10, "Second taken outcome reaches 10");
        check_prediction(A, TARGET_A, "10 predicts taken");
        train(A, 2'b01, TARGET_A);
        check_BHT(A, 2'b11, "Third taken outcome reaches 11");
        train(A, 2'b01, TARGET_A);
        check_BHT(A, 2'b11, "Taken counter saturates at 11");
        check_prediction(A, TARGET_A, "11 predicts taken");
        
        // Check prediction for not taken
        train(A, 2'b00, TARGET_A);
        check_BHT(A, 2'b10, "First not-taken outcome changes 11 to 10");
        check_prediction(A, TARGET_A, "One unexpected outcome retains taken prediction");
        train(A, 2'b00, TARGET_A);
        check_BHT(A, 2'b01, "Second not-taken outcome changes 10 to 01");
        check_prediction(A, A+4, "Two not-taken outcomes change prediction");
        train(A, 2'b00, TARGET_A);
        check_BHT(A, 2'b00, "Third not-taken outcome reaches 00");
        train(A, 2'b00, TARGET_A);
        check_BHT(A, 2'b00, "Not-taken counter saturates at 00");
        
        
        // Check independent PC with different prediction
        train(A, 2'b01, TARGET_A);
        train(A, 2'b01, TARGET_A);
        train(B, 2'b00, TARGET_B);
        check_BHT(B, 2'b00, "Cold not-taken entry starts at 00");
        check_prediction(B, B+4, "B predicts not taken");
        train(B, 2'b01, TARGET_B);
        train(B, 2'b01, TARGET_B);
        check_prediction(B, TARGET_B, "B learns its own target");
        check_prediction(A, TARGET_A, "Updating B does not disturb A");
        

        if (errors == 0)
            $display("ALL TESTS PASSED (%0d checks)", checks);
        else
            $display("TESTS FAILED: %0d errors in %0d checks", errors, checks);
        $finish;
    end
    
endmodule
