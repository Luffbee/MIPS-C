module RF2r1w(
  r_id1, r_id2, w_id, cp, w,
  r_data1, r_data2, w_data
);

parameter M = 5;
parameter W = 32;

input cp, w;
input [M-1:0] r_id1, r_id2, w_id;
input [W-1:0] w_data;
output [W-1:0] r_data1, r_data2;

reg [W-1:0] data[0:(1<<M)-1];
reg [M:0] i;
initial begin
  for (i = 0; i < (1<<M); i = i+1) data[i] = 0;
end


assign r_data1 = data[r_id1];
assign r_data2 = data[r_id2];

always @ (posedge cp)
  if (w) data[w_id] <= w_data;

endmodule
