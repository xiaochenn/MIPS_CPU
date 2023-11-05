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
      `OP_SLTI: funct <= `FUNCT_SLT;  // 有符号比较
      `OP_SLTIU: funct <= `FUNCT_SLTU; // 无符号比较
      `OP_LUI: funct <= `FUNCT_OR;
      `OP_LB, `OP_LBU, `OP_LW,
      `OP_SB, `OP_SW, `OP_ADDIU,`OP_LH, `OP_SH: funct <= `FUNCT_ADDU;
      `OP_JAL: funct <= `FUNCT_OR;
      `OP_ANDI:funct <= `FUNCT_AND;
      `OP_ORI:funct <= `FUNCT_XOR;
      default: funct <= `FUNCT_NOP;
    endcase
  end

endmodule // FunctGen
