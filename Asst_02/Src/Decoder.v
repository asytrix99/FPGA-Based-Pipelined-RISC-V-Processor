`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: Decoder
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor Decoder Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: Interface and implementation can be modified.
-- 
----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
--	License terms :
--	You are free to use this code as long as you
--		(i) DO NOT post it on any public repository;
--		(ii) use it only for educational purposes;
--		(iii) accept the responsibility to ensure that your implementation does not violate anyone's intellectual property.
--		(iv) accept that the program is provided "as is" without warranty of any kind or assurance regarding its suitability for any particular purpose;
--		(v) send an email to rajesh<dot>panicker<at>ieee.org briefly mentioning its use (except when used for the course CG3207 at the National University of Singapore);
--		(vi) retain this notice in this file as well as any files derived from this.
----------------------------------------------------------------------------------
*/

module Decoder(
    input [6:0] Opcode ,
    input [2:0] Funct3 ,
    input [6:0] Funct7 ,
    output reg [1:0] PCS,		// 00 for non-control, 01 for conditional branch, 10 for jal, 11 for jalr
    output reg RegWrite,		// Asserted only by instructions which write to register file (load, auipc, lui, DPImm, DPReg);
    output reg MemWrite,		// Asserted only by store (sw)
    output reg MemtoReg,		// Asserted only by load (lw)
    // 00: RD1, 01: 0, 11: PC
    output reg [1:0] ALUSrcA, 	// Needed for lui, auipic. Refer to the microarchitecture for its use. Uncomment wire and port map in RV.v as well
    // 00: RD2, 11: ExtImm, 01: 4
    output reg [1:0] ALUSrcB,		// Asserted by all instructions which use an immediate (load, store, lui, auipc, DPImm). Needs to be expanded to a 2-bit signal to support link functionality for jal, jalr. Change wire width in RV.v as well
    // 000: U, 010: J, 011: I, 110: S, 111: B
    output reg [2:0] ImmSrc, 	// 000 for U, 010 for UJ, 011 for I, 110 for S, 111 for SB.
    output reg [3:0] ALUControl	// 0000 for add, 0001 for sub, 1110 for and, 1100 for or, 0010 for sll, 1010 for srl, 1011 for sra, 0001 for branch, 0000 for all others.
    					// Note that the most significant 3 bits are Funct3 for all DP instrns. LSB is the same as Funct[5] for DPReg type and DPImm_shifts. For other DPImms, Funct[5] is 0.
    					// It is the same as sub for branches, and add for all others not mentioned in the line above.
    ); 
// Change wire to reg if assigned inside a procedural (always) block. However, where it is easy enough, use assign instead of always.
// A 2-1 multiplexing can be done easily using an assign with a ternary operator
// For multiplexing with number of inputs > 2, a case construct within an always block is a natural fit. DO NOT to use nested ternary assignment operator as it hampers the readability of your code.
    
    	// todo: Implement Decoder here
    	localparam OP_DPREG = 7'b0110011; // add, sub, and, or, xor, sll, srl, sra, slt, sltu
        localparam OP_DPIMM = 7'b0010011; // addi, andi, ori, xori, slli, srli, srai, slti, sltiu
        localparam OP_LOAD = 7'b0000011; // lw
        localparam OP_STORE = 7'b0100011; // sw
        localparam OP_BRANCH = 7'b1100011; // beq, bne, blt, bge, bltu, bgeu
        localparam OP_JAL = 7'b1101111; // jal
        localparam OP_AUIPC = 7'b0010111; // auipc
        localparam OP_LUI = 7'b0110111; // lui
        localparam OP_JALR = 7'b1100111; // jalr
        
        always @ (*) begin
            // Setting defaults, no B-type
            PCS = 2'b00;
            RegWrite = 1'b0;
            MemWrite = 1'b0;
            MemtoReg = 1'b0;
            ALUSrcA = 2'b00; // RD1
            ALUSrcB = 2'b00; // RD2
            ImmSrc = 3'b011; // I-type
            ALUControl = 4'b0000; // add
            
            case (Opcode)
                // ------------------NOTE----------------------              
                // ALUControl = {Funct 3, X} 
                // X = Funct7[5] -> DP Imm shifts & DP Reg
                // X = 1'b0 -> all other DP Imm 1'b0
                // ------------------NOTE---------------------- 
                
                OP_DPREG: begin
                    RegWrite = 1'b1;
                    ALUControl = {Funct3, Funct7[5]}; // Funct7[5] distinguish add/sub, srl/sra
                    // ALUSrcA/B stays default for DP Reg type
                    // ImmSrc don't care
                    // PCS stays default for non-B and non-J types
                end
                
                OP_DPIMM: begin
                    RegWrite = 1'b1;
                    ALUSrcB = 2'b11; // ExtImm
                    if (Funct3 == 3'b101)
                        ALUControl = {Funct3, Funct7[5]}; // Funct7[5] distinguish srli, srai
                    else
                        ALUControl = {Funct3, 1'b0}; // addi, slli, slti, sltiu, xori, ori. andi
                     // ImmSrc stays default (I-type)   
                     // PCS stays default for non-control (non-B, non-J types)
                end
                
                OP_STORE: begin
                    MemWrite = 1'b1;
                    ALUSrcB = 2'b11; // ExtImm
                    ImmSrc = 3'b110; // S-type
                    // ALUControl stays default (add) -> RD1 + ExtImm
                    // PCS stays default for non-control (non-B, non-J types)
                end
                
                OP_BRANCH: begin
                    PCS = 2'b01; // conditional taken/non-taken
                    ImmSrc = 3'b111; // B-type
                    ALUControl = 4'b0001; // sub
                    // ALUSrcA/B stays default (RD1, RD2)
                end
                
                OP_JAL: begin
                    PCS = 2'b10; // unconditional PC-relative (base = PC)
                    RegWrite = 1'b1;
                    ALUSrcA = 2'b11; // PC
                    ALUSrcB = 2'b01; // 4
                    ImmSrc = 3'b010; // J-type
                    // ALUControl stays default (add) -> PC + 4
                end
            
                OP_LUI: begin
                    RegWrite = 1'b1;
                    ALUSrcA = 2'b01; // 0
                    ALUSrcB = 2'b11; // ExtImm
                    ImmSrc = 3'b000; // U-type
                    // ALUControl stays default (add)
                end
                
                OP_JALR: begin
                    PCS = 2'b11; // unconditional register-relative (base = RD1)
                    RegWrite = 1'b1;
                    ALUSrcA = 2'b11; // PC
                    ALUSrcB = 2'b01; // 4
                    // ImmSrc stays default (I-type) -> PC + 4
                end
                
                // fence/ecall/system or garbage bits not relevant as opcodes in this assignment
                default: begin
                end
                
            endcase
        end
    	
	    
endmodule