module ALUCtrl(
  op, func, out
);

input [5:0] op, func;
output reg [3:0] out;



always @ (op or func) begin
  case (op)
    0:
      case (func)
        0, 4: out = 0; //SLL, SLLV
        2, 6: out = 1; //SRL, SRLV
        3, 7: out = 2; //SRA, SRAV
        24: out = 3; //MULT
        25: out = 4; //MULTU
        26: out = 5; //DIV
        27: out = 6; //DIVU
        32: out = 7; //ADD
        33: out = 8; //ADDU
        34: out = 9; //SUB
        35: out = 10; //SUBU
        36: out = 11; //AND
        37: out = 12; //OR
        38: out = 13; //XOR
        42: out = 14; //SLT
        43: out = 15; //SLTU
        default: out = 8;
      endcase
    1, 6, 7: out = 9; //SUB
    4, 5: out = 10; //SUBU
    8: out = 7; //ADD
    9: out = 8; //ADDU
    10: out = 14; //SLT
    11: out = 15; //SLTU
    12: out = 11; //AND
    13: out = 12; //OR
    14: out = 13; //XOR
    15: out = 8; //LUI
    default: out = 8;
  endcase
end

endmodule
