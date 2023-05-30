module sram_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32,

    parameter SRAM_ADDR_WIDTH = 20,
    parameter SRAM_DATA_WIDTH = 32,

    localparam SRAM_BYTES = SRAM_DATA_WIDTH / 8,
    localparam SRAM_BYTE_WIDTH = $clog2(SRAM_BYTES)
) (
    // clk and reset
    input wire clk_i,
    input wire rst_i,

    // wishbone slave interface
    input wire wb_cyc_i,
    input wire wb_stb_i,
    output reg wb_ack_o,
    input wire [ADDR_WIDTH-1:0] wb_adr_i,
    input wire [DATA_WIDTH-1:0] wb_dat_i,
    output reg [DATA_WIDTH-1:0] wb_dat_o,
    input wire [DATA_WIDTH/8-1:0] wb_sel_i,
    input wire wb_we_i,

    // sram interface
    output reg [SRAM_ADDR_WIDTH-1:0] sram_addr,
    inout wire [SRAM_DATA_WIDTH-1:0] sram_data,
    output reg sram_ce_n,
    output reg sram_oe_n,
    output reg sram_we_n,
    output reg [SRAM_BYTES-1:0] sram_be_n,
    output logic [31:0] sram_data_out
);
  // TODO: 实现 SRAM 控制�?????
  reg [31:0] sram_data_o;
  reg sram_data_t;
  reg [31:0] wb_mask;

  assign sram_data = sram_data_t ? 32'bz : sram_data_o;
  
  assign sram_data_out = sram_data;
  
  always_comb begin
    wb_mask = 32'b0;
    if (wb_sel_i & 4'b1000) wb_mask[31:24] = 8'b11111111;
    if (wb_sel_i & 4'b0100) wb_mask[23:16] = 8'b11111111;
    if (wb_sel_i & 4'b0010) wb_mask[15:8] = 8'b11111111;
    if (wb_sel_i & 4'b0001) wb_mask[7:0] = 8'b11111111;
  end

  typedef enum logic [1:0] {
      ST_IDLE = 0,
      ST_READ_2 = 1,
      ST_WRITE_2 = 2,
      ST_WRITE_3 = 3
  } state_t;

  state_t cur_state, nxt_state;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) 
      cur_state <= ST_IDLE;
    else 
      cur_state <= nxt_state;
  end
  
  always_comb begin
    case (cur_state)
      ST_IDLE:
        if (wb_stb_i && wb_cyc_i)
          if (wb_we_i) nxt_state = ST_WRITE_2;
          else nxt_state = ST_READ_2;
        else nxt_state = ST_IDLE;
      ST_WRITE_2: nxt_state = ST_WRITE_3;
      ST_WRITE_3: nxt_state = ST_IDLE;
      ST_READ_2: nxt_state = ST_IDLE;
      default: nxt_state = ST_IDLE;
    endcase
  end

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      wb_ack_o <= 1'b0;
      sram_data_t <= 1'b1;
    end else 
      case (cur_state)
        ST_IDLE: begin
          if (wb_stb_i && wb_cyc_i) 
            if (wb_we_i)
                sram_data_t <= 1'b0;
            else
                wb_ack_o <= 1'b1;
        end
        ST_WRITE_2: wb_ack_o <= 1'b1;
        ST_WRITE_3: begin 
            wb_ack_o <= 1'b0;
            sram_data_t <= 1'b1;
        end
        ST_READ_2: wb_ack_o <= 1'b0;
        default: ;
      endcase
  end

  always_comb begin
    sram_addr = 20'b0;
    sram_ce_n = 1'b1;
    sram_oe_n = 1'b1;
    sram_we_n = 1'b1;
    sram_be_n = 4'b1111;
    sram_data_o = 32'b0;
    wb_dat_o = 32'b0;
    if (~rst_i)
        case (cur_state)
          ST_IDLE: begin
            sram_oe_n = 1'b1;
            sram_ce_n = 1'b1;
            sram_we_n = 1'b1;
            if (wb_stb_i && wb_cyc_i)
              if (wb_we_i) begin
                sram_addr = wb_adr_i >> 2;
                sram_data_o = wb_dat_i & wb_mask;
                sram_oe_n = 1'b1;
                sram_ce_n = 1'b0;
                sram_we_n = 1'b1;
                sram_be_n = ~wb_sel_i;
              end else begin
                sram_addr = wb_adr_i >> 2;
                sram_oe_n = 1'b0;
                sram_ce_n = 1'b0;
                sram_we_n = 1'b1;
                sram_be_n = ~wb_sel_i;
              end
          end
          ST_READ_2: begin
            sram_addr = wb_adr_i >> 2;
            sram_oe_n = 1'b0;
            sram_ce_n = 1'b0;
            sram_we_n = 1'b1;
            sram_be_n = ~wb_sel_i;
            wb_dat_o = sram_data;
          end
          ST_WRITE_2: begin
            sram_addr = wb_adr_i >> 2;
            sram_data_o = wb_dat_i & wb_mask;
            sram_oe_n = 1'b1;
            sram_ce_n = 1'b0;
            sram_we_n = 1'b0;
            sram_be_n = ~wb_sel_i;
          end
          ST_WRITE_3: begin
            sram_addr = wb_adr_i >> 2;
            sram_data_o = wb_dat_i & wb_mask;
            sram_oe_n = 1'b1;
            sram_ce_n = 1'b0;
            sram_we_n = 1'b1;
            sram_be_n = ~wb_sel_i;
          end
        endcase
  end
endmodule
