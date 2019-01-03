module CP0(
  input clk, w, ex,
  input [4:0] adr,
  input [31:0] pc, ca, wd,
  output reg [31:0] rd, epc
);

reg [31:0] cause;

initial begin
  epc = 0;
  cause = 0;
end

always @ (adr) begin
  case (adr)
    13: rd = cause;
    14: rd = epc;
    default: rd = 0;
  endcase
end

always @ (posedge clk) begin
  if (ex) begin
    cause <= ca;
    epc <= pc;
  end else if (w)
    case (adr)
      13: cause <= wd;
      14: epc <= wd;
    endcase
end

endmodule


module CP0CU(
  input ov, dz, sys, brk,
  output ex,
  output reg [31:0] ca
);

assign ex = ov | dz | sys | brk;

always @ (ex) begin
  if (ex != 1) ca = 'bx;
  else
    ca = 0;
    if (dz) ca[6:2] = 15; // Divide by zero
    else if (ov) ca[6:2] = 12; // Arithmetic overflow
    else if (sys) ca[6:2] = 8; // Syscall
    else if (brk) ca[6:2] = 9; // Breakpoint
    else ca = 'bx;
end

endmodule
