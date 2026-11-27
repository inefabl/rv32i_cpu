//=======================================================
// rs32i - reg_IDEX.sv

// Date: 2026-11-26
// author: inefable

`include "constant.sv"

module reg_IDEX(
    input  logic        clk,
    input  logic        rst,
    input  logic        in_valid,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] rs1_data,
    input  logic [31:0] rs2_data,
    input  logic [31:0] imm,
    input  logic [3:0]  alu_funct,
    input  logic        alu_src_imm,
    input  logic        reg_write,

    output logic        out_valid,
    output logic [4:0]  o_rs1,
    output logic [4:0]  o_rs2,
    output logic [4:0]  o_rd,
    output logic [31:0] o_rs1_data,
    output logic [31:0] o_rs2_data,
    output logic [31:0] o_imm,
    output logic [3:0]  o_alu_funct,
    output logic        o_alu_src_imm,
    output logic        o_reg_write
);

    // 操作数和译码控制一起锁存，源寄存器编号供 EX 判断前递。
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_valid     <= 1'b0;
            o_rs1         <= 5'b0;
            o_rs2         <= 5'b0;
            o_rd          <= 5'b0;
            o_rs1_data    <= 32'b0;
            o_rs2_data    <= 32'b0;
            o_imm         <= 32'b0;
            o_alu_funct   <= `ALU_INVALID;
            o_alu_src_imm <= 1'b0;
            o_reg_write   <= 1'b0;
        end else begin
            out_valid     <= in_valid;
            o_rs1         <= rs1;
            o_rs2         <= rs2;
            o_rd          <= rd;
            o_rs1_data    <= rs1_data;
            o_rs2_data    <= rs2_data;
            o_imm         <= imm;
            o_alu_funct   <= alu_funct;
            o_alu_src_imm <= alu_src_imm;
            o_reg_write   <= reg_write;
        end
    end

endmodule
