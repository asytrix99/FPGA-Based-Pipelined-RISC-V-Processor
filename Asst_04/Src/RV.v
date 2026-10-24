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
    output reg [3:0] MemWrite_out,		// Column-wise write enable to support sb/sw. Each column is a byte.
    output [31:0] PC,
    output [31:0] ALUResult,
    output reg [31:0] WriteData_out		// Name mangled to support sb/sw
);
    
    // Please read Lab 4 Enhancement: Implementing additional instructions on how to support lb/lbu/lh/lhu/sb/sh
        
    // RV Signals
    wire [2:0] SizeSel;                                     // to support lb/lbu/lh/lhu/sb/sh

    // ============================ F stage ============================
    // ProgramCounter signals (the PC port is PC_F, the Instr port is Instr_F)
    reg WE_PC;                                              // Instantiated in the always loop
    reg [31:0] PC_IN;                                       // Instantiated in the always loop

    // ============================ D stage ============================
    // D stage register
    reg [31:0] Instr_D, PC_D;                               // Instantiated by D stage register
    // RegFile read signals
    wire [4:0] rs1_D, rs2_D, rd_D;                          // Instantiated by assign below
    wire [31:0] RD1_D, RD2_D;                               // Instantiated by assign below
    // Extend Module signals
    wire [2:0] ImmSrc;                                      // Instantiated by Decoder
    wire [24:0] InstrImm;                                   // Instantiated by assign below
    wire [31:0] ExtImm_D;                                   // Instantiated by Extend
    // Decoder signals
    wire [6:0] Opcode, Funct7;                              // Instantiated by assign below
    wire [2:0] Funct3_D;                                    // Instantiated by assign below
    wire [1:0] PCS_D, ALUSrcA_D, ALUSrcB_D, MCycleOp_D;     // Instantiated by Decoder
    wire [3:0] ALUControl_D;                                // Instantiated by Decoder
    wire RegWrite_D, MemWrite_D, MemtoReg_D;                // Instantiated by Decoder
    wire IsMCycle_D, MCycleResultHigh_D;                    // Instantiated by Decoder
    wire Forward1D, Forward2D;
    wire [31:0] RD1_D_reg, RD2_D_reg;                       // Instantiated by RegFile


    // ============================ E stage ============================
    // E stage register
    reg [31:0] PC_E, RD1_E, RD2_E, ExtImm_E;                // Instantiated by E stage register
    reg [4:0] rd_E;                                         // Instantiated by E stage register
    reg [2:0] Funct3_E;                                     // Instantiated by E stage register
    reg [1:0] PCS_E, ALUSrcA_E, ALUSrcB_E, MCycleOp_E;      // Instantiated by E stage register
    reg [3:0] ALUControl_E;                                 // Instantiated by E stage register
    reg RegWrite_E, MemWrite_E, MemtoReg_E;                 // Instantiated by E stage register
    reg IsMCycle_E, MCycleResultHigh_E;                     // Instantiated by E stage register
    // ALU signals
    reg [31:0] Src_A, Src_B;                                // Instantiated in the always loop
    wire [31:0] ALUResult_E;                                // Instantiated by ALU
    wire [2:0] ALUFlags_E;                                  // Instantiated by ALU
    // PC_Logic signals
    wire [1:0] PCSrc_E;                                     // Instantiated by PC_Logic
    wire [31:0] PC_Offset_E;                                // Instantiated by assign below
    // MCycle signals
    wire Start;                                             // Instantiated by assign below
    wire [31:0] Operand1, Operand2;                         // Instantiated by assign below
    wire [31:0] Result1, Result2;                           // Instantiated by MCycle
    wire Busy;                                              // Instantiated by MCycle
    wire Stall;                                             // MCycle still computing: hold F, D, E. Instantiated by assign below
    // Stage outputs
    reg [31:0] ExecResult_E;                                // ALU or MCycle result, instantiated in the always loop
    wire [31:0] WriteData_E;                                // Instantiated by assign below
    
    // Data forwarding  
    reg [4:0] rs1_E, rs2_E;                                 // Instantiated by assign below
    reg [1:0] ForwardAE;                                    // Instantiated in the always loop
    reg [1:0] ForwardBE;                                    // Instantiated in the always loop
    reg [31:0] RD1_E_FORWARD;
    reg [31:0] RD2_E_FORWARD;

    // ============================ M stage ============================
    // M stage register
    reg [31:0] ALUResult_M, WriteData_M;                    // Instantiated by M stage register
    reg [4:0] rd_M;                                         // Instantiated by M stage register
    reg [2:0] Funct3_M;                                     // Instantiated by M stage register
    reg RegWrite_M, MemWrite_M, MemtoReg_M;                 // Instantiated by M stage register
    // Data memory signals
    wire [31:0] ReadData_M;                                 // Instantiated by assign below
    reg [4:0] rs2_M;                                        // Instantiated by assign below
    wire FowardM;


    // ============================ W stage ============================
    // W stage register
    reg [31:0] ALUResult_W, ReadData_W;                     // Instantiated by W stage register
    reg [4:0] rd_W;                                         // Instantiated by W stage register
    reg [2:0] Funct3_W;                                     // Instantiated by W stage register
    reg RegWrite_W, MemtoReg_W;                             // Instantiated by W stage register
    // Load extraction and result signals
    reg [7:0] LoadByte;                                     // Instantiated in the always loop
    reg [15:0] LoadHalf;                                    // Instantiated in the always loop
    reg [31:0] Result_W;                                    // Instantiated in the always loop
    // RegFile write signals
    wire WE;                                                // Instantiated by assign below
    wire [31:0] WD;                                         // Instantiated by assign below
    wire [31:0] WriteData_M_FORWARD;


    // =========================== Stall/flush ==========================\
    wire lwStall;
    wire StallF;
    wire StallD;
    wire FlushD;
    wire FlushE;


    assign SizeSel = 3'b010;             // Change this to be generated by the Decoder (control) as appropriate if 
                                         // supporting lb/sb/lbu/lh/sh/lhu/lw/sw. Hint: funct3

    // todo: other datapath connections here
    // ============================ D stage ============================
    assign Funct3_D = Instr_D[14:12];
    assign Opcode = Instr_D[6:0];
    assign Funct7 = Instr_D[31:25];
    assign rs1_D = Instr_D[19:15];
    assign rs2_D = Instr_D[24:20];
    assign rd_D  = Instr_D[11:7];
    assign InstrImm = Instr_D[31:7];

    // D stage register
    always @ (posedge CLK) begin
        if (RESET | FlushD) begin
            Instr_D <= 32'h0000_0013;   // nop to pass illegal instruction check
            PC_D <= 32'b0;
        end else if (!Stall & !StallD) begin
            Instr_D <= Instr;
            PC_D <= PC;
        end
    end

    // ============================ E stage ============================
    assign PC_Offset_E = PC_E + ExtImm_E;
    assign WriteData_E = RD2_E_FORWARD;
    // Mcycle
    assign Start = IsMCycle_E;
    assign Operand1 = RD1_E_FORWARD;
    assign Operand2 = RD2_E_FORWARD;
    assign Stall = IsMCycle_E & Busy;
    
    assign RD1_D = Forward1D ? Result_W : RD1_D_reg;
    assign RD2_D = Forward2D ? Result_W : RD2_D_reg;

    // E stage register
    always @ (posedge CLK) begin
        if (RESET | FlushE) begin
            PCS_E <= 2'b0;
            RD1_E <= 32'b0;
            RD2_E <= 32'b0;
            RegWrite_E <= 1'b0;
            MemtoReg_E <= 1'b0;
            MemWrite_E <= 1'b0;
            ALUControl_E <= 4'b0;
            ALUSrcA_E <= 2'b0;
            ALUSrcB_E <= 2'b0;
            ExtImm_E <= 32'b0;
            rd_E <= 5'b0;
            PC_E <= 32'b0;
            Funct3_E <= 3'b0;
            // Mcycle
            IsMCycle_E <= 1'b0;
            MCycleOp_E <= 2'b0;
            MCycleResultHigh_E <= 1'b0;
            rs1_E <= 5'b0;
            rs2_E <= 5'b0;
        end else if (!Stall) begin
            PCS_E <= PCS_D;
            RD1_E <= RD1_D;
            RD2_E <= RD2_D;
            RegWrite_E <= RegWrite_D;
            MemtoReg_E <= MemtoReg_D;
            MemWrite_E <= MemWrite_D;
            ALUControl_E <= ALUControl_D;
            ALUSrcA_E <= ALUSrcA_D;
            ALUSrcB_E <= ALUSrcB_D;
            ExtImm_E <= ExtImm_D;
            rd_E <= rd_D;
            PC_E <= PC_D;
            Funct3_E <= Funct3_D;
            // Mcycle
            IsMCycle_E <= IsMCycle_D;
            MCycleOp_E <= MCycleOp_D;
            MCycleResultHigh_E <= MCycleResultHigh_D;
            rs1_E <= rs1_D;
            rs2_E <= rs2_D;
        end
    end

    // ============================ M stage ============================
    assign ReadData_M = ReadData_in; 
    assign MemRead = MemtoReg_M;           // This is needed for the proper functionality of some devices such as UART CONSOLE
    assign ALUResult = ALUResult_M;        // Data memory address to the Wrapper

    // M stage register
    always @ (posedge CLK) begin
        if (RESET) begin
            RegWrite_M <= 1'b0;
            MemtoReg_M <= 1'b0;
            MemWrite_M <= 1'b0;
            ALUResult_M <= 32'b0;
            WriteData_M <= 32'b0;
            rd_M <= 5'b0;
            Funct3_M <= 3'b0;
            rs2_M <= 5'b0;
        end else if (Stall) begin
            // MCycle instruction stays in E, nop prevents writes in M or W stages
            RegWrite_M <= 1'b0;
            MemtoReg_M <= 1'b0;
            MemWrite_M <= 1'b0;
            rs2_M <= 5'b0;
        end else begin
            RegWrite_M <= RegWrite_E;
            MemtoReg_M <= MemtoReg_E;
            MemWrite_M <= MemWrite_E;
            ALUResult_M <= ExecResult_E;
            WriteData_M <= WriteData_E;
            rd_M <= rd_E;
            Funct3_M <= Funct3_E;
            rs2_M <= rs2_E;
        end
    end

    // ============================ W stage ============================
    assign WE = RegWrite_W;
    assign WD = Result_W;

    // W stage register
    always @ (posedge CLK) begin
        if (RESET) begin
            RegWrite_W <= 1'b0;
            MemtoReg_W <= 1'b0;
            ReadData_W <= 32'b0;
            Funct3_W <= 3'b0;
            ALUResult_W <= 32'b0;
            rd_W <= 5'b0;
        end
        else begin
            RegWrite_W <= RegWrite_M;
            MemtoReg_W <= MemtoReg_M;
            ReadData_W <= ReadData_M;
            Funct3_W <= Funct3_M;
            ALUResult_W <= ALUResult_M;
            rd_W <= rd_M;
        end
    end

    // Instantiate Src_A
    always @(*) 
    begin
        casez (ALUSrcA_E)
            2'b?0 : Src_A = RD1_E_FORWARD;
            2'b01 : Src_A = 32'b0;
            2'b11 : Src_A = PC_E;
            default: Src_A = RD1_E_FORWARD;
        endcase
    end
    
    // Instantiate Src_B
    always @(*) 
    begin
        casez (ALUSrcB_E)
            2'b?0 : Src_B = RD2_E_FORWARD;
            2'b01 : Src_B = 32'b100;
            2'b11 : Src_B = ExtImm_E;
            default: Src_B = RD2_E_FORWARD;
        endcase
    end
    
    // Instantiate PC_IN
	always @(*)
	begin
        case (PCSrc_E) 
            2'b00: PC_IN = PC + 32'b100;
            2'b01: PC_IN = PC_Offset_E;
            2'b11: PC_IN = (RD1_E_FORWARD + ExtImm_E) & 32'hFFFFFFFE;
            default: PC_IN = PC + 32'b100;
        endcase	
	end
	
	// Instantiate WE_PC
	always @(*)
	begin
	   if (Stall | StallF)
	       WE_PC = 1'b0;
	   else 
	       WE_PC = 1'b1;
	end

    // Instantiate ExecResult_E
    always @ (*) begin
        if (IsMCycle_E)
            ExecResult_E = MCycleResultHigh_E ? Result2 : Result1;
        else
            ExecResult_E = ALUResult_E;
    end
	
	// Instantiate LoadByte and LoadWord
	always @(*) begin
        case (ALUResult_W[1:0])
            2'b00: LoadByte = ReadData_W[7:0];
            2'b01: LoadByte = ReadData_W[15:8];
            2'b10: LoadByte = ReadData_W[23:16];
            2'b11: LoadByte = ReadData_W[31:24];
            default: LoadByte = 8'b0;
        endcase
    
        case (ALUResult_W[1])
            1'b0: LoadHalf = ReadData_W[15:0];
            1'b1: LoadHalf = ReadData_W[31:16];
            default: LoadHalf = 16'b0;
        endcase
    end
	
    // Instantiate Result_W
	always @(*) begin
        if (MemtoReg_W) begin
            case (Funct3_W)
                3'b000: Result_W = {{24{LoadByte[7]}}, LoadByte};     //lb
                3'b001: Result_W = {{16{LoadHalf[15]}}, LoadHalf};    //lh
                3'b010: Result_W = ReadData_W;                        //lw
                3'b100: Result_W = {24'b0, LoadByte};                 //lbu
                3'b101: Result_W = {16'b0, LoadHalf};                 //lhu
                default: Result_W = ReadData_W;
            endcase
       end
         else
                Result_W = ALUResult_W;
	end
    
    // Instantiate WriteData_out and MemWrite_out
    always @ (*) begin
        WriteData_out = WriteData_M_FORWARD;
        MemWrite_out = 4'b0000;
        if (MemWrite_M) begin
            case (Funct3_M)
                3'b000: begin
                    // sb
                    WriteData_out = {4{WriteData_M_FORWARD[7:0]}};
                    case (ALUResult_M[1:0])
                        2'b00: MemWrite_out = 4'b0001;
                        2'b01: MemWrite_out = 4'b0010;
                        2'b10: MemWrite_out = 4'b0100;
                        2'b11: MemWrite_out = 4'b1000;
                        default: MemWrite_out = 4'b0000;
                    endcase
                end
                3'b001: begin
                    // sh
                    WriteData_out = {2{WriteData_M_FORWARD[15:0]}};
                    case (ALUResult_M[1])
                        1'b0: MemWrite_out = 4'b0011;
                        1'b1: MemWrite_out = 4'b1100;
                        default: MemWrite_out = 4'b0000;
                    endcase
                end
                // sw
                default: begin
                    MemWrite_out = 4'b1111;
                end
            endcase
        end
    end
    
    // Data forwarding for Decode stage
    assign Forward1D = (rs1_D == rd_W) & RegWrite_W & (rs1_D != 5'd0);
    assign Forward2D = (rs2_D == rd_W) & RegWrite_W & (rs2_D != 5'd0);
    
    // Data forwaring for execute stage
    always @ (*) begin
        if ((rs1_E == rd_M) & RegWrite_M & (rs1_E != 5'd0)) ForwardAE = 2'b10;
        else if ((rs1_E == rd_W) & RegWrite_W & (rs1_E != 5'd0)) ForwardAE = 2'b01;
        else ForwardAE = 2'b00;
    end
    
    always @ (*) begin
        if ((rs2_E == rd_M) & RegWrite_M & (rs2_E != 5'd0)) ForwardBE = 2'b10;
        else if ((rs2_E == rd_W) & RegWrite_W & (rs2_E != 5'd0)) ForwardBE = 2'b01;
        else ForwardBE = 2'b00;
    end
    
    always @ (*) begin
        case (ForwardAE)
            2'b00: RD1_E_FORWARD = RD1_E;
            2'b01: RD1_E_FORWARD = Result_W;
            2'b10: RD1_E_FORWARD = ALUResult_M;
            default: RD1_E_FORWARD = RD1_E;
        endcase
    end
    
    always @ (*) begin
        case (ForwardBE)
            2'b00: RD2_E_FORWARD = RD2_E;
            2'b01: RD2_E_FORWARD = Result_W;
            2'b10: RD2_E_FORWARD = ALUResult_M;
            default: RD2_E_FORWARD = RD2_E;
        endcase
    end
    
    // Data forwaring for memory stage
    assign FowardM = (rs2_M == rd_W) & MemWrite_M & MemtoReg_W & (rd_W != 5'd0);
    assign WriteData_M_FORWARD = FowardM ? Result_W : WriteData_M;


    // Stalling and Flushing
    assign lwStall = ((rs1_D == rd_E) | (rs2_D == rd_E)) & MemtoReg_E & (rd_E != 5'd0);
    assign StallF = lwStall;
    assign StallD = lwStall;
    assign FlushD = |PCSrc_E;
    assign FlushE = lwStall || (|PCSrc_E);
    
    
    // Instantiate RegFile
    RegFile RegFile1( 
                    CLK,
                    WE,
                    rs1_D,
                    rs2_D,
                    rd_W,
                    WD,
                    RD1_D_reg,
                    RD2_D_reg
                );

     // Instantiate Extend Module
    Extend Extend1(
                    ImmSrc,
                    InstrImm,
                    ExtImm_D
                );

    // Instantiate Decoder
    Decoder Decoder1(
                    Opcode,
                    Funct3_D,
                    Funct7,
                    PCS_D,
                    RegWrite_D,
                    MemWrite_D,
                    MemtoReg_D,
                    ALUSrcA_D,
                    ALUSrcB_D,
                    ImmSrc,
                    ALUControl_D,
                    IsMCycle_D,
                    MCycleOp_D,
                    MCycleResultHigh_D
                );

    // Instantiate PC_Logic
	PC_Logic PC_Logic1(
                    PCS_E,
                    Funct3_E,
                    ALUFlags_E,
                    PCSrc_E
		);

    // Instantiate ALU
    ALU ALU1(
                    Src_A,
                    Src_B,
                    ALUControl_E,
                    ALUResult_E,
                    ALUFlags_E
                );

    // Instantiate MCycle
    MCycle #(.width(32)) MCycle1(
                    CLK,
                    RESET,
                    Start,
                    MCycleOp_E,
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
