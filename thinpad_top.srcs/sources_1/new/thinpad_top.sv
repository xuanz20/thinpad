`default_nettype none
`include "utils/alu_op.vh"
`include "utils/csr_idx.vh"

module thinpad_top (
    input wire clk_50M,     // 50MHz 时钟输入
    input wire clk_11M0592, // 11.0592MHz 时钟输入（备用，可不用）

    input wire push_btn,  // BTN5 按钮�?????????????????关，带消抖电路，按下时为 1
    input wire reset_btn, // BTN6 复位按钮，带消抖电路，按下时�????????????????? 1

    input  wire [ 3:0] touch_btn,  // BTN1~BTN4，按钮开关，按下时为 1
    input  wire [31:0] dip_sw,     // 32 位拨码开关，拨到“ON”时�????????????????? 1
    output wire [15:0] leds,       // 16 �????????????????? LED，输出时 1 点亮
    output wire [ 7:0] dpy0,       // 数码管低位信号，包括小数点，输出 1 点亮
    output wire [ 7:0] dpy1,       // 数码管高位信号，包括小数点，输出 1 点亮

    // CPLD 串口控制器信�?????????????????
    output wire uart_rdn,        // 读串口信号，低有�?????????????????
    output wire uart_wrn,        // 写串口信号，低有�?????????????????
    input  wire uart_dataready,  // 串口数据准备�?????????????????
    input  wire uart_tbre,       // 发�?�数据标�?????????????????
    input  wire uart_tsre,       // 数据发�?�完毕标�?????????????????

    // BaseRAM 信号
    inout wire [31:0] base_ram_data,  // BaseRAM 数据，低 8 位与 CPLD 串口控制器共�?????????????????
    output wire [19:0] base_ram_addr,  // BaseRAM 地址
    output wire [3:0] base_ram_be_n,  // BaseRAM 字节使能，低有效。如果不使用字节使能，请保持�????????????????? 0
    output wire base_ram_ce_n,  // BaseRAM 片�?�，低有�?????????????????
    output wire base_ram_oe_n,  // BaseRAM 读使能，低有�?????????????????
    output wire base_ram_we_n,  // BaseRAM 写使能，低有�?????????????????

    // ExtRAM 信号
    inout wire [31:0] ext_ram_data,  // ExtRAM 数据
    (* MARK_DEBUG = "TRUE" *) output wire [19:0] ext_ram_addr,  // ExtRAM 地址
    output wire [3:0] ext_ram_be_n,  // ExtRAM 字节使能，低有效。如果不使用字节使能，请保持�????????????????? 0
    output wire ext_ram_ce_n,  // ExtRAM 片�?�，低有�?????????????????
    output wire ext_ram_oe_n,  // ExtRAM 读使能，低有�?????????????????
    output wire ext_ram_we_n,  // ExtRAM 写使能，低有�?????????????????

    // 直连串口信号
    output wire txd,  // 直连串口发�?�端
    input  wire rxd,  // 直连串口接收�?????????????????

    // Flash 存储器信号，参�?? JS28F640 芯片手册
    output wire [22:0] flash_a,  // Flash 地址，a0 仅在 8bit 模式有效�?????????????????16bit 模式无意�?????????????????
    inout wire [15:0] flash_d,  // Flash 数据
    output wire flash_rp_n,  // Flash 复位信号，低有效
    output wire flash_vpen,  // Flash 写保护信号，低电平时不能擦除、烧�?????????????????
    output wire flash_ce_n,  // Flash 片�?�信号，低有�?????????????????
    output wire flash_oe_n,  // Flash 读使能信号，低有�?????????????????
    output wire flash_we_n,  // Flash 写使能信号，低有�?????????????????
    output wire flash_byte_n, // Flash 8bit 模式选择，低有效。在使用 flash �????????????????? 16 位模式时请设�????????????????? 1

    // USB 控制器信号，参�?? SL811 芯片手册
    output wire sl811_a0,
    // inout  wire [7:0] sl811_d,     // USB 数据线与网络控制器的 dm9k_sd[7:0] 共享
    output wire sl811_wr_n,
    output wire sl811_rd_n,
    output wire sl811_cs_n,
    output wire sl811_rst_n,
    output wire sl811_dack_n,
    input  wire sl811_intrq,
    input  wire sl811_drq_n,

    // 网络控制器信号，参�?? DM9000A 芯片手册
    output wire dm9k_cmd,
    inout wire [15:0] dm9k_sd,
    output wire dm9k_iow_n,
    output wire dm9k_ior_n,
    output wire dm9k_cs_n,
    output wire dm9k_pwrst_n,
    input wire dm9k_int,

    // 图像输出信号
    output wire [2:0] video_red,    // 红色像素�?????????????????3 �?????????????????
    output wire [2:0] video_green,  // 绿色像素�?????????????????3 �?????????????????
    output wire [1:0] video_blue,   // 蓝色像素�?????????????????2 �?????????????????
    output wire       video_hsync,  // 行同步（水平同步）信�?????????????????
    output wire       video_vsync,  // 场同步（垂直同步）信�?????????????????
    output wire       video_clk,    // 像素时钟输出
    output wire       video_de      // 行数据有效信号，用于区分消隐�?????????????????
);
    
    
   (* MARK_DEBUG = "TRUE" *) logic [31:0] ext_ram_data_o;
  /* =========== Demo code begin =========== */

  // PLL 分频示例
  logic locked, clk_10M, clk_20M, clk_30M, clk_40M, clk_60M, clk_65M, clk_70M, clk_80M;
//  pll_example clock_gen (
//      // Clock in ports
//      .clk_in1(clk_50M),  // 外部时钟输入
//      // Clock out ports
//      .clk_out1(clk_10M),  // 时钟输出 1，频率在 IP 配置界面中设�?????????????????
//      .clk_out2(clk_20M),  // 时钟输出 2，频率在 IP 配置界面中设�?????????????????
//      // Status and control signals
//      .reset(reset_btn),  // PLL 复位输入
//      .locked(locked)  // PLL 锁定指示输出�?????????????????"1"表示时钟稳定�?????????????????
//                       // 后级电路复位信号应当由它生成（见下）
//  );
  
    clk_wiz_0 clk_wiz_0 (
      // Clock in ports
      .clk_in1(clk_50M),  // 外部时钟输入
      // Clock out ports
      .clk_out1(clk_20M),  // 时钟输出 1，频率在 IP 配置界面中设�?????????????????
      .clk_out2(clk_40M),
      .clk_out3(clk_60M),
      .clk_out4(clk_80M),
      // Status and control signals
      .reset(reset_btn),  // PLL 复位输入
      .locked(locked)  // PLL 锁定指示输出�?????????????????"1"表示时钟稳定�?????????????????
                       // 后级电路复位信号应当由它生成（见下）
  );

  logic sys_clk;
  logic sys_rst;
  
  logic reset_of_clk10M, reset_of_clk80M;
  // 异步复位，同步释放，�????????????????? locked 信号转为后级电路的复�????????????????? reset_of_clk10M
//  always_ff @(posedge clk_10M or negedge locked) begin
//    if (~locked) reset_of_clk10M <= 1'b1;
//    else reset_of_clk10M <= 1'b0;
//  end
  assign sys_clk = clk_60M;
  
  always_ff @(posedge sys_clk or negedge locked) begin
    if (~locked) sys_rst <= 1'b1;
    else sys_rst <= 1'b0;
  end


  

  // 不使用内存�?�串口时，禁用其使能信号
//   assign base_ram_ce_n = 1'b1;
//   assign base_ram_oe_n = 1'b1;
//   assign base_ram_we_n = 1'b1;

//   assign ext_ram_ce_n = 1'b1;
//   assign ext_ram_oe_n = 1'b1;
//   assign ext_ram_we_n = 1'b1;

   assign uart_rdn = 1'b1;
   assign uart_wrn = 1'b1;

  // 数码管连接关系示意图，dpy1 同理
  // p=dpy0[0] // ---a---
  // c=dpy0[1] // |     |
  // d=dpy0[2] // f     b
  // e=dpy0[3] // |     |
  // b=dpy0[4] // ---g---
  // a=dpy0[5] // |     |
  // f=dpy0[6] // e     c
  // g=dpy0[7] // |     |
  //           // ---d---  p

  // 7 段数码管译码器演示，�????????????????? number �????????????????? 16 进制显示在数码管上面
  logic [7:0] number;
  SEG7_LUT segL (
      .oSEG1(dpy0),
      .iDIG (number[3:0])
  );  // dpy0 是低位数码管
  SEG7_LUT segH (
      .oSEG1(dpy1),
      .iDIG (number[7:4])
  );  // dpy1 是高位数码管

  logic [15:0] led_bits;
  assign leds = led_bits;

  always_ff @(posedge push_btn or posedge reset_btn) begin
    if (reset_btn) begin  // 复位按下，设�????????????????? LED 为初始�??
      led_bits <= 16'h1;
    end else begin  // 每次按下按钮�?????????????????关，LED 循环左移
      led_bits <= {led_bits[14:0], led_bits[15]};
    end
  end
  
  /* =========== Demo code end =========== */

  (* MARK_DEBUG = "TRUE" *) logic [31:0] pc;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] pc_next;
  (* MARK_DEBUG = "TRUE" *) logic stall;

  (* MARK_DEBUG = "TRUE" *) logic interrupt;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] pc_int;

  /* =========== CSR =========== */

  logic [31:0] mtvec;
  logic [31:0] mscratch;
  logic [31:0] mepc;
  logic [31:0] mcause;
  logic [31:0] mstatus;
  logic [31:0] mie;
  logic [31:0] mip;
  logic [1:0] mode;
  logic [31:0] pmpcfg0;
  logic [31:0] pmpaddr0;
  logic [31:0] mtval;
  logic [31:0] satp;
  logic [31:0] sstatus;
  logic [31:0] sie;
  logic [31:0] stvec;
  logic [31:0] sscratch;
  logic [31:0] sepc;
  logic [31:0] scause;
  logic [31:0] stval;
  logic [31:0] sip;
  logic [31:0] mhartid;
  logic [31:0] medeleg;
  logic [31:0] mideleg;

  logic [31:0] mtime_hi;
  logic [31:0] mtime_lo;
  logic [31:0] mtimecmp_hi;
  logic [31:0] mtimecmp_lo;


  /* =========== IF register =========== */

  logic [31:0] if_instr;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] if_pc;

  logic if_int_ready;

  assign if_pc = pc;

  /* =========== ID register =========== */

  (* MARK_DEBUG = "TRUE" *) logic id_interrupt;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] id_pc;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] id_pc_jump;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] id_instr;
  (* MARK_DEBUG = "TRUE" *) logic [4:0] id_reg_rs1;
  (* MARK_DEBUG = "TRUE" *) logic [4:0] id_reg_rs2;
  logic [31:0] id_reg_rdata1_raw;
  logic [31:0] id_reg_rdata2_raw;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] id_reg_rdata1;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] id_reg_rdata2;
  (* MARK_DEBUG = "TRUE" *) logic [4:0] id_reg_rd;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] id_imm;
  logic [4:0] id_alu_op;
  (* MARK_DEBUG = "TRUE" *) logic id_pc_select; // 0-rs1 1-pc
  (* MARK_DEBUG = "TRUE" *) logic id_imm_select; // 0-rs2 1-imm
  logic id_zimm_select;
  (* MARK_DEBUG = "TRUE" *) logic id_branch;
  (* MARK_DEBUG = "TRUE" *) logic [2:0] id_branch_type; // 0-beq 1-bne
  (* MARK_DEBUG = "TRUE" *) logic id_branch_jump;
  (* MARK_DEBUG = "TRUE" *) logic id_jump;
  (* MARK_DEBUG = "TRUE" *) logic id_mem_en;
  (* MARK_DEBUG = "TRUE" *) logic id_mem_type; // 0-read 1-write
  (* MARK_DEBUG = "TRUE" *) logic [1:0] id_mem_byte; // 0-B 1-W
  logic id_mem_extend;
  (* MARK_DEBUG = "TRUE" *) logic id_wb_en;
  (* MARK_DEBUG = "TRUE" *) logic [1:0] id_wb_type; // 0-ALU 1-MEM 2-PC

  logic [11:0] id_csr_reg;
  logic [31:0] id_csr_rdata;
  logic [31:0] id_csr_rdata_raw;
  logic id_csr_select;
  logic id_wb_csr_en;
  logic id_ecall;
  logic id_ebreak;
  logic id_mret;
  logic id_sret;
  logic id_sfence;
  
  logic id_int_en;
  logic id_mepc_we;
  logic [31:0] id_mepc_wdata;
  logic id_mcause_we;
  logic [31:0] id_mcause_wdata;
  logic id_mstatus_we;
  logic [31:0] id_mstatus_wdata;
  logic id_mip_we;
  logic [31:0] id_mip_wdata;
  logic id_mode_we;
  logic [1:0] id_mode_wdata;
  logic id_mtval_we;
  logic [31:0] id_mtval_wdata;
  logic id_sepc_we;
  logic [31:0] id_sepc_wdata;
  logic id_scause_we;
  logic [31:0] id_scause_wdata;
  logic id_sstatus_we;
  logic [31:0] id_sstatus_wdata;
  logic id_stval_we;
  logic [31:0] id_stval_wdata;

  /* =========== EXE register =========== */

  logic exe_interrupt;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] exe_pc;
  logic [31:0] exe_reg_rdata1;
  logic [31:0] exe_reg_rdata2;
  logic [4:0] exe_reg_rd;
  logic [31:0] exe_imm;
  (* MARK_DEBUG = "TRUE" *) logic [4:0] exe_alu_op;
  logic exe_pc_select; // 0-rs1 1-pc
  logic exe_imm_select; // 0-rs2 1-imm
  logic exe_zimm_select;
  logic exe_branch;
  logic [2:0] exe_branch_type; // 0-beq 1-bne
  logic exe_branch_jump; // 0-false 1-true
  logic exe_jump;
  logic exe_mem_en;
  logic exe_mem_type; // 0-read 1-write
  logic [1:0] exe_mem_byte; // 0-B 1-W
  logic exe_mem_extend;
  logic exe_wb_en;
  logic [1:0] exe_wb_type; // 0-ALU 1-MEM 2-PC

  logic [11:0] exe_csr_reg;
  logic [31:0] exe_csr_rdata;
  logic exe_csr_select;
  logic exe_wb_csr_en;
  logic exe_sfence;

  logic exe_int_en;
  logic exe_mepc_we;
  logic [31:0] exe_mepc_wdata;
  logic exe_mcause_we;
  logic [31:0] exe_mcause_wdata;
  logic exe_mstatus_we;
  logic [31:0] exe_mstatus_wdata;
  logic exe_mip_we;
  logic [31:0] exe_mip_wdata;
  logic exe_mode_we;
  logic [1:0] exe_mode_wdata;
  logic exe_mtval_we;
  logic [31:0] exe_mtval_wdata;
  logic exe_sepc_we;
  logic [31:0] exe_sepc_wdata;
  logic exe_scause_we;
  logic [31:0] exe_scause_wdata;
  logic exe_sstatus_we;
  logic [31:0] exe_sstatus_wdata;
  logic exe_stval_we;
  logic [31:0] exe_stval_wdata;

  assign exe_branch_jump = exe_branch && ((exe_branch_type) ? (exe_reg_rdata1 != exe_reg_rdata2) : (exe_reg_rdata1 == exe_reg_rdata2));

  /* =========== ALU ============*/

  logic [31:0] alu_a;
  logic [31:0] alu_b;
  logic [31:0] exe_alu_o;

  assign alu_a = exe_pc_select ? exe_pc : (exe_zimm_select ? exe_imm : exe_reg_rdata1);
  assign alu_b = exe_imm_select ? exe_imm : (exe_csr_select ? exe_csr_rdata : exe_reg_rdata2);

  /* =========== MEM register =========== */
  
  (* MARK_DEBUG = "TRUE" *) logic mem_interrupt;
  logic mem_interrupt_o;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] mem_pc;
  logic [4:0] mem_reg_rd;
  logic [31:0] mem_reg_rdata2;
  logic [31:0] mem_alu_o;
  logic mem_en;
  logic mem_type; // 0-read 1-write
  logic [1:0] mem_byte; // 0-B 1-W
  logic mem_extend;
  logic [31:0] mem_dat_i;
  logic [31:0] mem_dat_o;
  logic mem_wb_en;
  logic [1:0] mem_wb_type; // 0-ALU 1-MEM 2-PC

  logic [11:0] mem_csr_reg;
  logic [31:0] mem_csr_rdata;
  logic mem_wb_csr_en;
  logic mem_sfence;

  logic mem_int_en;
  logic mem_mepc_we;
  logic [31:0] mem_mepc_wdata;
  logic mem_mcause_we;
  logic [31:0] mem_mcause_wdata;
  logic mem_mstatus_we;
  logic [31:0] mem_mstatus_wdata;
  logic mem_mip_we;
  logic [31:0] mem_mip_wdata;
  logic mem_mode_we;
  logic [1:0] mem_mode_wdata;
  logic mem_mtval_we;
  logic [31:0] mem_mtval_wdata;
  logic mem_sepc_we;
  logic [31:0] mem_sepc_wdata;
  logic mem_scause_we;
  logic [31:0] mem_scause_wdata;
  logic mem_sstatus_we;
  logic [31:0] mem_sstatus_wdata;
  logic mem_stval_we;
  logic [31:0] mem_stval_wdata;
  
  logic mem_int_en_o;
  // logic mem_mepc_we_o;
  // logic [31:0] mem_mepc_wdata_o;
  // logic mem_mcause_we_o;
  // logic [31:0] mem_mcause_wdata_o;
  // logic mem_mstatus_we_o;
  // logic [31:0] mem_mstatus_wdata_o;
  // logic mem_mip_we_o;
  // logic [31:0] mem_mip_wdata_o;
   logic mem_mode_we_o;
   logic [1:0] mem_mode_wdata_o;
  // logic mem_mtval_we_o;
  // logic [31:0] mem_mtval_wdata_o;
  logic mem_sepc_we_o;
  logic [31:0] mem_sepc_wdata_o;
  logic mem_scause_we_o;
  logic [31:0] mem_scause_wdata_o;
  logic mem_sstatus_we_o;
  logic [31:0] mem_sstatus_wdata_o;
  logic mem_stval_we_o;
  logic [31:0] mem_stval_wdata_o;

  /* =========== WB register =========== */

  logic wb_interrupt;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] wb_pc;
  logic [4:0] wb_reg_rd;
  logic [31:0] wb_reg_rdata2;
  logic [31:0] wb_alu_o;
  logic [31:0] wb_mem_dat_o;
  logic wb_en;
  logic [1:0] wb_type; // 0-ALU 1-MEM 2-PC
  logic [31:0] wb_wdata;

  logic [11:0] wb_csr_reg;
  logic [31:0] wb_csr_rdata;
  logic wb_csr_en;

  logic wb_int_en;
  logic wb_mepc_we;
  logic [31:0] wb_mepc_wdata;
  logic wb_mcause_we;
  logic [31:0] wb_mcause_wdata;
  logic wb_mstatus_we;
  logic [31:0] wb_mstatus_wdata;
  logic wb_mip_we;
  logic [31:0] wb_mip_wdata;
  logic wb_mode_we;
  logic [1:0] wb_mode_wdata;
  logic wb_mtval_we;
  logic [31:0] wb_mtval_wdata;
  logic wb_sepc_we;
  logic [31:0] wb_sepc_wdata;
  logic wb_scause_we;
  logic [31:0] wb_scause_wdata;
  logic wb_sstatus_we;
  logic [31:0] wb_sstatus_wdata;
  logic wb_stval_we;
  logic [31:0] wb_stval_wdata;

  always_comb begin
    case (wb_type)
      2'd0: wb_wdata = wb_alu_o;
      2'd1: wb_wdata = wb_mem_dat_o;
      2'd2: wb_wdata = wb_pc + 4;
      2'd3: wb_wdata = wb_csr_rdata;
      default: wb_wdata = 32'b0;
    endcase
  end


  /* =========== IF Wishbone Master =========== */

  logic [31:0] if_adr;
  logic [31:0] if_dat_o;
  logic [31:0] if_wbm_adr_o;
  logic [31:0] if_wbm_dat_i;
  logic [31:0] if_wbm_dat_o;
  logic if_wbm_we_o;
  logic [3:0] if_wbm_sel_o;
  logic if_wbm_stb_o;
  logic if_wbm_ack_i;
  logic if_wbm_cyc_o;
  logic if_ready;
  logic if_page_fault;

  /* =========== MEM Wishbone Master =========== */

  logic mem_reset;
  logic mem_we;
  logic [31:0] mem_adr;
  logic [3:0] mem_sel;
  logic [31:0] mem_wbm_adr_o;
  logic [31:0] mem_wbm_dat_i;
  logic [31:0] mem_wbm_dat_o;
  logic mem_wbm_we_o;
  logic [3:0] mem_wbm_sel_o;
  logic mem_wbm_stb_o;
  logic mem_wbm_ack_i;
  logic mem_wbm_cyc_o;
  logic mem_ready;
  logic mem_page_fault;
  
  logic id_exe_stall;
  logic id_exe_flush;
  
  logic time_interrupt_m_t;
  assign time_interrupt_m_t = ((mtime_hi == mtimecmp_hi && mtime_lo >= mtimecmp_lo) || (mtime_hi > mtimecmp_hi)) && (mode != 2'b11 || mstatus[3]) && mie[7];

  logic time_interrupt_s_t;
  assign time_interrupt_s_t = sip[5] && sie[5] && ((mode == 2'b01 && sstatus[1]) || mode == 2'b00);
  
  logic time_interrupt_s_en;
  logic time_interrupt_s_rst;
  
  always_ff @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
      time_interrupt_s_en <= 1'b0;
      time_interrupt_s_rst <= 1'b1;
    end else begin
      if (time_interrupt_s_t && time_interrupt_s_rst) begin 
        time_interrupt_s_en <= 1'b1;
        time_interrupt_s_rst <= 1'b0;
      end
      if (time_interrupt_s_en == 1'b1 && ~id_exe_stall && ~id_exe_flush) time_interrupt_s_en <= 1'b0;
      if (time_interrupt_s_t == 1'b0) time_interrupt_s_rst <= 1'b1;
    end
  end
  
  logic time_interrupt_m_en;
  logic time_interrupt_m_rst;
  
  always_ff @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst) begin
      time_interrupt_m_en <= 1'b0;
      time_interrupt_m_rst <= 1'b1;
    end else begin
      if (time_interrupt_m_t && time_interrupt_m_rst) begin 
        time_interrupt_m_en <= 1'b1;
        time_interrupt_m_rst <= 1'b0;
      end
      if (time_interrupt_m_en == 1'b1 && ~id_exe_stall && ~id_exe_flush) time_interrupt_m_en <= 1'b0;
      if (time_interrupt_m_t == 1'b0) time_interrupt_m_rst <= 1'b1;
    end
  end
  
  (* MARK_DEBUG = "TRUE" *) logic time_interrupt_s;
  assign time_interrupt_s = time_interrupt_s_en & time_interrupt_s_t;
  
  (* MARK_DEBUG = "TRUE" *) logic time_interrupt_m;
  assign time_interrupt_m = time_interrupt_m_en & time_interrupt_m_t;

  logic interrupt_end;

  (* MARK_DEBUG = "TRUE" *) assign stall = ~(if_ready && mem_ready);

  (* MARK_DEBUG = "TRUE" *) logic branch_delay;
  assign branch_delay = (~id_interrupt) && (id_jump || id_branch_jump);

  (* MARK_DEBUG = "TRUE" *) logic load_delay;
  assign load_delay = ~mem_interrupt && exe_mem_en && (~exe_mem_type) && ((exe_reg_rd == id_reg_rs1) || (~id_mret && ~id_sret && exe_reg_rd == id_reg_rs2));
  
  always_comb begin
    if (id_branch && (~load_delay)) 
      case (id_branch_type)
        3'd0: id_branch_jump = id_reg_rdata1 == id_reg_rdata2;
        3'd1: id_branch_jump = id_reg_rdata1 != id_reg_rdata2;
        3'd2: id_branch_jump = $signed(id_reg_rdata1) < $signed(id_reg_rdata2);
        3'd3: id_branch_jump = $signed(id_reg_rdata1) >= $signed(id_reg_rdata2);
        3'd4: id_branch_jump = id_reg_rdata1 < id_reg_rdata2;
        3'd5: id_branch_jump = id_reg_rdata1 >= id_reg_rdata2;
        default: id_branch_jump = 1'b0;
      endcase
    else id_branch_jump = 1'b0;
  end 
  

  assign interrupt = id_interrupt | exe_interrupt | mem_interrupt | wb_interrupt;

  assign pc_next = (sys_rst || stall || load_delay) ? pc : ((interrupt | interrupt_end) ? pc_int : ((branch_delay) ? (id_pc_jump) : pc + 4));

  always_ff @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
      pc <= 32'h80000000;
    else
      pc <= pc_next;
  end

  always_ff @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
      interrupt_end <= 1'b0;
    else
      interrupt_end <= wb_interrupt;
  end

  /* =========== IF / ID register =========== */

  logic if_id_stall;
  logic if_id_flush;

  assign if_id_stall = stall | load_delay;
  assign if_id_flush = (~stall) & (~load_delay) & (branch_delay | interrupt);

  if_id_register if_id_reg (
    .clk (sys_clk),
    .rst (sys_rst),
    .stall (if_id_stall),
    .flush (if_id_flush),
    .if_instr (if_instr),
    .if_pc (if_pc),
    .id_instr (id_instr),
    .id_pc (id_pc)
  );

  /* =========== Instruction Decoder =========== */

  instr_decoder decoder (
    .id_instr (id_instr),
    .id_reg_rs1 (id_reg_rs1),
    .id_reg_rs2 (id_reg_rs2),
    .id_reg_rd (id_reg_rd),
    .id_imm (id_imm),
    .id_alu_op (id_alu_op),
    .id_pc_select (id_pc_select),
    .id_imm_select (id_imm_select),
    .id_zimm_select (id_zimm_select),
    .id_branch (id_branch),
    .id_branch_type (id_branch_type),
    .id_jump (id_jump),
    .id_mem_en (id_mem_en),
    .id_mem_type (id_mem_type),
    .id_mem_byte (id_mem_byte),
    .id_mem_extend (id_mem_extend),
    .id_wb_en (id_wb_en),
    .id_wb_type (id_wb_type),
    .id_csr_reg (id_csr_reg),
    .id_csr_select (id_csr_select),
    .id_wb_csr_en (id_wb_csr_en),
    .id_ecall (id_ecall),
    .id_ebreak (id_ebreak),
    .id_mret (id_mret),
    .id_sret (id_sret),
    .id_sfence (id_sfence)
  );

  reg_file regfile (
    .clk (sys_clk),
    .rst (sys_rst),
    .we (wb_en),
    .waddr (wb_reg_rd),
    .wdata (wb_wdata),
    .raddr_a (id_reg_rs1),
    .rdata_a (id_reg_rdata1_raw),
    .raddr_b (id_reg_rs2),
    .rdata_b (id_reg_rdata2_raw)
  );

  csr_reg_file csr_regfile (
    .clk (sys_clk),
    .rst (sys_rst),
    .csr_raddr (id_csr_reg),
    .csr_rdata (id_csr_rdata_raw),
    .csr_we (wb_csr_en),
    .csr_waddr (wb_csr_reg),
    .csr_wdata (wb_alu_o),

    .mepc_we (wb_mepc_we),
    .mcause_we (wb_mcause_we),
    .mstatus_we (wb_mstatus_we),
    .mip_we (wb_mip_we),
    .mode_we (wb_mode_we),
    .mtval_we (wb_mtval_we),
    .sepc_we (wb_sepc_we),
    .scause_we (wb_scause_we),
    .sstatus_we (wb_sstatus_we),
    .stval_we (wb_stval_we),

    .mepc_wdata (wb_mepc_wdata),
    .mcause_wdata (wb_mcause_wdata),
    .mstatus_wdata (wb_mstatus_wdata),
    .mip_wdata (wb_mip_wdata),
    .mode_wdata (wb_mode_wdata),
    .mtval_wdata (wb_mtval_wdata),
    .sepc_wdata (wb_sepc_wdata),
    .scause_wdata (wb_scause_wdata),
    .sstatus_wdata (wb_sstatus_wdata),
    .stval_wdata (wb_stval_wdata),

    .mtvec_o (mtvec),
    .mscratch_o (mscratch),
    .mepc_o (mepc),
    .mcause_o (mcause),
    .mstatus_o (mstatus),
    .mie_o (mie),
    .mip_o (mip),
    .mode_o (mode),
    .pmpcfg0_o (pmpcfg0),
    .pmpaddr0_o (pmpaddr0),
    .mtval_o (mtval),
    .satp_o (satp),
    .sstatus_o (sstatus),
    .sie_o (sie),
    .stvec_o (stvec),
    .sscratch_o (sscratch),
    .sepc_o (sepc),
    .scause_o (scause),
    .stval_o (stval),
    .sip_o (sip),
    .mhartid_o (mhartid),
    .medeleg_o (medeleg),
    .mideleg_o (mideleg),

    .mtime_lo (mtime_lo),
    .mtime_hi (mtime_hi),
    .mtimecmp_lo (mtimecmp_lo),
    .mtimecmp_hi (mtimecmp_hi)
);
  logic [31:0] exe_wb_wdata;
  
   always_comb begin
    case (exe_wb_type)
      2'd0: exe_wb_wdata = exe_alu_o;
      2'd2: exe_wb_wdata = exe_pc + 4;
      2'd3: exe_wb_wdata = exe_csr_rdata;
      default: exe_wb_wdata = 32'b0;
    endcase
  end
  
  logic [31:0] mem_wb_wdata;

  always_comb begin
    case (mem_wb_type)
      2'd0: mem_wb_wdata = mem_alu_o;
      2'd1: mem_wb_wdata = mem_dat_o;
      2'd2: mem_wb_wdata = mem_pc + 4;
      2'd3: mem_wb_wdata = mem_csr_rdata;
      default: mem_wb_wdata = 32'b0;
    endcase
  end

  forward_unit forward (
    .id_reg_rs1 (id_reg_rs1),
    .id_reg_rs2 (id_reg_rs2),
    .id_reg_rdata1_raw (id_reg_rdata1_raw),
    .id_reg_rdata2_raw (id_reg_rdata2_raw),
    .mem_reg_rd (exe_reg_rd & {5{exe_wb_en}}),
    .wb_reg_rd (mem_reg_rd & {5{mem_wb_en}}),
    .mem_reg_data (exe_wb_wdata),
    .wb_reg_data (mem_wb_wdata),
    .id_reg_rdata1 (id_reg_rdata1),
    .id_reg_rdata2 (id_reg_rdata2),

    .id_csr_reg (id_csr_reg),
    .id_csr_rdata_raw (id_csr_rdata_raw),
    .mem_csr_reg (exe_csr_reg & {12{exe_wb_csr_en}}),
    .wb_csr_reg (mem_csr_reg & {12{mem_wb_csr_en}}),
    .mem_csr_data (exe_alu_o),
    .wb_csr_data (mem_alu_o),
    .id_csr_rdata (id_csr_rdata)
  );
  
  always_comb begin
    id_pc_jump = id_pc;
    if (id_jump)
        if (id_pc_select)
            id_pc_jump = id_pc + id_imm;
        else
            id_pc_jump = id_reg_rdata1 + id_imm;
    else if (id_branch)
        id_pc_jump = id_pc + id_imm;
  end

  /* =========== ID / EXE register =========== */



  assign id_exe_stall = stall;
  assign id_exe_flush = (~stall) & (load_delay | wb_interrupt | mem_interrupt | exe_interrupt);


  id_exe_register id_exe_reg (
    .clk                (sys_clk),
    .rst                (sys_rst),
    .stall              (id_exe_stall),
    .flush              (id_exe_flush),

    .id_interrupt (id_interrupt),
    .id_pc              (id_pc),
    .id_reg_rs1         (id_reg_rs1),
    .id_reg_rs2         (id_reg_rs2),
    .id_reg_rdata1      (id_reg_rdata1),
    .id_reg_rdata2      (id_reg_rdata2),
    .id_reg_rd          (id_reg_rd),
    .id_imm             (id_imm),
    .id_alu_op          (id_alu_op),
    .id_pc_select       (id_pc_select),
    .id_imm_select      (id_imm_select),
    .id_zimm_select      (id_zimm_select),
    .id_branch          (id_branch),
    .id_branch_type     (id_branch_type),
    .id_jump            (id_jump),
    .id_mem_en          (id_mem_en),
    .id_mem_type        (id_mem_type),
    .id_mem_byte        (id_mem_byte),
    .id_mem_extend       (id_mem_extend),
    .id_wb_en           (id_wb_en),
    .id_wb_type         (id_wb_type),
    .id_csr_reg         (id_csr_reg),
    .id_csr_rdata       (id_csr_rdata),
    .id_csr_select      (id_csr_select),
    .id_wb_csr_en       (id_wb_csr_en),
    .id_sfence       (id_sfence),
    .id_int_en          (id_int_en),
    .id_mepc_we         (id_mepc_we),
    .id_mepc_wdata      (id_mepc_wdata),
    .id_mcause_we       (id_mcause_we),
    .id_mcause_wdata    (id_mcause_wdata),
    .id_mstatus_we      (id_mstatus_we),
    .id_mstatus_wdata   (id_mstatus_wdata),
    .id_mip_we      (id_mip_we),
    .id_mip_wdata   (id_mip_wdata),
    .id_mode_we         (id_mode_we),
    .id_mode_wdata      (id_mode_wdata),
    .id_mtval_we         (id_mtval_we),
    .id_mtval_wdata      (id_mtval_wdata),
    .id_sepc_we         (id_sepc_we),
    .id_sepc_wdata      (id_sepc_wdata),
    .id_scause_we       (id_scause_we),
    .id_scause_wdata    (id_scause_wdata),
    .id_sstatus_we      (id_sstatus_we),
    .id_sstatus_wdata   (id_sstatus_wdata),
    .id_stval_we         (id_stval_we),
    .id_stval_wdata      (id_stval_wdata),

    .exe_interrupt (exe_interrupt),
    .exe_pc             (exe_pc),
    .exe_reg_rdata1     (exe_reg_rdata1),
    .exe_reg_rdata2     (exe_reg_rdata2),
    .exe_reg_rd         (exe_reg_rd),
    .exe_imm            (exe_imm),
    .exe_alu_op         (exe_alu_op),
    .exe_pc_select      (exe_pc_select),
    .exe_imm_select     (exe_imm_select),
    .exe_zimm_select     (exe_zimm_select),
    .exe_branch         (exe_branch),
    .exe_branch_type    (exe_branch_type),
    .exe_jump           (exe_jump),
    .exe_mem_en         (exe_mem_en),
    .exe_mem_type       (exe_mem_type),
    .exe_mem_byte       (exe_mem_byte),
    .exe_mem_extend      (exe_mem_extend),
    .exe_wb_en          (exe_wb_en),
    .exe_wb_type        (exe_wb_type),
    .exe_csr_reg        (exe_csr_reg),
    .exe_csr_rdata      (exe_csr_rdata),
    .exe_csr_select     (exe_csr_select),
    .exe_wb_csr_en      (exe_wb_csr_en),
    .exe_sfence       (exe_sfence),
    .exe_int_en         (exe_int_en),
    .exe_mepc_we        (exe_mepc_we),
    .exe_mepc_wdata     (exe_mepc_wdata),
    .exe_mcause_we      (exe_mcause_we),
    .exe_mcause_wdata   (exe_mcause_wdata),
    .exe_mstatus_we     (exe_mstatus_we),
    .exe_mstatus_wdata  (exe_mstatus_wdata),
    .exe_mip_we      (exe_mip_we),
    .exe_mip_wdata   (exe_mip_wdata),
    .exe_mode_we        (exe_mode_we),
    .exe_mode_wdata     (exe_mode_wdata),
    .exe_mtval_we         (exe_mtval_we),
    .exe_mtval_wdata      (exe_mtval_wdata),
    .exe_sepc_we         (exe_sepc_we),
    .exe_sepc_wdata      (exe_sepc_wdata),
    .exe_scause_we       (exe_scause_we),
    .exe_scause_wdata    (exe_scause_wdata),
    .exe_sstatus_we      (exe_sstatus_we),
    .exe_sstatus_wdata   (exe_sstatus_wdata),
    .exe_stval_we         (exe_stval_we),
    .exe_stval_wdata      (exe_stval_wdata)
  );

  /* =========== ALU ============*/

  ALU alu(
    .alu_op (exe_alu_op),
    .alu_a (alu_a),
    .alu_b (alu_b),
    .alu_y (exe_alu_o)
  );

  /* =========== EXE / MEM register =========== */
  logic exe_mem_stall;
  logic exe_mem_flush;

  assign exe_mem_stall = stall;
  assign exe_mem_flush = (~stall) & (mem_interrupt | wb_interrupt);

  exe_mem_register exe_mem_reg (
    .clk              (sys_clk),
    .rst              (sys_rst),
    .stall            (exe_mem_stall),
    .flush            (exe_mem_flush),

    .exe_interrupt (exe_interrupt),
    .exe_pc           (exe_pc),
    .exe_reg_rdata2   (exe_reg_rdata2),
    .exe_reg_rd       (exe_reg_rd),
    .exe_alu_o        (exe_alu_o),
    .exe_mem_en       (exe_mem_en),
    .exe_mem_type     (exe_mem_type),
    .exe_mem_byte     (exe_mem_byte),
    .exe_mem_extend      (exe_mem_extend),
    .exe_mem_dat_i    (exe_reg_rdata2),
    .exe_wb_en        (exe_wb_en),
    .exe_wb_type      (exe_wb_type),    
    .exe_csr_reg      (exe_csr_reg),
    .exe_csr_rdata      (exe_csr_rdata),
    .exe_wb_csr_en    (exe_wb_csr_en),
    .exe_sfence       (exe_sfence),
    .exe_int_en         (exe_int_en),
    .exe_mepc_we        (exe_mepc_we),
    .exe_mepc_wdata     (exe_mepc_wdata),
    .exe_mcause_we      (exe_mcause_we),
    .exe_mcause_wdata   (exe_mcause_wdata),
    .exe_mstatus_we     (exe_mstatus_we),
    .exe_mstatus_wdata  (exe_mstatus_wdata),
    .exe_mip_we      (exe_mip_we),
    .exe_mip_wdata   (exe_mip_wdata),
    .exe_mode_we        (exe_mode_we),
    .exe_mode_wdata     (exe_mode_wdata),
    .exe_mtval_we         (exe_mtval_we),
    .exe_mtval_wdata      (exe_mtval_wdata),
    .exe_sepc_we         (exe_sepc_we),
    .exe_sepc_wdata      (exe_sepc_wdata),
    .exe_scause_we       (exe_scause_we),
    .exe_scause_wdata    (exe_scause_wdata),
    .exe_sstatus_we      (exe_sstatus_we),
    .exe_sstatus_wdata   (exe_sstatus_wdata),
    .exe_stval_we         (exe_stval_we),
    .exe_stval_wdata      (exe_stval_wdata),

    .mem_interrupt (mem_interrupt_o),
    .mem_pc           (mem_pc),
    .mem_reg_rdata2   (mem_reg_rdata2),
    .mem_reg_rd       (mem_reg_rd),
    .mem_alu_o        (mem_alu_o),
    .mem_en           (mem_en),
    .mem_type         (mem_type),
    .mem_byte         (mem_byte),
    .mem_extend      (mem_extend),
    .mem_dat_i        (mem_dat_i),
    .mem_wb_en        (mem_wb_en),
    .mem_wb_type      (mem_wb_type),
    .mem_csr_reg      (mem_csr_reg),
    .mem_csr_rdata      (mem_csr_rdata),
    .mem_wb_csr_en    (mem_wb_csr_en),
    .mem_sfence       (mem_sfence),
    .mem_int_en         (mem_int_en_o),
    .mem_mepc_we        (mem_mepc_we),
    .mem_mepc_wdata     (mem_mepc_wdata),
    .mem_mcause_we      (mem_mcause_we),
    .mem_mcause_wdata   (mem_mcause_wdata),
    .mem_mstatus_we     (mem_mstatus_we),
    .mem_mstatus_wdata  (mem_mstatus_wdata),
    .mem_mip_we      (mem_mip_we),
    .mem_mip_wdata   (mem_mip_wdata),
    .mem_mode_we        (mem_mode_we_o),
    .mem_mode_wdata     (mem_mode_wdata_o),
    .mem_mtval_we         (mem_mtval_we),
    .mem_mtval_wdata      (mem_mtval_wdata),
    .mem_sepc_we         (mem_sepc_we_o),
    .mem_sepc_wdata      (mem_sepc_wdata_o),
    .mem_scause_we       (mem_scause_we_o),
    .mem_scause_wdata    (mem_scause_wdata_o),
    .mem_sstatus_we      (mem_sstatus_we_o),
    .mem_sstatus_wdata   (mem_sstatus_wdata_o),
    .mem_stval_we         (mem_stval_we_o),
    .mem_stval_wdata      (mem_stval_wdata_o)
  );

  /* =========== MEM / WB register =========== */
  logic mem_wb_stall;
  logic mem_wb_flush;

  assign mem_wb_stall = stall;
  assign mem_wb_flush = wb_interrupt;

  mem_wb_register mem_wb_reg (
    .clk             (sys_clk),
    .rst             (sys_rst),
    .stall           (mem_wb_stall),
    .flush           (mem_wb_flush),
    .mem_interrupt (mem_interrupt),
    .mem_pc          (mem_pc),
    .mem_reg_rdata2  (mem_reg_rdata2),
    .mem_reg_rd      (mem_reg_rd),
    .mem_alu_o       (mem_alu_o),
    .mem_dat_o       (mem_dat_o),
    .mem_wb_en       (mem_wb_en),
    .mem_wb_type     (mem_wb_type),
    .mem_csr_reg     (mem_csr_reg),
    .mem_csr_rdata      (mem_csr_rdata),
    .mem_wb_csr_en   (mem_wb_csr_en),
    .mem_int_en         (mem_int_en),
    .mem_mepc_we        (mem_mepc_we),
    .mem_mepc_wdata     (mem_mepc_wdata),
    .mem_mcause_we      (mem_mcause_we),
    .mem_mcause_wdata   (mem_mcause_wdata),
    .mem_mstatus_we     (mem_mstatus_we),
    .mem_mstatus_wdata  (mem_mstatus_wdata),
    .mem_mip_we      (mem_mip_we),
    .mem_mip_wdata   (mem_mip_wdata),
    .mem_mode_we        (mem_mode_we),
    .mem_mode_wdata     (mem_mode_wdata),    
    .mem_mtval_we         (mem_mtval_we),
    .mem_mtval_wdata      (mem_mtval_wdata),
    .mem_sepc_we         (mem_sepc_we),
    .mem_sepc_wdata      (mem_sepc_wdata),
    .mem_scause_we       (mem_scause_we),
    .mem_scause_wdata    (mem_scause_wdata),
    .mem_sstatus_we      (mem_sstatus_we),
    .mem_sstatus_wdata   (mem_sstatus_wdata),
    .mem_stval_we         (mem_stval_we),
    .mem_stval_wdata      (mem_stval_wdata),

    .wb_interrupt (wb_interrupt),
    .wb_pc           (wb_pc),
    .wb_reg_rdata2   (wb_reg_rdata2),
    .wb_reg_rd       (wb_reg_rd),
    .wb_alu_o        (wb_alu_o),
    .wb_mem_dat_o    (wb_mem_dat_o),
    .wb_en           (wb_en),
    .wb_type         (wb_type),
    .wb_csr_reg      (wb_csr_reg),
    .wb_csr_rdata      (wb_csr_rdata),
    .wb_csr_en       (wb_csr_en),
    .wb_int_en         (wb_int_en),
    .wb_mepc_we        (wb_mepc_we),
    .wb_mepc_wdata     (wb_mepc_wdata),
    .wb_mcause_we      (wb_mcause_we),
    .wb_mcause_wdata   (wb_mcause_wdata),
    .wb_mstatus_we     (wb_mstatus_we),
    .wb_mstatus_wdata  (wb_mstatus_wdata),
    .wb_mip_we      (wb_mip_we),
    .wb_mip_wdata   (wb_mip_wdata),
    .wb_mode_we        (wb_mode_we),
    .wb_mode_wdata     (wb_mode_wdata),
    .wb_mtval_we         (wb_mtval_we),
    .wb_mtval_wdata      (wb_mtval_wdata),
    .wb_sepc_we         (wb_sepc_we),
    .wb_sepc_wdata      (wb_sepc_wdata),
    .wb_scause_we       (wb_scause_we),
    .wb_scause_wdata    (wb_scause_wdata),
    .wb_sstatus_we      (wb_sstatus_we),
    .wb_sstatus_wdata   (wb_sstatus_wdata),
    .wb_stval_we         (wb_stval_we),
    .wb_stval_wdata      (wb_stval_wdata)
);


  /* =========== Wishbone Master =========== */
  
  /* =========== IF Master =========== */
  assign if_adr = pc_next;
  
  logic [1:0] if_mode;
  assign if_mode = (wb_mode_we) ? wb_mode_wdata : mode;
  
  logic [46:0] tlb1, tlb2, tlb3, tlb4;

  wb_master if_master (
    .clk_i(sys_clk),
    .rst_i(sys_rst),
    .reset(~(id_interrupt | exe_interrupt | mem_interrupt)),
    .we_i (1'b0),
    .adr_i (if_adr),
    .sel_i (4'b1111),
    .dat_i (32'b0),
    .dat_o (if_instr),
    .extend_i (1'b0),
    .wb_cyc_o(if_wbm_cyc_o),
    .wb_stb_o(if_wbm_stb_o),
    .wb_ack_i(if_wbm_ack_i),
    .wb_adr_o(if_wbm_adr_o),
    .wb_dat_o(if_wbm_dat_o),
    .wb_dat_i(if_wbm_dat_i),
    .wb_sel_o(if_wbm_sel_o),
    .wb_we_o (if_wbm_we_o),
    .ready_o(if_ready),
    .satp(satp),
    .mode(if_mode),
    .page_fault(if_page_fault),
    .reset_page_fault(mem_interrupt),
    .reset_tlb(id_sfence),
    .sum(sstatus[18])
  );

  /* =========== MEM Master =========== */
  assign mem_sel = (exe_mem_byte == 2'd1) ? (4'b1111) : (exe_mem_byte == 2'd2 ? (4'b0011) : (4'b0001));
  assign mem_reset = (~stall) & exe_mem_en;

  wb_master mem_master (
    .clk_i(sys_clk),
    .rst_i(sys_rst),
    .reset(mem_reset),
    .we_i (exe_mem_type),
    .adr_i (exe_alu_o),
    .sel_i (mem_sel),
    .dat_i (exe_reg_rdata2),
    .dat_o (mem_dat_o),
    .extend_i (exe_mem_extend),
    .wb_cyc_o(mem_wbm_cyc_o),
    .wb_stb_o(mem_wbm_stb_o),
    .wb_ack_i(mem_wbm_ack_i),
    .wb_adr_o(mem_wbm_adr_o),
    .wb_dat_o(mem_wbm_dat_o),
    .wb_dat_i(mem_wbm_dat_i),
    .wb_sel_o(mem_wbm_sel_o),
    .wb_we_o (mem_wbm_we_o),
    .ready_o(mem_ready),
    .satp(satp),
    .mode(mode),
    .page_fault(mem_page_fault),
    .reset_page_fault(mem_interrupt),
    .reset_tlb(mem_sfence),
    .sum(sstatus[18])
  );

  /* =========== Wishbone Arbiter&MUX =========== */

  logic        wbm_cyc_o;
  logic        wbm_stb_o;
  logic        wbm_ack_i;
  logic [31:0] wbm_adr_o;
  logic [31:0] wbm_dat_o;
  logic [31:0] wbm_dat_i;
  logic [ 3:0] wbm_sel_o;
  logic        wbm_we_o;


  // Wishbone MUX (Masters) => bus slaves
  logic wbs0_cyc_o;
  logic wbs0_stb_o;
  logic wbs0_ack_i;
  logic [31:0] wbs0_adr_o;
  logic [31:0] wbs0_dat_o;
  logic [31:0] wbs0_dat_i;
  logic [3:0] wbs0_sel_o;
  logic wbs0_we_o;

  (* MARK_DEBUG = "TRUE" *) logic wbs1_cyc_o;
  (* MARK_DEBUG = "TRUE" *) logic wbs1_stb_o;
  (* MARK_DEBUG = "TRUE" *) logic wbs1_ack_i;
  (* MARK_DEBUG = "TRUE" *)  logic [31:0] wbs1_adr_o;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] wbs1_dat_o;
  (* MARK_DEBUG = "TRUE" *) logic [31:0] wbs1_dat_i;
  (* MARK_DEBUG = "TRUE" *) logic [3:0] wbs1_sel_o;
  (* MARK_DEBUG = "TRUE" *) logic wbs1_we_o;

  logic wbs2_cyc_o;
  logic wbs2_stb_o;
  logic wbs2_ack_i;
  logic [31:0] wbs2_adr_o;
  logic [31:0] wbs2_dat_o;
  logic [31:0] wbs2_dat_i;
  logic [3:0] wbs2_sel_o;
  logic wbs2_we_o;

  logic wbs3_cyc_o;
  logic wbs3_stb_o;
  logic wbs3_ack_i;
  logic [31:0] wbs3_adr_o;
  logic [31:0] wbs3_dat_o;
  logic [31:0] wbs3_dat_i;
  logic [3:0] wbs3_sel_o;
  logic wbs3_we_o;

  logic [3:0] if_wbm_sel, mem_wbm_sel;
  logic [31:0] if_wbm_dat, mem_wbm_dat;

  assign if_wbm_sel = if_wbm_sel_o << (if_wbm_adr_o & 2'b11);
  assign mem_wbm_sel = mem_wbm_sel_o << (mem_wbm_adr_o & 2'b11);
  assign if_wbm_dat = if_wbm_dat_o << ((if_wbm_adr_o & 2'b11) << 3);
  assign mem_wbm_dat = mem_wbm_dat_o << ((mem_wbm_adr_o & 2'b11) << 3);

  wb_arbiter_2 wb_arbiter (
    .clk(sys_clk),
    .rst(sys_rst),
    /*
     * Wishbone master 0 input IF
     */
    .wbm0_adr_i(if_wbm_adr_o),
    .wbm0_dat_i(if_wbm_dat),
    .wbm0_dat_o(if_wbm_dat_i),
    .wbm0_we_i(if_wbm_we_o),
    .wbm0_sel_i(if_wbm_sel),
    .wbm0_stb_i(if_wbm_stb_o),
    .wbm0_ack_o(if_wbm_ack_i),
    .wbm0_err_o(),
    .wbm0_rty_o(),
    .wbm0_cyc_i(if_wbm_cyc_o),
    /*
     * Wishbone master 1 input MEM
     */
    .wbm1_adr_i(mem_wbm_adr_o),
    .wbm1_dat_i(mem_wbm_dat),
    .wbm1_dat_o(mem_wbm_dat_i),
    .wbm1_we_i(mem_wbm_we_o),
    .wbm1_sel_i(mem_wbm_sel),
    .wbm1_stb_i(mem_wbm_stb_o),
    .wbm1_ack_o(mem_wbm_ack_i),
    .wbm1_err_o(),
    .wbm1_rty_o(),
    .wbm1_cyc_i(mem_wbm_cyc_o),
    /*
     * Wishbone slave output
     */
    .wbs_adr_o(wbm_adr_o),
    .wbs_dat_i(wbm_dat_i),
    .wbs_dat_o(wbm_dat_o),
    .wbs_we_o(wbm_we_o),
    .wbs_sel_o(wbm_sel_o),
    .wbs_stb_o(wbm_stb_o),
    .wbs_ack_i(wbm_ack_i),
    .wbs_err_i(),
    .wbs_rty_i(),
    .wbs_cyc_o(wbm_cyc_o)
);


  wb_mux_4 wb_mux (
      .clk(sys_clk),
      .rst(sys_rst),

      // Master interface
      .wbm_adr_i(wbm_adr_o),
      .wbm_dat_i(wbm_dat_o),
      .wbm_dat_o(wbm_dat_i),
      .wbm_we_i (wbm_we_o),
      .wbm_sel_i(wbm_sel_o),
      .wbm_stb_i(wbm_stb_o),
      .wbm_ack_o(wbm_ack_i),
      .wbm_err_o(),
      .wbm_rty_o(),
      .wbm_cyc_i(wbm_cyc_o),

      // Slave interface 0 (to BaseRAM controller)
      // Address range: 0x8000_0000 ~ 0x803F_FFFF
      .wbs0_addr    (32'h8000_0000),
      .wbs0_addr_msk(32'hFFC0_0000),

      .wbs0_adr_o(wbs0_adr_o),
      .wbs0_dat_i(wbs0_dat_i),
      .wbs0_dat_o(wbs0_dat_o),
      .wbs0_we_o (wbs0_we_o),
      .wbs0_sel_o(wbs0_sel_o),
      .wbs0_stb_o(wbs0_stb_o),
      .wbs0_ack_i(wbs0_ack_i),
      .wbs0_err_i('0),
      .wbs0_rty_i('0),
      .wbs0_cyc_o(wbs0_cyc_o),

      // Slave interface 1 (to ExtRAM controller)
      // Address range: 0x8040_0000 ~ 0x807F_FFFF
      .wbs1_addr    (32'h8040_0000),
      .wbs1_addr_msk(32'hFFC0_0000),

      .wbs1_adr_o(wbs1_adr_o),
      .wbs1_dat_i(wbs1_dat_i),
      .wbs1_dat_o(wbs1_dat_o),
      .wbs1_we_o (wbs1_we_o),
      .wbs1_sel_o(wbs1_sel_o),
      .wbs1_stb_o(wbs1_stb_o),
      .wbs1_ack_i(wbs1_ack_i),
      .wbs1_err_i('0),
      .wbs1_rty_i('0),
      .wbs1_cyc_o(wbs1_cyc_o),

      // Slave interface 2 (to UART controller)
      // Address range: 0x1000_0000 ~ 0x1000_FFFF
      .wbs2_addr    (32'h1000_0000),
      .wbs2_addr_msk(32'hFFFF_0000),

      .wbs2_adr_o(wbs2_adr_o),
      .wbs2_dat_i(wbs2_dat_i),
      .wbs2_dat_o(wbs2_dat_o),
      .wbs2_we_o (wbs2_we_o),
      .wbs2_sel_o(wbs2_sel_o),
      .wbs2_stb_o(wbs2_stb_o),
      .wbs2_ack_i(wbs2_ack_i),
      .wbs2_err_i('0),
      .wbs2_rty_i('0),
      .wbs2_cyc_o(wbs2_cyc_o),

      // CLINT 0x0200BFF8 0x02004000
      .wbs3_addr    (32'h0200_0000),
      .wbs3_addr_msk(32'hFFFF_0000),

      .wbs3_adr_o(wbs3_adr_o),
      .wbs3_dat_i(wbs3_dat_i),
      .wbs3_dat_o(wbs3_dat_o),
      .wbs3_we_o (wbs3_we_o),
      .wbs3_sel_o(wbs3_sel_o),
      .wbs3_stb_o(wbs3_stb_o),
      .wbs3_ack_i(wbs3_ack_i),
      .wbs3_err_i('0),
      .wbs3_rty_i('0),
      .wbs3_cyc_o(wbs3_cyc_o)
  );


 /* =========== SRAM&UART Controller =========== */
  sram_controller #(
      .SRAM_ADDR_WIDTH(20),
      .SRAM_DATA_WIDTH(32)
  ) sram_controller_base (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      // Wishbone slave (to MUX)
      .wb_cyc_i(wbs0_cyc_o),
      .wb_stb_i(wbs0_stb_o),
      .wb_ack_o(wbs0_ack_i),
      .wb_adr_i(wbs0_adr_o),
      .wb_dat_i(wbs0_dat_o),
      .wb_dat_o(wbs0_dat_i),
      .wb_sel_i(wbs0_sel_o),
      .wb_we_i (wbs0_we_o),

      // To SRAM chip
      .sram_addr(base_ram_addr),
      .sram_data(base_ram_data),
      .sram_ce_n(base_ram_ce_n),
      .sram_oe_n(base_ram_oe_n),
      .sram_we_n(base_ram_we_n),
      .sram_be_n(base_ram_be_n),
      .sram_data_out()
  );


  sram_controller #(
      .SRAM_ADDR_WIDTH(20),
      .SRAM_DATA_WIDTH(32)
  ) sram_controller_ext (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      // Wishbone slave (to MUX)
      .wb_cyc_i(wbs1_cyc_o),
      .wb_stb_i(wbs1_stb_o),
      .wb_ack_o(wbs1_ack_i),
      .wb_adr_i(wbs1_adr_o),
      .wb_dat_i(wbs1_dat_o),
      .wb_dat_o(wbs1_dat_i),
      .wb_sel_i(wbs1_sel_o),
      .wb_we_i (wbs1_we_o),

      // To SRAM chip
      .sram_addr(ext_ram_addr),
      .sram_data(ext_ram_data),
      .sram_ce_n(ext_ram_ce_n),
      .sram_oe_n(ext_ram_oe_n),
      .sram_we_n(ext_ram_we_n),
      .sram_be_n(ext_ram_be_n),
      .sram_data_out(ext_ram_data_o)
  );

  // 串口控制器模�?????????????????
  // NOTE: 如果修改系统时钟频率，也�?????????????????要修改此处的时钟频率参数
  uart_controller #(
      .CLK_FREQ(60_000_000),
      .BAUD    (115200)
  ) uart_controller (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      .wb_cyc_i(wbs2_cyc_o),
      .wb_stb_i(wbs2_stb_o),
      .wb_ack_o(wbs2_ack_i),
      .wb_adr_i(wbs2_adr_o),
      .wb_dat_i(wbs2_dat_o),
      .wb_dat_o(wbs2_dat_i),
      .wb_sel_i(wbs2_sel_o),
      .wb_we_i (wbs2_we_o),

      // to UART pins
      .uart_txd_o(txd),
      .uart_rxd_i(rxd)
  );

  clint_controller clint_controller (
      .clk_i(sys_clk),
      .rst_i(sys_rst),

      // Wishbone slave (to MUX)
      .wb_cyc_i(wbs3_cyc_o),
      .wb_stb_i(wbs3_stb_o),
      .wb_ack_o(wbs3_ack_i),
      .wb_adr_i(wbs3_adr_o),
      .wb_dat_i(wbs3_dat_o),
      .wb_dat_o(wbs3_dat_i),
      .wb_sel_i(wbs3_sel_o),
      .wb_we_i (wbs3_we_o),

      .mtime_hi_o (mtime_hi),
      .mtime_lo_o (mtime_lo),
      .mtimecmp_hi_o (mtimecmp_hi),
      .mtimecmp_lo_o (mtimecmp_lo)
  );

  /* =========== Interrupt Handle =========== */

  always_ff @(posedge sys_clk or posedge sys_rst) begin
    if (sys_rst)
      pc_int <= 32'h00000000;
    else 
      if (time_interrupt_m) pc_int <= (mtvec[1:0] == 2'b00) ? {mtvec[31:2], 2'b00} : {mtvec[31:2], 2'b00} + 32'd28;
      else if (time_interrupt_s) pc_int <= (stvec[1:0] == 2'b00) ? {stvec[31:2], 2'b00} : {stvec[31:2], 2'b00} + 32'd20;
      else if (id_ebreak) pc_int <= {mtvec[31:2], 2'b00};
      else if (id_ecall && mode == 2'b00) pc_int <= {stvec[31:2], 2'b00};
      else if (id_ecall && mode == 2'b01) pc_int <= {mtvec[31:2], 2'b00};
      else if (id_mret) pc_int <= mepc;
      else if (id_sret) pc_int <= sepc;
      else if (if_page_fault) pc_int <= {stvec[31:2], 2'b00};
      else if (mem_page_fault) pc_int <= {stvec[31:2], 2'b00};
  end


  always_comb begin
    id_interrupt = 1'b0;
    id_int_en = 1'b0;
    id_mepc_we = 1'b0;
    id_mepc_wdata = 32'b0;
    id_mcause_we = 1'b0;
    id_mcause_wdata = 32'b0;
    id_mstatus_we = 1'b0;
    id_mstatus_wdata = 32'b0;
    id_mode_we = 1'b0;
    id_mode_wdata = 2'b00;
    id_mtval_we = 1'b0;
    id_mtval_wdata = 32'b0;
    id_mip_we = 1'b0;
    id_mip_wdata = 32'b0;
    id_sepc_we = 1'b0;
    id_sepc_wdata = 32'b0;
    id_scause_we = 1'b0;
    id_scause_wdata = 32'b0;
    id_sstatus_we = 1'b0;
    id_sstatus_wdata = 32'b0;
    id_stval_we = 1'b0;
    id_stval_wdata = 32'b0;

    if (~if_id_stall) begin
      if (time_interrupt_m) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_mepc_we = 1'b1;
        id_mepc_wdata = (id_jump || id_branch_jump) ? (id_pc_jump) : if_pc;
        id_mcause_we = 1'b1;
        id_mcause_wdata = {1'b1, 31'd7};
        id_mstatus_we = 1'b1;
        id_mstatus_wdata = {mstatus[31:13], mode, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        id_mode_we = 1'b1;
        id_mode_wdata = 2'b11;
      end else if (time_interrupt_s) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_sepc_we = 1'b1;
        id_sepc_wdata = (id_jump || id_branch_jump) ? (id_pc_jump) : if_pc;
        id_scause_we = 1'b1;
        id_scause_wdata = {1'b1, 31'd5};
        id_sstatus_we = 1'b1;
        id_sstatus_wdata = {sstatus[31:9], mode[0], sstatus[7:6], sstatus[1], sstatus[4:2], 1'b0, sstatus[0]};
        id_mode_we = 1'b1;
        id_mode_wdata = 2'b01;
      end else if (id_ebreak) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_mepc_we = 1'b1;
        id_mepc_wdata = id_pc;
        id_mcause_we = 1'b1;
        id_mcause_wdata = 32'd3;
        id_mstatus_we = 1'b1;
        id_mstatus_wdata = {mstatus[31:13], mode, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        id_mode_we = 1'b1;
        id_mode_wdata = 2'b11;
      end else if (id_ecall && mode == 2'b00) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_sepc_we = 1'b1;
        id_sepc_wdata = id_pc;
        id_scause_we = 1'b1;
        id_scause_wdata = 32'b1000;
        id_sstatus_we = 1'b1;
        id_sstatus_wdata = {sstatus[31:9], mode[0], sstatus[7:6], sstatus[1], sstatus[4:2], 1'b0, sstatus[0]};
        id_mode_we = 1'b1;
        id_mode_wdata = 2'b01;
      end else if (id_ecall && mode == 2'b01) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_mepc_we = 1'b1;
        id_mepc_wdata = id_pc;
        id_mcause_we = 1'b1;
        id_mcause_wdata = 32'b1001;
        id_mstatus_we = 1'b1;
        id_mstatus_wdata = {mstatus[31:13], mode, mstatus[10:8], mstatus[3], mstatus[6:4], 1'b0, mstatus[2:0]};
        id_mode_we = 1'b1;
        id_mode_wdata = 2'b11;
      end else if (id_mret) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_mstatus_we = 1'b1;
        id_mstatus_wdata = {mstatus[31:13], 2'b00, mstatus[10:8], 1'b1, mstatus[6:4], mstatus[7], mstatus[2:0]};
        id_mode_we = 1'b1;
        id_mode_wdata = mstatus[12:11];
      end else if (id_sret) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_sstatus_we = 1'b1;
        id_sstatus_wdata = {sstatus[31:9], 1'b0, sstatus[7:6], 1'b1, sstatus[4:2], sstatus[5], sstatus[0]};
        id_mode_we = 1'b1;
        id_mode_wdata = {1'b0, sstatus[8]};
      end else if (if_page_fault) begin
        id_interrupt = 1'b1;
        id_int_en = 1'b1;
        id_sepc_we = 1'b1;
        id_sepc_wdata = (id_jump || id_branch_jump) ? (id_pc_jump) : if_pc;
        id_scause_we = 1'b1;
        id_scause_wdata = 32'b1100;
        id_sstatus_we = 1'b1;
        id_sstatus_wdata = {sstatus[31:9], mode[0], sstatus[7:6], sstatus[1], sstatus[4:2], 1'b0, sstatus[0]};
        id_mode_we = 1'b1;
        id_mode_wdata = 2'b01;
        id_stval_we = 1'b1;
        id_stval_wdata = if_pc;
      end
    end
  end
  
  always_comb begin
    if (~stall && mem_page_fault) begin
      mem_interrupt = 1'b1;
      mem_int_en = 1'b1;
      mem_sepc_we = 1'b1;
      mem_sepc_wdata = mem_pc;
      mem_scause_we = 1'b1;
      mem_scause_wdata = (mem_type) ? 32'd15 : 32'd13;
      mem_sstatus_we = 1'b1;
      mem_sstatus_wdata = {sstatus[31:9], mode[0], sstatus[7:6], sstatus[1], sstatus[4:2], 1'b0, sstatus[0]};
      mem_mode_we = 1'b1;
      mem_mode_wdata = 2'b01;
      mem_stval_we = 1'b1;
      mem_stval_wdata = mem_alu_o;
    end else begin
      mem_interrupt = mem_interrupt_o;
      mem_int_en = mem_int_en_o;
      mem_sepc_we = mem_sepc_we_o;
      mem_sepc_wdata = mem_sepc_wdata_o;
      mem_scause_we = mem_scause_we_o;
      mem_scause_wdata = mem_scause_wdata_o;
      mem_sstatus_we = mem_sstatus_we_o;
      mem_sstatus_wdata = mem_sstatus_wdata_o;
      mem_mode_we = mem_mode_we_o;
      mem_mode_wdata = mem_mode_wdata_o;
      mem_stval_we = mem_stval_we_o;
      mem_stval_wdata = mem_stval_wdata_o;
    end
  end
  
//  ila_0 ila (
//    .clk(sys_clk),
//    .probe0(if_pc),
//    .probe1(pc_next),
//    .probe2(pc_int),
//    .probe3(id_pc),
//    .probe4(exe_pc),
//    .probe5(mem_pc),
//    .probe6(wb_pc),
//    .probe7(id_interrupt),
//    .probe8(stall),
//    .probe9(branch_delay),
//    .probe10(load_delay),
//    .probe11(id_pc_jump),
//    .probe12(id_instr),
//    .probe13(id_reg_rs1),
//    .probe14(id_reg_rs2),
//    .probe15(id_reg_rdata1),
//    .probe16(id_reg_rdata2),
//    .probe17(id_reg_rd),
//    .probe18(id_imm),
//    .probe19(id_pc_select),
//    .probe20(id_imm_select),
//    .probe21(id_branch),
//    .probe22(id_branch_type),
//    .probe23(id_branch_jump),
//    .probe24(id_jump),
//    .probe25(id_mem_en),
//    .probe26(id_mem_type),
//    .probe27(id_mem_byte),
//    .probe28(id_wb_en),
//    .probe29(id_wb_type),
//    .probe30(exe_alu_o),
//    .probe31(satp),
//    .probe32(sstatus),
//    .probe33(if_wbm_adr_o),
//    .probe34(mem_wbm_adr_o),
//    .probe35(if_wbm_dat_o),
//    .probe36(mem_wbm_dat_o),
//    .probe37(if_wbm_dat_i),
//    .probe38(mem_wbm_dat_i),
//    .probe39(if_page_fault),
//    .probe40(mem_page_fault),
//    .probe41(if_ready),
//    .probe42(mem_ready),
//    .probe43(sepc),
//    .probe44(scause),
//    .probe45(stval),
//    .probe46(mem_alu_o),
//    .probe47(mode),
//    .probe48(ext_ram_addr),
//    .probe49(ext_ram_data_o),
//    .probe50(mem_sstatus_we),
//    .probe51(mem_sstatus_wdata),
//    .probe52(wb_sstatus_we),
//    .probe53(wb_sstatus_wdata),
//    .probe54(time_interrupt_m),
//    .probe55(time_interrupt_s),
//    .probe56(mip),
//    .probe57(mie),
//    .probe58(mtime_hi),
//    .probe59(mtime_lo),
//    .probe60(mtimecmp_hi),
//    .probe61(mtimecmp_lo),
//    .probe62(wb_reg_rd),
//    .probe63(wb_wdata)
//  );

endmodule
