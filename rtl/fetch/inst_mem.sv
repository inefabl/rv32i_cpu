//=======================================================
// rs32i - inst_mem.sv

// Date: 2026-11-25
// author: inefable

module inst_mem #(
    parameter int unsigned DEPTH_WORDS = 64,
    parameter INIT_FILE = "sim/program.hex"
) (
    input  logic [31:0] addr,
    output logic [31:0] rdata
);

    localparam logic [31:0] NOP = 32'h00000013;
    localparam int INDEX_WIDTH = (DEPTH_WORDS > 1) ? $clog2(DEPTH_WORDS) : 1;

    logic [31:0] rom [0:DEPTH_WORDS-1];
    logic [29:0] word_index;
    logic        addr_aligned;

    assign word_index   = addr[31:2];          // 将字节地址换算为指令字索引
    assign addr_aligned = (addr[1:0] == 2'b00); // 32 位指令从 4 字节边界开始

    initial begin
        // 先填满 NOP，程序文件只覆盖其中提供的指令字。
        for (int word = 0; word < DEPTH_WORDS; word++) begin
            rom[word] = NOP;
        end
        if (INIT_FILE != "") begin
            $readmemh(INIT_FILE, rom);
        end
    end

    always_comb begin
        rdata = NOP;
        // 检查完整索引后再取低位，避免越界地址折回 ROM 开头。
        if (addr_aligned && ({2'b00, word_index} < DEPTH_WORDS)) begin
            rdata = rom[word_index[INDEX_WIDTH-1:0]];
        end
    end

endmodule
