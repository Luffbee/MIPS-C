module CP0(
  clk, adr, w, w_data,
  int, pc, ca, out, epc
);

input [4:0] adr;
input w, clk, int;
input [31:0] pc, ca, w_data;
output reg [31:0] out, epc;

reg [31:0] cause;

always @ (adr) begin
  case (adr)
    13: out = cause;
    14: out = epc;
    default: out = 0;
  endcase
end

always @ (posedge clk) begin
  if (int) begin
    cause <= ca;
    epc <= pc;
  end else if (w)
    case (adr)
      13: cause <= w_data;
      14: epc <= w_data;
    endcase
end

endmodule


module CP0Ctrl(
  clk, ov, sys, brk, dz,
  cause, int
);

input ov, sys, brk, dz, clk;
output reg [31:0] cause;
output reg int;

always @ (posedge clk) int <= 0;

always @ (negedge clk) begin
  cause <= 0;
  if (ov | sys | brk | dz) begin
    int <= 1;
    if (dz) cause[6:2] <= 15; // DIVIDE BY ZERO
    else if (ov) cause[6:2] <= 12; // ARITHMETIC OVERFLOW
    else if (sys) cause[6:2] <= 8; // SYSCALL
    else if (brk) cause[6:2] <= 9; // BREAKPOINT
    else cause <= 0;
  end
end

endmodule
