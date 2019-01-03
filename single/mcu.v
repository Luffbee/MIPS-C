module MCU(
  Jump, JumpType, MemRd, MemWr, RegDst, RegSrc, RegWr,
  HLSrc, HiWr, LoWr, HiRd, CP0Rd, CP0Wr, ALUSrcA, ALUSrcB,
  BranchType, Syscall, Break, UnsigImm,
  clk, inst, exception
);

parameter HALF_PERIOD = 50;

input [31:0] inst;
input exception;
output  MemWr;
output reg Jump, MemRd, RegWr, Syscall, ALUSrcA, UnsigImm;
output reg HLSrc, HiWr, LoWr, HiRd, CP0Rd, CP0Wr, Break;
output reg [1:0] ALUSrcB, RegDst, RegSrc, JumpType;
output reg [2:0] BranchType;
reg unkown_inst;

output reg clk;

reg mem_wr;
initial clk = 0;
always #HALF_PERIOD clk = ~clk;


wire [5:0] op, funct;
assign op = inst[31:26];
assign funct = inst[5:0];

wire [4:0] rs, rt;
assign rs = inst[25:21];
assign rt = inst[20:16];

always @ (exception) begin
  if (exception) begin
    // Cancel all write operation.
    {
      mem_wr, RegWr, HiWr, LoWr, CP0Wr
    } = 0;
    Jump = 1;
    JumpType = 'b10;
  end
end

assign MemWr = mem_wr & (~clk);

always @ (inst) begin
  {
    Syscall, Break, Jump, JumpType, MemRd, mem_wr, RegDst,
    RegSrc, RegWr, HLSrc, HiWr, LoWr, HiRd, UnsigImm,
    CP0Rd, CP0Wr, ALUSrcA, ALUSrcB, BranchType,
    unkown_inst
  } = 0;
  if (op == 0) begin
    if ((4 <= funct && funct <= 7) || (32 <= funct && funct <= 43)) begin // add
      case (funct)
        5, 40, 41: unkown_inst = 1;
        default: RegWr = 1;
      endcase
    end else if (funct <= 3) begin // sll
      if (funct == 1) begin
        unkown_inst = 1;
      end else begin
        RegWr = 1;
        ALUSrcA = 1;
      end
    end else if (24 <= funct && funct <= 27) begin // mult
      HiWr = 1;
      LoWr = 1;
    end else if (funct == 12) begin // syscall
      Syscall = 1;
    end else if (funct == 13) begin // break
      Break = 1;
    end else if (funct == 16 || funct == 18) begin // mfhi, mflo
      RegSrc = 'b01;
      RegWr = 1;
      HiRd = funct == 16;
    end else if (funct == 17 || funct == 19) begin // mthi, mtlo
      HLSrc = 1;
      HiWr = funct == 17;
      LoWr = funct == 19;
    end else if (funct == 9) begin // jalr
      Jump = 1;
      JumpType = 'b01;
      RegSrc = 'b11;
      RegWr = 1;
    end else if (funct == 8) begin //jr
      Jump = 1;
      JumpType = 'b01;
    end else unkown_inst = 1;
  end else if (op == 1) begin
    if (rt == 0 || rt == 1) begin // bltz, bgez
      BranchType = {2'b01, rt[0]}; // 2 or 3
      ALUSrcB = 'b11;
    end else unkown_inst = 1;
  end else if (op == 2) begin // j
    Jump = 1;
  end else if (op == 3) begin // jal
    Jump = 1;
    RegDst = 'b11;
    RegSrc = 'b11;
    RegWr =1;
  end else if (op <= 7) begin // branch
    BranchType = {op[2:0]};
    ALUSrcB = op[1] ? 'b11 : 'b00;
  end else if (op <= 14) begin // addi
    RegDst = 'b01;
    RegWr = 1;
    ALUSrcB = 'b01;
    UnsigImm = op[2];
  end else if (op == 15) begin // lui
    RegDst = 'b01;
    RegWr = 1;
    ALUSrcB = 'b10;
  end else if (op == 16) begin // cp0
    case (rs)
      0: // mfcz
        begin
          RegDst = 'b01;
          RegSrc = 'b01;
          RegWr = 1;
          CP0Rd = 1;
        end
      4: // mtcz
        begin
          CP0Wr = 1;
        end
      16: // eret if funct == 24
        if (funct == 24) begin
          Jump = 1;
          JumpType = 'b11;
        end else unkown_inst = 1;
      default unkown_inst = 1;
    endcase
  end else if (32 <= op && op <= 37) begin // load
    if (op == 34) unkown_inst = 1;
    else begin
      RegDst = 'b01;
      RegSrc = 'b10;
      RegWr = 1;
      MemRd = 1;
      ALUSrcB = 'b01;
    end
  end else if (40 <= op && op <= 43) begin
    if (op == 42) unkown_inst = 1;
    else begin
      mem_wr = 1;
      ALUSrcB = 'b01;
    end
  end else unkown_inst = 1;
end

endmodule
