module ALU(
    input  reg  [31:0] alu_a,
    input  reg  [31:0] alu_b,
    input  reg  [4:0]  alu_op,
    output wire [31:0] alu_y
);
        
  reg [31:0] result;

  logic [15:0] ctz_temp16;
  logic [7:0] ctz_temp8;
  logic [3:0] ctz_temp4;

  logic [31:0] delta;

  assign alu_y = result;

  always_comb begin
    case (alu_op)
      5'd1: result = alu_a + alu_b;
      5'd2: result = alu_a - alu_b;
      5'd3: result = alu_a & alu_b;
      5'd4: result = alu_a | alu_b;
      5'd5: result = alu_a ^ alu_b;
      5'd6: result = ~alu_a;
      5'd7: result = alu_a << (alu_b & 5'h1F);
      5'd8: result = alu_a >> (alu_b & 5'h1F);
      5'd9: result = $signed(alu_a) >>> (alu_b & 5'h1F);
      5'd10: result = (alu_a << (alu_b & 5'h1F)) | (alu_a >> (32 - (alu_b & 5'h1F)));
      5'd11: begin
        if (alu_a & 32'h0000FFFF) begin
          ctz_temp16 = alu_a[15:0];
          result = 0;
        end else begin
          ctz_temp16 = alu_a[31:16];
          result = 16;
        end
        if (ctz_temp16 & 16'h00FF) ctz_temp8 = ctz_temp16[7:0];
        else begin
          ctz_temp8 = ctz_temp16[15:8];
          result = result + 8;
        end
        if (ctz_temp8 & 8'h0F) ctz_temp4 = ctz_temp8[3:0];
        else begin
          ctz_temp4 = ctz_temp8[7:4];
          result = result + 4;
        end
        if (ctz_temp4 & 4'b0001) result = result;
        else if (ctz_temp4 & 4'b0010) result = result + 1;
        else if (ctz_temp4 & 4'b0100) result = result + 2;
        else if (ctz_temp4 & 4'b1000) result = result + 3;
        else result = result + 4;
      end
      5'd12: result = alu_a & (~(32'b1 << (alu_b & 5'h1F)));
      5'd13: begin
        if (alu_a[31] & ~alu_b[31]) result = alu_a;
        else if (~alu_a[31] & alu_b[31]) result = alu_b;
        else begin
          delta = alu_a - alu_b;
          if (delta[31]) result = alu_a;
          else result = alu_b;
        end
      end
      5'd14: result = (alu_a  < alu_b) ? 32'b1 : 32'b0;
      5'd15: result = (~alu_a) & alu_b;
      5'd16: result = alu_a;
      5'd17: result = ($signed(alu_a)  < $signed(alu_b)) ? 32'b1 : 32'b0;
      default: result = 0;
    endcase
  end

endmodule