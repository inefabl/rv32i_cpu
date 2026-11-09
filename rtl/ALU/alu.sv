//=======================================================
// rs32i - alu.sv

// Date: 2026-11-10
// author: inefable


module alu(
    input  logic     [31:0]  a,
    input  logic     [31:0]  b,
    input  logic      [3:0]   alu_op,
 
    output logic      [31:0]  result,
    output logic              zero

);

assign zero = (result == 32'b0) ? 1'b1 : 1'b0;

always_comb begin
    result = 32'd0; // default value

    case(alu_op)
        4'b0000: result = a + b;
        4'b0001: result = a - b;
        4'b0010: result = a & b;
        4'b0011: result = a | b;
        4'b0100: result = a ^ b;
        4'b0101: result = signed'(a) < signed'(b) ? 32'd1 : 32'd0;
        4'b0110: result = a << b[4:0];
        4'b0111: result = a >> b[4:0];
    endcase
end



endmodule