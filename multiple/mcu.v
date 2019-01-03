module MCU(
  input ex, clk,
  input [31:0] IR,
  output reg PCWr, PCWrCond, IRWr, MemRd, MemWr, IorD,
  output reg RegWr, UnsImm, HiWr, LoWr, CP0Wr,
  output reg ALUOp, HLWD, Syscall, Break,
  output reg [1:0] RegWA, ALUSrcA,
  output reg [2:0] PCSrc, RegWD, ALUSrcB
);

parameter FILE = "mu_text.txt";

parameter W = 28;


reg [W+1:0] utext[0:63];
reg [5:0] upc;
wire [5:0] nxt;

Decoder decoder(.nxt(nxt), .IR(IR));

initial begin
  upc = 1;
  if (FILE != "") begin
    $readmemb(FILE, utext);
  end
end


always @ (posedge clk) begin
  if (ex) begin
    {
      PCWr, PCWrCond, PCSrc, IRWr, MemRd, MemWr, IorD,
      RegWA, RegWD, RegWr, UnsImm, ALUSrcA, ALUSrcB, ALUOp,
      HLWD, HiWr, LoWr, CP0Wr, Syscall, Break
    } <= utext[0][W+1:2];
    upc <= 1;
  end else begin
    {
      PCWr, PCWrCond, PCSrc, IRWr, MemRd, MemWr, IorD,
      RegWA, RegWD, RegWr, UnsImm, ALUSrcA, ALUSrcB, ALUOp,
      HLWD, HiWr, LoWr, CP0Wr, Syscall, Break
    } <= utext[upc][W+1:2];
    case (utext[upc][1:0])
      'b00: upc <= 1;
      'b01: upc <= upc+1;
      'b10: upc <= upc+2;
      'b11:
        case (upc)
          2: // decode
            upc <= nxt;
          3: // addr
            upc <= (IR[29] ? 6 : 4);
          7: // calc
            upc <= (IR[5:3] == 'b011 ? 10 : 9);
          default: begin
            upc <= 0;
          end
        endcase
    endcase
  end
end

endmodule


module Decoder(
  input [31:0] IR,
  output reg [5:0] nxt
);

reg unkown_inst;
initial unkown_inst = 0;

wire [5:0] op, func;
assign op = IR[31:26];
assign func = IR[5:0];

wire [4:0] rs, rt;
assign rs = IR[25:21];
assign rt = IR[20:16];

always @ (IR) begin
  unkown_inst = 0;
  case (op)
    0:
      case (func)
        0, 2, 3: nxt = 8;
        4, 6, 7, 24, 25, 26, 27, 42, 43,
        32, 33, 34, 35, 36, 37, 38, 39:
          nxt = 7;
        8: nxt = 24;
        9: nxt = 25;
        12: nxt = 28;
        13: nxt = 29;
        16: nxt = 15;
        17: nxt = 18;
        18: nxt = 16;
        19: nxt = 19;
        default: begin
          nxt = 1;
          unkown_inst = 1;
        end
      endcase
    1, 6, 7: nxt = 27;
    4, 5: nxt = 26;
    2: nxt = 22;
    3: nxt = 23;
    8, 9, 10, 11: nxt = 11;
    12, 13, 14: nxt = 12;
    15: nxt = 14;
    16:
      case (rs)
        0: nxt = 17;
        4: nxt = 20;
        16:
          if (func == 24) nxt = 21;
          else begin
            nxt = 1;
            unkown_inst = 1;
          end
        default: begin
          nxt = 1;
          unkown_inst = 1;
        end
      endcase
    32, 33, 35, 36, 37, 40, 41, 43:
      nxt = 3;
    default: begin
      nxt = 1;
      unkown_inst = 1;
    end
  endcase
end

endmodule
