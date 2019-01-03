module MIPS32_MULTICYCLE();

parameter RAM_SIZE = 32'h20000;
parameter TEXT = 32'h00400000;
parameter KTEXT = TEXT+RAM_SIZE/4;
parameter DATA = TEXT+RAM_SIZE/2;
parameter TEXT_FILE = "../data/text.txt";
parameter KTEXT_FILE = "../data/ktext.txt";

wire PCWr, PCWrCond, IRWr, MemRd, MemWr, IorD, RegWr, UnsImm, HiWr, LoWr, CP0Wr;
wire ALUOp, HLWD, Syscall, Break;
wire [1:0] RegWA, ALUSrcA;
wire [2:0] PCSrc, RegWD, ALUSrcB;
wire clk_P, clk_T;

Clock clk(.P(clk_P), .T(clk_T));

wire pc_w;
wire [31:0] pc_d, PC;
FlopR pc_reg(.clk(clk_P), .w(pc_w), .reset(1'b0), .d(pc_d), .q(PC));
// Backup PC for EPC.
wire [31:0] PC_bk;
FlopR pc_bk(.clk(clk_P), .w(PCWr), .reset(1'b0), .d(PC), .q(PC_bk));
initial pc_reg.q = TEXT;

wire [4:0] rf_ra, rf_rb, rf_wid;
wire [31:0] reg_a, reg_b, rf_wd, A, B;
FlopR rfA(.clk(clk_P), .w(1'b1), .reset(1'b0), .d(reg_a), .q(A));
FlopR rfB(.clk(clk_P), .w(1'b1), .reset(1'b0), .d(reg_b), .q(B));
RF2r1w rf(.r_id1(rf_ra), .r_id2(rf_rb), .w_id(rf_wid), .cp(clk_P),
  .w(RegWr&&(rf_wid!=0)), .r_data1(reg_a), .r_data2(reg_b), .w_data(rf_wd));
initial rf.data[28] = DATA;

wire [31:0] mem_adr, mem_rd, MDR, IR;
wire [2:0] mem_rt;
FlopR ir_reg(.clk(clk_P), .w(IRWr), .reset(1'b0), .d(mem_rd), .q(IR));
FlopR mdr_reg(.clk(clk_P), .w(1'b1), .reset(1'b0), .d(mem_rd), .q(MDR));
RAM #(.SIZE(RAM_SIZE), .ZERO(TEXT), .FILE1(TEXT_FILE), .FILE2(KTEXT_FILE))
  mem(.radr(mem_adr), .r(MemRd), .r_type(mem_rt),
  .w(MemWr), .w_type(IR[27:26]), .w_data(B), .r_data(mem_rd));

wire [3:0] alu_f;
wire [31:0] alu_a, alu_b;
wire [63:0] alu_c, ALUOUT;
wire ze, ov, si, dz;
FlopR #(.W(64)) alu_out(.clk(clk_P), .w(1'b1), .reset(1'b0), .d(alu_c), .q(ALUOUT));
ALU alu(.f(alu_f), .a(alu_a), .b(alu_b), .c(alu_c),
  .ze(ze), .ov(ov), .si(si), .dz(dz));

wire [31:0] hi_wd, lo_wd, HI, LO;
FlopR hi_reg(.clk(clk_P), .w(HiWr), .reset(1'b0), .d(hi_wd), .q(HI));
FlopR lo_reg(.clk(clk_P), .w(LoWr), .reset(1'b0), .d(lo_wd), .q(LO));
initial begin
  hi_reg.q = 0;
  lo_reg.q = 0;
end

wire exception;
wire [31:0] cause, cp0_rd, EPC, C0;
FlopR cp0_reg(.clk(clk_P), .w(1'b1), .reset(1'b0), .d(cp0_rd), .q(C0));
CP0 cp0(.clk(clk_P), .adr(IR[15:11]), .w(CP0Wr), .ex(exception), .pc(PC_bk),
  .ca(cause), .rd(cp0_rd), .epc(EPC), .wd(B));

wire [31:0] imm, sig_imm, uns_imm;
SigExt sig_ext(.in(IR[15:0]), .out(sig_imm));
UnsigExt uns_ext(.in(IR[15:0]), .out(uns_imm));
Mux2 imm_mux( .sl(UnsImm), .in0(sig_imm), .in1(uns_imm), .out(imm));

MCU mcu(.clk(clk_T), .PCWr(PCWr), .PCWrCond(PCWrCond), .IRWr(IRWr), .MemRd(MemRd),
  .MemWr(MemWr), .IorD(IorD), .RegWr(RegWr), .UnsImm(UnsImm), .HiWr(HiWr),
  .LoWr(LoWr), .CP0Wr(CP0Wr), .ALUOp(ALUOp), .ALUSrcA(ALUSrcA), .HLWD(HLWD),
  .Syscall(Syscall), .Break(Break), .RegWA(RegWA), .ALUSrcB(ALUSrcB),
  .PCSrc(PCSrc), .RegWD(RegWD), .IR(IR), .ex(exception));

// Datapath for PC start
// PCSrc: alu_c, inst[25:0], A, ALUOUT, KTEXT, EPC
wire [31:0] pc_j = {PC[31:28], IR[25:0], 2'b0};
Mux8 pc_mux(.sl(PCSrc), .in000(alu_c[31:0]), .in001(pc_j), .in010(A),
  .in011(ALUOUT[31:0]), .in100(KTEXT), .in101(EPC), .in110(32'bx),
  .in111(32'bx), .out(pc_d));
wire branch;
assign pc_w = PCWr | (PCWrCond & branch);
BranchCU branch_ctrl(.op({IR[28:26], IR[16]}), .si(si), .ze(ze), .out(branch));
// Datapath for PC end


// Datapath for RF start
assign rf_ra = IR[25:21];
assign rf_rb = IR[20:16];
Mux4 #(.W(5)) wReg(.sl(RegWA), .in00(IR[15:11]), .in01(rf_rb), .in10(5'bx),
  .in11(5'd31), .out(rf_wid));
// rf_wd: alu, mem, pc, hi, lo, cp0, lui_imm
wire [31:0] lui_imm = {IR[15:0], 16'b0};
Mux8 rf_wd_mux(.sl(RegWD), .in000(ALUOUT[31:0]), .in001(MDR), .in010(PC),
  .in011(HI), .in100(LO), .in101(C0), .in110(lui_imm), .in111(32'bx),
  .out(rf_wd));
// Datapath for RF end


// Datapath for RAM start
Mux2 mem_adr_mux(.sl(IorD), .in0(PC), .in1(ALUOUT[31:0]), .out(mem_adr));
Mux2 #(.W(3)) mem_rt_mux(.sl(IorD), .in0(3'b011),
  .in1(IR[28:26]), .out(mem_rt));
// Datapath for RAM end


// Datapath for ALU start
wire [31:0] shift_s;
UnsigExt #(.M(5), .W(32)) shift_s_ext(.in(IR[10:6]), .out(shift_s));
Mux4 alu_a_mux(.sl(ALUSrcA), .in00(A), .in01(shift_s), .in10(PC),
  .in11(32'bx), .out(alu_a));
// alu_b: B, imm, 0, 4, offset
wire [31:0] offset = {imm[29:0], 2'b0};
Mux8 alu_b_mux(.sl(ALUSrcB), .in000(B), .in001(imm), .in010(32'b0),
  .in011(32'd4), .in100(offset), .in101('bx), .in110('bx), .in111('bx),
  .out(alu_b));
ALUCU alu_ctrl(.cu(ALUOp), .op(IR[31:26]), .func(IR[5:0]), .out(alu_f));
// Datapath for ALU end


// Datapath for HI, LO start
Mux2 hi_wd_mux(.sl(HLWD), .in0(ALUOUT[63:32]), .in1(A), .out(hi_wd));
Mux2 lo_wd_mux(.sl(HLWD), .in0(ALUOUT[31:0]), .in1(A), .out(lo_wd));
// Datapath for HI, LO end


// Datapath for CP0 start
CP0CU cp0_ctrl(.ov(ov), .dz(dz), .sys(Syscall), .brk(Break),
  .ca(cause), .ex(exception));
// Datapath for CP0 end

endmodule
