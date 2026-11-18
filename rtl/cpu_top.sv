// //=======================================================
// rs32i - cpu_top.sv

// Date: 2026-11-16
// author: inefable

`include "constant.sv"

module cpu_top(
    input  logic        clk,
    input  logic        rst,
    input  logic [31:0] imem_rdata,
    
    output logic [31:0] imem_addr
);

    typedef enum logic [1:0] { IF, ID, EX, WB } state_t;
    state_t state;

    logic [31:0] pc;
    logic [31:0] if_id_inst;

    logic [1:0]  id_alu_op_type;
    logic        id_alu_src_imm;
    logic        id_supported;
    logic [3:0]  id_alu_funct;
    logic [31:0] id_rs1_data, id_rs2_data, id_imm;

    logic [31:0] id_ex_rs1_data, id_ex_rs2_data, id_ex_imm;
    logic [4:0]  id_ex_rd;
    logic [3:0]  id_ex_alu_funct;
    logic        id_ex_alu_src_imm, id_ex_reg_write;

    logic [31:0] alu_b, alu_result;
    logic [31:0] ex_wb_result;
    logic [4:0]  ex_wb_rd;
    logic        ex_wb_reg_write, wb_write_enable;

    // IF: the instruction memory returns data for pc within this cycle.
    assign imem_addr = pc;

    // ID: select the arithmetic instruction family and read its operands.
    always_comb begin
        id_alu_op_type = `CTL_ALU_ROP;
        id_alu_src_imm = 1'b0;
        id_supported = 1'b0;

        case (if_id_inst[6:0])
            `OPCODE_OP: id_supported = 1'b1;
            `OPCODE_OP_IMM: begin
                id_alu_op_type = `CTL_ALU_IOP;
                id_alu_src_imm = 1'b1;
                id_supported = 1'b1;
            end
            default: id_supported = 1'b0;
        endcase
    end

    regfile u_regfile (
        .clock        (clk),
        .write_enable (wb_write_enable),
        .rd_addr      (ex_wb_rd),
        .rs1_addr     (if_id_inst[19:15]),
        .rs2_addr     (if_id_inst[24:20]),
        .rd_data      (ex_wb_result),
        .rs1_data     (id_rs1_data),
        .rs2_data     (id_rs2_data)
    );

    immediate_generator u_immediate_generator (
        .inst   (if_id_inst),
        .imme32 (id_imm)
    );

    alu_ctrl u_alu_ctrl (
        .funct7      (if_id_inst[31:25]),
        .funct3      (if_id_inst[14:12]),
        .alu_op_type (id_alu_op_type),
        .alu_funct   (id_alu_funct)
    );

    // EX: operate on the values captured during ID.
    assign alu_b = id_ex_alu_src_imm ? id_ex_imm : id_ex_rs2_data;

    alu u_alu (
        .a      (id_ex_rs1_data),
        .b      (alu_b),
        .alu_op (id_ex_alu_funct),
        .result (alu_result),
        .zero   ()
    );

    // WB: the register file commits the result at the end of this state.
    assign wb_write_enable = !rst && (state == WB) && ex_wb_reg_write;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state             <= IF;
            pc                <= 32'b0;
            if_id_inst        <= 32'b0;
            id_ex_rs1_data    <= 32'b0;
            id_ex_rs2_data    <= 32'b0;
            id_ex_imm         <= 32'b0;
            id_ex_rd          <= 5'b0;
            id_ex_alu_funct   <= `ALU_INVALID;
            id_ex_alu_src_imm <= 1'b0;
            id_ex_reg_write   <= 1'b0;
            ex_wb_result      <= 32'b0;
            ex_wb_rd          <= 5'b0;
            ex_wb_reg_write   <= 1'b0;
        end 
        else begin
            case (state)
                IF: begin
                    if_id_inst <= imem_rdata;
                    pc         <= pc + 32'd4;
                    state      <= ID;
                end
                ID: begin
                    id_ex_rs1_data    <= id_rs1_data;
                    id_ex_rs2_data    <= id_rs2_data;
                    id_ex_imm         <= id_imm;
                    id_ex_rd          <= if_id_inst[11:7];
                    id_ex_alu_funct   <= id_alu_funct;
                    id_ex_alu_src_imm <= id_alu_src_imm;
                    id_ex_reg_write   <= id_supported && (id_alu_funct != `ALU_INVALID);
                    state            <= EX;
                end
                EX: begin
                    ex_wb_result    <= alu_result;
                    ex_wb_rd        <= id_ex_rd;
                    ex_wb_reg_write <= id_ex_reg_write;
                    state           <= WB;
                end
                WB: state <= IF;
                default: state <= IF;
            endcase
        end
    end

endmodule
