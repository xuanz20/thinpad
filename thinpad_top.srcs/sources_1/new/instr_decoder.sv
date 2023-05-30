`include "utils/alu_op.vh"

module instr_decoder(
  input wire [31:0] id_instr,
  output reg [4:0] id_reg_rs1,
  output reg [4:0] id_reg_rs2,
  output reg [4:0] id_reg_rd,
  output reg [31:0] id_imm,
  output reg [4:0] id_alu_op,
  output reg id_pc_select, // 0-rs1 1-pc
  output reg id_imm_select, // 0-rs2 1-imm
  output reg id_zimm_select,
  output reg id_branch,
  output reg [2:0] id_branch_type, // 0-beq 1-bne 2-blt 3-bge 4-bltu 5-bgeu
  output reg id_jump,
  output reg id_mem_en,
  output reg id_mem_type, // 0-read 1-write
  output reg [1:0] id_mem_byte, // 0-B 1-W 2-H
  output reg id_mem_extend, // 0-signed 1-unsigned
  output reg id_wb_en,
  output reg [1:0] id_wb_type, // 0-ALU 1-MEM 2-PC
  
  output reg [11:0] id_csr_reg,
  output reg id_csr_select,
  output reg id_wb_csr_en,
  output reg id_ecall,
  output reg id_ebreak,
  output reg id_mret,
  output reg id_sret,
  output reg id_sfence
);
    
  wire sign;
  assign sign = id_instr[31];
  wire[19:0] sign_ext_20;
  assign sign_ext_20 = {20{sign}};
  wire[10:0] sign_ext_11;
  assign sign_ext_11 = {11{sign}};
  
  always_comb begin
    id_reg_rs1 = id_instr[19:15];
    id_reg_rs2 = id_instr[24:20];
    id_reg_rd = id_instr[11:7];
    id_imm = 32'h0;
    id_alu_op = `ALU_OP_ZERO;
    id_pc_select = 1'b0;
    id_imm_select = 1'b0;
    id_zimm_select = 1'b0;
    id_branch = 1'b0;
    id_branch_type = 3'b0;
    id_jump = 1'b0;
    id_mem_en = 1'b0;
    id_mem_type = 1'b0;
    id_mem_byte = 2'b0;
    id_mem_extend = 1'b0;
    id_wb_en = 1'b0;
    id_wb_type = 2'b0;
    id_csr_reg = 12'b0;
    id_csr_select = 1'b0;
    id_wb_csr_en = 1'b0;
    id_ecall = 1'b0;
    id_ebreak = 1'b0;
    id_mret = 1'b0;
    id_sret = 1'b0;
    id_sfence = 1'b0;
    case (id_instr[6:0])
        7'b0110011: begin // R
          case (id_instr[14:12])
            3'b000: 
              case (id_instr[31:25])
                7'b0000000: id_alu_op = `ALU_OP_ADD;
                7'b0100000: id_alu_op = `ALU_OP_SUB;
                default: id_alu_op = `ALU_OP_ZERO;
              endcase
            3'b111: id_alu_op = `ALU_OP_AND;
            3'b110: id_alu_op = `ALU_OP_OR;
            3'b100: begin
              case (id_instr[31:25])
                7'b0000000: id_alu_op = `ALU_OP_XOR;
                7'b0000101: id_alu_op = `ALU_OP_MIN;
                default: id_alu_op = `ALU_OP_ZERO;
              endcase
            end
            3'b001: 
              case (id_instr[31:25])
                7'b0000000: id_alu_op = `ALU_OP_SLL;
                7'b0100100: id_alu_op = `ALU_OP_SBCLR;
                default : id_alu_op = `ALU_OP_ZERO;
              endcase
            3'b011: id_alu_op = `ALU_OP_SLTU;
            3'b010: id_alu_op = `ALU_OP_SLT;
            3'b101:
              case (id_instr[31:25])
                7'b0000000: id_alu_op = `ALU_OP_SRL;
                7'b0100000: id_alu_op = `ALU_OP_SRA;
                default : id_alu_op = `ALU_OP_ZERO;
              endcase
            default: id_alu_op = `ALU_OP_ZERO;
          endcase
          id_wb_en = 1'b1;
          id_wb_type = 2'b0;
        end
        7'b0010011: begin // I
          case (id_instr[14:12])
            3'b000: begin
              id_alu_op = `ALU_OP_ADD;
              id_imm_select = 1'b1;
              id_imm = {sign_ext_20, id_instr[31:20]};
            end
            3'b111: begin
              id_alu_op = `ALU_OP_AND;
              id_imm_select = 1'b1;
              id_imm = {sign_ext_20, id_instr[31:20]};
            end
            3'b110: begin
              id_alu_op = `ALU_OP_OR;
              id_imm_select = 1'b1;
              id_imm = {sign_ext_20, id_instr[31:20]};
            end
            3'b001: begin
              case (id_instr[31:27])
                5'b00000: begin
                  id_alu_op = `ALU_OP_SLL;
                  id_imm_select = 1'b1;
                  id_imm = {27'b0, id_instr[24:20]};
                end
                5'b01100: begin
                  id_alu_op = `ALU_OP_CTZ;
                  id_imm_select = 1'b1;
                  id_imm = 32'b0;
                end
                default: id_alu_op = `ALU_OP_ZERO;
              endcase
            end
            3'b101: begin
              case (id_instr[31:25])
                7'b0000000: begin
                  id_alu_op = `ALU_OP_SRL;
                  id_imm_select = 1'b1;
                  id_imm = {27'b0, id_instr[24:20]};
                end
                7'b0100000: begin
                  id_alu_op = `ALU_OP_SRA;
                  id_imm_select = 1'b1;
                  id_imm = {27'b0, id_instr[24:20]};  
                end
                default: id_alu_op = `ALU_OP_ZERO;
              endcase
            end
            3'b010: begin
              id_alu_op = `ALU_OP_SLT;
              id_imm_select = 1'b1;
              id_imm = {sign_ext_20, id_instr[31:20]};
            end
            3'b011: begin
              id_alu_op = `ALU_OP_SLTU;
              id_imm_select = 1'b1;
              id_imm = {sign_ext_20, id_instr[31:20]};
            end
            3'b100: begin
              id_alu_op = `ALU_OP_XOR;
              id_imm_select = 1'b1;
              id_imm = {sign_ext_20, id_instr[31:20]};
            end
            default: id_alu_op = `ALU_OP_ZERO;
          endcase
          id_wb_en = 1'b1;
          id_wb_type = 2'b0;
        end
        7'b0000011: begin // L
          id_alu_op = `ALU_OP_ADD;
          id_imm_select = 1'b1;
          id_imm = {sign_ext_20, id_instr[31:20]};
          id_mem_en = 1'b1;
          id_mem_type = 1'b0;
          case (id_instr[14:12])
            3'b000: id_mem_byte = 2'd0;
            3'b010: id_mem_byte = 2'd1;
            3'b001: id_mem_byte = 2'd2;
            3'b100: begin 
              id_mem_byte = 2'd0;
              id_mem_extend = 1'b1;
            end
            3'b101: begin 
              id_mem_byte = 2'd2;
              id_mem_extend = 1'b1;
            end
            default: id_mem_byte = 2'b0;
          endcase
          id_wb_en = 1'b1;
          id_wb_type = 2'b1;
        end
        7'b0100011: begin // S
          id_alu_op = `ALU_OP_ADD;
          id_imm_select = 1'b1;
          id_imm = {sign_ext_20, id_instr[31:25], id_instr[11:7]};
          id_mem_en = 1'b1;
          id_mem_type = 1'b1;
          case (id_instr[14:12])
            3'b000: id_mem_byte = 2'b0;
            3'b010: id_mem_byte = 2'b1;
            3'b001: id_mem_byte = 2'd2;
            default: id_mem_byte = 2'b0;
          endcase
        end
        7'b1100011: begin // B
          id_alu_op = `ALU_OP_ADD;
          id_pc_select = 1'b1;
          id_imm_select = 1'b1;
          id_imm = {sign_ext_20, id_instr[7], id_instr[30:25], id_instr[11:8], 1'b0};
          id_branch = 1'b1;
          case (id_instr[14:12])
            3'b000: id_branch_type = 3'd0;
            3'b001: id_branch_type = 3'd1;
            3'b100: id_branch_type = 3'd2;
            3'b101: id_branch_type = 3'd3;
            3'b110: id_branch_type = 3'd4;
            3'b111: id_branch_type = 3'd5;
            default: id_branch_type = 3'd0;
          endcase
        end
        7'b0110111: begin // LUI
          id_reg_rs1 = 5'b00000;
          id_alu_op = `ALU_OP_ADD;
          id_imm_select = 1'b1;
          id_imm = {id_instr[31:12], 12'b0};
          id_wb_en = 1'b1;
          id_wb_type = 2'b0;
        end
        7'b1101111: begin // JAL
          id_alu_op = `ALU_OP_ADD;
          id_pc_select = 1'b1;
          id_imm_select = 1'b1;
          id_imm = {sign_ext_11, id_instr[31], id_instr[19:12], id_instr[20], id_instr[30:21], 1'b0};
          id_jump = 1'b1;
          id_wb_en = 1'b1;
          id_wb_type = 2'd2;
        end
        7'b1100111: begin // JALR
          id_alu_op = `ALU_OP_ADD;
          id_imm_select = 1'b1;
          id_imm = {sign_ext_20, id_instr[31:20]};
          id_jump = 1'b1;
          id_wb_en = 1'b1;
          id_wb_type = 2'd2;
        end
        7'b0010111: begin // AUIPC
          id_alu_op = `ALU_OP_ADD;
          id_pc_select = 1'b1;
          id_imm_select = 1'b1;
          id_imm = {id_instr[31:12], 12'b0};
          id_wb_en = 1'b1;
          id_wb_type = 2'b0;
        end
        7'b1110011: begin // CSR
          id_csr_reg = id_instr[31:20];
          case (id_instr[14:12]) 
            3'b001: begin // CSRRW
              id_alu_op = `ALU_OP_NOB;
              id_csr_select = 1'b1;
              id_wb_en = 1'b1;
              id_wb_type = 2'd3;
              id_wb_csr_en = 1'b1;
            end
            3'b010: begin //CSRRS
              id_alu_op = `ALU_OP_OR;
              id_csr_select = 1'b1;
              id_wb_en = 1'b1;
              id_wb_type = 2'd3;
              id_wb_csr_en = 1'b1;
            end
            3'b011: begin // CSRRC
              id_alu_op = `ALU_OP_NAND;
              id_csr_select = 1'b1;
              id_wb_en = 1'b1;
              id_wb_type = 2'd3;
              id_wb_csr_en = 1'b1;
            end
            3'b101: begin // CSRRWI
              id_alu_op = `ALU_OP_NOB;
              id_csr_select = 1'b1;
              id_zimm_select = 1'b1;
              id_imm = {27'b0, id_instr[19:15]};
              id_wb_en = 1'b1;
              id_wb_type = 2'd3;
              id_wb_csr_en = 1'b1;
            end
            3'b110: begin //CSRRSI
              id_alu_op = `ALU_OP_OR;
              id_csr_select = 1'b1;
              id_zimm_select = 1'b1;
              id_imm = {27'b0, id_instr[19:15]};
              id_wb_en = 1'b1;
              id_wb_type = 2'd3;
              id_wb_csr_en = 1'b1;
            end
            3'b111: begin // CSRRCI
              id_alu_op = `ALU_OP_NAND;
              id_csr_select = 1'b1;
              id_zimm_select = 1'b1;
              id_imm = {27'b0, id_instr[19:15]};
              id_wb_en = 1'b1;
              id_wb_type = 2'd3;
              id_wb_csr_en = 1'b1;
            end
            3'b000: begin
              case (id_instr[31:25])
                7'b0000000: begin
                  case (id_instr[24:20])
                    5'b00000: begin // ECALL
                      id_alu_op = `ALU_OP_ZERO;
                      id_ecall = 1'b1;
                    end
                    5'b00001: begin // EBREAK
                      id_alu_op = `ALU_OP_ZERO;
                      id_ebreak = 1'b1;
                    end
                    default: id_alu_op = `ALU_OP_ZERO;
                  endcase
                end
                7'b0011000: begin // MRET
                  id_alu_op = `ALU_OP_ZERO;
                  id_mret = 1'b1;
                end
                7'b0001000: begin // SRET
                  case (id_instr[24:20])
                    5'b00010: begin
                      id_alu_op = `ALU_OP_ZERO;
                      id_sret = 1'b1;
                    end
                    5'b00101: begin // WFI
                      id_alu_op = `ALU_OP_ZERO;
                    end
                    default: id_alu_op = `ALU_OP_ZERO;
                  endcase
                end
                7'b0001001: begin // SFENCE.VMA
                  id_alu_op = `ALU_OP_ZERO;
                  id_sfence = 1'b1;
                end
                default: id_alu_op = `ALU_OP_ZERO;
              endcase
            end
            default: id_alu_op = `ALU_OP_ZERO;
          endcase
        end
        default: id_alu_op = `ALU_OP_ZERO;
    endcase 
  end
endmodule
