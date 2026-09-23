`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.09.2026 00:53:48
// Design Name: 
// Module Name: tb_Decoder
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


module tb_Decoder(

    );

    reg [6:0] Opcode;
    reg [2:0] Funct3;
    reg [6:0] Funct7;

    wire [1:0] PCS;
    wire RegWrite;
    wire MemWrite;
    wire MemtoReg;
    wire [1:0] ALUSrcA;
    wire [1:0] ALUSrcB;
    wire [2:0] ImmSrc;
    wire [3:0] ALUControl;

    Decoder dut (
        .Opcode(Opcode),
        .Funct3(Funct3),
        .Funct7(Funct7),
        .PCS(PCS),
        .RegWrite(RegWrite),
        .MemWrite(MemWrite),
        .MemtoReg(MemtoReg),
        .ALUSrcA(ALUSrcA),
        .ALUSrcB(ALUSrcB),
        .ImmSrc(ImmSrc),
        .ALUControl(ALUControl)
    );

    task check;
        input [127:0] name;
        input [6:0] test_Opcode;
        input [2:0] test_Funct3;
        input [6:0] test_Funct7;
        input [1:0]  exp_PCS;
        input        exp_RegWrite;
        input        exp_MemWrite;
        input        exp_MemtoReg;
        input [1:0]  exp_ALUSrcA;
        input [1:0]  exp_ALUSrcB;
        input [2:0]  exp_ImmSrc;
        input [3:0]  exp_ALUControl;
        begin
            Opcode = test_Opcode;
            Funct3 = test_Funct3;
            Funct7 = test_Funct7;
            #1;

            if (PCS !== exp_PCS || RegWrite !== exp_RegWrite || MemWrite !== exp_MemWrite ||
                MemtoReg !== exp_MemtoReg || ALUSrcA !== exp_ALUSrcA || ALUSrcB !== exp_ALUSrcB ||
                ImmSrc !== exp_ImmSrc || ALUControl !== exp_ALUControl) begin
                $display("Test failed [%0s] | Opcode=%b Funct3=%b Funct7=%b", name, test_Opcode, test_Funct3, test_Funct7);
                $display("   Expected: PCS=%b RegWrite=%b MemWrite=%b MemtoReg=%b ALUSrcA=%b ALUSrcB=%b ImmSrc=%b ALUControl=%b",
                          exp_PCS, exp_RegWrite, exp_MemWrite, exp_MemtoReg, exp_ALUSrcA, exp_ALUSrcB, exp_ImmSrc, exp_ALUControl);
                $display("   Got:      PCS=%b RegWrite=%b MemWrite=%b MemtoReg=%b ALUSrcA=%b ALUSrcB=%b ImmSrc=%b ALUControl=%b",
                          PCS, RegWrite, MemWrite, MemtoReg, ALUSrcA, ALUSrcB, ImmSrc, ALUControl);
            end
        end
    endtask


    initial begin

        // OP_DPREG
        // add:  Funct3=000, Funct7[5]=0 -> ALUControl=0000
        check("add",  7'b0110011, 3'b000, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b0000);
        // sub:  Funct3=000, Funct7[5]=1 -> ALUControl=0001
        check("sub",  7'b0110011, 3'b000, 7'b0100000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b0001);
        // sll:  Funct3=001, Funct7[5]=0 -> ALUControl=0010
        check("sll",  7'b0110011, 3'b001, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b0010);
        // slt:  Funct3=010, Funct7[5]=0 -> ALUControl=0100
        check("slt",  7'b0110011, 3'b010, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b0100);
        // sltu: Funct3=011, Funct7[5]=0 -> ALUControl=0110
        check("sltu", 7'b0110011, 3'b011, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b0110);
        // xor:  Funct3=100, Funct7[5]=0 -> ALUControl=1000
        check("xor",  7'b0110011, 3'b100, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b1000);
        // srl:  Funct3=101, Funct7[5]=0 -> ALUControl=1010
        check("srl",  7'b0110011, 3'b101, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b1010);
        // sra:  Funct3=101, Funct7[5]=1 -> ALUControl=1011
        check("sra",  7'b0110011, 3'b101, 7'b0100000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b1011);
        // or:   Funct3=110, Funct7[5]=0 -> ALUControl=1100
        check("or",   7'b0110011, 3'b110, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b1100);
        // and:  Funct3=111, Funct7[5]=0 -> ALUControl=1110
        check("and",  7'b0110011, 3'b111, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b1110);


        // OP_DPIMM
        // addi: Funct3=000 -> ALUControl=0000, ALUSrcB=11
        check("addi",  7'b0010011, 3'b000, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b0000);
        // slli: Funct3=001, Funct7[5]=0 -> ALUControl=0010 (else-branch)
        check("slli",  7'b0010011, 3'b001, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b0010);
        // slti: Funct3=010 -> ALUControl=0100
        check("slti",  7'b0010011, 3'b010, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b0100);
        // sltiu: Funct3=011 -> ALUControl=0110
        check("sltiu", 7'b0010011, 3'b011, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b0110);
        // xori: Funct3=100 -> ALUControl=1000
        check("xori",  7'b0010011, 3'b100, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b1000);
        // srli: Funct3=101, Funct7[5]=0 -> ALUControl=1010 (if-branch)
        check("srli",  7'b0010011, 3'b101, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b1010);
        // srai: Funct3=101, Funct7[5]=1 -> ALUControl=1011 (if-branch)
        check("srai",  7'b0010011, 3'b101, 7'b0100000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b1011);
        // ori: Funct3=110 -> ALUControl=1100
        check("ori",   7'b0010011, 3'b110, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b1100);
        // andi: Funct3=111 -> ALUControl=1110
        check("andi",  7'b0010011, 3'b111, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b00, 2'b11, 3'b011, 4'b1110);


        // OP_LOAD
        check("lw", 7'b0000011, 3'b010, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b1, 2'b00, 2'b11, 3'b011, 4'b0000);


        // OP_STORE
        check("sw", 7'b0100011, 3'b010, 7'b0000000, 2'b00, 1'b0, 1'b1, 1'b0, 2'b00, 2'b11, 3'b110, 4'b0000);


        // OP_BRANCH
        // beq/bne/blt/bge/bltu/bgeu all decode identically at Decoder level (Funct3 handled in PC_Logic)
        check("beq", 7'b1100011, 3'b000, 7'b0000000, 2'b01, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 3'b111, 4'b0001);
        check("bne", 7'b1100011, 3'b001, 7'b0000000, 2'b01, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 3'b111, 4'b0001);
        check("blt", 7'b1100011, 3'b100, 7'b0000000, 2'b01, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 3'b111, 4'b0001);
        check("bge",  7'b1100011, 3'b101, 7'b0000000, 2'b01, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 3'b111, 4'b0001);
        check("bltu", 7'b1100011, 3'b110, 7'b0000000, 2'b01, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 3'b111, 4'b0001);
        check("bgeu", 7'b1100011, 3'b111, 7'b0000000, 2'b01, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 3'b111, 4'b0001);

        // OP_JAL
        check("jal", 7'b1101111, 3'b000, 7'b0000000, 2'b10, 1'b1, 1'b0, 1'b0, 2'b11, 2'b01, 3'b010, 4'b0000);


        // OP_LUI
        check("lui", 7'b0110111, 3'b000, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b01, 2'b11, 3'b000, 4'b0000);


        // OP_AUIPC
        check("auipc", 7'b0010111, 3'b000, 7'b0000000, 2'b00, 1'b1, 1'b0, 1'b0, 2'b11, 2'b11, 3'b000, 4'b0000);


        // OP_JALR
        check("jalr", 7'b1100111, 3'b000, 7'b0000000, 2'b11, 1'b1, 1'b0, 1'b0, 2'b11, 2'b01, 3'b011, 4'b0000);


        // Invalid
        check("invalid", 7'b1111111, 3'b000, 7'b0000000, 2'b00, 1'b0, 1'b0, 1'b0, 2'b00, 2'b00, 3'b011, 4'b0000);


        $display("Decoder simulation done.");
        $finish;
    end
endmodule