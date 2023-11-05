

`include "bus.v"
`include "sysreg.v"
`include "execode.v"

module CP0_reg(
    input wire clk,
    input wire rst,

    //read & write on privilege mode
    input wire read_en_i,
    input wire write_en_i,
    input [`REG_ADDR_BUS] read_addr_i,
    input [`REG_ADDR_BUS] write_addr_i,
    input [`DATA_BUS] write_data_i,
    
    //exception
    input [5:0] int_i,
    input wire eret_flag_i,
    input wire syscall_flag_i,
    input wire break_flag_i,
    input wire overflow_flag_i,
    input wire delayslot_flag_i,
    input wire address_read_error_flag_i,
    input wire address_write_error_flag_i,
    input [`ADDR_BUS] current_pc_addr_i,
    output [`ADDR_BUS] epc_o,
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

    wire [`ADDR_BUS] exc_epc;

    assign epc_o = reg_epc;
    assign exc_epc = delayslot_flag_i ? current_pc_addr_i - 4 : current_pc_addr_i;
    
    // BADVADDR
   always @(posedge clk) 
   begin
       if (rst) 
       begin
           reg_badvaddr <= 32'h0;
       end
       // only read
       else 
       begin
           reg_badvaddr <= reg_badvaddr;
       end
   end

    // COUNT
    always @(posedge clk) 
    begin
        if (rst) begin
            reg_count <= 33'h0;
        end
        else if (write_en_i && write_addr_i == `CP0_REG_COUNT) 
        begin
            reg_count <= {write_data_i, 1'b0};
        end
        else begin
            reg_count <= reg_count + 1;
        end
    end

    // COMPARE
    always @(posedge clk)
    begin
        if (rst)
        begin
            reg_compare <= 0;
        end
        else if (write_en_i && write_addr_i == `CP0_REG_COMPARE)
        begin
            reg_compare <= write_data_i;
        end
        else 
        begin
            reg_compare <= reg_compare;
        end
    end

    // TIMER
    always @(posedge clk)
    begin
        if (rst)
        begin
            timer_int_o <= 0;
        end
        else if (write_en_i && write_addr_i == `CP0_REG_COMPARE)
        begin
            timer_int_o <= 0;
        end
        else if (reg_compare != 0 && reg_count == reg_compare)
        begin
            timer_int_o <= 1;
        end
        else
        begin
            timer_int_o <= 0;
        end
    end

    // STATUS
    always @(posedge clk) 
    begin
        if (rst) 
        begin
            reg_status <= 32'h0040ff00;
        end
        else if (break_flag_i || syscall_flag_i || overflow_flag_i || address_read_error_flag_i || address_write_error_flag_i) 
        begin
            reg_status[1] <= 1;
        end
        else if (eret_flag_i) 
        begin
            reg_status[1] <= 0;
        end
        else if (write_en_i && write_addr_i == `CP0_REG_STATUS) 
        begin
            reg_status[22] <= write_data_i[22];
            reg_status[15:8] <= write_data_i[15:8];
            reg_status[1:0] <= write_data_i[1:0];
        end
        else 
        begin
            reg_cause <= reg_cause;
        end
    end

    // CAUSE
    always @(posedge clk) 
    begin
        if (rst) 
        begin
            reg_cause <= 32'h0;
            reg_cause[15:10] = int_i;
        end
        else if (break_flag_i || syscall_flag_i || overflow_flag_i || address_read_error_flag_i || address_write_error_flag_i) 
        begin
            if (reg_status[1] != 1)
                reg_cause[31] <= delayslot_flag_i;
            if (break_flag_i)
                reg_cause[6:2] <= `CP0_EXCCODE_BP;
            else if (syscall_flag_i)
                reg_cause[6:2] <= `CP0_EXCCODE_SYS;
            else if (overflow_flag_i)
                reg_cause[6:2] <= `CP0_EXCCODE_OV;
            else if (address_write_error_flag_i)
                reg_cause[6:2] <= `CP0_EXCCODE_ADES;
            else if (address_read_error_flag_i)
                reg_cause[6:2] <= `CP0_EXCCODE_ADEL;
        end
        else if (write_en_i && write_addr_i == `CP0_REG_CAUSE) 
        begin
            reg_cause[9:8] <= write_data_i[9:8];
        end
        else 
        begin
            reg_cause <= reg_cause;
        end
    end

    // EPC
    always @(posedge clk) 
    begin
        if (rst) 
        begin
            reg_epc <= 32'h0;
        end
        else if ((break_flag_i || syscall_flag_i || overflow_flag_i || address_read_error_flag_i || address_write_error_flag_i)) 
        begin
            reg_epc <= exc_epc;
        end
        else if (write_en_i && write_addr_i == `CP0_REG_EPC) 
        begin
            reg_epc <= write_data_i;
        end
        else 
        begin
            reg_epc <= reg_epc;
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
                    read_data_o <= reg_count;     //读count
                end
                `CP0_REG_COMPARE:
                begin
                    read_data_o <= reg_compare;   //读compare
                end
                `CP0_REG_STATUS:
                begin
                    read_data_o <= reg_status;    //读status
                end
                `CP0_REG_CAUSE:
                begin
                    read_data_o <= reg_cause;     //读cause
                end
                `CP0_REG_EPC:
                begin
                    read_data_o <= reg_epc;       //读epc
                end
                default:
                begin
                    read_data_o <= 0;
                end
            endcase
        end
    end
    
endmodule