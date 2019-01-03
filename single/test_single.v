module TestSinglecycle();

parameter ANS_FILE = "../data/mars_mem.txt";

MIPS32_SINGLECYCLE cpu();

reg [31:0] i;
reg [31:0] ans[0:cpu.RAM_SIZE/4-1];
initial begin
  if (ANS_FILE != "") begin
    $readmemh(ANS_FILE, ans);
  end
end
initial begin
#34300
for (i = 0; i < cpu.RAM_SIZE/4; i = i+1) begin
  if (cpu.mem.data[i] !== ans[i]) begin
    $display("Memory different: %x: %x <---> %x", i, cpu.mem.data[i], ans[i]);
    $stop();
  end
end
while (1) begin
  $display("Run finish");
  $stop();
end
end

endmodule
