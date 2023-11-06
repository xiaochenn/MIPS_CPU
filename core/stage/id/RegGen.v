`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"

module RegGen(
  input       [`INST_OP_BUS]  op,
  input       [`REG_ADDR_BUS] rs,
  input       [`REG_ADDR_BUS] rt,
  input       [`REG_ADDR_BUS] rd,
  input                       inst_mfc0,
  input                       inst_mtc0,
  output  reg                 reg_read_en_1,
  output  reg                 reg_read_en_2,
  output  reg [`REG_ADDR_BUS] reg_addr_1,
  output  reg [`REG_ADDR_BUS] reg_addr_2,
  output  reg                 reg_write_en,
  output  reg [`REG_ADDR_BUS] reg_write_addr,
  output  reg                 cp_read_en,
  output  reg [`REG_ADDR_BUS] cp_read_addr,
  output  reg                 cp_write_en,
  output  reg [`REG_ADDR_BUS] cp_write_addr

);

  // generate read address
  always @(*) begin
    case (op)
      // jump
      `OP_BGTZ,`OP_BLEZ,
      // arithmetic & logic (immediate)
      `OP_ADDIU,`OP_ORI,
      // memory accessing
      `OP_LB, `OP_LW, `OP_LBU,`OP_LH: begin
        reg_read_en_1 <= 1;
        reg_read_en_2 <= 0;
        reg_addr_1 <= rs;
        reg_addr_2 <= 0;
      end
      // branch
      `OP_BEQ, `OP_BNE,
      // arithmetic & logic (immediate)
      `OP_ANDI,`OP_XORI,
      // memory accessing
      `OP_SB, `OP_SW,
      // r-type
      `OP_SPECIAL,`OP_BSPECIAL: begin
        reg_read_en_1 <= 1;
        reg_read_en_2 <= 1;
        reg_addr_1 <= rs;
        reg_addr_2 <= rt;
      end
      // privilege
      `OP_PRIVILEGE: begin
        if (rs == 5'b00000) begin
          reg_read_en_1 <= 0;
          reg_read_en_2 <= 0;
          reg_addr_1 <= 0;
          reg_addr_2 <= 0;
        end
        else if (rs == 5'b00100) begin
          reg_read_en_1 <= 0;
          reg_read_en_2 <= 1;
          reg_addr_1 <= 0;
          reg_addr_2 <= rt;
        end
        else begin
          reg_read_en_1 <= 0;
          reg_read_en_2 <= 0;
          reg_addr_1 <= 0;
          reg_addr_2 <= 0;
        end
      end
      default: begin  // OP_JAL, OP_LUI
        reg_read_en_1 <= 0;
        reg_read_en_2 <= 0;
        reg_addr_1 <= 0;
        reg_addr_2 <= 0;
      end
    endcase
  end

  // generate write address
  always @(*) begin
    case (op)
      // immediate
      `OP_ADDIU, `OP_LUI: begin
        reg_write_en <= 1;
        reg_write_addr <= rt;
      end
      `OP_SPECIAL: begin
        reg_write_en <= 1;
        reg_write_addr <= rd;
      end
      `OP_JAL: begin
        reg_write_en <= 1;
        reg_write_addr <= 31;   // $ra (return address)
      end
      `OP_LB, `OP_LBU, `OP_LW,`OP_ANDI,`OP_ORI,`OP_LH,`OP_XORI: begin
        reg_write_en <= 1;
        reg_write_addr <= rt;
      end
      `OP_BSPECIAL:begin
        if (rt == 5'b10001) begin
          reg_write_en <= 1;
          reg_write_addr <= 5'h1f;
        end
        else if (rt == 5'b10000) begin
          reg_write_en <= 1;
          reg_write_addr <= 5'h1f;
        end
        else begin
          reg_write_en <= 0;
          reg_write_addr <= 0;
        end
      end
      `OP_PRIVILEGE: begin
        if (rs == 5'b00000) begin
          reg_write_en <= 1;
          reg_write_addr <= rt; // MFC0
        end
        else begin
          reg_write_en <= 0;
          reg_write_addr <= 0;
        end
      end
      default: begin
        reg_write_en <= 0;
        reg_write_addr <= 0;
      end
    endcase
  end

  // generate read address for CP0
  always @(*) begin
    if (inst_mfc0) begin
      cp_read_en <= 1;
      cp_read_addr <= rd;
    end
    else begin
      cp_read_en <= 0;
      cp_read_addr <= 0;
    end
  end

  // generate write address for CP0
  always @(*) begin
    if (inst_mtc0) begin
      cp_write_en <= 1;
      cp_write_addr <= rd;
    end
    else begin
      cp_write_en <= 0;
      cp_write_addr <= 0;
    end
  end
  

endmodule // RegGen
