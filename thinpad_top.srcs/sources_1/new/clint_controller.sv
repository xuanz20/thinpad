module clint_controller #(
    parameter DATA_WIDTH = 32,
    parameter ADDR_WIDTH = 32
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

    output reg [31:0] mtime_hi_o,
    output reg [31:0] mtime_lo_o,
    output reg [31:0] mtimecmp_hi_o,
    output reg [31:0] mtimecmp_lo_o
);

  reg [31:0] mtime_hi;
  reg [31:0] mtime_lo;
  reg [31:0] mtimecmp_hi;
  reg [31:0] mtimecmp_lo;

  logic [31:0] count;

  assign mtime_hi_o = mtime_hi;
  assign mtime_lo_o = mtime_lo;
  assign mtimecmp_hi_o = mtimecmp_hi;
  assign mtimecmp_lo_o = mtimecmp_lo;

  always_ff @(posedge clk_i or posedge rst_i) begin
    if (rst_i) begin
      wb_ack_o <= 1'b0;
      wb_dat_o <= 32'b0;
      mtime_lo <= 32'b0;
      mtime_hi <= 32'b0;
      mtimecmp_lo <= 32'b0;
      mtimecmp_hi <= 32'b0;
      count <= 32'd0;
    end else begin
      if (count == 32'd5) begin
        if (mtime_lo == 32'hffffffff) begin 
          mtime_lo <= 0;
          mtime_hi <= mtime_hi + 1;
        end else mtime_lo <= mtime_lo + 1;
        count <= 32'd0;
      end else count <= count + 1;
      wb_ack_o <= 1'b0;
      if (wb_stb_i && wb_cyc_i) begin
        if (wb_adr_i == 32'h200BFF8) begin
          if (wb_we_i) mtime_lo <= wb_dat_i;
          else wb_dat_o <= mtime_lo;
        end else if (wb_adr_i == 32'h200BFFC) begin
          if (wb_we_i) mtime_hi <= wb_dat_i;
          else wb_dat_o <= mtime_hi;
        end else if (wb_adr_i == 32'h2004000) begin
          if (wb_we_i) mtimecmp_lo <= wb_dat_i;
          else wb_dat_o <= mtimecmp_lo;
        end else if (wb_adr_i == 32'h2004004) begin
          if (wb_we_i) mtimecmp_hi <= wb_dat_i;
          else wb_dat_o <= mtimecmp_hi;
        end
        wb_ack_o <= 1'b1;
       end
     end
  end

endmodule
