`timescale 1ns / 1ps
/*
----------------------------------------------------------------------------------
-- Company: NUS	
-- Engineer: (c) Rajesh Panicker  
-- 
-- Create Date: 09/22/2020 06:49:10 PM
-- Module Name: RV
-- Project Name: CG3207 Project
-- Target Devices: Nexys 4 / Basys 3
-- Tool Versions: Vivado 2019.2
-- Description: RISC-V Processor Module
-- 
-- Dependencies: NIL
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: The interface SHOULD NOT be modified (except making output reg) unless you modify Wrapper.v/vhd too. 
                        The implementation can be modified.
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

// Change wire to reg if assigned inside a procedural (always) block. However, where it is easy enough, use assign instead of always.
// A 2-1 multiplexing can be done easily using an assign with a ternary operator
// For multiplexing with number of inputs > 2, a case construct within an always block is a natural fit. DO NOT to use nested ternary assignment operator as it hampers the readability of your code.


module RV #(
    parameter PC_INIT = 32'h00400000
)(
    input CLK,
    input RESET,
    //input Interrupt,      // for optional future use.
    input [31:0] Instr,
    input [31:0] ReadData_in,       // Name mangled to support lb/lbu/lh/lhu
    output MemRead,
    output [3:0] MemWrite_out,		// Column-wise write enable to support sb/sw. Each column is a byte.
    output [31:0] PC,
    output [31:0] ALUResult,
    output [31:0] WriteData_out		// Name mangled to support sb/sw
);
    
    // Please read Lab 4 Enhancement: Implementing additional instructions on how to support lb/lbu/lh/lhu/sb/sh
        
    //RV Signals
    wire [2:0] SizeSel;                 //to support lb/lbu/lh/lhu/sb/sh
    wire [31:0] ReadData;
    wire [31:0] WriteData;              // Instantiated by assign below
    wire MemWrite;                      // Instantiated by decoder

    // The signals that are commented out (except CLK) will need to be uncommented and attached a stage suffix for pipelining,
    //  except if the connection is within the same stage.

    // RegFile signals
    //wire CLK ;
    wire WE ;                           // Instantiated by assign below
    wire [4:0] rs1 ;                    // Instantiated by assign below
    wire [4:0] rs2 ;                    // Instantiated by assign below
    wire [4:0] rd ;                     // Instantiated by assign below
    wire [31:0] WD ;                    // Instantiated by assign below
    wire [31:0] R15 ;                   // ????
    wire [31:0] RD1 ;                   // Instantiated by RegFile
    wire [31:0] RD2 ;                   // Instantiated by RegFile
    
    // Extend Module signals
    wire [2:0] ImmSrc ;                 // Instantiated by decoder
    wire [24:0] InstrImm ;              // Instantiated by assign below
    wire [31:0] ExtImm ;                // Instantiated by Extend
    
    // Decoder signals
    wire [6:0] Opcode ;                 // Instantiated by assign below
    wire [2:0] Funct3 ;                 // Instantiated by assign below
    wire [6:0] Funct7 ;                 // Instantiated by assign below
    wire [1:0] PCS;                     // Instantiated by decoder
    wire RegWrite ;                     // Instantiated by decoder
    //wire MemWrite ;
    wire MemtoReg ;                     // Instantiated by decoder
    wire [1:0] ALUSrcA ;                // Instantiated by decoder
    wire [1:0] ALUSrcB ;                // Instantiated by decoder
    //wire [2:0] ImmSrc ;
    wire [3:0] ALUControl ;             // Instantiated by decoder
    wire IsMCycle;                      // Instantiated by decoder
    wire MCycleResultHigh;              // Instantiated by decoder

    // PC_Logic signals
    //wire [1:0] PCS
    //wire [2:0] Funct3;
    //wire [2:0] ALUFlags;
    wire [1:0] PCSrc;                   // Instantiated by PC_Logic
      
    // ALU signals
    reg [31:0] Src_A ;                 // Instantiated in the alway loop
    reg [31:0] Src_B ;                 // Instantiated in the alway loop
    //wire [3:0] ALUControl ;
    //wire [31:0] ALUResult ;
    wire [2:0] ALUFlags;                // Instantiated by PC_Logic
    
    // MCycle signals   
    wire Start;                         // Instantiated by assign below
    wire [1:0] MCycleOp;                // Instantiated by Decoder
    wire [31:0] Operand1;               // Instantiated by assign below
    wire [31:0] Operand2;               // Instantiated by assign below
    wire [31:0] Result1;                // Instantiated by MCycle
    wire [31:0] Result2;                // Instantiated by MCycle
    wire Busy;                          // Instantiated by MCycle
    
    // ProgramCounter signals
    //wire CLK ;
    //wire RESET ;
    reg WE_PC ;                         // Instantiated in the alway loop
    reg [31:0] PC_IN ;                  // Instantiated in the alway loop
    //wire [31:0] PC ; 
            
    // Other internal signals here
    wire [31:0] PC_Offset ;              
    reg [31:0] Result ;                  // Instantiated by assign below
    
    assign MemRead = MemtoReg;           // This is needed for the proper functionality of some devices such as UART CONSOLE

    assign ReadData = ReadData_in;       // Change datapath as appropriate if supporting lb/lbu/lh/lhu
    assign WriteData_out = WriteData;    // Change datapath as appropriate if supporting sb/sh
    assign MemWrite_out = {4{MemWrite}}; // Change datapath as appropriate if supporting sb/sh
    assign SizeSel = 3'b010;             // Change this to be generated by the Decoder (control) as appropriate if 
                                         // supporting lb/sb/lbu/lh/sh/lhu/lw/sw. Hint: funct3

    // todo: other datapath connections here
    assign WriteData = RD2;
    
    assign WE = RegWrite;
    assign rs1 = Instr[19:15];
    assign rs2 = Instr[24:20];
    assign rd  = Instr[11:7];
    assign WD = Result;

    assign InstrImm = Instr[31:7];
    
    assign Opcode = Instr[6:0];
    assign Funct3 = Instr[14:12];
    assign Funct7 = Instr[31:25];
    
    assign PC_Offset = PC + ExtImm;
    
    // MCycle
    assign Start = IsMCycle;
    assign Operand1 = RD1;
    assign Operand2 = RD2;
    
    // Instantiate Src_A
    always @(*) 
    begin
        casez (ALUSrcA)
            2'b?0 : Src_A = RD1;
            2'b01 : Src_A = 32'b0;
            2'b11 : Src_A = PC;
            default: Src_A = RD1;
        endcase
    end
    
    // Instantiate Src_B
    always @(*) 
    begin
        casez (ALUSrcB)
            2'b?0 : Src_B = RD2;
            2'b01 : Src_B = 32'b100;
            2'b11 : Src_B = ExtImm;
            default: Src_B = RD2;
        endcase
    end
    
    // Instantiate PC_IN
	always @(*)
	begin
        case (PCSrc) 
            2'b00: PC_IN = PC + 32'b100;
            2'b01: PC_IN = PC_Offset;
            2'b11: PC_IN = (RD1 + ExtImm) & 32'hFFFFFFFE;
            default: PC_IN = PC + 32'b100;
        endcase	
	end
	
	// Instantiate WE_PC
	always @(*)
	begin
	   if (IsMCycle && Busy)
	       WE_PC = 1'b0;
	   else
	       WE_PC = 1'b1;
	end
	
	always @(*)
	begin
	   if (MemtoReg)
	       Result = ReadData;
	   else if (IsMCycle)
	       Result = MCycleResultHigh ? Result2 : Result1;
	   else
	       Result = ALUResult;
	end


    // Instantiate RegFile
    RegFile RegFile1( 
                    CLK,
                    WE,
                    rs1,
                    rs2,
                    rd,
                    WD,
                    RD1,
                    RD2     
                );
                
     // Instantiate Extend Module
    Extend Extend1(
                    ImmSrc,
                    InstrImm,
                    ExtImm
                );
                
    // Instantiate Decoder
    Decoder Decoder1(
                    Opcode,
                    Funct3,
                    Funct7,
                    PCS,
                    RegWrite,
                    MemWrite,
                    MemtoReg,
                    ALUSrcA,
                    ALUSrcB,
                    ImmSrc,
                    ALUControl,
                    IsMCycle,
                    MCycleOp,
                    MCycleResultHigh
                );
                
    // Instantiate PC_Logic
	PC_Logic PC_Logic1(
                    PCS,
                    Funct3,
                    ALUFlags,
                    PCSrc
		);
                
    // Instantiate ALU        
    ALU ALU1(
                    Src_A,
                    Src_B,
                    ALUControl,
                    ALUResult,
                    ALUFlags
                );       
                
    // Instantiate MCycle
    MCycle #(.width(32)) MCycle1(
                    CLK,
                    RESET,
                    Start,
                    MCycleOp,
                    Operand1,
                    Operand2,
                    Result1,
                    Result2,
                    Busy
                );  
    
    // Instantiate ProgramCounter    
    ProgramCounter #(.PC_INIT(PC_INIT)) ProgramCounter1(
                    CLK,
                    RESET,
                    WE_PC,    
                    PC_IN,
                    PC  
                );                         
endmodule
