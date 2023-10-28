

`include "bus.v"
`include "sysreg.v"

module CP0_reg(
    input wire clk,
    input wire rst,

    input wire read_en_i,
    input wire write_en_i,
    input [`REG_ADDR_BUS] read_addr_i,
    input [`REG_ADDR_BUS] write_addr_i,
    input [5:0] int_i,
    input [`DATA_BUS] write_data_i,

    output reg[`DATA_BUS] read_data_o,
    //output reg[`DATA_BUS] config_o,
    //output reg[`DATA_BUS] prid_o,
    output reg            timer_int_o
);
    reg[`ADDR_BUS] reg_badvaddr;
    reg[`DATA_BUS] reg_count;
    reg[`DATA_BUS] reg_compare;
    reg[`DATA_BUS] reg_status;
    reg[`DATA_BUS] reg_cause;
    reg[`DATA_BUS] reg_epc;
    //write operation
    always @(posedge clk) 
    begin
        if (rst)
        begin
            reg_badvaddr <= 0;
            reg_count <= 0;
            reg_compare <= 0;
            reg_status <= 32'h10000000;
            reg_cause <= 0;
            reg_epc <= 0;
            //config_o <= 0;
            //prid_o <= 0;
            timer_int_o <= 0;
        end
        else
        begin
            reg_count <= reg_count + 1;
            reg_cause[15:10] <= int_i; //外部硬件中断
            
            //如果compare的�?�不�?0且等于count寄存器的寄存�?
            //触发时钟中断
            if (reg_compare != 0 && reg_count == reg_compare)
            begin
                timer_int_o <= 0;
            end
            else 
            begin
                timer_int_o <= 1;
            end

            if (write_en_i == 1)
            begin
                case(write_addr_i)
                    `CP0_REG_COUNT:     //count寄存�?
                    begin
                        reg_count <= write_data_i;
                    end
                    `CP0_REG_COMPARE:  //compare寄存�?
                    begin
                        reg_compare <= write_data_i;
                        timer_int_o <= 0;
                    end
                    `CP0_REG_STATUS:    //status寄存�?
                    begin
                        reg_status[15:8] <= write_data_i[15:8];
                        reg_status[1:0] <= write_data_i[1:0];
                    end
                    `CP0_REG_EPC:       //epc寄存�?
                    begin
                        reg_epc <= write_data_i;
                    end
                    `CP0_REG_CAUSE:     //cause寄存�?
                    begin
                        reg_cause[9:8] <= write_data_i[9:8];
                    end
                endcase
            end
            else
            begin
                reg_count <= reg_count;
                reg_compare <= reg_compare;
                reg_status <= reg_status;
                reg_epc <= reg_epc;
                reg_cause <= reg_cause;
            end
        end
    end

    //read operation
    always @(*)
    begin
        if (rst)
        begin
            read_data_o <= 0;
        end
        else
        begin
            case(read_addr_i)
                `CP0_REG_COUNT:
                begin
                    read_data_o <= reg_count;     //读count寄存�?
                end
                `CP0_REG_COMPARE:
                begin
                    read_data_o <= reg_compare;   //读compare寄存�?
                end
                `CP0_REG_STATUS:
                begin
                    read_data_o <= reg_status;    //读status寄存�?
                end
                `CP0_REG_CAUSE:
                begin
                    read_data_o <= reg_cause;     //读cause寄存�?
                end
                `CP0_REG_EPC:
                begin
                    read_data_o <= reg_epc;       //读epc寄存�?
                end
                default:
                begin
                    read_data_o <= 0;
                end
            endcase
        end
    end
    
endmodule