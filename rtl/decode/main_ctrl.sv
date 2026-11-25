// //=======================================================
// rs32i - main_control.sv

// Date: 2026-11-19
// author: inefable

`include "constant.sv"

module main_ctrl(
    input           [6:0]   opcode,

    output logic    [1:0]   alu_op_type,
    output logic            alu_src_num,
    output logic            reg_write
);

    always_comb begin
        alu_op_type = `CTL_ALU_ROP;
        alu_src_imm = 1'b0;
        reg_write = 1'b0;

        case (opcode)
            `OPCODE_OP: begin
                alu_op_type = `CTL_ALU_ROP;
                alu_src_num = 1'b0;
                reg_write = 1'b1;
            end
            `OPCODE_OP_IMM: begin
                alu_op_type = `CTL_ALU_IOP;
                alu_src_num = 1'b1;
                reg_write = 1'b1;
            end
        endcase
    end

endmodule