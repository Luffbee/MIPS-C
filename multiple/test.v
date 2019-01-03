module TestMulticycle();

parameter ANS_FILE = "../data/mars_mem.txt";

MIPS32_MULTICYCLE cpu();

reg [31:0] i, zero;
reg [31:0] ans[0:cpu.RAM_SIZE/8-1];
initial begin
  if (ANS_FILE != "") begin
    $readmemh(ANS_FILE, ans);
  end
end
initial begin
#52400
zero = (cpu.DATA-cpu.TEXT)/4;
for (i = 0; i < cpu.RAM_SIZE/8; i = i+1) begin
  if (cpu.mem.data[zero+i] !== ans[i]) begin
    $display("Memory different: %x: %x <---> %x", i, cpu.mem.data[zero+i], ans[i]);
    $stop();
  end
end
while (1) begin
  $display("Run finish");
  $stop();
end
end

endmodule
