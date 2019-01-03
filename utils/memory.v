module RAM(
  radr, r, r_type, w, w_type,
  w_data, r_data
);

parameter SIZE = 32'h10000;
parameter FILE1 = "";
parameter FILE2 = "";
parameter ZERO = 32'h0;

input w, r;
input [2:0] r_type;
input [1:0] w_type;
input [31:0] radr, w_data;
output reg [31:0] r_data;

wire  [31:0] adr = radr - ZERO;
reg [31:0] data[0:SIZE/4-1];
initial begin
  if (FILE1 != "") $readmemh(FILE1, data);
  if (FILE2 != "") $readmemh(FILE2, data, SIZE/16);
end

wire [29:0] addr = adr[31:2];

always @ (r or r_type or adr) begin
  if (r)
    case (r_type)
      'b000:
        case (adr[1:0])
          'b00: r_data = $signed(data[addr][7:0]);
          'b01: r_data = $signed(data[addr][15:8]);
          'b10: r_data = $signed(data[addr][23:16]);
          'b11: r_data = $signed(data[addr][31:24]);
        endcase
      'b001:
        case (adr[1])
          'b0: r_data = $signed(data[addr][15:0]);
          'b1: r_data = $signed(data[addr][31:16]);
        endcase
      'b011: r_data = data[addr];
      'b100:
        case (adr[1:0])
          'b00: r_data = data[addr][7:0];
          'b01: r_data = data[addr][15:8];
          'b10: r_data = data[addr][23:16];
          'b11: r_data = data[addr][31:24];
        endcase
      'b101:
        case (adr[1])
          'b0: r_data = data[addr][15:0];
          'b1: r_data = data[addr][31:16];
        endcase
      default: r_data = 'hx;
    endcase
  else r_data = 'hx;
end

always @ (posedge w) begin
  case (w_type)
    'b00:
      case (adr[1:0])
        'b00: data[addr][7:0] <= w_data[7:0];
        'b01: data[addr][15:8] <= w_data[7:0];
        'b10: data[addr][23:16] <= w_data[7:0];
        'b11: data[addr][31:24] <= w_data[7:0];
      endcase
    'b01:
      case (adr[1])
        'b0: data[addr][15:0] <= w_data[15:0];
        'b1: data[addr][31:16] <= w_data[15:0];
      endcase
    'b11: data[addr] <= w_data;
  endcase
end

endmodule


module ROM(
  radr, r_data
);

parameter SIZE = 32'h10000;
parameter ZERO = 32'h0;
parameter FILE1 = "";
parameter FILE2 = "";

input [31:0] radr;
output [31:0] r_data;

wire  [31:0] adr = radr-ZERO;
reg [31:0] data[0:SIZE/4-1];
initial begin
  if (FILE1 != "") begin
    $readmemh(FILE1, data);
  end
  if (FILE2 != "") begin
    $readmemh(FILE2, data, SIZE/8);
  end
end

wire [29:0] addr = adr[31:2];

assign r_data = data[addr];

endmodule
