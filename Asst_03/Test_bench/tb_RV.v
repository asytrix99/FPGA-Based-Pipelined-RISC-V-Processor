`timescale 1ns / 1ps

module tb_RV(

    );
    
    localparam [31:0] BASE = 32'h0040_0000;
    localparam IROM_DEPTH_BITS = 9;	//9 for 128 words. Change if your program is larger.
    localparam DMEM_DEPTH_BITS = 9;		//9 for 128 words. Change if your data (const+variable) is larger, and in C/Assembly to set STACK_INIT appropriately.
    
    reg [31:0] IROM [0:2**(IROM_DEPTH_BITS-2)-1];
    reg [31:0] DMEM [0:2**(DMEM_DEPTH_BITS-2)-1];

    reg CLK = 1'b0;
    reg RESET = 1'b1;
    reg [31:0] Instr;
    wire [31:0] ReadData_in;
    wire MemRead;
    wire [3:0] MemWrite_out;
    wire [31:0] PC;
    wire [31:0] ALUResult;
    wire [31:0] WriteData_out;
    
    assign ReadData_in = (MemRead) ? DMEM[ALUResult[DMEM_DEPTH_BITS-1:2]] : 32'b0;
    
    always #5 CLK = ~CLK;
   
    always@( * ) begin 
        Instr = ( ( PC[31:IROM_DEPTH_BITS] == BASE[31:IROM_DEPTH_BITS]) && (PC[1:0] == 2'b00) ) 
                ? IROM[PC[IROM_DEPTH_BITS-1:2]] : 32'h00000013 ;    						
    end
   
   
    RV #(.PC_INIT(BASE)) dut (
        .CLK(CLK),
        .RESET(RESET),
        .Instr(Instr),
        .ReadData_in(ReadData_in),
        .MemRead(MemRead),
        .MemWrite_out(MemWrite_out),
        .PC(PC),
        .ALUResult(ALUResult),
        .WriteData_out(WriteData_out)
    );
    
    function [31:0] encode_r;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            encode_r = {funct7, rs2, rs1, funct3, rd, 7'b0110011};
        end
    endfunction 
    
    
    function [31:0] encode_i;
        input [11:0] imm;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            encode_i = {imm, rs1, funct3, rd, 7'b0010011};
        end
    endfunction
    
    function [31:0] encode_s;
        input [11:0] imm;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        begin
            encode_s = {imm[11:5], rs2, rs1, funct3, imm[4:0], 7'b0100011};
        end
    endfunction
    
    function [31:0] encode_b;
        input [12:0] imm;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        begin
            encode_b = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], 7'b1100011};
        end
    endfunction
    
    function [31:0] encode_u;
        input [19:0] imm;
        input [4:0] rd;
        begin
            encode_u = {imm, rd, 7'b0010111};
        end
    endfunction
    
    function [31:0] encode_j;
        input [20:0] imm;
        input [4:0] rd;
        begin
            encode_j = {imm[20], imm[10:1], imm[11], imm[19:12], rd, 7'b1101111};
        end
    endfunction
    
    function [31:0] encode_l;
        input [11:0] imm;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            encode_l = {imm, rs1, funct3, rd, 7'b0000011};
        end
    endfunction
 
     function [31:0] encode_jalr;
        input [11:0] imm;
        input [4:0] rs1;
        input [4:0] rd;
        begin
            encode_jalr = {imm, rs1, 3'b000, rd, 7'b1100111};
        end
    endfunction
    
    reg busy_at_edge;
    reg [31:0] pc_at_edge;
    
    // Check that the PC does not change across an edge where MCycle is busy.
    always @(posedge CLK) begin
        if (!RESET) begin
            busy_at_edge = dut.Busy;
            pc_at_edge = PC;
            #1;
            if (busy_at_edge && PC !== pc_at_edge)
                $display("MCycle incorporation to RV.v failed. PC changed while MCycle was busy");
        end
    end
    
    integer i;
    integer store_count = 0;
    // Check each stored result. ALUResult is the store address. This is because we will use sw rs2, imm(x0) 
    // ALUResult = imm
    always @(posedge CLK) begin
        if (!RESET && MemWrite_out != 4'b0000) begin // SW is executed
            case (ALUResult)
                32'd0:  if (WriteData_out !== 32'hffff_fff9) $display("ADDI failed");
                32'd4:  if (WriteData_out !== 32'd3)         $display("ADDI failed");
                32'd8:  if (WriteData_out !== 32'hffff_ffeb) $display("MUL failed");
                32'd12: if (WriteData_out !== 32'hffff_ffff) $display("MULH failed");
                32'd16: if (WriteData_out !== 32'd2)         $display("MULHU failed");
                32'd20: if (WriteData_out !== 32'hffff_fffe) $display("DIV failed");
                32'd24: if (WriteData_out !== 32'h5555_5553) $display("DIVU failed");
                32'd28: if (WriteData_out !== 32'hffff_ffff) $display("REM failed");
                32'd32: if (WriteData_out !== 32'd0)         $display("REMU failed");
            
                32'd36: if (WriteData_out !== 32'hffff_fffc) $display("ADD failed");
                32'd40: if (WriteData_out !== 32'hffff_fff6) $display("SUB failed");
                32'd44: if (WriteData_out !== 32'hffff_fffa) $display("XOR failed");
                32'd48: if (WriteData_out !== 32'hffff_fffb) $display("OR failed");
                32'd52: if (WriteData_out !== 32'h0000_0001) $display("AND failed");
                32'd56: if (WriteData_out !== 32'hffff_ffc8) $display("SLL failed");
                32'd60: if (WriteData_out !== 32'h1fff_ffff) $display("SRL failed");
                32'd64: if (WriteData_out !== 32'hffff_ffff) $display("SRA failed");
                32'd68: if (WriteData_out !== 32'd1)         $display("SLT failed");
                32'd72: if (WriteData_out !== 32'd0)         $display("SLTU failed");
                
                // I-Type
                32'd76:  if (WriteData_out !== 32'hffff_fffc) $display("ADDI failed");
                32'd80:  if (WriteData_out !== 32'hffff_fffa) $display("XORI failed");
                32'd84:  if (WriteData_out !== 32'hffff_fffb) $display("ORI failed");
                32'd88:  if (WriteData_out !== 32'h0000_0001) $display("ANDI failed");
                32'd92:  if (WriteData_out !== 32'hffff_ffc8) $display("SLLI failed");
                32'd96:  if (WriteData_out !== 32'h1fff_ffff) $display("SRLI failed");
                32'd100: if (WriteData_out !== 32'hffff_ffff) $display("SRAI failed");
                32'd104: if (WriteData_out !== 32'd1)         $display("SLTI failed");
                32'd108: if (WriteData_out !== 32'd0)         $display("SLTIU failed");

                // U-Type
                32'd112: if (WriteData_out !== 32'h1234_5000) $display("LUI failed");
                32'd116: if (WriteData_out !== 32'h1274_50e8) $display("AUIPC failed");
                
                // Load
                32'd120: if (WriteData_out !== 32'h1234_5678) $display("LW failed");
                
                // B-Type
                32'd124: if (WriteData_out !== 32'd42)        $display("BEQ failed");
                32'd128: if (WriteData_out !== 32'd42)        $display("BNE failed");
                32'd132: if (WriteData_out !== 32'd42)        $display("BLT failed");
                32'd136: if (WriteData_out !== 32'd42)        $display("BGE failed");
                32'd140: if (WriteData_out !== 32'd42)        $display("BLTU failed");
                32'd144: if (WriteData_out !== 32'd42)        $display("BGEU failed");

                // J-Type
                32'd148: if (WriteData_out !== 32'd42)        $display("JAL jump failed");
                32'd152: if (WriteData_out !== 32'h0040_0160) $display("JAL link failed");

                // JALR
                32'd156: if (WriteData_out !== 32'd42)        $display("JALR jump failed");
                32'd160: if (WriteData_out !== 32'h0040_017c) $display("JALR link failed");
                
                default: $display("Unexpected store address: %h", ALUResult);
            endcase
            
            store_count = store_count + 1;

            if (store_count == 41) begin
                $display("All RV tests completed");
                $finish;
            end
        end
    end
    
    initial begin
        for (i = 0; i < 128; i = i + 1)
            IROM[i] = 32'h0000_0013; // NOP
         
        for (i = 0; i < 128; i = i + 1)
            DMEM[i] = 32'b0;
            
        DMEM[0] = 32'h1234_5678;
        // -7 is ffff_fff9
        // 3 is 0000_0003

        IROM[0]  = encode_i(12'hff9, 5'd0, 3'b000, 5'd1);          // addi x1, x0, -7
        IROM[1]  = encode_s(12'd0,  5'd1, 5'd0, 3'b010);           // sw x1, 0(x0)
        
        IROM[2]  = encode_i(12'd3,   5'd0, 3'b000, 5'd2);          // addi x2, x0, 3
        IROM[3]  = encode_s(12'd4,  5'd2, 5'd0, 3'b010);           // sw x2, 4(x0)
        
        IROM[4]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3); // mul x3, x1, x2
        IROM[5]  = encode_s(12'd8,  5'd3, 5'd0, 3'b010);           // sw x3, 8(x0)

        IROM[6]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b001, 5'd4); // mulh x4, x1, x2
        IROM[7]  = encode_s(12'd12,  5'd4, 5'd0, 3'b010);          // sw x4, 12(x0)

        IROM[8]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b011, 5'd5); // mulhu x5, x1, x2
        IROM[9]  = encode_s(12'd16,  5'd5, 5'd0, 3'b010);           // sw x5, 16(x0)

        IROM[10]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b100, 5'd6); // div x6, x1, x2
        IROM[11]  = encode_s(12'd20, 5'd6, 5'd0, 3'b010);           // sw x6, 20(x0)

        IROM[12] = encode_r(7'b0000001, 5'd2, 5'd1, 3'b101, 5'd7); // divu x7, x1, x2
        IROM[13] = encode_s(12'd24, 5'd7, 5'd0, 3'b010);           // sw x7, 24(x0)

        IROM[14] = encode_r(7'b0000001, 5'd2, 5'd1, 3'b110, 5'd8); // rem x8, x1, x2
        IROM[15] = encode_s(12'd28, 5'd8, 5'd0, 3'b010);           // sw x8, 28(x0)

        IROM[16] = encode_r(7'b0000001, 5'd2, 5'd1, 3'b111, 5'd9); // remu x9, x1, x2
        IROM[17] = encode_s(12'd32, 5'd9, 5'd0, 3'b010);           // sw x9, 32(x0)

        IROM[18] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd9); // add x9, x1, x2
        IROM[19] = encode_s(12'd36, 5'd9, 5'd0, 3'b010);           // sw x9, 36(x0)
        
        IROM[20] = encode_r(7'b0100000, 5'd2, 5'd1, 3'b000, 5'd9); // sub x9, x1, x2
        IROM[21] = encode_s(12'd40, 5'd9, 5'd0, 3'b010);           // sw x9, 40(x0)
        
        IROM[22] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b100, 5'd9); // xor x9, x1, x2
        IROM[23] = encode_s(12'd44, 5'd9, 5'd0, 3'b010);           // sw x9, 44(x0)              
        
        IROM[24] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b110, 5'd9); // or x9, x1, x2
        IROM[25] = encode_s(12'd48, 5'd9, 5'd0, 3'b010);           // sw x9, 48(x0)                
        
        IROM[26] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b111, 5'd9); // and x9, x1, x2
        IROM[27] = encode_s(12'd52, 5'd9, 5'd0, 3'b010);           // sw x9, 52(x0)
        
        IROM[28] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b001, 5'd9); // sll x9, x1, x2
        IROM[29] = encode_s(12'd56, 5'd9, 5'd0, 3'b010);           // sw x9, 56(x0)

        IROM[30] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b101, 5'd9); // srl x9, x1, x2
        IROM[31] = encode_s(12'd60, 5'd9, 5'd0, 3'b010);           // sw x9, 60(x0)

        IROM[32] = encode_r(7'b0100000, 5'd2, 5'd1, 3'b101, 5'd9); // sra x9, x1, x2
        IROM[33] = encode_s(12'd64, 5'd9, 5'd0, 3'b010);           // sw x9, 64(x0)

        IROM[34] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b010, 5'd9); // slt x9, x1, x2
        IROM[35] = encode_s(12'd68, 5'd9, 5'd0, 3'b010);           // sw x9, 68(x0)
        
        IROM[36] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b011, 5'd9); // sltu x9, x1, x2
        IROM[37] = encode_s(12'd72, 5'd9, 5'd0, 3'b010);           // sw x9, 72(x0)       

        // I-Type
        IROM[38] = encode_i(12'd3, 5'd1, 3'b000, 5'd9);          // addi x9, x1, 3
        IROM[39] = encode_s(12'd76, 5'd9, 5'd0, 3'b010);          // sw x9, 76(x0)

        IROM[40] = encode_i(12'd3, 5'd1, 3'b100, 5'd9);          // xori x9, x1, 3
        IROM[41] = encode_s(12'd80, 5'd9, 5'd0, 3'b010);          // sw x9, 80(x0)

        IROM[42] = encode_i(12'd3, 5'd1, 3'b110, 5'd9);          // ori x9, x1, 3
        IROM[43] = encode_s(12'd84, 5'd9, 5'd0, 3'b010);          // sw x9, 84(x0)

        IROM[44] = encode_i(12'd3, 5'd1, 3'b111, 5'd9);          // andi x9, x1, 3
        IROM[45] = encode_s(12'd88, 5'd9, 5'd0, 3'b010);          // sw x9, 88(x0)

        IROM[46] = encode_i(12'd3, 5'd1, 3'b001, 5'd9);          // slli x9, x1, 3
        IROM[47] = encode_s(12'd92, 5'd9, 5'd0, 3'b010);          // sw x9, 92(x0)

        IROM[48] = encode_i(12'd3, 5'd1, 3'b101, 5'd9);          // srli x9, x1, 3
        IROM[49] = encode_s(12'd96, 5'd9, 5'd0, 3'b010);          // sw x9, 96(x0)

        IROM[50] = encode_i(12'h403, 5'd1, 3'b101, 5'd9);        // srai x9, x1, 3
        IROM[51] = encode_s(12'd100, 5'd9, 5'd0, 3'b010);         // sw x9, 100(x0)

        IROM[52] = encode_i(12'd3, 5'd1, 3'b010, 5'd9);          // slti x9, x1, 3
        IROM[53] = encode_s(12'd104, 5'd9, 5'd0, 3'b010);         // sw x9, 104(x0)

        IROM[54] = encode_i(12'd3, 5'd1, 3'b011, 5'd9);          // sltiu x9, x1, 3
        IROM[55] = encode_s(12'd108, 5'd9, 5'd0, 3'b010);         // sw x9, 108(x0)

        // U-Type
        IROM[56] = {20'h12345, 5'd9, 7'b0110111};               // lui x9, 0x12345
        IROM[57] = encode_s(12'd112, 5'd9, 5'd0, 3'b010);         // sw x9, 112(x0)

        IROM[58] = encode_u(20'h12345, 5'd9);                    // auipc x9, 0x12345
        // 0x004000E8 + 0x12345000} = 0x127450E8
        IROM[59] = encode_s(12'd116, 5'd9, 5'd0, 3'b010);         // sw x9, 116(x0)

        // Load
        IROM[60] = encode_l(12'd0, 5'd0, 3'b010, 5'd9);    // lw x9, 0(x0)
        IROM[61] = encode_s(12'd120, 5'd9, 5'd0, 3'b010);  // sw x9, 120(x0)

        // B-Type
        IROM[62] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[63] = encode_b(13'd8, 5'd1, 5'd1, 3'b000);   // beq x1, x1, 8
        IROM[64] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[65] = encode_s(12'd124, 5'd9, 5'd0, 3'b010); // sw x9, 124(x0)

        IROM[66] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[67] = encode_b(13'd8, 5'd2, 5'd1, 3'b001);   // bne x1, x2, 8
        IROM[68] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[69] = encode_s(12'd128, 5'd9, 5'd0, 3'b010); // sw x9, 128(x0)

        IROM[70] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[71] = encode_b(13'd8, 5'd2, 5'd1, 3'b100);   // blt x1, x2, 8
        IROM[72] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[73] = encode_s(12'd132, 5'd9, 5'd0, 3'b010); // sw x9, 132(x0)

        IROM[74] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[75] = encode_b(13'd8, 5'd1, 5'd2, 3'b101);   // bge x2, x1, 8
        IROM[76] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[77] = encode_s(12'd136, 5'd9, 5'd0, 3'b010); // sw x9, 136(x0)

        IROM[78] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[79] = encode_b(13'd8, 5'd1, 5'd2, 3'b110);   // bltu x2, x1, 8
        IROM[80] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[81] = encode_s(12'd140, 5'd9, 5'd0, 3'b010); // sw x9, 140(x0)

        IROM[82] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[83] = encode_b(13'd8, 5'd2, 5'd1, 3'b111);   // bgeu x1, x2, 8
        IROM[84] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[85] = encode_s(12'd144, 5'd9, 5'd0, 3'b010); // sw x9, 144(x0)

        // J-Type
        IROM[86] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[87] = encode_j(21'd8, 5'd10);                // jal x10, 8
        IROM[88] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[89] = encode_s(12'd148, 5'd9, 5'd0, 3'b010); // sw x9, 148(x0)
        IROM[90] = encode_s(12'd152, 5'd10, 5'd0, 3'b010);// sw x10, 152(x0)

        // JALR
        IROM[91] = encode_u(20'd0, 5'd11);                // auipc x11, 0
        IROM[92] = encode_i(12'd21, 5'd11, 3'b000, 5'd11);// addi x11, x11, 21
        IROM[93] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[94] = encode_jalr(12'd0, 5'd11, 5'd10);      // jalr x10, 0(x11)
        IROM[95] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[96] = encode_s(12'd156, 5'd9, 5'd0, 3'b010); // sw x9, 156(x0)
        IROM[97] = encode_s(12'd160, 5'd10, 5'd0, 3'b010);// sw x10, 160(x0)

        IROM[98] = encode_j(21'd0, 5'd0);                 // jal x0, 0                
        // Initialise CPU
        repeat (2) @(negedge CLK);
        RESET = 1'b0;
    end

    initial begin
        #100000;
        $display("TEST TIMEOUT: Only %0d / 41 stores completed", store_count);
        $finish;
    end
    
endmodule
