`timescale 1ns / 1ps

`include "bus.v"

module PipelineController(
  // stall request signals
  input   request_from_id,
  // stall whole pipeline
  input   stall_all,
  // exception
  input [`ADDR_BUS] cp0_epc,
  input eret_flag,
  input syscall_flag,
  input break_flag,
  input overflow_flag,
  input address_read_error_flag,
  input address_write_error_flag,
  // stall signals for each mid-stage
  output  stall_pc,
  output  stall_if,
  output  stall_id,
  output  stall_ex,
  output  stall_mem,
  output  stall_wb,
  // exception
  output flush,
  output reg[`ADDR_BUS] exc_pc
);

  reg[5:0] stall;

  // assign the output of the stall signal
  assign {stall_wb, stall_mem, stall_ex,
          stall_id, stall_if, stall_pc} = stall;

  assign flush = stall_all? 0: (eret_flag || syscall_flag || break_flag || overflow_flag || address_read_error_flag || address_write_error_flag) ? 1 : 0;


  always @(*) begin
    if (stall_all) begin
      stall <= 6'b111111;
    end
    else if (request_from_id) begin
      stall <= 6'b000111;
    end
    else begin
      stall <= 6'b000000;
    end
  end

  always @(*) begin
    if (eret_flag) 
    begin
      exc_pc <= cp0_epc;
    end
    else if (syscall_flag || break_flag || overflow_flag || address_read_error_flag || address_write_error_flag) 
    begin
      exc_pc <= 32'hbfc00380;
    end
    else 
    begin
      exc_pc <= 32'hbfc00000;
    end
  end
endmodule // PipelineController
