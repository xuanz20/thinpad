module reg_file (
    input  wire        clk,
    input  wire        rst,
    input  wire        we,
    input  wire [4:0]  waddr,
    input  wire [31:0] wdata,
    input  wire [4:0]  raddr_a,
    output reg  [31:0] rdata_a,
    input  wire [4:0]  raddr_b,
    output reg  [31:0] rdata_b
);
    
  reg [31:0] registers [0:31];

  always @(posedge clk or posedge rst) begin
    if (rst) begin
      registers <= '{default: 32'b0};
    end
    else if (we && waddr != 5'b0) begin
      registers[waddr] <= wdata;
    end
  end

  always_comb begin
    case (raddr_a)
        5'b0: rdata_a = 32'b0;
        waddr: rdata_a =  we ? wdata : registers[raddr_a];
        default: rdata_a = registers[raddr_a];
    endcase
  end

  always_comb begin
    case (raddr_b)
        5'b0: rdata_b = 32'b0;
        waddr: rdata_b = we ? wdata : registers[raddr_b];
        default: rdata_b = registers[raddr_b];
    endcase
  end

endmodule