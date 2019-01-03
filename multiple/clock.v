module Clock(
  output reg P, T
);

parameter HALF_PERIOD = 5;

reg clk;
reg a, b, c, d;


initial begin
  clk = 1;
  T = 1;
  {a, b, c, d} = 4'b1000;
end

always @ (T) P = ~T;
always #HALF_PERIOD clk = ~clk;
always @ (negedge clk) begin
  a <= b;
  b <= c;
  c <= d;
  d <= a;
end
always @ (posedge clk) T <= 1;
always @ (posedge a) T <= 0;

endmodule
