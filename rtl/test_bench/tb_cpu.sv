`timescale 1ns/1ps

module tb_cpu;
    localparam int PROGRAM_WORDS = 32;
    localparam int MAX_CYCLES = 512;

    logic        clk = 1'b0;
    logic        rst = 1'b1;
    logic [31:0] imem_addr;
    logic [31:0] imem_rdata;

    always #5 clk = ~clk;

    // 从仓库根目录用 sim/tb_cpu.f 编译，ROM 加载 sim/program.hex。
    // 指令源位于 CPU 之外，使用和外部组合读存储器相同的端口。
    inst_mem u_imem (
        .addr  (imem_addr),
        .rdata (imem_rdata)
    );

    cpu_top dut (
        .clk        (clk),
        .rst        (rst),
        .imem_addr  (imem_addr),
        .imem_rdata (imem_rdata)
    );

    // 程序的 32 条指令都写非零编号的 rd，按顺序检查写回。
    function automatic logic [36:0] expected_write(input int index);
        case (index)
             0: expected_write = { 5'd5, 32'h00000007}; // addi x5, x0, 7
             1: expected_write = { 5'd6, 32'h0000000e}; // add x6, x5, x5
             2: expected_write = { 5'd1, 32'h00000003}; // addi x1, x0, 3
             3: expected_write = { 5'd2, 32'hfffffff8}; // addi x2, x0, -8
             4: expected_write = { 5'd3, 32'h0000001f}; // addi x3, x0, 31
             5: expected_write = { 5'd4, 32'h00000001}; // addi x4, x0, 1
             6: expected_write = { 5'd7, 32'h00000007}; // sub x7, x6, x5
             7: expected_write = { 5'd8, 32'h00000003}; // and x8, x7, x1
             8: expected_write = { 5'd9, 32'h0000000f}; // or x9, x8, x6
             9: expected_write = {5'd10, 32'h00000008}; // xor x10, x9, x5
            10: expected_write = {5'd11, 32'h80000000}; // sll x11, x5, x3
            11: expected_write = {5'd12, 32'h10000000}; // srl x12, x11, x1
            12: expected_write = {5'd13, 32'hf0000000}; // sra x13, x11, x1
            13: expected_write = {5'd14, 32'h00000001}; // slt x14, x2, x1
            14: expected_write = {5'd15, 32'h00000000}; // sltu x15, x2, x1
            15: expected_write = {5'd16, 32'h00000008}; // andi x16, x10, 12
            16: expected_write = {5'd17, 32'h00000009}; // ori x17, x16, 1
            17: expected_write = {5'd18, 32'hfffffff6}; // xori x18, x17, -1
            18: expected_write = {5'd19, 32'h00000070}; // slli x19, x5, 4
            19: expected_write = {5'd20, 32'h7ffffffb}; // srli x20, x18, 1
            20: expected_write = {5'd21, 32'hfffffffb}; // srai x21, x18, 1
            21: expected_write = {5'd22, 32'h00000001}; // slti x22, x21, -4
            22: expected_write = {5'd23, 32'h00000001}; // sltiu x23, x12, -1
            23: expected_write = {5'd24, 32'h00000021}; // addi x24, x0, 33
            24: expected_write = {5'd25, 32'h00000006}; // sll x25, x1, x24
            25: expected_write = {5'd26, 32'h00000001}; // addi x26, x0, 1
            26: expected_write = {5'd26, 32'h00000003}; // addi x26, x26, 2
            27: expected_write = {5'd27, 32'h00000003}; // sub x27, x25, x26
            28: expected_write = {5'd28, 32'h80000000}; // slli x28, x4, 31
            29: expected_write = {5'd29, 32'h00000000}; // add x29, x11, x28
            30: expected_write = {5'd30, 32'h0000000b}; // sub x30, x1, x2
            31: expected_write = {5'd31, 32'h0000000b}; // add x31, x29, x30
            default: expected_write = 'x;
        endcase
    endfunction

    initial begin
        int cycles;
        int retired;
        logic [36:0] expected;

        cycles = 0;
        retired = 0;
        repeat (2) @(negedge clk);
        rst = 1'b0;

        while (retired < PROGRAM_WORDS && cycles < MAX_CYCLES) begin
            @(posedge clk);
            cycles++;
            if (dut.wb_write_enable) begin
                expected = expected_write(retired);
                if ({dut.ex_wb_rd, dut.ex_wb_result} !== expected) begin
                    $fatal(1, "Instruction %0d, cycle %0d: expected x%0d=%08h, got x%0d=%08h",
                           retired + 1, cycles, expected[36:32], expected[31:0],
                           dut.ex_wb_rd, dut.ex_wb_result);
                end

                // 在写入上升沿之后检查寄存器堆中的值。
                @(negedge clk);
                if (dut.u_regfile.register[expected[36:32]] !== expected[31:0]) begin
                    $fatal(1, "Instruction %0d: register x%0d did not store %08h",
                           retired + 1, expected[36:32], expected[31:0]);
                end
                retired++;
            end
        end

        if (retired != PROGRAM_WORDS) begin
            $fatal(1, "Timeout: %0d of %0d instructions completed in %0d cycles",
                   retired, PROGRAM_WORDS, cycles);
        end

        $display("PASS: instructions=%0d cycles=%0d CPI=%0.3f IPC=%0.3f",
                 retired, cycles, $itor(cycles) / $itor(retired),
                 $itor(retired) / $itor(cycles));
        $finish;
    end
endmodule
