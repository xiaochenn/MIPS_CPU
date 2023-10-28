`timescale 1ns / 1ps

`include "bus.v"

module CP0ReadProxy(
    input [`REG_ADDR_BUS]   read_addr_i,
    //from cp0
    input [`DATA_BUS]       read_data_i,
    //from ex
    input [`DATA_BUS]       ex_cp_write_data,
    input [`REG_ADDR_BUS]   ex_cp_write_addr,
    input                   ex_cp_write_en,
    //from mem
    input [`DATA_BUS]       mem_cp_write_data,
    input [`REG_ADDR_BUS]   mem_cp_write_addr,
    input                   mem_cp_write_en,
    //output
    output reg [`DATA_BUS]      cp_read_data_o
);
    always @(*)
    begin
        if (mem_cp_write_en && read_addr_i == mem_cp_write_addr)
        begin
            cp_read_data_o <= mem_cp_write_data;
        end
        else if (ex_cp_write_en && read_addr_i == ex_cp_write_addr)
        begin
            cp_read_data_o <= ex_cp_write_data;
        end
        else
        begin
            cp_read_data_o <= read_data_i;
        end
    end
endmodule