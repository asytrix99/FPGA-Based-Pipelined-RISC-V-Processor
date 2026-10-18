`timescale 1ns / 1ps

module tb_RV(

    );
    
    localparam [31:0] BASE = 32'h0040_0000;
    localparam IROM_DEPTH_BITS = 11;	//11 for 512 words. Change if your program is larger.
    localparam NOPS = 2;                // nops after every test instruction
    localparam STRIDE = NOPS + 1;       // IROM slots per test instruction: instruction + NOPS
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
    
    // Byte-wise DMEM write, same as in Wrapper.v. Only addresses from SCRATCH onwards are written, 
    // as the lower addresses are only used to tag which test a store belongs to.
    localparam [31:0] SCRATCH = 32'd256;
    localparam NUM_STORES = 65;
    integer k;
    always @(posedge CLK) begin
        if (!RESET && ALUResult >= SCRATCH) begin
            for (k = 0; k < 4; k = k + 1) begin
                if (MemWrite_out[k])
                    DMEM[ALUResult[DMEM_DEPTH_BITS-1:2]][k*8 +: 8] <= WriteData_out[k*8 +: 8];
            end
        end
    end
    
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
                32'd116: if (WriteData_out !== 32'h1234_5000 + BASE + 58*STRIDE*4) $display("AUIPC failed");  // auipc is instruction 58
                
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
                32'd152: if (WriteData_out !== BASE + 87*STRIDE*4 + 4) $display("JAL link failed");      // jal is instruction 87

                // JALR
                32'd156: if (WriteData_out !== 32'd42)        $display("JALR jump failed");
                32'd160: if (WriteData_out !== BASE + 94*STRIDE*4 + 4) $display("JALR link failed");     // jalr is instruction 94
                
                // LB
                32'd164: if (WriteData_out !== 32'h0000_0001) $display("LB byte 0 failed");
                32'd168: if (WriteData_out !== 32'h0000_007F) $display("LB byte 1 failed");
                32'd172: if (WriteData_out !== 32'hFFFF_FFFF) $display("LB byte 2 sign extension failed");
                32'd176: if (WriteData_out !== 32'hFFFF_FF80) $display("LB byte 3 sign extension failed");
                
                // LBU
                32'd180: if (WriteData_out !== 32'h0000_00FF) $display("LBU byte 2 zero extension failed");
                32'd184: if (WriteData_out !== 32'h0000_0080) $display("LBU byte 3 zero extension failed");
                
                // LH
                32'd188: if (WriteData_out !== 32'h0000_7F01) $display("LH lower half failed");
                32'd192: if (WriteData_out !== 32'hFFFF_80FF) $display("LH sign extension failed");
                
                // LHU
                32'd196: if (WriteData_out !== 32'h0000_7F01) $display("LHU lower half failed");
                32'd200: if (WriteData_out !== 32'h0000_80FF) $display("LHU zero extension failed");
                
                // SB - word read back after each store, the other bytes must be unchanged
                32'd204: if (WriteData_out !== 32'h1122_33A1) $display("SB byte 0 readback failed");
                32'd208: if (WriteData_out !== 32'h1122_B2A1) $display("SB byte 1 readback failed");
                32'd212: if (WriteData_out !== 32'h11C3_B2A1) $display("SB byte 2 readback failed");
                32'd216: if (WriteData_out !== 32'hD4C3_B2A1) $display("SB byte 3 readback failed");
                
                // SH
                32'd220: if (WriteData_out !== 32'h1122_BEEF) $display("SH lower half readback failed");
                32'd224: if (WriteData_out !== 32'hCAFE_BEEF) $display("SH upper half readback failed");
                
                // SW
                32'd228: if (WriteData_out !== 32'h0005_CAFE) $display("SW readback failed");
                
                // The SB/SH/SW stores themselves. Only the enabled bytes of WriteData_out are checked.
                32'd256: if (MemWrite_out !== 4'b0001 || WriteData_out[7:0]   !== 8'hA1)    $display("SB byte 0 failed");
                32'd257: if (MemWrite_out !== 4'b0010 || WriteData_out[15:8]  !== 8'hB2)    $display("SB byte 1 failed");
                32'd258: if (MemWrite_out !== 4'b0100 || WriteData_out[23:16] !== 8'hC3)    $display("SB byte 2 failed");
                32'd259: if (MemWrite_out !== 4'b1000 || WriteData_out[31:24] !== 8'hD4)    $display("SB byte 3 failed");
                32'd260: if (MemWrite_out !== 4'b0011 || WriteData_out[15:0]  !== 16'hBEEF) $display("SH lower half failed");
                32'd262: if (MemWrite_out !== 4'b1100 || WriteData_out[31:16] !== 16'hCAFE) $display("SH upper half failed");
                32'd264: if (MemWrite_out !== 4'b1111 || WriteData_out !== 32'h0005_CAFE)   $display("SW failed");
                default: $display("Unexpected store address: %h", ALUResult);
            endcase
            
            store_count = store_count + 1;

            if (store_count == NUM_STORES) begin
                $display("All RV tests completed");
                $finish;
            end
        end
    end
    
    initial begin
        for (i = 0; i < 2**(IROM_DEPTH_BITS-2); i = i + 1)
            IROM[i] = 32'h0000_0013; // NOP
         
        for (i = 0; i < 128; i = i + 1)
            DMEM[i] = 32'b0;
            
        DMEM[0] = 32'h1234_5678;
        DMEM[1] = 32'h80FF_7F01;
        DMEM[64] = 32'h1122_3344; // address 256, for sb
        DMEM[65] = 32'h1122_3344; // address 260, for sh
        // -7 is ffff_fff9
        // 3 is 0000_0003

        IROM[0*STRIDE]  = encode_i(12'hff9, 5'd0, 3'b000, 5'd1);          // addi x1, x0, -7
        IROM[1*STRIDE]  = encode_s(12'd0,  5'd1, 5'd0, 3'b010);           // sw x1, 0(x0)
        
        IROM[2*STRIDE]  = encode_i(12'd3,   5'd0, 3'b000, 5'd2);          // addi x2, x0, 3
        IROM[3*STRIDE]  = encode_s(12'd4,  5'd2, 5'd0, 3'b010);           // sw x2, 4(x0)
        
        IROM[4*STRIDE]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3); // mul x3, x1, x2
        IROM[5*STRIDE]  = encode_s(12'd8,  5'd3, 5'd0, 3'b010);           // sw x3, 8(x0)

        IROM[6*STRIDE]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b001, 5'd4); // mulh x4, x1, x2
        IROM[7*STRIDE]  = encode_s(12'd12,  5'd4, 5'd0, 3'b010);          // sw x4, 12(x0)

        IROM[8*STRIDE]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b011, 5'd5); // mulhu x5, x1, x2
        IROM[9*STRIDE]  = encode_s(12'd16,  5'd5, 5'd0, 3'b010);           // sw x5, 16(x0)

        IROM[10*STRIDE]  = encode_r(7'b0000001, 5'd2, 5'd1, 3'b100, 5'd6); // div x6, x1, x2
        IROM[11*STRIDE]  = encode_s(12'd20, 5'd6, 5'd0, 3'b010);           // sw x6, 20(x0)

        IROM[12*STRIDE] = encode_r(7'b0000001, 5'd2, 5'd1, 3'b101, 5'd7); // divu x7, x1, x2
        IROM[13*STRIDE] = encode_s(12'd24, 5'd7, 5'd0, 3'b010);           // sw x7, 24(x0)

        IROM[14*STRIDE] = encode_r(7'b0000001, 5'd2, 5'd1, 3'b110, 5'd8); // rem x8, x1, x2
        IROM[15*STRIDE] = encode_s(12'd28, 5'd8, 5'd0, 3'b010);           // sw x8, 28(x0)

        IROM[16*STRIDE] = encode_r(7'b0000001, 5'd2, 5'd1, 3'b111, 5'd9); // remu x9, x1, x2
        IROM[17*STRIDE] = encode_s(12'd32, 5'd9, 5'd0, 3'b010);           // sw x9, 32(x0)

        IROM[18*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b000, 5'd9); // add x9, x1, x2
        IROM[19*STRIDE] = encode_s(12'd36, 5'd9, 5'd0, 3'b010);           // sw x9, 36(x0)
        
        IROM[20*STRIDE] = encode_r(7'b0100000, 5'd2, 5'd1, 3'b000, 5'd9); // sub x9, x1, x2
        IROM[21*STRIDE] = encode_s(12'd40, 5'd9, 5'd0, 3'b010);           // sw x9, 40(x0)
        
        IROM[22*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b100, 5'd9); // xor x9, x1, x2
        IROM[23*STRIDE] = encode_s(12'd44, 5'd9, 5'd0, 3'b010);           // sw x9, 44(x0)              
        
        IROM[24*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b110, 5'd9); // or x9, x1, x2
        IROM[25*STRIDE] = encode_s(12'd48, 5'd9, 5'd0, 3'b010);           // sw x9, 48(x0)                
        
        IROM[26*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b111, 5'd9); // and x9, x1, x2
        IROM[27*STRIDE] = encode_s(12'd52, 5'd9, 5'd0, 3'b010);           // sw x9, 52(x0)
        
        IROM[28*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b001, 5'd9); // sll x9, x1, x2
        IROM[29*STRIDE] = encode_s(12'd56, 5'd9, 5'd0, 3'b010);           // sw x9, 56(x0)

        IROM[30*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b101, 5'd9); // srl x9, x1, x2
        IROM[31*STRIDE] = encode_s(12'd60, 5'd9, 5'd0, 3'b010);           // sw x9, 60(x0)

        IROM[32*STRIDE] = encode_r(7'b0100000, 5'd2, 5'd1, 3'b101, 5'd9); // sra x9, x1, x2
        IROM[33*STRIDE] = encode_s(12'd64, 5'd9, 5'd0, 3'b010);           // sw x9, 64(x0)

        IROM[34*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b010, 5'd9); // slt x9, x1, x2
        IROM[35*STRIDE] = encode_s(12'd68, 5'd9, 5'd0, 3'b010);           // sw x9, 68(x0)
        
        IROM[36*STRIDE] = encode_r(7'b0000000, 5'd2, 5'd1, 3'b011, 5'd9); // sltu x9, x1, x2
        IROM[37*STRIDE] = encode_s(12'd72, 5'd9, 5'd0, 3'b010);           // sw x9, 72(x0)       

        // I-Type
        IROM[38*STRIDE] = encode_i(12'd3, 5'd1, 3'b000, 5'd9);          // addi x9, x1, 3
        IROM[39*STRIDE] = encode_s(12'd76, 5'd9, 5'd0, 3'b010);          // sw x9, 76(x0)

        IROM[40*STRIDE] = encode_i(12'd3, 5'd1, 3'b100, 5'd9);          // xori x9, x1, 3
        IROM[41*STRIDE] = encode_s(12'd80, 5'd9, 5'd0, 3'b010);          // sw x9, 80(x0)

        IROM[42*STRIDE] = encode_i(12'd3, 5'd1, 3'b110, 5'd9);          // ori x9, x1, 3
        IROM[43*STRIDE] = encode_s(12'd84, 5'd9, 5'd0, 3'b010);          // sw x9, 84(x0)

        IROM[44*STRIDE] = encode_i(12'd3, 5'd1, 3'b111, 5'd9);          // andi x9, x1, 3
        IROM[45*STRIDE] = encode_s(12'd88, 5'd9, 5'd0, 3'b010);          // sw x9, 88(x0)

        IROM[46*STRIDE] = encode_i(12'd3, 5'd1, 3'b001, 5'd9);          // slli x9, x1, 3
        IROM[47*STRIDE] = encode_s(12'd92, 5'd9, 5'd0, 3'b010);          // sw x9, 92(x0)

        IROM[48*STRIDE] = encode_i(12'd3, 5'd1, 3'b101, 5'd9);          // srli x9, x1, 3
        IROM[49*STRIDE] = encode_s(12'd96, 5'd9, 5'd0, 3'b010);          // sw x9, 96(x0)

        IROM[50*STRIDE] = encode_i(12'h403, 5'd1, 3'b101, 5'd9);        // srai x9, x1, 3
        IROM[51*STRIDE] = encode_s(12'd100, 5'd9, 5'd0, 3'b010);         // sw x9, 100(x0)

        IROM[52*STRIDE] = encode_i(12'd3, 5'd1, 3'b010, 5'd9);          // slti x9, x1, 3
        IROM[53*STRIDE] = encode_s(12'd104, 5'd9, 5'd0, 3'b010);         // sw x9, 104(x0)

        IROM[54*STRIDE] = encode_i(12'd3, 5'd1, 3'b011, 5'd9);          // sltiu x9, x1, 3
        IROM[55*STRIDE] = encode_s(12'd108, 5'd9, 5'd0, 3'b010);         // sw x9, 108(x0)

        // U-Type
        IROM[56*STRIDE] = {20'h12345, 5'd9, 7'b0110111};               // lui x9, 0x12345
        IROM[57*STRIDE] = encode_s(12'd112, 5'd9, 5'd0, 3'b010);         // sw x9, 112(x0)

        IROM[58*STRIDE] = encode_u(20'h12345, 5'd9);                    // auipc x9, 0x12345
        // 0x004000E8 + 0x12345000} = 0x127450E8
        IROM[59*STRIDE] = encode_s(12'd116, 5'd9, 5'd0, 3'b010);         // sw x9, 116(x0)

        // Load
        IROM[60*STRIDE] = encode_l(12'd0, 5'd0, 3'b010, 5'd9);    // lw x9, 0(x0)
        IROM[61*STRIDE] = encode_s(12'd120, 5'd9, 5'd0, 3'b010);  // sw x9, 120(x0)

        // B-Type
        IROM[62*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[63*STRIDE] = encode_b(13'd8*STRIDE,5'd1, 5'd1, 3'b000);   // beq x1, x1, 8
        IROM[64*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[65*STRIDE] = encode_s(12'd124, 5'd9, 5'd0, 3'b010); // sw x9, 124(x0)

        IROM[66*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[67*STRIDE] = encode_b(13'd8*STRIDE,5'd2, 5'd1, 3'b001);   // bne x1, x2, 8
        IROM[68*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[69*STRIDE] = encode_s(12'd128, 5'd9, 5'd0, 3'b010); // sw x9, 128(x0)

        IROM[70*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[71*STRIDE] = encode_b(13'd8*STRIDE,5'd2, 5'd1, 3'b100);   // blt x1, x2, 8
        IROM[72*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[73*STRIDE] = encode_s(12'd132, 5'd9, 5'd0, 3'b010); // sw x9, 132(x0)

        IROM[74*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[75*STRIDE] = encode_b(13'd8*STRIDE,5'd1, 5'd2, 3'b101);   // bge x2, x1, 8
        IROM[76*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[77*STRIDE] = encode_s(12'd136, 5'd9, 5'd0, 3'b010); // sw x9, 136(x0)

        IROM[78*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[79*STRIDE] = encode_b(13'd8*STRIDE,5'd1, 5'd2, 3'b110);   // bltu x2, x1, 8
        IROM[80*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[81*STRIDE] = encode_s(12'd140, 5'd9, 5'd0, 3'b010); // sw x9, 140(x0)

        IROM[82*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[83*STRIDE] = encode_b(13'd8*STRIDE,5'd2, 5'd1, 3'b111);   // bgeu x1, x2, 8
        IROM[84*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[85*STRIDE] = encode_s(12'd144, 5'd9, 5'd0, 3'b010); // sw x9, 144(x0)

        // J-Type
        IROM[86*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[87*STRIDE] = encode_j(21'd8*STRIDE, 5'd10);         // jal x10, 8
        IROM[88*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[89*STRIDE] = encode_s(12'd148, 5'd9, 5'd0, 3'b010); // sw x9, 148(x0)
        IROM[90*STRIDE] = encode_s(12'd152, 5'd10, 5'd0, 3'b010);// sw x10, 152(x0)

        // JALR
        IROM[91*STRIDE] = encode_u(20'd0, 5'd11);                // auipc x11, 0
        IROM[92*STRIDE] = encode_i(12'd20*STRIDE + 12'd1, 5'd11, 3'b000, 5'd11);// addi x11, x11, 21 (5 instructions ahead, +1 to test that jalr clears bit 0)
        IROM[93*STRIDE] = encode_i(12'd42, 5'd0, 3'b000, 5'd9);  // addi x9, x0, 42
        IROM[94*STRIDE] = encode_jalr(12'd0, 5'd11, 5'd10);      // jalr x10, 0(x11)
        IROM[95*STRIDE] = encode_i(12'd99, 5'd0, 3'b000, 5'd9);  // should skip
        IROM[96*STRIDE] = encode_s(12'd156, 5'd9, 5'd0, 3'b010); // sw x9, 156(x0)
        IROM[97*STRIDE] = encode_s(12'd160, 5'd10, 5'd0, 3'b010);// sw x10, 160(x0)

        IROM[98*STRIDE]  = encode_l(12'd4, 5'd0, 3'b000, 5'd1);   // lb  x1, 4(x0)
        IROM[99*STRIDE]  = encode_s(12'd164, 5'd1, 5'd0, 3'b010); // sw  x1, 164(x0)
        
        IROM[100*STRIDE] = encode_l(12'd5, 5'd0, 3'b000, 5'd2);   // lb  x2, 5(x0)
        IROM[101*STRIDE] = encode_s(12'd168, 5'd2, 5'd0, 3'b010); // sw  x2, 168(x0)
        
        IROM[102*STRIDE] = encode_l(12'd6, 5'd0, 3'b000, 5'd3);   // lb  x3, 6(x0)
        IROM[103*STRIDE] = encode_s(12'd172, 5'd3, 5'd0, 3'b010); // sw  x3, 172(x0)
        
        IROM[104*STRIDE] = encode_l(12'd7, 5'd0, 3'b000, 5'd4);   // lb  x4, 7(x0)
        IROM[105*STRIDE] = encode_s(12'd176, 5'd4, 5'd0, 3'b010); // sw  x4, 176(x0)
        
        IROM[106*STRIDE] = encode_l(12'd6, 5'd0, 3'b100, 5'd5);   // lbu x5, 6(x0)
        IROM[107*STRIDE] = encode_s(12'd180, 5'd5, 5'd0, 3'b010); // sw  x5, 180(x0)
        
        IROM[108*STRIDE] = encode_l(12'd7, 5'd0, 3'b100, 5'd6);   // lbu x6, 7(x0)
        IROM[109*STRIDE] = encode_s(12'd184, 5'd6, 5'd0, 3'b010); // sw  x6, 184(x0)
        
        IROM[110*STRIDE] = encode_l(12'd4, 5'd0, 3'b001, 5'd7);   // lh  x7, 4(x0)
        IROM[111*STRIDE] = encode_s(12'd188, 5'd7, 5'd0, 3'b010); // sw  x7, 188(x0)
        
        IROM[112*STRIDE] = encode_l(12'd6, 5'd0, 3'b001, 5'd8);   // lh  x8, 6(x0)
        IROM[113*STRIDE] = encode_s(12'd192, 5'd8, 5'd0, 3'b010); // sw  x8, 192(x0)
        
        IROM[114*STRIDE] = encode_l(12'd4, 5'd0, 3'b101, 5'd10);  // lhu x10, 4(x0)
        IROM[115*STRIDE] = encode_s(12'd196, 5'd10, 5'd0, 3'b010);// sw  x10, 196(x0)
        
        IROM[116*STRIDE] = encode_l(12'd6, 5'd0, 3'b101, 5'd11);  // lhu x11, 6(x0)
        IROM[117*STRIDE] = encode_s(12'd200, 5'd11, 5'd0, 3'b010);// sw  x11, 200(x0)
        
        // SB - upper bits of x12 are non-zero to check that only the lowest byte is stored
        IROM[118*STRIDE] = encode_i(12'h5A1, 5'd0, 3'b000, 5'd12); // addi x12, x0, 0x5A1
        IROM[119*STRIDE] = encode_s(12'd256, 5'd12, 5'd0, 3'b000); // sb  x12, 256(x0)
        IROM[120*STRIDE] = encode_l(12'd256, 5'd0, 3'b010, 5'd9);  // lw  x9, 256(x0)
        IROM[121*STRIDE] = encode_s(12'd204, 5'd9, 5'd0, 3'b010);  // sw  x9, 204(x0)
        
        IROM[122*STRIDE] = encode_i(12'h5B2, 5'd0, 3'b000, 5'd12); // addi x12, x0, 0x5B2
        IROM[123*STRIDE] = encode_s(12'd257, 5'd12, 5'd0, 3'b000); // sb  x12, 257(x0)
        IROM[124*STRIDE] = encode_l(12'd256, 5'd0, 3'b010, 5'd9);  // lw  x9, 256(x0)
        IROM[125*STRIDE] = encode_s(12'd208, 5'd9, 5'd0, 3'b010);  // sw  x9, 208(x0)
        
        IROM[126*STRIDE] = encode_i(12'h5C3, 5'd0, 3'b000, 5'd12); // addi x12, x0, 0x5C3
        IROM[127*STRIDE] = encode_s(12'd258, 5'd12, 5'd0, 3'b000); // sb  x12, 258(x0)
        IROM[128*STRIDE] = encode_l(12'd256, 5'd0, 3'b010, 5'd9);  // lw  x9, 256(x0)
        IROM[129*STRIDE] = encode_s(12'd212, 5'd9, 5'd0, 3'b010);  // sw  x9, 212(x0)
        
        IROM[130*STRIDE] = encode_i(12'h5D4, 5'd0, 3'b000, 5'd12); // addi x12, x0, 0x5D4
        IROM[131*STRIDE] = encode_s(12'd259, 5'd12, 5'd0, 3'b000); // sb  x12, 259(x0)
        IROM[132*STRIDE] = encode_l(12'd256, 5'd0, 3'b010, 5'd9);  // lw  x9, 256(x0)
        IROM[133*STRIDE] = encode_s(12'd216, 5'd9, 5'd0, 3'b010);  // sw  x9, 216(x0)
        
        // SH - upper bits of x12 are non-zero to check that only the lower half-word is stored
        IROM[134*STRIDE] = {20'h0005C, 5'd12, 7'b0110111};          // lui x12, 0x5C
        IROM[135*STRIDE] = encode_i(12'hEEF, 5'd12, 3'b000, 5'd12); // addi x12, x12, -273 -> x12 = 0x0005BEEF
        IROM[136*STRIDE] = encode_s(12'd260, 5'd12, 5'd0, 3'b001);  // sh  x12, 260(x0)
        IROM[137*STRIDE] = encode_l(12'd260, 5'd0, 3'b010, 5'd9);   // lw  x9, 260(x0)
        IROM[138*STRIDE] = encode_s(12'd220, 5'd9, 5'd0, 3'b010);   // sw  x9, 220(x0)
        
        IROM[139*STRIDE] = {20'h0005D, 5'd12, 7'b0110111};          // lui x12, 0x5D
        IROM[140*STRIDE] = encode_i(12'hAFE, 5'd12, 3'b000, 5'd12); // addi x12, x12, -1282 -> x12 = 0x0005CAFE
        IROM[141*STRIDE] = encode_s(12'd262, 5'd12, 5'd0, 3'b001);  // sh  x12, 262(x0)
        IROM[142*STRIDE] = encode_l(12'd260, 5'd0, 3'b010, 5'd9);   // lw  x9, 260(x0)
        IROM[143*STRIDE] = encode_s(12'd224, 5'd9, 5'd0, 3'b010);   // sw  x9, 224(x0)
        
        // SW - all 4 bytes are still written
        IROM[144*STRIDE] = encode_s(12'd264, 5'd12, 5'd0, 3'b010);  // sw  x12, 264(x0)
        IROM[145*STRIDE] = encode_l(12'd264, 5'd0, 3'b010, 5'd9);   // lw  x9, 264(x0)
        IROM[146*STRIDE] = encode_s(12'd228, 5'd9, 5'd0, 3'b010);   // sw  x9, 228(x0)
        
        IROM[147*STRIDE] = encode_j(21'd0, 5'd0); // jal x0, 0
        // Initialise CPU
        repeat (2) @(negedge CLK);
        RESET = 1'b0;
    end

    // Waveform dump for GTKWave / Surfer / VaporView. Ignored by Vivado's own waveform viewer.
    initial begin
        $dumpfile("tb_RV.vcd");
        $dumpvars(0, tb_RV);
    end

    initial begin
        #100000;
        $display("TEST TIMEOUT: Only %0d / %0d stores completed", store_count, NUM_STORES);
        $finish;
    end
    
endmodule
