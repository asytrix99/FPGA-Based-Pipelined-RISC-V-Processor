`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/19/2026 07:12:02 PM
// Design Name: 
// Module Name: tb_PC_Logic
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


module tb_PC_Logic(

    );  
    
    reg [1:0] PCS;	           // 00 for non-control, 01 for conditional branch, 10 for jal, 11 for jalr
	reg [2:0] Funct3;          // condition specified in the instruction (eq / ne / lt / ge / ltu / geu)
	reg [2:0] ALUFlags; 	   // {eq, lt, ltu}
	wire [1:0] PCSrc;          // PCSrc[1]: 0 = PC, 1 = RD1
                               // PCSrc[0]: 0 = 4,  1 = ExtImm
	
	PC_Logic dut (
        .PCS(PCS),
        .Funct3(Funct3),
        .ALUFlags(ALUFlags),
        .PCSrc(PCSrc)
    );
	
	task check;
       input [127:0] name;
	   input [1:0] test_PCS;
	   input [2:0] test_Funct3;
	   input [2:0] test_ALUFlags;
	   input [1:0] expected;
	   begin
	       PCS = test_PCS;
	       Funct3 = test_Funct3;
	       ALUFlags = test_ALUFlags;
	       #1;
           
           if (PCSrc !== expected) begin
               $display("Test failed | PCS=%b Funct3=%b Flags=%b | Expected=%b Got=%b", 
                       PCS, Funct3, ALUFlags, expected, PCSrc);
           end
       end        
	endtask
	
	
	initial begin
	   // Non Control
       check("Non Control",   2'b00, 3'b000, 3'b111, 2'b00);
	
	
	   // Branch   
	   // beq
       check("beq taken",     2'b01, 3'b000, 3'b100, 2'b01);
       check("beq not taken", 2'b01, 3'b000, 3'b000, 2'b00);
    
       //bne
       check("bne taken",     2'b01, 3'b001, 3'b000, 2'b01);
       check("bne not taken", 2'b01, 3'b001, 3'b100, 2'b00);

	   // blt
       check("blt taken",     2'b01, 3'b100, 3'b010, 2'b01);
       check("blt not taken", 2'b01, 3'b100, 3'b100, 2'b00);
       
       // bge
       check("bge taken",     2'b01, 3'b101, 3'b100, 2'b01);
       check("bge not taken", 2'b01, 3'b101, 3'b010, 2'b00);
       
       // bltu 
       check("bltu taken",    2'b01, 3'b110, 3'b001, 2'b01);
       check("bltu not taken",2'b01, 3'b110, 3'b100, 2'b00);
       
       // bgeu
       check("bgeu taken",    2'b01, 3'b111, 3'b100, 2'b01);
       check("bgeu not taken",2'b01, 3'b111, 3'b001, 2'b00);
       
       // Invalid branch Funct3
       check("Invalid Funct3",2'b01, 3'b010, 3'b111, 2'b00);
       check("Invalid Funct3",2'b01, 3'b011, 3'b111, 2'b00);
       
       
       // Jump
       // jal & jalr
       check("jal",           2'b10, 3'b111, 3'b111, 2'b01);
       check("jalr",          2'b11, 3'b111, 3'b111, 2'b11);
       
       
       // Invalid PCS
       check("Invalid PC"    ,2'bxx, 3'b000, 3'b000, 2'b00);

       $display("PC Logic simulation done.");
       $finish;
	end
endmodule
