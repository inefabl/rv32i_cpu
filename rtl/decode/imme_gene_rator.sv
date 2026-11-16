// //=======================================================
// rs32i - imme_gene_rator.sv

// Date: 2026-11-16
// author: inefable

`include "constant.sv"

module immediate_generator (
    input        [31:0] inst,

    output logic [31:0] imme32
);

    // Immediate format
    //       31.............30........20.19........12.11.....11.10.........5.4..........1.0.....0
    // I = { {21{inst[31]}},                                     inst[30:25], inst[24:20]         };
    // S = { {21{inst[31]}},                                     inst[30:25], inst[11:7]          };
    // B = { {20{inst[31]}}, inst[7],                            inst[30:25], inst[11:8],   1'b0  };
    // U = { {1{inst[31]}},  inst[30:20], inst[19:12],                                      12'b0 };
    // J = { {12{inst[31]}},              inst[19:12], inst[20], inst[30:25], inst[24:21],  1'b0  };
    
    always_comb begin
        case (inst[6:0]) // Opcode
            `OPCODE_LOAD,
            `OPCODE_OP_IMM,
            `OPCODE_JALR:   // I-type immediate
                imme32 = {{20{inst[31]}}, inst[31:20]};
            `OPCODE_STORE:  // S-type immediate
                imme32 = {{20{inst[31]}}, inst[31:25], inst[11:7]};
            `OPCODE_BRANCH: // B-type immediate
                imme32 = {{20{inst[31]}}, inst[7], inst[30:25], inst[11:8], 1'b0};
            `OPCODE_AUIPC,
            `OPCODE_LUI:    // U-type immediate
                imme32 = {inst[31:12], 12'b0};
            `OPCODE_JAL:    // J-type immediate
                imme32 = {{12{inst[31]}}, inst[19:12], inst[20], inst[30:21], 1'b0};
            default: imme32 = 32'b0;
        endcase
    end

endmodule
