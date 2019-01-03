module BranchCU(
  input [3:0] op, 
  input si, ze,
  output reg out
);

always @ (op, si, ze)
  case (op)
    'b0010: // bltz
      out = si;
    'b0011: // bgez
      out = ~si;
    'b1000, 'b1001: // beq
      out = ze;
    'b1010, 'b1011: // bne
      out = ~ze;
    'b1100: // blez
      out = ze | si;
    'b1110: // bgtz
      out = ~(ze | si);
    default:
      out = 'bx;
  endcase

endmodule
