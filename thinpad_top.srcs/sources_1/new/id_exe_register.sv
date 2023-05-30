`include "utils/alu_op.vh"

module id_exe_register (
  input wire clk,
  input wire rst,
  input wire stall,
  input wire flush,

  input wire id_interrupt,
  input wire [31:0] id_pc,
  input wire [4:0] id_reg_rs1,
  input wire [4:0] id_reg_rs2,
  input wire [31:0] id_reg_rdata1,
  input wire [31:0] id_reg_rdata2,
  input wire [4:0] id_reg_rd,
  input wire [31:0] id_imm,
  input wire [4:0] id_alu_op,
  input wire id_pc_select, // 0-rs1 1-pc
  input wire id_imm_select, // 0-rs2 1-imm
  input wire id_zimm_select,
  input wire id_branch,
  input wire [2:0] id_branch_type, // 0-beq 1-bne
  input wire id_jump,
  input wire id_mem_en,
  input wire id_mem_type, // 0-read 1-write
  input wire [1:0] id_mem_byte, // 0-B 1-W
  input wire id_mem_extend,
  input wire id_wb_en,
  input wire [1:0] id_wb_type, // 0-ALU 1-MEM 2-PC

  input wire [11:0] id_csr_reg,
  input wire [31:0] id_csr_rdata,
  input wire id_csr_select,
  input wire id_wb_csr_en,
  input wire id_sfence,
  
  input wire id_int_en,
  input wire id_mepc_we,
  input wire [31:0] id_mepc_wdata,
  input wire id_mcause_we,
  input wire [31:0] id_mcause_wdata,
  input wire id_mstatus_we,
  input wire [31:0] id_mstatus_wdata,
  input wire id_mip_we,
  input wire [31:0] id_mip_wdata,
  input wire id_mode_we,
  input wire [1:0] id_mode_wdata,
  input wire id_mtval_we,
  input wire [31:0] id_mtval_wdata,
  input wire id_sepc_we,
  input wire [31:0] id_sepc_wdata,
  input wire id_scause_we,
  input wire [31:0] id_scause_wdata,
  input wire id_sstatus_we,
  input wire [31:0] id_sstatus_wdata,
  input wire id_stval_we,
  input wire [31:0] id_stval_wdata,

  output reg exe_interrupt,
  output reg [31:0] exe_pc,
  output reg [31:0] exe_reg_rdata1,
  output reg [31:0] exe_reg_rdata2,
  output reg [4:0] exe_reg_rd,
  output reg [31:0] exe_imm,
  output reg [4:0] exe_alu_op,
  output reg exe_pc_select, // 0-rs1 1-pc
  output reg exe_imm_select, // 0-rs2 1-imm
  output reg exe_zimm_select,
  output reg exe_branch,
  output reg [2:0] exe_branch_type, // 0-beq 1-bne
  output reg exe_jump,
  output reg exe_mem_en,
  output reg exe_mem_type, // 0-read 1-write
  output reg [1:0] exe_mem_byte, // 0-B 1-W
  output reg exe_mem_extend,
  output reg exe_wb_en,
  output reg [1:0] exe_wb_type, // 0-ALU 1-MEM 2-PC

  output reg [11:0] exe_csr_reg,
  output reg [31:0] exe_csr_rdata,
  output reg exe_csr_select,
  output reg exe_wb_csr_en,
  output reg exe_sfence,
  
  output reg exe_int_en,
  output reg exe_mepc_we,
  output reg [31:0] exe_mepc_wdata,
  output reg exe_mcause_we,
  output reg [31:0] exe_mcause_wdata,
  output reg exe_mstatus_we,
  output reg [31:0] exe_mstatus_wdata,
  output reg exe_mip_we,
  output reg [31:0] exe_mip_wdata,
  output reg exe_mode_we,
  output reg [1:0] exe_mode_wdata,
  output reg exe_mtval_we,
  output reg [31:0] exe_mtval_wdata,
  output reg exe_sepc_we,
  output reg [31:0] exe_sepc_wdata,
  output reg exe_scause_we,
  output reg [31:0] exe_scause_wdata,
  output reg exe_sstatus_we,
  output reg [31:0] exe_sstatus_wdata,
  output reg exe_stval_we,
  output reg [31:0] exe_stval_wdata
);

  always_ff @(posedge clk or posedge rst) begin
    if (rst | flush) begin
      exe_pc <= 32'b0;
      exe_reg_rdata1 <= 32'b0;
      exe_reg_rdata2 <= 32'b0;
      exe_reg_rd <= 5'b0;
      exe_imm <= 32'b0;
      exe_alu_op <= `ALU_OP_ADD;
      exe_pc_select <= 1'b0;
      exe_imm_select <= 1'b0;
      exe_zimm_select <= 1'b0;
      exe_branch <= 1'b0;
      exe_branch_type <= 3'b0;
      exe_jump <= 1'b0;
      exe_mem_en <= 1'b0;
      exe_mem_type <= 1'b0;
      exe_mem_byte <= 2'b0;
      exe_mem_extend <= 1'b0;
      exe_wb_en <= 1'b0;
      exe_wb_type <= 2'b0;
      exe_csr_reg <= 12'b0;
      exe_csr_rdata <= 32'b0;
      exe_csr_select <= 1'b0;
      exe_wb_csr_en <= 1'b0;
      exe_int_en <= 1'b0;
      exe_mepc_we <= 1'b0;
      exe_mepc_wdata <= 32'b0;
      exe_mcause_we <= 1'b0;
      exe_mcause_wdata <= 32'b0;
      exe_mstatus_we <= 1'b0;
      exe_mstatus_wdata <= 32'b0;
      exe_mip_we <= 1'b0;
      exe_mip_wdata <= 32'b0;
      exe_mode_we <= 1'b0;
      exe_mode_wdata <= 2'b0;
      exe_mtval_we <= 1'b0;
      exe_mtval_wdata <= 32'b0;
      exe_interrupt <= 1'b0;
      exe_sfence <= 1'b0;
      exe_sepc_we <= 1'b0;
      exe_sepc_wdata <= 32'b0;
      exe_scause_we <= 1'b0;
      exe_scause_wdata <= 32'b0;
      exe_sstatus_we <= 1'b0;
      exe_sstatus_wdata <= 32'b0;
      exe_stval_we <= 1'b0;
      exe_stval_wdata <= 32'b0;
    end
    else if (!stall) begin
        exe_pc <= id_pc;
        exe_reg_rdata1 <= id_reg_rdata1;
        exe_reg_rdata2 <= id_reg_rdata2;
        exe_reg_rd <= id_reg_rd;
        exe_imm <= id_imm;
        exe_alu_op <= id_alu_op;
        exe_pc_select <= id_pc_select;
        exe_imm_select <= id_imm_select;
        exe_zimm_select <= id_zimm_select;
        exe_branch <= id_branch;
        exe_branch_type <= id_branch_type;
        exe_jump <= id_jump;
        exe_mem_en <= id_mem_en;
        exe_mem_type <= id_mem_type;
        exe_mem_byte <= id_mem_byte;
        exe_mem_extend <= id_mem_extend;
        exe_wb_en <= id_wb_en;
        exe_wb_type <= id_wb_type;
        exe_csr_reg <= id_csr_reg;
        exe_csr_rdata <= id_csr_rdata;
        exe_csr_select <= id_csr_select;
        exe_wb_csr_en <= id_wb_csr_en;
        exe_sfence <= id_sfence;
    
      exe_int_en <= id_int_en;
      exe_mepc_we <= id_mepc_we;
      exe_mepc_wdata <= id_mepc_wdata;
      exe_mcause_we <= id_mcause_we;
      exe_mcause_wdata <= id_mcause_wdata;
      exe_mstatus_we <= id_mstatus_we;
      exe_mstatus_wdata <= id_mstatus_wdata;
      exe_mip_we <= id_mip_we;
      exe_mip_wdata <= id_mip_wdata;
      exe_mode_we <= id_mode_we;
      exe_mode_wdata <= id_mode_wdata;
      exe_mtval_we <= id_mtval_we;
      exe_mtval_wdata <= id_mtval_wdata;
      exe_interrupt <= id_interrupt;
      exe_sepc_we <= id_sepc_we;
      exe_sepc_wdata <= id_sepc_wdata;
      exe_scause_we <= id_scause_we;
      exe_scause_wdata <= id_scause_wdata;
      exe_sstatus_we <= id_sstatus_we;
      exe_sstatus_wdata <= id_sstatus_wdata;
      exe_stval_we <= id_stval_we;
      exe_stval_wdata <= id_stval_wdata;
   end
  end

endmodule