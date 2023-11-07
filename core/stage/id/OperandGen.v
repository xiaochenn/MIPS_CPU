`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"

module OperandGen(
  input       [`ADDR_BUS]       addr,
  input       [`INST_OP_BUS]    op,
  input       [`FUNCT_BUS]      funct,
  input       [`HALF_DATA_BUS]  imm,
  input                         inst_mfc0,
  input                         inst_mtc0,
  input                         inst_al,
  input       [`DATA_BUS]       reg_data_1,
  input       [`DATA_BUS]       reg_data_2,
  input       [`DATA_BUS]       cp_read_data,
  output  reg [`DATA_BUS]       operand_1,
  output  reg [`DATA_BUS]       operand_2,
  output  reg                   reserved_inst
);

  // calculate link address
  wire[`ADDR_BUS] link_addr = addr + 8;

  // extract immediate from instruction
  wire[`DATA_BUS] zero_ext_imm_hi = {imm, 16'b0};
  wire[`DATA_BUS] sign_ext_imm = {{16{imm[15]}}, imm};
  wire[`DATA_BUS] zero_ext_imm = {16'b0, imm};

  // generate operand_1
  always @(*) begin
    case (op)
      // immediate
      `OP_ADDIU, `OP_LUI, `OP_ANDI,`OP_XORI,`OP_ADDI,
      `OP_SLTI, `OP_SLTIU,`OP_ORI,
      // memory accessing
      `OP_LB, `OP_LW, `OP_LBU, `OP_SB, `OP_SW,`OP_LH, `OP_SH, `OP_LHU: begin
        operand_1 <= reg_data_1;
        reserved_inst <= 1;
      end
      `OP_SPECIAL: begin
        operand_1 <= funct == `FUNCT_JALR ? link_addr : reg_data_1;
        reserved_inst <= 0;
      end
      `OP_JAL: begin
        operand_1 <= link_addr;
        reserved_inst <= 0;
      end
      `OP_BSPECIAL: begin
        reserved_inst <= 0;
        if (inst_al)
        begin
          operand_1 <= link_addr;
        end
        else
        begin
          operand_1 <= 0;
        end
      end
      `OP_PRIVILEGE: begin
        if (inst_mfc0) 
        begin
          operand_1 <= cp_read_data;
        end
        else 
        begin
          operand_1 <= 0;
        end
      end
      default: begin
        operand_1 <= 0;
        reserved_inst <= 0;
      end
    endcase
  end

  // generate operand_2
  always @(*) begin
    case (op)
      `OP_LUI: begin
        operand_2 <= zero_ext_imm_hi;
      end
      // arithmetic & logic (immediate)
      `OP_ADDIU,`OP_ADDI,
      `OP_SLTI, `OP_SLTIU,
      // memory accessing
      `OP_LB, `OP_LW, `OP_LBU, `OP_SB, `OP_SW,`OP_LH, `OP_SH, `OP_LHU: begin
        operand_2 <= sign_ext_imm;
      end
      `OP_ANDI,`OP_ORI,`OP_XORI: begin
        operand_2 <= zero_ext_imm;
      end
      `OP_SPECIAL: begin
        operand_2 <= reg_data_2;
      end
      `OP_PRIVILEGE: begin
        if (inst_mtc0)
        begin
          operand_2 <= reg_data_2;
        end
        else
        begin
          operand_2 <= 0;
        end
      end
      default: begin
        operand_2 <= 0;
      end
    endcase
  end

endmodule // OperandGen
