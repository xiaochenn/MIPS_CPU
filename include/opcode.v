`ifndef TINYMIPS_OPCODE_V_
`define TINYMIPS_OPCODE_V_

// r-type (SPECIAL)
`define OP_SPECIAL    6'b000000

// j-type
`define OP_JAL        6'b000011
`define OP_BGTZ       6'b000111
`define OP_BLTZ        6'b000001

// branch
`define OP_BEQ        6'b000100
`define OP_BNE        6'b000101

// arithmetic
`define OP_ADDIU      6'b001001
`define OP_SLTI       6'b001010
`define OP_SLTIU      6'b001011

// immediate
`define OP_LUI        6'b001111
`define OP_ANDI       6'b001100
`define OP_ORI        6'b001101

// memory accessing
`define OP_LB         6'b100000
`define OP_LW         6'b100011
`define OP_LBU        6'b100100
`define OP_SB         6'b101000
`define OP_SW         6'b101011
`define OP_LH         6'b100001
`define OP_SH         6'b101001
`define OP_LHU        6'b100101

`endif  // TINYMIPS_OPCODE_V_
