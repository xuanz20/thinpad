module exe_mem_register (
  input wire clk,
  input wire rst,
  input wire stall,
  input wire flush,

  input wire exe_interrupt,
  input wire [31:0] exe_pc,
  input wire [31:0] exe_reg_rdata2,
  input wire [4:0] exe_reg_rd,
  input wire [31:0] exe_alu_o,
  input wire exe_mem_en,
  input wire exe_mem_type, // 0-read 1-write
  input wire [1:0] exe_mem_byte, // 0-B 1-W
  input wire exe_mem_extend,
  input wire [31:0] exe_mem_dat_i,
  input wire exe_wb_en,
  input wire [1:0] exe_wb_type, // 0-ALU 1-MEM 2-PC

  input wire [11:0] exe_csr_reg,
  input wire [31:0] exe_csr_rdata,
  input wire exe_wb_csr_en,
  input wire exe_sfence,
  
  input wire exe_int_en,
  input wire exe_mepc_we,
  input wire [31:0] exe_mepc_wdata,
  input wire exe_mcause_we,
  input wire [31:0] exe_mcause_wdata,
  input wire exe_mstatus_we,
  input wire [31:0] exe_mstatus_wdata,
  input wire exe_mip_we,
  input wire [31:0] exe_mip_wdata,
  input wire exe_mode_we,
  input wire [1:0] exe_mode_wdata,
  input wire exe_mtval_we,
  input wire [31:0] exe_mtval_wdata,
  input wire exe_sepc_we,
  input wire [31:0] exe_sepc_wdata,
  input wire exe_scause_we,
  input wire [31:0] exe_scause_wdata,
  input wire exe_sstatus_we,
  input wire [31:0] exe_sstatus_wdata,
  input wire exe_stval_we,
  input wire [31:0] exe_stval_wdata,

  output reg mem_interrupt,
  output reg [31:0] mem_pc,
  output reg [31:0] mem_reg_rdata2,
  output reg [4:0] mem_reg_rd,
  output reg [31:0] mem_alu_o,
  output reg mem_en,
  output reg mem_type,
  output reg [1:0] mem_byte,
  output reg mem_extend,
  output reg [31:0] mem_dat_i,
  output reg mem_wb_en,
  output reg [1:0] mem_wb_type,

  output reg [11:0] mem_csr_reg,
  output reg [31:0] mem_csr_rdata,
  output reg mem_wb_csr_en,
  output reg mem_sfence,
  
  output reg mem_int_en,
  output reg mem_mepc_we,
  output reg [31:0] mem_mepc_wdata,
  output reg mem_mcause_we,
  output reg [31:0] mem_mcause_wdata,
  output reg mem_mstatus_we,
  output reg [31:0] mem_mstatus_wdata,
  output reg mem_mip_we,
  output reg [31:0] mem_mip_wdata,
  output reg mem_mode_we,
  output reg [1:0] mem_mode_wdata,
  output reg mem_mtval_we,
  output reg [31:0] mem_mtval_wdata,
  output reg mem_sepc_we,
  output reg [31:0] mem_sepc_wdata,
  output reg mem_scause_we,
  output reg [31:0] mem_scause_wdata,
  output reg mem_sstatus_we,
  output reg [31:0] mem_sstatus_wdata,
  output reg mem_stval_we,
  output reg [31:0] mem_stval_wdata
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst | flush) begin
      mem_pc <= 32'b0;
      mem_reg_rdata2 <= 32'b0;
      mem_reg_rd <= 5'b0;
      mem_alu_o <= 32'b0;
      mem_en <= 1'b0;
      mem_type <= 1'b0;
      mem_byte <= 2'b0;
      mem_extend <= 1'b0;
      mem_dat_i <= 32'b0;
      mem_wb_en <= 1'b0;
      mem_wb_type <= 2'b0;
      mem_csr_reg <= 12'b0;
      mem_csr_rdata <= 32'b0;
      mem_wb_csr_en <= 1'b0;
      mem_int_en <= 1'b0;
      mem_mepc_we <= 1'b0;
      mem_mepc_wdata <= 32'b0;
      mem_mcause_we <= 1'b0;
      mem_mcause_wdata <= 32'b0;
      mem_mstatus_we <= 1'b0;
      mem_mstatus_wdata <= 32'b0;
      mem_mip_we <= 1'b0;
      mem_mip_wdata <= 32'b0;
      mem_mode_we <= 1'b0;
      mem_mode_wdata <= 2'b0;
      mem_mtval_we <= 1'b0;
      mem_mtval_wdata <= 32'b0;
      mem_interrupt <= 1'b0;
      mem_sfence <= 1'b0;
      mem_sepc_we <= 1'b0;
      mem_sepc_wdata <= 32'b0;
      mem_scause_we <= 1'b0;
      mem_scause_wdata <= 32'b0;
      mem_sstatus_we <= 1'b0;
      mem_sstatus_wdata <= 32'b0;
      mem_stval_we <= 1'b0;
      mem_stval_wdata <= 32'b0;
    end
    else if (!stall) begin
      mem_pc <= exe_pc;
      mem_reg_rdata2 <= exe_reg_rdata2;
      mem_reg_rd <= exe_reg_rd;
      mem_alu_o <= exe_alu_o;
      mem_en <= exe_mem_en;
      mem_type <= exe_mem_type;
      mem_byte <= exe_mem_byte;
      mem_extend <= exe_mem_extend;
      mem_dat_i <= exe_mem_dat_i;
      mem_wb_en <= exe_wb_en;
      mem_wb_type <= exe_wb_type;
      mem_csr_reg <= exe_csr_reg;
      mem_wb_csr_en <= exe_wb_csr_en;
      mem_csr_rdata <= exe_csr_rdata;
      mem_int_en <= exe_int_en;
      mem_mepc_we <= exe_mepc_we;
      mem_mepc_wdata <= exe_mepc_wdata;
      mem_mcause_we <= exe_mcause_we;
      mem_mcause_wdata <= exe_mcause_wdata;
      mem_mstatus_we <= exe_mstatus_we;
      mem_mstatus_wdata <= exe_mstatus_wdata;
      mem_mip_we <= exe_mip_we;
      mem_mip_wdata <= exe_mip_wdata;
      mem_mode_we <= exe_mode_we;
      mem_mode_wdata <= exe_mode_wdata;
      mem_mtval_we <= exe_mtval_we;
      mem_mtval_wdata <= exe_mtval_wdata;
      mem_interrupt <= exe_interrupt;
      mem_sfence <= exe_sfence;
      mem_sepc_we <= exe_sepc_we;
      mem_sepc_wdata <= exe_sepc_wdata;
      mem_scause_we <= exe_scause_we;
      mem_scause_wdata <= exe_scause_wdata;
      mem_sstatus_we <= exe_sstatus_we;
      mem_sstatus_wdata <= exe_sstatus_wdata;
      mem_stval_we <= exe_stval_we;
      mem_stval_wdata <= exe_stval_wdata;
   end
  end

endmodule