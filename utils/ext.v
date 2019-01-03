module SigExt(
  in, out
);

parameter M = 16;
parameter W = 32;

input [M-1:0] in;
output [W-1:0] out;

assign out = $signed(in);

endmodule


module UnsigExt(
  in, out
);

parameter M = 16;
parameter W = 32;

input [M-1:0] in;
output [W-1:0] out;

assign out = in;

endmodule
