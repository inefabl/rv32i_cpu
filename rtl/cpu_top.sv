// //=======================================================
// rs32i - cpu_top.sv

// Date: 2026-11-16
// author: inefable

`include "constant.sv"

module cpu_top(
    input  logic        clk,        // CPU 时钟，寄存器在上升沿更新
    input  logic        rst,        // 高电平有效的异步复位
    input  logic [31:0] imem_rdata, // 指令存储器返回的 32 位指令字
    
    output logic [31:0] imem_addr   // 取指字节地址，由 PC 驱动
);

    // 每条指令依次经历取指、译码、执行、写回四拍。写回后才取下一条。
    typedef enum logic [1:0] { IF, ID, EX, WB } state_t;
    state_t         state; // 当前时钟周期所处的阶段

    logic [31:0]    pc;         // 下一次取指的字节地址，IF 拍末递增 4
    logic [31:0]    if_id_inst; // IF 拍末锁存的指令，供 ID 译码

    // ID 拍的组合信号，均来自 if_id_inst 的译码和寄存器读取。
    logic [1:0]     id_alu_op_type; // 传给 alu_ctrl 的指令类别，区分 OP 和 OP-IMM
    logic           id_alu_src_imm; // 为 1 时选择立即数作为 ALU 的第二操作数
    logic           id_supported;   // opcode 属于已接通的指令类别
    logic [3:0]     id_alu_funct;   // alu_ctrl 输出的具体运算编码，如 ADD、SUB
    logic [31:0]    id_rs1_data, id_rs2_data, id_imm; // 两个源寄存器读值、扩展后的立即数

    // ID 拍末锁存，EX 使用同一条指令的操作数和控制信号。
    logic [31:0]    id_ex_rs1_data, id_ex_rs2_data, id_ex_imm; // 锁存的两个读值和立即数
    logic [4:0]     id_ex_rd;        // 目标寄存器编号
    logic [3:0]     id_ex_alu_funct; // 锁存的 ALU 运算编码
    logic           id_ex_alu_src_imm, id_ex_reg_write; // 操作数选择、译码通过后的写回许可

    logic [31:0]    alu_b, alu_result; // EX 拍的第二操作数和 ALU 组合结果
    logic [31:0]    ex_wb_result;     // EX 拍末锁存的结果，供 WB 写入寄存器堆
    logic [4:0]     ex_wb_rd;         // 与结果一起锁存的目标寄存器编号
    logic           ex_wb_reg_write, wb_write_enable; // 锁存的写回许可、寄存器堆实际写使能

    // IF：指令存储器需要在当前拍结束前返回 PC 对应的指令字。
    assign imem_addr = pc;

    // ID：主译码负责选择指令类别和操作数来源，alu_ctrl 负责细分运算，main_ctrl判断opcode部分是否进入R/I指令
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

    main_ctrl u_main_ctrl(
        .opcode      (if_id_inst[6:0]),
        .alu_op_type (id_alu_op_type),
        .alu_src_num (id_alu_src_imm),
        .reg_write   (id_supported)
    );

    // EX：第一操作数固定取 rs1，第二操作数在立即数和 rs2 之间选择。
    assign alu_b = id_ex_alu_src_imm ? id_ex_imm : id_ex_rs2_data;

    alu u_alu (
        .a      (id_ex_rs1_data),
        .b      (alu_b),
        .alu_op (id_ex_alu_funct),
        .result (alu_result),
        .zero   ()
    );

    // WB：仅在未复位且处于 WB 时开放写口，寄存器堆在该拍末写入结果。
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
