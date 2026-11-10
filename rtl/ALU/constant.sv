//=======================================================
// rs32i - constant.sv

// Date: 2026-11-10
// author: inefable

//All ALU operations
`define ALU_ADD                 4'b0000                         
`define ALU_SUB                 4'b0001                                
`define ALU_AND                 4'b0010                                  
`define ALU_OR                  4'b0011
`define ALU_XOR                 4'b0100
`define ALU_SLT                 4'b0101
`define ALU_SLL                 4'b0110
`define ALU_SRL                 4'b0111
`define ALU_SLTU                4'b1000
`define ALU_SRA                 4'b1001
`define ALU_SEQ                 4'b1010

//branch code
`define FUNCT3_ALU_BRANCH_BEQ   3'b000
`define FUNCT3_ALU_BRANCH_BNE   3'b001
`define FUNCT3_ALU_BRANCH_BLT   3'b100
`define FUNCT3_ALU_BRANCH_BGE   3'b101
`define FUNCT3_ALU_BRANCH_BLTU  3'b101
`define FUNCT3_ALU_BRANCH_BGEU  3'b111

//R code - funct7 operations
`define ALU_INVALID             4'b1111

//ALU operations type       
`define CTL_ALU_ROP             2'b00
`define CTL_ALU_IOP             2'b01
`define CTL_ALU_BRANCH          2'b10

//R code - funct3 operations
`define FUNCT3_ALU_ADD_SUB      3'b000
`define FUNCT3_ALU_AND          3'b111
`define FUNCT3_ALU_OR           3'b110
`define FUNCT3_ALU_XOR          3'b100
`define FUNCT3_ALU_SLT          3'b010
`define FUNCT3_ALU_SLL          3'b001
`define FUNCT3_ALU_SHIFTER      3'b101
`define FUNCT3_ALU_SLTU         3'b011
