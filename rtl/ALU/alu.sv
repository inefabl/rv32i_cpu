//=======================================================
// rs32i - alu.sv

// Date: 2026-11-10
// author: inefable
`include "constant.sv"
`include "alu_ctrl.sv"

module alu(
    input  logic     [31:0]  a,
    input  logic     [31:0]  b,
    input  logic     [3:0]   alu_op,
 
    output logic     [31:0]  result,
    output logic              zero

);

assign zero = (result == 32'b0) ? 1'b1 : 1'b0;

always_comb begin
    result = 32'd0; // default value

    case(alu_op)
        `ALU_ADD:   result = a + b;
        `ALU_SUB:   result = a - b;
        `ALU_AND:   result = a & b;
        `ALU_OR:    result = a | b;
        `ALU_XOR:   result = a ^ b;
        `ALU_SLT:   result = signed'(a) < signed'(b) ? 32'd1 : 32'd0;
        `ALU_SLL:   result = a << b[4:0];
        `ALU_SRL:   result = a >> b[4:0];
        `ALU_SLTU:  result = a < b;
        `ALU_SRA:   result = $signed(a) >>> b[4:0];
        `ALU_SEQ:   result = {31'b0, (a == b)};
    endcase
end


endmodule