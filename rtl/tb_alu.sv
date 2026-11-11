// //=======================================================
// rs32i - tb_alu.sv

// Date: 2026-11-11
// author: inefable

`timescale 1ns/1ps
`include "constant.sv"
`include "alu_ctrl.sv"
`include "alu.sv"

module tb_alu_ctrl;
    logic [6:0] funct7;
    logic [2:0] funct3;
    logic [1:0] alu_op_type;
    
    logic [31:0] a;
    logic [31:0] b;

    alu_ctrl uut (
        .funct7      (funct7),
        .funct3      (funct3),
        .alu_op_type (alu_op_type)
    );

    // 3. 自动检查任务
    task automatic check_case(
        input string      test_name,
        input logic [1:0] mode,
        input logic [2:0] f3,
        input logic [6:0] f7,
        input logic [3:0] expected
    );
    begin
        alu_op_type = mode;      
        funct3      = f3;
        funct7      = f7;

        #1; // 等待组合逻辑稳定

        test_count++;

        if (alu_funct !== expected) begin
            error_count++;
            $error(
                "[FAIL] %s: expected=%b, actual=%b",
                test_name, expected, alu_funct
            );
        end
        else begin
            $display("[PASS] %s", test_name);
        end
    end
    endtask

    // 4. 测试过程
    initial begin

        $display("===== R-type Test =====");

        check_case("ADD", `CTL_ALU_ROP,
                   3'b000, 7'b0000000, `ALU_ADD);

        check_case("SUB", `CTL_ALU_ROP,
                   3'b000, 7'b0100000, `ALU_SUB);

        check_case("AND", `CTL_ALU_ROP,
                   3'b111, 7'b0000000, `ALU_AND);

        check_case("OR",  `CTL_ALU_ROP,
                   3'b110, 7'b0000000, `ALU_OR);

        check_case("XOR", `CTL_ALU_ROP,
                   3'b100, 7'b0000000, `ALU_XOR);

        check_case("SLT", `CTL_ALU_ROP,
                   3'b010, 7'b0000000, `ALU_SLT);

        check_case("SLL", `CTL_ALU_ROP,
                   3'b001, 7'b0000000, `ALU_SLL);

        check_case("SRL", `CTL_ALU_ROP,
                   3'b101, 7'b0000000, `ALU_SRL);

        check_case("SLTU", `CTL_ALU_ROP,
                   3'b011, 7'b0000000, `ALU_SLTU);

        check_case("SRA", `CTL_ALU_ROP,
                   3'b101, 7'b0100000, `ALU_SRA);


        $display("===== I-type Test =====");

        check_case("ADDI", `CTL_ALU_IOP,
                   3'b000, 7'b1111111, `ALU_ADD);

        check_case("SLTI", `CTL_ALU_IOP,
                   3'b010, 7'b1110000, `ALU_SLT);

        check_case("SLTIU", `CTL_ALU_IOP,
                   3'b011, 7'b1100000, `ALU_SLTU);

        check_case("XORI", `CTL_ALU_IOP,
                   3'b100, 7'b1010101, `ALU_XOR);

        check_case("ORI", `CTL_ALU_IOP,
                   3'b110, 7'b0100000, `ALU_OR);

        check_case("ANDI", `CTL_ALU_IOP,
                   3'b111, 7'b1111111, `ALU_AND);

        check_case("SLLI", `CTL_ALU_IOP,
                   3'b001, 7'b0000000, `ALU_SLL);

        check_case("SRLI", `CTL_ALU_IOP,
                   3'b101, 7'b0000000, `ALU_SRL);
 
        check_case("SRAI", `CTL_ALU_IOP,
                   3'b101, 7'b0100000, `ALU_SRA);


        $display("===== Invalid Instruction Test =====");

        check_case("R-invalid funct7", `CTL_ALU_ROP,
                   3'b000, 7'b0000001, `ALU_INVALID);

        check_case("R-invalid SUB", `CTL_ALU_ROP,
                   3'b111, 7'b0100000, `ALU_INVALID);

        check_case("R-invalid upper", `CTL_ALU_ROP,
                   3'b000, 7'b1100000, `ALU_INVALID);

        check_case("I-invalid SLLI", `CTL_ALU_IOP,
                   3'b001, 7'b0100000, `ALU_INVALID);

        check_case("I-invalid SRLI", `CTL_ALU_IOP,
                   3'b101, 7'b0000001, `ALU_INVALID);

        check_case("I-invalid shift", `CTL_ALU_IOP,
                   3'b101, 7'b1111111, `ALU_INVALID);


        // 5. 输出最终统计结果
        $display("==============================");
        $display("Total tests : %0d", test_count);
        $display("Failed      : %0d", error_count);

        if (error_count == 0)
            $display("ALL TESTS PASSED!");
        else
            $fatal(1, "ALU Control Test Failed");

        $finish;
    end

endmodule
