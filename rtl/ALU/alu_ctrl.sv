// //=======================================================
// rs32i - alu_ctrl.sv

// Date: 2026-11-10
// author: inefable
`include "constant.sv"

module alu_ctrl(
    input  logic     [6:0]   funct7,
    input  logic     [2:0]   funct3,
    input  logic     [1:0]   alu_op_type,

    output logic     [3:0]   alu_funct
);

    logic [3:0]     default_alu_funct;
    logic [3:0]     secondary_funct;
    logic [3:0]     op_funct;
    logic [3:0]     op_imm_funct;
    logic [3:0]     branch_funct;

    always_comb
        case(alu_op_type)
            `CTL_ALU_ROP:       alu_funct = op_funct;
            `CTL_ALU_IOP:       alu_funct = op_imm_funct;
            default:            alu_funct = `ALU_INVALID;
        endcase

    always_comb
        case(funct7)
            7'b0000000:             op_funct = default_alu_funct;
            7'b0100000:             op_funct = secondary_funct;
            default:                op_funct = `ALU_INVALID;
        endcase

    always_comb
        case(funct3)
            // SLLI
            `FUNCT3_ALU_SLL:begin
                if (funct7 == 7'b0000000)   op_imm_funct = `ALU_SLL;
                else                        op_imm_funct = `ALU_INVALID;
            end

            // SRLI SRAI
            `FUNCT3_ALU_SHIFTER:begin
                case(funct7)
                    7'b0000000:             op_imm_funct = `ALU_SRL;
                    7'b0100000:             op_imm_funct = `ALU_SRA;
                    default:                op_imm_funct = `ALU_INVALID;
                endcase
            end
            default:                        op_imm_funct = default_alu_funct;
        endcase

    always_comb
        case(funct3)
            `FUNCT3_ALU_ADD_SUB:    default_alu_funct = `ALU_ADD ;
            `FUNCT3_ALU_AND    :    default_alu_funct = `ALU_AND ;
            `FUNCT3_ALU_OR     :    default_alu_funct = `ALU_OR  ;
            `FUNCT3_ALU_XOR    :    default_alu_funct = `ALU_XOR ;
            `FUNCT3_ALU_SLT    :    default_alu_funct = `ALU_SLT ;
            `FUNCT3_ALU_SLL    :    default_alu_funct = `ALU_SLL ;
            `FUNCT3_ALU_SHIFTER:    default_alu_funct = `ALU_SRL ;
            `FUNCT3_ALU_SLTU   :    default_alu_funct = `ALU_SLTU;
            default            :    default_alu_funct = `ALU_INVALID;            
        endcase

    always_comb
        case(funct3)
            `FUNCT3_ALU_ADD_SUB:    secondary_funct = `ALU_SUB;
            `FUNCT3_ALU_SHIFTER:    secondary_funct = `ALU_SRA;
            default:                secondary_funct = `ALU_INVALID;
        endcase

endmodule