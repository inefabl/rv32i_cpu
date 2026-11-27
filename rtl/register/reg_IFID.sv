//=======================================================
// rs32i - reg_IFID.sv

// Date: 2026-11-26
// author: inefable

module reg_IFID(
    input  logic        clk,
    input  logic        rst,
    input  logic        in_valid,
    input  logic [31:0] pc,
    input  logic [31:0] inst,

    output logic        out_valid,
    output logic [31:0] o_pc,
    output logic [31:0] o_inst
);

    // 指令字和取到这条指令时的 PC 在同一个沿进入 ID。
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            out_valid <= 1'b0;
            o_pc      <= 32'b0;
            o_inst    <= 32'b0;
        end else begin
            out_valid <= in_valid;
            o_pc      <= pc;
            o_inst    <= inst;
        end
    end
endmodule
