module wb_master #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
) (
    input wire clk_i,
    input wire rst_i,
    input wire reset,
    input wire we_i,
    input wire [ADDR_WIDTH-1:0] adr_i,
    input wire [DATA_WIDTH/8-1:0] sel_i,
    input wire [DATA_WIDTH-1:0] dat_i,
    output reg [DATA_WIDTH-1:0] dat_o,
    input wire extend_i,

    // wishbone master
    output reg wb_cyc_o,
    output reg wb_stb_o,
    input wire wb_ack_i,
    output reg [ADDR_WIDTH-1:0] wb_adr_o,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH/8-1:0] wb_sel_o,
    output reg wb_we_o,
    output reg ready_o,
    
    input wire [31:0] satp,
    input wire [1:0] mode,
    output reg page_fault,
    input wire reset_page_fault,
    input wire reset_tlb,
    input wire sum
);


  typedef enum logic [2:0] {
    IDLE,
    ACTION,
    PAGE_1_ACTION,
    PAGE_2_IDLE,
    PAGE_2_ACTION,
    PAGE_3_IDLE
  } state_t;

  logic [31:0] tmp_dat_o;
  assign tmp_dat_o = wb_dat_i >> ((wb_adr_o % 32'd4) << 3);

  logic page_en;
  assign page_en = satp[31] && (mode != 2'b11);

  logic va_valid;
  assign va_valid = 1'b1;

  logic [31:0] ppn;
  assign ppn = satp[21:0] << 12;

  logic [33:0] nxt_adr;
  
  state_t cur_state, nxt_state;

  logic tmp_we;
  logic [31:0] tmp_adr;
  logic [3:0] tmp_sel;
  logic [31:0] tmp_dat;
  logic tmp_extend;

  logic [46:0] tlb1;
  logic [46:0] tlb2;
  logic [46:0] tlb3;
  logic [46:0] tlb4;


  logic [31:0] tlb1_adr;
  assign tlb1_adr = (tlb1[22:1] << 12) + adr_i[11:0];

  logic [31:0] tlb2_adr;
  assign tlb2_adr = (tlb2[22:1] << 12) + adr_i[11:0];

  logic [31:0] tlb3_adr;
  assign tlb3_adr = (tlb3[22:1] << 12) + adr_i[11:0];

  logic [31:0] tlb4_adr;
  assign tlb4_adr = (tlb4[22:1] << 12) + adr_i[11:0];

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      ready_o <= ~reset;
      dat_o <= 32'b0;
      wb_stb_o <= 1'b0;
      wb_cyc_o <= 1'b0;
      page_fault <= 1'b0;
      wb_we_o <= 1'b0;
      wb_adr_o <= 32'b0;
      wb_sel_o <= 4'b0;
      wb_dat_o <= 32'b0;
      cur_state <= IDLE;
      cur_state <= IDLE;
      tlb1 <= 46'b0;
      tlb2 <= 46'b0; 
      tlb3 <= 46'b0; 
      tlb4 <= 46'b0; 
    end else begin
      case (cur_state)
        IDLE: begin
          if (reset_tlb) begin
            tlb1 <= 46'b0;
            tlb2 <= 46'b0; 
            tlb3 <= 46'b0; 
            tlb4 <= 46'b0; 
          end
          if (reset_page_fault) page_fault <= 1'b0;
          if (reset) begin
            ready_o <= 1'b0;
            wb_stb_o <= 1'b1;
            wb_cyc_o <= 1'b1;
            page_fault <= 1'b0;
            tmp_we <= we_i;
            tmp_adr <= adr_i;
            tmp_dat <= dat_i;
            tmp_sel <= sel_i;
            tmp_extend <= extend_i;
            if (~page_en) begin
              wb_we_o <= we_i;
              wb_adr_o <= adr_i;
              wb_sel_o <= sel_i;
              wb_dat_o <= dat_i;
              cur_state <= ACTION;
            end else begin
              if (~va_valid) begin 
                page_fault <= 1'b1;
                ready_o <= 1'b1;
                cur_state <= IDLE;
              end else begin
                tlb1[46:43] <= {tlb1[45:43], 1'b0};
                tlb2[46:43] <= {tlb2[45:43], 1'b0};
                tlb3[46:43] <= {tlb3[45:43], 1'b0};
                tlb4[46:43] <= {tlb4[45:43], 1'b0};
                if (tlb1[0] && adr_i[31:12] == tlb1[42:23]) begin
                  wb_adr_o <= tlb1_adr;
                  wb_we_o <= we_i;
                  wb_sel_o <= sel_i;
                  wb_dat_o <= dat_i;
                  tlb1[43] <= 1'b1;
                  cur_state <= ACTION;
                end else if (tlb2[0] && adr_i[31:12] == tlb2[42:23]) begin
                  wb_adr_o <= tlb2_adr;
                  wb_we_o <= we_i;
                  wb_sel_o <= sel_i;
                  wb_dat_o <= dat_i;
                  tlb2[43] <= 1'b1;
                  cur_state <= ACTION;
                end else if (tlb3[0] && adr_i[31:12] == tlb3[42:23]) begin
                  wb_adr_o <= tlb3_adr;
                  wb_we_o <= we_i;
                  wb_sel_o <= sel_i;
                  wb_dat_o <= dat_i;
                  tlb3[43] <= 1'b1;
                  cur_state <= ACTION;
                end else if (tlb4[0] && adr_i[31:12] == tlb4[42:23]) begin
                  wb_adr_o <= tlb4_adr;
                  wb_we_o <= we_i;
                  wb_sel_o <= sel_i;
                  wb_dat_o <= dat_i;
                  tlb4[43] <= 1'b1;
                  cur_state <= ACTION;
                end else begin
                    wb_adr_o <= (adr_i[31:22] << 2) + ppn;
                    wb_sel_o <= 4'b1111;
                    wb_we_o <= 1'b0;
                    cur_state <= PAGE_1_ACTION;
                end
              end
            end
          end
        end
        ACTION:
          if (wb_ack_i) begin 
            wb_stb_o <= 1'b0;
            wb_cyc_o <= 1'b0;
            wb_we_o <= 1'b0;
            if (~wb_we_o) begin
                if (wb_sel_o == 4'b0001)
                    dat_o <= {{24{tmp_extend ? 1'b0 : tmp_dat_o[7]}}, tmp_dat_o[7:0]};
                else if (wb_sel_o== 4'b0011)
                    dat_o <= {{16{tmp_extend ? 1'b0 : tmp_dat_o[15]}}, tmp_dat_o[15:0]};
                else
                    dat_o <= tmp_dat_o;
            end
            ready_o <= 1'b1;
            cur_state <= IDLE;
          end
        PAGE_1_ACTION: begin
          if (wb_ack_i) begin
            wb_stb_o <= 1'b0;
            wb_cyc_o <= 1'b0;
            wb_we_o <= 1'b0;
            if (~wb_dat_i[0] || (~wb_dat_i[1] && wb_dat_i[2])) begin
              page_fault <= 1'b1;
              ready_o <= 1'b1;
              cur_state <= IDLE;
            end else
            if (wb_dat_i[1] || wb_dat_i[3]) begin
              if (wb_dat_i[19:10] != 10'b0 || (tmp_we && ~wb_dat_i[2]) || (~wb_dat_i[4] && mode == 2'b00) || (wb_dat_i[4] && ~sum && mode == 2'b01)) begin
                page_fault <= 1'b1;
                ready_o <= 1'b1;
                cur_state <= IDLE;
              end else begin
                nxt_adr <= {wb_dat_i[31:20], tmp_adr[21:12], tmp_adr[11:0]};
                cur_state <= PAGE_3_IDLE;
              end
            end else begin
              nxt_adr <= (wb_dat_i[31:10] << 12) + (tmp_adr[21:12] << 2);
              cur_state <= PAGE_2_IDLE;
            end
          end
        end
        PAGE_2_IDLE: begin
          wb_stb_o <= 1'b1;
          wb_cyc_o <= 1'b1;
          wb_adr_o <= nxt_adr;
          wb_sel_o <= 4'b1111;
          wb_we_o <= 1'b0;
          cur_state <= PAGE_2_ACTION;
        end
        PAGE_2_ACTION: begin
          if (wb_ack_i) begin
            wb_stb_o <= 1'b0;
            wb_cyc_o <= 1'b0;
            wb_we_o <= 1'b0;
            if (~wb_dat_i[0] || (~wb_dat_i[1] && wb_dat_i[2])) begin
              page_fault <= 1'b1;
              ready_o <= 1'b1;
              cur_state <= IDLE;
            end
            else if (wb_dat_i[1] || wb_dat_i[3]) begin
              if ((tmp_we && ~wb_dat_i[2]) || (~wb_dat_i[4] && mode == 2'b00) || (wb_dat_i[4] && ~sum && mode == 2'b01)) begin
                page_fault <= 1'b1;
                ready_o <= 1'b1;
                cur_state <= IDLE;
              end else begin
                nxt_adr <= {wb_dat_i[31:10], tmp_adr[11:0]};
                cur_state <= PAGE_3_IDLE;
              end
            end else begin
              page_fault <= 1'b1;
              ready_o <= 1'b1;
              cur_state <= IDLE;
            end
          end
        end
        PAGE_3_IDLE: begin
          wb_stb_o <= 1'b1;
          wb_cyc_o <= 1'b1;
          wb_we_o <= tmp_we;
          wb_adr_o <= nxt_adr;
          wb_sel_o <= tmp_sel;
          if (tlb1[0] == 0 || tlb1[46:43] == 4'b0) 
            tlb1 <= {4'b0001, tmp_adr[31:12], nxt_adr[33:12], 1'b1};
          else if (tlb2[0] == 0 || tlb2[46:43] == 4'b0)
            tlb2 <= {4'b0001, tmp_adr[31:12], nxt_adr[33:12], 1'b1};
          else if (tlb3[0] == 0 || tlb3[46:43] == 4'b0)
            tlb3 <= {4'b0001, tmp_adr[31:12], nxt_adr[33:12], 1'b1};
          else if (tlb4[0] == 0 || tlb4[46:43] == 4'b0)
            tlb4 <= {4'b0001, tmp_adr[31:12], nxt_adr[33:12], 1'b1};
          if (tmp_we) wb_dat_o <= tmp_dat;
          cur_state <= ACTION;
        end
        default: ;
      endcase
    end
  end

endmodule
