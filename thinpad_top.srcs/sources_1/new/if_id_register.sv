module if_id_register (
  input wire clk,
  input wire rst,
  input wire stall,
  input wire flush,
  input wire[31:0] if_instr,
  input wire[31:0] if_pc,
  output reg[31:0] id_instr,
  output reg[31:0] id_pc
);
    
  always_ff @(posedge clk or posedge rst) begin
    if (rst || flush) begin
      id_instr <= 32'h13;
      id_pc <= 32'h0;
    end
    else if (!stall) begin 
      id_instr <= if_instr;
      id_pc <= if_pc;
    end
  end

endmodule