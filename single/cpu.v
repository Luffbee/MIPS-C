module MIPS32_SINGLECYCLE();

parameter ROM_SIZE = 32'h10000;
parameter RAM_SIZE = 32'h10000;
parameter TEXT = 32'h00400000;
parameter KTEXT = TEXT+ROM_SIZE/2;
parameter ROM_ZERO = TEXT;
parameter RAM_ZERO = 32'h0;
parameter TEXT_FILE = "../data/text.txt";
parameter KTEXT_FILE = "../data/ktext.txt";

wire Jump, MemRd, MemWr, RegWr, Syscall, Break, UnsigImm;
wire HLSrc, HiWr, LoWr, HiRd, CP0Rd, CP0Wr, ALUSrcA;
wire [1:0] ALUSrcB, RegDst, RegSrc, JumpType;
wire [2:0] BranchType;
wire [31:0] inst;
wire clk, exception;
MCU mcu(
  .Jump(Jump), .JumpType(JumpType), .MemRd(MemRd), .MemWr(MemWr),
  .RegDst(RegDst), .RegSrc(RegSrc), .RegWr(RegWr), .HLSrc(HLSrc),
  .HiWr(HiWr), .LoWr(LoWr), .HiRd(HiRd), .CP0Rd(CP0Rd), .CP0Wr(CP0Wr),
  .ALUSrcA(ALUSrcA), .ALUSrcB(ALUSrcB), .BranchType(BranchType),
  .UnsigImm(UnsigImm), .Syscall(Syscall), .Break(Break),
  .clk(clk), .inst(inst), .exception(exception)
);

reg [31:0] PC, HI, LO;
initial begin
  PC = TEXT;
  HI = 0;
  LO = 0;
end
ROM #(
  .SIZE(ROM_SIZE), .ZERO(ROM_ZERO),
  .FILE1(TEXT_FILE), .FILE2(KTEXT_FILE)
) rom(.radr(PC), .r_data(inst));

wire [31:0] imm, imm_sig, imm_unsig;
SigExt sig_ext(.in(inst[15:0]), .out(imm_sig));
UnsigExt unsig_ext(.in(inst[15:0]), .out(imm_unsig));
Mux2 imm_mux(
  .sl(UnsigImm), .in0(imm_sig),
  .in1(imm_unsig), .out(imm)
);

wire [3:0] alu_f;
wire [31:0] alu_a, alu_b;
wire [63:0] alu_c;
wire ze, ov, si, dz;
ALU alu(
  .f(alu_f), .a(alu_a), .b(alu_b),
  .c(alu_c), .ze(ze), .ov(ov), .si(si), .dz(dz)
);

wire [4:0] r_reg1, r_reg2, w_reg;
wire [31:0] reg1, reg2, reg_data;
RF2r1w rf(
  .r_id1(r_reg1), .r_id2(r_reg2), .w_id(w_reg),
  .cp(clk), .w(RegWr&&(w_reg!=0)), .r_data1(reg1), .r_data2(reg2),
  .w_data(reg_data)
);

wire [4:0] cp0_adr;
wire [31:0] cause, cp0_data, cp0_wdata, EPC;
CP0 cp0(
  .clk(clk), .adr(cp0_adr), .w(CP0Wr),
  .int(exception), .pc(PC), .ca(cause),
  .out(cp0_data), .epc(EPC), .w_data(cp0_wdata)
);

wire [31:0] mem_adr, r_mem, w_mem;
RAM #(.SIZE(RAM_SIZE), .ZERO(RAM_ZERO)) mem(
  .radr(mem_adr), .r(MemRd), .r_type(inst[28:26]),
  .w(MemWr), .w_type(inst[27:26]),
  .w_data(w_mem), .r_data(r_mem)
);

// Datapath for HI, LO start
wire [31:0] HI_D, LO_D, hl_data;
always @ (posedge clk) begin
  if (HiWr) HI <= HI_D;
  if (LoWr) LO <= LO_D;
end
Mux2 hlData(
  .sl(HiRd), .in0(LO),
  .in1(HI), .out(hl_data)
);
Mux2 hiD(
  .sl(HLSrc), .in0(alu_c[63:32]),
  .in1(reg1), .out(HI_D)
);
Mux2 loD(
  .sl(HLSrc), .in0(alu_c[31:0]),
  .in1(reg1), .out(LO_D)
);
// Datapath for HI, LO end


// Datapath for PC start
wire [31:0] PC_D;
always @ (posedge clk) PC <= PC_D;
// PC for normal
wire [31:0] PC_nxt;
assign PC_nxt = PC + 4;
// PC for J or JAL
wire [31:0] PC_j;
assign PC_j = {PC_nxt[31:28], inst[25:0], 2'b0};
// PC for JR or JALR
wire [31:0] PC_jr;
assign PC_jr = reg1;
wire [31:0] PC_jmp;
Mux4 jmp(
  .sl(JumpType), .in00(PC_j),
  .in01(PC_jr), .in10(KTEXT),
  .in11(EPC), .out(PC_jmp)
);
// PC for Branch
wire [31:0] PC_b1, PC_b;
wire [31:0] offset = {imm[29:0], 2'b0};
assign PC_b1 = PC_nxt + offset;
wire branch;
BranchCtrl branchCtrl(
  .want(BranchType), .cond({si, ze}), .out(branch)
);
Mux2 ifBranch(
  .sl(branch), .in0(PC_nxt),
  .in1(PC_b1), .out(PC_b)
);
Mux2 ifJump(
  .sl(Jump), .in0(PC_b),
  .in1(PC_jmp), .out(PC_D)
);
// Datapath for PC end


// Datapath for ALU start
wire [31:0] shift_s;
UnsigExt #(.M(5), .W(32)) shift_ext(
  .in(inst[10:6]), .out(shift_s)
);
Mux2 aluA(
  .sl(ALUSrcA), .in0(reg1),
  .in1(shift_s), .out(alu_a)
);
wire [31:0] uimm = {inst[15:0], 16'b0};
Mux4 aluB(
  .sl(ALUSrcB), .in00(reg2),
  .in01(imm), .in10(uimm),
  .in11(0), .out(alu_b)
);
ALUCtrl aluCtrl(
  .op(inst[31:26]), .func(inst[5:0]),
  .out(alu_f)
);
// Datapath for ALU end


// Datapath for RF start
assign r_reg1 = inst[25:21];
assign r_reg2 = inst[20:16];
Mux4 #(.W(5)) wReg(
  .sl(RegDst), .in00(inst[15:11]),
  .in01(r_reg2), .in10(5'dx),
  .in11(5'd31), .out(w_reg)
);
wire [31:0] special;
Mux2 cp0orhl(
  .sl(CP0Rd), .in0(hl_data),
  .in1(cp0_data), .out(special)
);
Mux4 wRegData(
  .sl(RegSrc), .in00(alu_c[31:0]),
  .in01(special), .in10(r_mem),
  .in11(PC_nxt), .out(reg_data)
);
// Datapath for RF end


// Datapath for CP0 start
assign cp0_adr = inst[15:11];
assign cp0_wdata = reg2;
CP0Ctrl cp0_ctrl(
  .ov(ov), .sys(Syscall), .brk(Break), .dz(dz),
  .cause(cause), .int(exception), .clk(clk)
);
// Datapath for CP0 end


// Datapath for MEM start
assign mem_adr = alu_c[31:0];
assign w_mem = reg2;
// Datapath for MEM end

endmodule
