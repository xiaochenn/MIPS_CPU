`include "bus.v"
`include "system_reg.v"

module CP0_reg(
    input wire clk,
    input wire rst,

    input wire write_en_i,
    input [`REG_ADDR_BUS] read_addr_i,
    input [`REG_ADDR_BUS] write_addr_i,
    input [5:0] int_i,
    input [`DATA_BUS] write_data_i,

    output reg[`ADDR_BUS] badvaddr_o,
    output reg[`DATA_BUS] read_data_o,
    output reg[`DATA_BUS] count_o,
    output reg[`DATA_BUS] compare_o,
    output reg[`DATA_BUS] status_o,
    output reg[`DATA_BUS] cause_o,
    output reg[`DATA_BUS] epc_o,
    //output reg[`DATA_BUS] config_o,
    //output reg[`DATA_BUS] prid_o,
    output reg            timer_int_o
);

    //write operation
    always @(posedge clk) 
    begin
        if (rst)
        begin
            badvaddr_o <= 0;
            count_o <= 0;
            compare_o <= 0;
            status_o <= 32'h10000000;
            cause_o <= 0;
            epc_o <= 0;
            //config_o <= 0;
            //prid_o <= 0;
            timer_int_o <= 0;
        end
        else
        begin
            count_o <= count_o + 1;
            cause_o[15:10] <= int_i; //外部硬件中断
            
            //如果compare的�?�不�?0且等于count寄存器的�?
            //触发时钟中断
            if (compare_o != 0 && count_o == compare_o)
            begin
                timer_int_o <= 0;
            end

            if (write_en_i == 1)
            begin
                case(write_addr_i)
                    `CP0_REG_COUNT:     //count寄存�?
                    begin
                        count_o <= write_data_i;
                    end
                    `CP0_REG_COMPARE:  //compare寄存�?
                    begin
                        compare_o <= write_data_i;
                        timer_int_o <= 0;
                    end
                    `CP0_REG_STATUS:    //status寄存�?
                    begin
                        status_o[15:8] <= write_data_i[15:8];
                        status_o[1:0] <= write_data_i[1:0];
                    end
                    `CPO_REG_EPC:       //epc寄存�?
                    begin
                        epc_o <= write_data_i;
                    end
                    `CP0_REG_CAUSE:     //cause寄存�?
                    begin
                        cause_o[9:8] <= write_data_i[9:8];
                    end
                endcase
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
                    read_data_o <= count_o;     //读count寄存�?
                end
                `CP0_REG_COMPARE:
                begin
                    read_data_o <= compare_o;   //读compare寄存�?
                end
                `CP0_REG_STATUS:
                begin
                    read_data_o <= status_o;    //读status寄存�?
                end
                `CP0_REG_CAUSE:
                begin
                    read_data_o <= cause_o;     //读cause寄存�?
                end
                `CP0_REG_EPC:
                begin
                    read_data_o <= epc_o;       //读epc寄存�?
                end
                default:
                begin
                    read_data_o <= 0;
                end
            endcase
        end
    end
    
endmodule