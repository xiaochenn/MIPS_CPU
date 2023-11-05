`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"

module FunctGen(
  input       [`INST_OP_BUS]  op,
  input       [`FUNCT_BUS]    funct_in,
  output  reg [`FUNCT_BUS]    funct
);

  // generating FUNCT signal in order for the ALU to perform operations
  always @(*) begin
    case (op)
      `OP_SPECIAL: funct <= funct_in;
      `OP_ORI, `OP_LUI, `OP_JAL: funct <= `FUNCT_OR;
      `OP_LB, `OP_LBU, `OP_LW,
      `OP_SB, `OP_SW, `OP_ADDIU,`OP_LH,`OP_PRIVILEGE,`OP_BSPECIAL: funct <= `FUNCT_ADDU;
      `OP_ANDI:funct <= `FUNCT_AND;
      `OP_XORI: funct <= `FUNCT_XOR;
      default: funct <= `FUNCT_NOP;
    endcase
  end

endmodule // FunctGen
