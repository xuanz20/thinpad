`include "utils/csr_idx.vh"

module csr_reg_file (
    input wire clk,
    input wire rst,
    
    input wire [11:0] csr_raddr,
    output reg [31:0] csr_rdata,

    input wire csr_we,
    input wire [11:0] csr_waddr,
    input wire [31:0] csr_wdata,

    input wire mepc_we,
    input wire mcause_we,
    input wire mstatus_we,
    input wire mip_we,
    input wire mode_we,
    input wire mtval_we,
    input wire sepc_we,
    input wire scause_we,
    input wire sstatus_we,
    input wire stval_we,

    input wire [31:0] mepc_wdata,
    input wire [31:0] mcause_wdata,
    input wire [31:0] mstatus_wdata,
    input wire [31:0] mip_wdata,
    input wire [1:0] mode_wdata,
    input wire [31:0] mtval_wdata,
    input wire [31:0] sepc_wdata,
    input wire [31:0] scause_wdata,
    input wire [31:0] sstatus_wdata,
    input wire [31:0] stval_wdata,

    output reg [31:0] mtvec_o,
    output reg [31:0] mscratch_o,
    output reg [31:0] mepc_o,
    output reg [31:0] mcause_o,
    output reg [31:0] mstatus_o,
    output reg [31:0] mie_o,
    output reg [31:0] mip_o,
    output reg [1:0] mode_o,
    output reg [31:0] mtval_o,
    output reg [31:0] satp_o,
    output reg [31:0] pmpcfg0_o,
    output reg [31:0] pmpaddr0_o,
    output reg [31:0] sstatus_o,
    output reg [31:0] sie_o,
    output reg [31:0] stvec_o,
    output reg [31:0] sscratch_o,
    output reg [31:0] sepc_o,
    output reg [31:0] scause_o,
    output reg [31:0] stval_o,
    output reg [31:0] sip_o,
    output reg [31:0] mhartid_o,
    output reg [31:0] medeleg_o,
    output reg [31:0] mideleg_o,

    input wire [31:0] mtime_lo,
    input wire [31:0] mtime_hi,
    input wire [31:0] mtimecmp_lo,
    input wire [31:0] mtimecmp_hi
);
    
  logic [31:0] mtvec;
  logic [31:0] mscratch;
  logic [31:0] mepc;
  logic [31:0] mcause;
  logic [31:0] mstatus;
  logic [31:0] mie;
  logic [31:0] mip;
  logic [1:0] mode;
  logic [31:0] mtval;
  logic [31:0] satp;
  logic [31:0] pmpcfg0;
  logic [31:0] pmpaddr0;
  logic [31:0] stvec;
  logic [31:0] sscratch;
  logic [31:0] sepc;
  logic [31:0] scause;
  logic [31:0] stval;
  logic [31:0] mhartid;
  logic [31:0] medeleg;
  logic [31:0] mideleg;
  
  logic mtip;
  assign mtip = ((mtime_hi == mtimecmp_hi && mtime_lo >= mtimecmp_lo) || (mtime_hi > mtimecmp_hi));

  always_comb begin
    mtvec_o = mtvec;
    mscratch_o = mscratch;
    mepc_o = mepc;
    mcause_o = mcause;
    mstatus_o = mstatus;
    mie_o = mie;
    mip_o = mip;
    mode_o = mode;
    mtval_o = mtval;
    satp_o = satp;
    pmpcfg0_o = pmpcfg0;
    pmpaddr0_o = pmpaddr0;
    sstatus_o = mstatus;
    sie_o = mie;
    stvec_o = stvec;
    sscratch_o = sscratch;
    sepc_o = sepc;
    scause_o = scause;
    stval_o = stval;
    sip_o = mip;
    mhartid_o = mhartid;
    medeleg_o = medeleg;
    mideleg_o = mideleg;
  end

  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin 
      mtvec <= 32'b0;
      mscratch <= 32'b0;
      mepc <= 32'b0;
      mcause <= 32'b0;
      mstatus <= 32'b0;
      mie <= 32'b0;
      mip <= 32'b0;
      mode <= 2'b11;
      mtval <= 32'b0;
      satp <= 32'b0;
      pmpcfg0 <= 32'b0;
      pmpaddr0 <= 32'b0;
      stvec <= 32'b0;
      sscratch <= 32'b0;
      sepc <= 32'b0;
      scause <= 32'b0;
      stval <= 32'b0;
      mhartid <= 32'b0;
      medeleg <= 32'b0;
      mideleg <= 32'b0;
    end
    else begin
      if (mepc_we) mepc <= mepc_wdata;
      if (mcause_we) mcause <= mcause_wdata;
      if (mstatus_we) mstatus <= mstatus_wdata;
      if (mode_we) mode <= mode_wdata;
      if (mtval_we) mtval <= mtval_wdata;
      if (sepc_we) sepc <= sepc_wdata;
      if (scause_we) scause <= scause_wdata;
      if (sstatus_we) mstatus <= sstatus_wdata;
      if (stval_we) stval <= stval_wdata;
      if (csr_we) begin
        case (csr_waddr) 
          `MSTATUS: if (!mstatus_we) mstatus <= csr_wdata;
          `MIE: mie <= csr_wdata;
          `MTVEC: mtvec <= csr_wdata;
          `MSCRATCH: mscratch <= csr_wdata;
          `MEPC: if (!mepc_we) mepc <= csr_wdata;
          `MCAUSE: if (!mcause_we) mcause <= csr_wdata;
          `MIP: mip <= {csr_wdata[31:8], mtip, csr_wdata[6:0]};
          `MTVAL: if (!mtval_we) mtval <= csr_wdata;
          `SATP: satp <= csr_wdata;
          `pmpcfg0: pmpcfg0 <= csr_wdata;
          `pmpaddr0: pmpaddr0 <= csr_wdata;
          `SSTATUS: if (!sstatus_we) mstatus <= csr_wdata;
          `SEPC: if (!sepc_we) sepc <= csr_wdata;
          `SCAUSE: if (!scause_we) scause <= csr_wdata;
          `STVAL: if (!stval_we) stval <= csr_wdata;
          `SIE: mie <= csr_wdata;
          `STVEC: stvec <= csr_wdata;
          `SSCRATCH: sscratch <= csr_wdata;
          `SIP: mip <= {csr_wdata[31:8], mtip, csr_wdata[6:0]};
          `MHARTID: mhartid <= csr_wdata;
          `MEDELEG: medeleg <= csr_wdata;
          `MIDELEG: mideleg <= csr_wdata;
          default: ;
        endcase
      end
      mip[7] <= mtip;
    end
  end

  always_comb begin
    case (csr_raddr)
      `MSTATUS: csr_rdata = mstatus;
      `MIE: csr_rdata = mie;
      `MTVEC: csr_rdata = mtvec;
      `MSCRATCH: csr_rdata = mscratch;
      `MEPC: csr_rdata = mepc;
      `MCAUSE: csr_rdata = mcause;
      `MIP: csr_rdata = mip;
      `MTVAL: csr_rdata = mtval;
      `SATP: csr_rdata = satp;
      `pmpcfg0: csr_rdata = pmpcfg0;
      `pmpaddr0: csr_rdata = pmpaddr0;
      `MTIME: csr_rdata = mtime_lo;
      `MTIMEH: csr_rdata = mtime_hi;
      `SSTATUS: csr_rdata = mstatus;
      `SEPC: csr_rdata = sepc;
      `SCAUSE: csr_rdata = scause;
      `STVAL: csr_rdata = stval;
      `SIE: csr_rdata = mie;
      `STVEC: csr_rdata = stvec;
      `SSCRATCH: csr_rdata = sscratch;
      `SIP: csr_rdata = mip;
      `MHARTID: csr_rdata = mhartid;
      `MEDELEG: csr_rdata = medeleg;
      `MIDELEG: csr_rdata = mideleg;
      default: csr_rdata = 32'b0;
    endcase
  end


endmodule