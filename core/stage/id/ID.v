`timescale 1ns / 1ps

`include "bus.v"
`include "segpos.v"
`include "opcode.v"
`include "funct.v"

module ID(
  // from IF stage (PC)
  input   [`ADDR_BUS]     addr,
  input   [`INST_BUS]     inst,
  // delay slot
  input                   delayslot_flag_in,
  // load related signals
  input                   load_related_1,
  input                   load_related_2,
  // regfile channel #1
  output                  reg_read_en_1,
  output  [`REG_ADDR_BUS] reg_addr_1,
  input   [`DATA_BUS]     reg_data_1,
  // regfile channel #2
  output                  reg_read_en_2,
  output  [`REG_ADDR_BUS] reg_addr_2,
  input   [`DATA_BUS]     reg_data_2,
  // cp0 channel
  output                      cp_read_en,
  output  [`REG_ADDR_BUS]     cp_read_addr,
  input   [`DATA_BUS]         cp_read_data,
  // stall request
  output                  stall_request,
  // to IF stage
  output                  branch_flag,
  output  [`ADDR_BUS]     branch_addr,
  // to EX stage
  output  [`FUNCT_BUS]    funct,
  output  [`SHAMT_BUS]    shamt,
  output  [`DATA_BUS]     operand_1,
  output  [`DATA_BUS]     operand_2,
  // to MEM stage
  output                  mem_read_flag,
  output                  mem_write_flag,
  output                  mem_sign_ext_flag,
  output  [`MEM_SEL_BUS]  mem_sel,
  output  [`DATA_BUS]     mem_write_data,
  // to WB stage (write back to regfile)
  output                  reg_write_en,
  output  [`REG_ADDR_BUS] reg_write_addr,
  output  [`ADDR_BUS]     current_pc_addr,
  // CP0 channel
  output                  cp_write_en,
  output  [`REG_ADDR_BUS] cp_write_addr,
  // exception
  output                  eret_flag,
  output                  syscall_flag,
  output                  break_flag,
  output                  next_inst_delayslot_flag,
  output                  overflow_judge_flag,
  output                  delayslot_flag_out,
  output                  reserved_inst_flag
);

  // extract information from instruction
  wire[`INST_OP_BUS]    inst_op     = inst[`SEG_OPCODE];
  wire[`REG_ADDR_BUS]   inst_rs     = inst[`SEG_RS];
  wire[`REG_ADDR_BUS]   inst_rt     = inst[`SEG_RT];
  wire[`REG_ADDR_BUS]   inst_rd     = inst[`SEG_RD];
  wire[`SHAMT_BUS]      inst_shamt  = inst[`SEG_SHAMT];
  wire[`FUNCT_BUS]      inst_funct  = inst[`SEG_FUNCT];
  wire[`HALF_DATA_BUS]  inst_imm    = inst[`SEG_IMM];
  wire inst_mfc0,inst_mtc0,inst_al;
  wire reserved_inst[1:0];
  // generate reserved_inst_flag
  assign reserved_inst_flag = !(  (reserved_inst[0] == 1 || reserved_inst[1] == 1)
                               || (eret_flag || syscall_flag || break_flag || inst_mfc0 || inst_mtc0)
                               || (inst_op == `OP_SPECIAL));

  // generate output signals
  assign shamt = inst_shamt;
  assign stall_request = load_related_1 || load_related_2;
  assign current_pc_addr = addr;
  assign inst_mfc0 = (inst[31:21] == 11'b01000000000 && inst[10:0] == 11'b00000000000); //mfc0指令
  assign inst_mtc0 = (inst[31:21] == 11'b01000000100 && inst[10:0] == 11'b00000000000); //mtc0指令
  assign delayslot_flag_out = delayslot_flag_in;

  assign overflow_judge_flag = ((inst_op == `OP_SPECIAL && (inst_funct == `FUNCT_ADD || inst_funct == `FUNCT_SUB)) || inst_op == `OP_ADDI);

  assign inst_al = (inst_op == `OP_BSPECIAL) && (inst_rt == 5'b10001 || inst_rt == 5'b10000);
  // generate address of registers
  RegGen reg_gen(
    .op             (inst_op),
    .rs             (inst_rs),
    .rt             (inst_rt),
    .rd             (inst_rd),
    .inst_mfc0      (inst_mfc0),
    .inst_mtc0      (inst_mtc0),
    .reg_read_en_1  (reg_read_en_1),
    .reg_read_en_2  (reg_read_en_2),
    .reg_addr_1     (reg_addr_1),
    .reg_addr_2     (reg_addr_2),
    .reg_write_en   (reg_write_en),
    .reg_write_addr (reg_write_addr),
    .cp_read_en     (cp_read_en),
    .cp_read_addr   (cp_read_addr),
    .cp_write_en    (cp_write_en),
    .cp_write_addr  (cp_write_addr)
  );

  // generate FUNCT signal
  FunctGen funct_gen(
    .op       (inst_op),
    .funct_in (inst_funct),
    .funct    (funct)
  );

  // generate operands
  OperandGen operand_gen(
    .addr       (addr),
    .op         (inst_op),
    .funct      (inst_funct),
    .imm        (inst_imm),
    .inst_mfc0  (inst_mfc0),
    .inst_mtc0  (inst_mtc0),
    .inst_al    (inst_al),
    .reg_data_1 (reg_data_1),
    .reg_data_2 (reg_data_2),
    .cp_read_data (cp_read_data),
    .operand_1  (operand_1),
    .operand_2  (operand_2),
    .reserved_inst (reserved_inst[0])
  );

  // generate branch address
  BranchGen branch_gen(
    .addr         (addr),
    .inst         (inst),
    .op           (inst_op),
    .funct        (inst_funct),
    .reg_data_1   (reg_data_1),
    .reg_data_2   (reg_data_2),
    .branch_flag  (branch_flag),
    .branch_addr  (branch_addr),
    .next_inst_delayslot_flag (next_inst_delayslot_flag),
    .reserved_inst (reserved_inst[1])
  );

  // generate memory accessing signals
  MemGen mem_gen(
    .op                 (inst_op),
    .reg_data_2         (reg_data_2),
    .mem_read_flag      (mem_read_flag),
    .mem_write_flag     (mem_write_flag),
    .mem_sign_ext_flag  (mem_sign_ext_flag),
    .mem_sel            (mem_sel),
    .mem_write_data     (mem_write_data)
  );

  ExceptionGen exception_gen(
    .inst         (inst),
    .inst_op      (inst_op),
    .inst_funct   (inst_funct),
    .eret_flag    (eret_flag),
    .syscall_flag (syscall_flag),
    .break_flag   (break_flag)
  );



endmodule // ID
