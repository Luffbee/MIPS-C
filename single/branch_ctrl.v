module BranchCtrl(
  want, cond, out
);

input [2:0] want;
input signed [1:0] cond;
output reg out;


always @ (want or cond) begin
  case (want)
    'd2: out = cond == 'b10; // <
    'd3: out = cond >= 0; // >=
    'd4: out = cond == 'b01; // ==
    'd5: out = cond != 'b01; // !=
    'd6: out = |cond; // <=
    'd7: out = cond == 'b00; // >
    default: out = 0;
  endcase
end

endmodule

