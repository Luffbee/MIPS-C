module ALU(
  f, a, b, c,
  ze, ov, si, dz
);

parameter W = 32;

input [3:0] f;
input [W-1:0] a, b;
output reg [2*W-1:0] c;
output reg ze, ov, si, dz;

always @ (f or a or b) begin
  ov = 0;
  dz = 0;
  case (f)
    0:  //SLL, SLLV
      c = b << a[4:0];
    1:  //SRL, SRLV
      c = b >> a[4:0];
    2:  //SRA, SRAV
      c = $signed(b) >> a[4:0];
    3: //MULT
      begin
        c = $signed(a) * $signed(b);
      end
    4: //MULTU
      c = a * b;
    5: //DIV
      begin
        if (b) begin
          c[W-1:0] = $signed(a) / $signed(b);
          c[2*W-1:W] = $signed(a) % $signed(b);
        end else begin
          c = -1;
          dz = 1;
        end
      end
    6: //DIVU
      begin
        if (b) begin
          c[W-1:0] = a / b;
          c[2*W-1:W] = a % b;
        end else begin
          c = -1;
          dz = 1;
        end
      end
    7: //ADD
      begin
        c = $signed(a) + $signed(b);
        ov = c[W] == c[W-1] ? 0 : 1;
      end
    8: //ADDU
      c = a + b;
    9: //SUB
      begin
        c = $signed(a) - $signed(b);
        ov = c[W] == c[W-1] ? 0 : 1;
      end
    10: //SUBU
      c = a - b;
    11: //AND
      c = a & b;
    12: //OR
      c = a | b;
    13: //XOR
      c = a ^ b;
    14: //SLT
      c = $signed(a) < $signed(b) ? 1 : 0;
    15: //SLTU
      c = a < b ? 1 : 0;
  endcase
  ze = c == 0 ? 1 : 0;
  si = c[53];
end

endmodule
