module Mux2 #(parameter W=32) (
  input sl,
  input [W-1:0] in0, in1,
  output [W-1:0] out
);

assign out = sl ? in1 : in0;

endmodule


module Mux4 #(parameter W=32) (
  input [1:0] sl,
  input [W-1:0] in00, in01, in10, in11,
  output [W-1:0] out
);

wire [W-1:0] in0;
wire [W-1:0] in1;

assign in0 = sl[0] ? in01 : in00;
assign in1 = sl[0] ? in11 : in10;
assign out = sl[1] ? in1 : in0;

endmodule


module Mux8 #(parameter W=32) (
  input [2:0] sl,
  input [W-1:0] in000, in001, in010, in011,
  input [W-1:0] in100, in101, in110, in111,
  output reg [W-1:0] out
);

always @ (*)
  case (sl)
    'b000: out = in000;
    'b001: out = in001;
    'b010: out = in010;
    'b011: out = in011;
    'b100: out = in100;
    'b101: out = in101;
    'b110: out = in110;
    'b111: out = in111;
  endcase

endmodule
