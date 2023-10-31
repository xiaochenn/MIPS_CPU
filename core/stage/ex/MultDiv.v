`include "bus.v"

module(
  input                       clk,
  input                       rst,
  input                       stall_all,
  input       [`DATA_BUS]     funct,
  input       [`DATA_BUS]     operand_1,
  input       [`DATA_BUS]     operand_2,
  output                      done,
  output      [`MULT_DIV_BUS] result
);

  reg [`MULT_DIV_BUS] hilo_tmp;
  assign hilo_tmp = operand_1 * operand_2;
  always @ (*) begin
    if (rst) begin
      result = {64'b0};
    end
  end


endmodule
