//=======================================================
// rs32i - reg_EXWB.sv

// Date: 2026-11-26
// author: inefable

module reg_EXWB(
    input  logic        clk,
    input  logic        rst,
    input  logic        in_valid,
    input  logic [4:0]  rd,
    input  logic [31:0] result,
    input  logic        reg_write,

    output logic        out_valid,
    output logic [4:0]  o_rd,
    output logic [31:0] o_result,
    output logic        o_reg_write
);

    // 写回结果、目标编号和写回许可属于同一条指令。
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_valid   <= 1'b0;
            o_rd        <= 5'b0;
            o_result    <= 32'b0;
            o_reg_write <= 1'b0;
        end else begin
            out_valid   <= in_valid;
            o_rd        <= rd;
            o_result    <= result;
            o_reg_write <= reg_write;
        end
    end

endmodule
