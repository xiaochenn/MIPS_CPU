`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/10/10 16:44:33
// Design Name: 
// Module Name: CPU_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

`include "bus.v"

module CPU_tb(
    );
    reg clk;
    reg rst;
    initial 
    begin
        clk = 1;
        rst = 1;
        #7 rst = 0;
    end
    
    always  
    begin
        #5 clk = ~clk;    
    end

    wire rom_en;
    wire[`MEM_SEL_BUS] rom_write_en;
    wire[`ADDR_BUS] rom_addr;
    wire[`DATA_BUS] rom_write_data;
    wire[`DATA_BUS] rom_read_data;

    wire ram_en;
    wire[`MEM_SEL_BUS] ram_write_en;
    wire[`ADDR_BUS] ram_addr;
    wire[`DATA_BUS] ram_write_data;
    wire[`DATA_BUS] ram_read_data;

    Core Core(
        .clk(clk),
        .rst(rst),
        .stall(0),

        .rom_en(rom_en),
        .rom_write_en(rom_write_en),
        .rom_addr(rom_addr),
        .rom_write_data(rom_write_data),
        .rom_read_data(rom_read_data),

        .ram_en(ram_en),
        .ram_write_en(ram_write_en),
        .ram_addr(ram_addr),
        .ram_write_data(ram_write_data),
        .ram_read_data(ram_read_data)
    );

    ROM rom(
        .clk(clk),
        .rom_en(rom_en),
        .rom_write_en(rom_write_en),
        .rom_addr(rom_addr),
        .rom_write_data(rom_write_data),
        .rom_read_data(rom_read_data)
    );

    RAM ram(
        .clk(clk),
        .ram_en(ram_en),
        .ram_write_en(ram_write_en),
        .ram_addr(ram_addr),
        .ram_write_data(ram_write_data),
        .ram_read_data(ram_read_data)
    );
endmodule
