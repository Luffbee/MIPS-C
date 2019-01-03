module FlopR #(parameter W=32) (
  input clk, w, reset,
  input [W-1:0] d,
  output reg [W-1:0] q
);

always @ (posedge clk or posedge reset)
  if (reset) q <= 0;
  else if (w) q <= d;

endmodule
