module mem_wb_register (
  input wire clk,
  input wire rst,
  input wire stall,
  input wire flush,

  input wire mem_interrupt,
  input wire [31:0] mem_pc,
  input wire [31:0] mem_reg_rdata2,
  input wire [4:0] mem_reg_rd,
  input wire [31:0] mem_alu_o,
  input wire [31:0] mem_dat_o,
  input wire mem_wb_en,
  input wire [1:0] mem_wb_type, // 0-ALU 1-MEM 2-PC
  input wire [11:0] mem_csr_reg,
  input wire [31:0] mem_csr_rdata,
  input wire mem_wb_csr_en,
  
  input wire mem_int_en,
  input wire mem_mepc_we,
  input wire [31:0] mem_mepc_wdata,
  input wire mem_mcause_we,
  input wire [31:0] mem_mcause_wdata,
  input wire mem_mstatus_we,
  input wire [31:0] mem_mstatus_wdata,
  input wire mem_mip_we,
  input wire [31:0] mem_mip_wdata,
  input wire mem_mode_we,
  input wire [1:0] mem_mode_wdata,
  input wire mem_mtval_we,
  input wire [31:0] mem_mtval_wdata,
  input wire mem_sepc_we,
  input wire [31:0] mem_sepc_wdata,
  input wire mem_scause_we,
  input wire [31:0] mem_scause_wdata,
  input wire mem_sstatus_we,
  input wire [31:0] mem_sstatus_wdata,
  input wire mem_stval_we,
  input wire [31:0] mem_stval_wdata,

  output reg wb_interrupt,
  output reg [31:0] wb_pc,
  output reg [31:0] wb_reg_rdata2,
  output reg [4:0] wb_reg_rd,
  output reg [31:0] wb_alu_o,
  output reg [31:0] wb_mem_dat_o,
  output reg wb_en,
  output reg [1:0] wb_type, // 0-ALU 1-MEM 2-PC

  output reg [11:0] wb_csr_reg,
  output reg [31:0] wb_csr_rdata,
  output reg wb_csr_en,
  
  output reg wb_int_en,
  output reg wb_mepc_we,
  output reg [31:0] wb_mepc_wdata,
  output reg wb_mcause_we,
  output reg [31:0] wb_mcause_wdata,
  output reg wb_mstatus_we,
  output reg [31:0] wb_mstatus_wdata,
  output reg wb_mip_we,
  output reg [31:0] wb_mip_wdata,
  output reg wb_mode_we,
  output reg [1:0] wb_mode_wdata,
  output reg wb_mtval_we,
  output reg [31:0] wb_mtval_wdata,
  output reg wb_sepc_we,
  output reg [31:0] wb_sepc_wdata,
  output reg wb_scause_we,
  output reg [31:0] wb_scause_wdata,
  output reg wb_sstatus_we,
  output reg [31:0] wb_sstatus_wdata,
  output reg wb_stval_we,
  output reg [31:0] wb_stval_wdata
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst | flush) begin
      wb_pc <= 32'b0;
      wb_reg_rdata2 <= 32'b0;
      wb_reg_rd <= 5'b0;
      wb_alu_o <= 32'b0;
      wb_mem_dat_o <= 32'b0;
      wb_en <= 1'b0;
      wb_type <= 2'b0;
      wb_csr_reg <= 12'b0;
      wb_csr_rdata <= 32'b0;
      wb_csr_en <= 1'b0;
      wb_int_en <= 1'b0;
      wb_mepc_we <= 1'b0;
      wb_mepc_wdata <= 32'b0;
      wb_mcause_we <= 1'b0;
      wb_mcause_wdata <= 32'b0;
      wb_mstatus_we <= 1'b0;
      wb_mstatus_wdata <= 32'b0;
      wb_mip_we <= 1'b0;
      wb_mip_wdata <= 32'b0;
      wb_mode_we <= 1'b0;
      wb_mode_wdata <= 2'b0;
      wb_mtval_we <= 1'b0;
      wb_mtval_wdata <= 32'b0;
      wb_interrupt <= 1'b0;
      wb_sepc_we <= 1'b0;
      wb_sepc_wdata <= 32'b0;
      wb_scause_we <= 1'b0;
      wb_scause_wdata <= 32'b0;
      wb_sstatus_we <= 1'b0;
      wb_sstatus_wdata <= 32'b0;
      wb_stval_we <= 1'b0;
      wb_stval_wdata <= 32'b0;
    end
    else if (!stall) begin
      if (mem_scause_wdata != 32'd13 && mem_scause_wdata != 32'd15) begin
        wb_pc <= mem_pc;
        wb_reg_rdata2 <= mem_reg_rdata2;
        wb_reg_rd <= mem_reg_rd;
        wb_alu_o <= mem_alu_o;
        wb_mem_dat_o <= mem_dat_o;
        wb_en <= mem_wb_en;
        wb_type <= mem_wb_type;
        wb_csr_reg <= mem_csr_reg;
        wb_csr_rdata <= mem_csr_rdata;
        wb_csr_en <= mem_wb_csr_en;
      end else begin
        wb_pc <= 32'b0;
        wb_reg_rdata2 <= 32'b0;
        wb_reg_rd <= 5'b0;
        wb_alu_o <= 32'b0;
        wb_mem_dat_o <= 32'b0;
        wb_en <= 1'b0;
        wb_type <= 2'b0;
        wb_csr_reg <= 12'b0;
        wb_csr_rdata <= 32'b0;
        wb_csr_en <= 1'b0;
      end
      wb_int_en <= mem_int_en;
      wb_mepc_we <= mem_mepc_we;
      wb_mepc_wdata <= mem_mepc_wdata;
      wb_mcause_we <= mem_mcause_we;
      wb_mcause_wdata <= mem_mcause_wdata;
      wb_mstatus_we <= mem_mstatus_we;
      wb_mstatus_wdata <= mem_mstatus_wdata;
      wb_mip_we <= mem_mip_we;
      wb_mip_wdata <= mem_mip_wdata;
      wb_mode_we <= mem_mode_we;
      wb_mode_wdata <= mem_mode_wdata;
      wb_mtval_we <= mem_mtval_we;
      wb_mtval_wdata <= mem_mtval_wdata;
      wb_interrupt <= mem_interrupt;
      wb_sepc_we <= mem_sepc_we;
      wb_sepc_wdata <= mem_sepc_wdata;
      wb_scause_we <= mem_scause_we;
      wb_scause_wdata <= mem_scause_wdata;
      wb_sstatus_we <= mem_sstatus_we;
      wb_sstatus_wdata <= mem_sstatus_wdata;
      wb_stval_we <= mem_stval_we;
      wb_stval_wdata <= mem_stval_wdata;
   end
  end

endmodule