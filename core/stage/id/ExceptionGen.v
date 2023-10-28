`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"

module ExceptionGen(
    input [`INST_BUS] inst,
    input [`INST_OP_BUS] inst_op,
    input [`FUNCT_BUS] inst_funct,

    output             eret_flag,
    output             syscall_flag,
    output             break_flag
);

    assign eret_flag = (inst == 32'h42000018)?1:0;
    assign syscall_flag = (inst_op == `OP_SPECIAL && inst_funct == `FUNCT_SYSCALL)?1:0;
    assign break_flag = (inst_op == `OP_SPECIAL && inst_funct == `FUNCT_BREAK)?1:0;
endmodule