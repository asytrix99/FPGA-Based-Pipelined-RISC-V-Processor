`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: ALU
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor ALU Module
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

module ALU(
	input [31:0] Src_A,
	input [31:0] Src_B,
	input [3:0] ALUControl, // 0000 for add, 0001 for sub, 1110 for and, 1100 for or, 0010 for sll, 1010 for srl, 1011 for sra.
	output reg [31:0] ALUResult,
	output [2:0] ALUFlags //{eq, lt, ltu}
);
    
	// Shifter signals
	reg [1:0] Sh ;
	reg [4:0] Shamt5 ;
	reg [31:0] ShIn ;
	wire [31:0] ShOut ;
	
	// Other signals
	wire [32:0] S_wider ;
	reg [32:0] Src_A_comp ;
	reg [32:0] Src_B_comp ;
	reg [32:0] C_0 ;
	wire N, Z, C, V; 	// optional intermediate values to derive eq, lt, ltu
				// Hint: We need to care about V only for subtraction
	
	assign S_wider = Src_A_comp + Src_B_comp + C_0 ;
    
	always@(Src_A, Src_B, ALUControl, S_wider, ShOut) begin
        // default values; help avoid latches
		C_0 = 0 ; 
		Src_A_comp = {1'b0, Src_A} ;
		Src_B_comp = {1'b0, Src_B} ;
		ShIn = Src_A;
		Shamt5 = Src_B[4:0];
		Sh = 2'b00;
    
		case(ALUControl)
			4'b0000: ALUResult = S_wider[31:0]; // add
			4'b0001: begin // sub
				C_0[0] = 1 ;  
				Src_B_comp = {1'b0, ~ Src_B} ;
				ALUResult = S_wider[31:0] ;
			end
			4'b1110: ALUResult = Src_A & Src_B; // and
            4'b1100: ALUResult = Src_A | Src_B; // or
            
            4'b0010: begin Sh = 2'b00; ALUResult = ShOut; end // sll
            4'b1010: begin Sh = 2'b10; ALUResult = ShOut; end // srl
            4'b1011: begin Sh = 2'b11; ALUResult = ShOut; end // sra
            
            4'b1000: ALUResult = Src_A ^ Src_B; // xor
            4'b0100: ALUResult = ($signed(Src_A) < $signed(Src_B)) ? 32'd1 : 32'd0; // slt
            4'b0110: ALUResult = (Src_A < Src_B) ? 32'd1 : 32'd0; // sltu
            
			// include cases for shifts
			default: ALUResult = 32'bx;
	        endcase
	    end
      
	assign Z = (ALUResult == 0) ? 1 : 0 ;
	
	assign C = S_wider[32]; // for all A-B >= 0 (unsigned)
	assign N = ALUResult[31]; // for A-B < 0
	
	// Src_A[31] ^ Src_B[31] considers only scenarios both signs different
	//     scenario 1: A >= 0, B < 0: largest possible -> MAX - MIN = A - B = A + |B| = 2^32 - 1 (out of range)
	//     scenario 2: A < 0, B >= 0: smallest possible -> MIN - MAX = A - B = -2^32 + 1 (out of range)
	
	// Src_A[31] ^ ALUResult[31] filters above XOR operation to whether overflow actually occurs
	//     scenario 1 (A >= 0, B < 0) from above is used
	//     no overflow -> magnitudes small enough within window -> ALUResult[31] = 0
	//     overflow -> MAX - MIN = 2^32 - 1, wraps to positive -> ALUResult[31]
	
	assign V = (Src_A[31] ^ Src_B[31]) & (Src_A[31] ^ ALUResult[31]); // for overflow wrap around
	
	// case 1: N=1, V=0 -> A-B < 0, no overflow
	// case 2: N=0, V=1 -> INT_MIN-1 > 0 (non-negative), overflow
	wire lt = N ^ V;
	wire ltu = ~C; // for all A < B (unsigned)
    
	assign ALUFlags = {Z, lt, ltu}; // differentiate branch types
    // todo: Will need to be modified in lab 3 to support blt, bltu, bge, bgeu.

	// Instantiate Shifter        
	Shifter Shifter1(
            Sh,
        	Shamt5,
        	ShIn,
        	ShOut
        );
     
endmodule