//=======================================================
// rs32i - regfile.sv

// Date: 2026-11-11
// author: inefable

//save num[31:0]
`include "constant.sv"

module regfile(
    input            clock,
    input            write_enable,
    input  [4:0]     rd_addr,
    input  [4:0]     rs1_addr,
    input  [4:0]     rs2_addr,
    input  [31:0]    rd_data,
    output [31:0]    rs1_data,
    output [31:0]    rs2_data  
);

    logic [31:0] register [0:31];

    assign rs1_data = (rs1_addr == 5'd0) ? 32'd0 : register[rs1_addr];
    assign rs2_data = (rs2_addr == 5'd0) ? 32'd0 : register[rs2_addr];

    inital register[0] = 32'b0;

    always_ff@(posedge clock)
        if (write_enable)
            if (rd_addr != 5'b0)
                register[rd_addr] <= rd_data;
endmodule