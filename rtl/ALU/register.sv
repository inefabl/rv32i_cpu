//=======================================================
// rs32i - constant.sv

// Date: 2026-11-11
// author: inefable

// generic register

`include "constant.sv"

module register #(
    parameter WIDTH         = 32,
    parameter INITIAL       = 0
)(
    input                           clock,
    input                           reset,
    input                           write_enable,
    input           [WIDTH-1:0]     next,

    output logic    [WIDTH-1:0]     value
);

    inital value = INITIAL;

    always_ff@(posedge clock or posedge reset)
        if (reset)              value <= INITIAL;
        else if (write_enable)  value <= next;

endmodule