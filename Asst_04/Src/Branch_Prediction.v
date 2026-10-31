`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2026 10:58:35 PM
// Design Name: 
// Module Name: Branch_Prediction
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


module Branch_Prediction #(
    parameter INDEX_BITS = 6
)(
    input CLK,
    input RESET,
    input [31:0] PC_F,
    input [31:0] PC_E,
    input [1:0] PCSrc_E,
    input [31:0] BTA_E,
    input Update_E,
    output [31:0] PrNextPC_F
    );
    
    localparam ENTRIES = 1 << INDEX_BITS;
    localparam TAG_BITS = 32 - INDEX_BITS - 2;
    
    reg Valid [0:ENTRIES-1];
    reg [TAG_BITS-1:0] Tag [0:ENTRIES-1];
    reg [1:0] BHT [0:ENTRIES-1];
    reg [31:0] BTB [0:ENTRIES-1];
    
    wire [INDEX_BITS-1:0] Index_F = PC_F[INDEX_BITS+1:2];           // Index of PC_F
    wire [INDEX_BITS-1:0] Index_E = PC_E[INDEX_BITS+1:2];           // Index of PC_E
    wire [TAG_BITS-1:0] Tag_F = PC_F[31:INDEX_BITS+2];              // Check if Rest of PC_F agree to prevent misprediction
    wire [TAG_BITS-1:0] Tag_E = PC_E[31:INDEX_BITS+2];              // Check if Rest of PC_E agree to prevent misprediction
    wire Hit_F = Valid[Index_F] && (Tag[Index_F] == Tag_F);
    wire Hit_E = Valid[Index_E] && (Tag[Index_E] == Tag_E);
    wire PrTakenF;
    wire TakenE;
    
    
    assign PrTakenF = Hit_F && BHT[Index_F][1];                     // Conditon to 
    assign PrNextPC_F = PrTakenF ? BTB[Index_F] : PC_F + 32'd4;
    assign TakenE = |PCSrc_E;                                       // If branch is taken
    
    integer i;
    
    initial begin
        for (i = 0; i < ENTRIES; i = i + 1) begin
            Valid[i] = 1'b0;
            Tag[i]   = {TAG_BITS{1'b0}};
            BHT[i]   = 2'b00;
            BTB[i]   = 32'b0;
        end
    end
    
    always @(posedge CLK) begin
        if (RESET) begin
            for (i = 0; i < ENTRIES; i = i + 1) begin
                Valid[i] <= 1'b0;
                Tag[i] <= {TAG_BITS{1'b0}};
                BHT[i] <= 2'b00;
                BTB[i] <= 32'b0;
            end
        end else if (Update_E) begin
            Valid[Index_E] <= 1'b1;
            Tag[Index_E] <= Tag_E;
            BTB[Index_E] <= BTA_E;
            
            if (!Hit_E) begin
                BHT[Index_E] <= TakenE ? 2'b01 : 2'b00;
            end else if (TakenE) begin
                if (BHT[Index_E] != 2'b11)
                    BHT[Index_E] <= BHT[Index_E] + 2'b01;
            end else begin
                if (BHT[Index_E] != 2'b00)
                    BHT[Index_E] <= BHT[Index_E] - 2'b01;
            end
        end
    end

endmodule
