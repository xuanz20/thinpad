module forward_unit (
    input wire [4:0] id_reg_rs1,
    input wire [4:0] id_reg_rs2,
    input wire [31:0] id_reg_rdata1_raw,
    input wire [31:0] id_reg_rdata2_raw,
    input wire [4:0] mem_reg_rd,
    input wire [4:0] wb_reg_rd,
    input wire [31:0] mem_reg_data,
    input wire [31:0] wb_reg_data,
    output reg [31:0] id_reg_rdata1,
    output reg [31:0] id_reg_rdata2,

    input wire [11:0] id_csr_reg,
    input wire [31:0] id_csr_rdata_raw,
    input wire [11:0] mem_csr_reg,
    input wire [11:0] wb_csr_reg,
    input wire [31:0] mem_csr_data,
    input wire [31:0] wb_csr_data,
    output reg [31:0] id_csr_rdata
);

    always_comb begin
        if (mem_reg_rd != 5'b0 && mem_reg_rd == id_reg_rs1)
            id_reg_rdata1 = mem_reg_data;
        else if (wb_reg_rd != 5'b0 && wb_reg_rd == id_reg_rs1)
            id_reg_rdata1 = wb_reg_data;
        else
            id_reg_rdata1 = id_reg_rdata1_raw;

        if (mem_reg_rd != 5'b0 && mem_reg_rd == id_reg_rs2)
            id_reg_rdata2 = mem_reg_data;
        else if (wb_reg_rd != 5'b0 && wb_reg_rd == id_reg_rs2)
            id_reg_rdata2 = wb_reg_data;
        else
            id_reg_rdata2 = id_reg_rdata2_raw;

        if (mem_csr_reg != 12'b0 && mem_csr_reg == id_csr_reg)
            id_csr_rdata = mem_csr_data;
        else if (wb_csr_reg != 12'b0 && wb_csr_reg == id_csr_reg)
            id_csr_rdata = wb_csr_data;
        else
            id_csr_rdata = id_csr_rdata_raw;
    end
endmodule