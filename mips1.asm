.text
# test for MIPS32
# test full R-I, SAVE
addi	$v0	$zero	0x1234
xori	$v1	$v0	0x34
ori	$v1	$v1	0x1030
slti	$a0	$v1	0x1234
sll	$a0	$a0	1
slti	$a1	$v0	0x1234
or	$a0	$a0	$a1
sll	$a0	$a0	1
sltiu	$a1	$v0	-1
or	$a0	$a0	$a1
sll	$a0	$a0	1
slti	$a1	$v0	-1
or	$a0	$a0	$a1
andi	$a0	$a0	2
sb	$v0	0x00($gp)
sb	$v1	0x01($gp)
sh	$v1	0x02($gp)
sw	$a0	0x04($gp)
# 0($gp): 0x12303034
# 4($gp): 0x00000001
# full R-I, SAVE passed

# test full LOAD, LUI
lb	$t0	0x00($gp)
sw	$t0	0x08($gp)
lbu	$t0	0x00($gp)
sw	$t0	0x0c($gp)
lh	$t0	0x00($gp)
sw	$t0	0x10($gp)
lhu	$t0	0x00($gp)
sw	$t0	0x14($gp)
lw	$t0	0x00($gp)
sw	$t0	0x18($gp)
lui	$t3	0xe5e4
sw	$t3	0x1c($gp)
srl	$t3	$t3	16
sh	$t3	0x1c($gp)
lb	$t4	0x1c($gp)
lbu	$t5	0x1c($gp)
lh	$t6	0x1c($gp)
lhu	$t7	0x1c($gp)
sw	$t4	0x20($gp)
sw	$t5	0x24($gp)
sw	$t6	0x28($gp)
sw	$t7	0x2c($gp)
# full LOAD, LUI passed

# test full R-R, HI, LO
# sll, srl, sra
sll	$t0	$t0	3
sw	$t0	0x30($gp)
srl	$t0	$t0	3
sw	$t0	0x34($gp)
sll	$t0	$t0	3
sra	$t0	$t0	3
sw	$t0	0x38($gp)
# and, sllv, srlv, srav
and	$t1	$t0	$zero
addi	$t1	$t1	6
sllv	$t0	$t0	$t1
sw	$t0	0x3c($gp)
srlv	$t0	$t0	$t1
sw	$t0	0x40($gp)
sllv	$t0	$t0	$t1
srav	$t0	$t0	$t1
sw	$t0	0x44($gp)
addiu	$t2	$zero	-1
sll	$t2	$t2	16
addu	$t1	$t1	$t2
or	$t1	$t1	$t2
sllv	$t0	$t0	$t1
sw	$t0	0x48($gp)
srlv	$t0	$t0	$t1
sw	$t0	0x4c($gp)
sllv	$t0	$t0	$t1
srav	$t0	$t0	$t1
sw	$t0	0x50($gp)
#add, addu, sub, subu, xor, slt, sltu
add	$t0	$t0	$t3
sw	$t0	0x54($gp)
add	$t0	$t1	$t2
sw	$t0	0x58($gp)
lui	$t1	0x8000
addu	$t0	$t1	$t1
sw	$t0	0x5c($gp)
sub	$t0	$t0	$t3
sub	$t0	$t0	$t2
sw	$t0	0x60($gp)
subu	$t0	$t1	$t3
sw	$t0	0x64($gp)
xor	$t0	$t4	$t6
sw	$t2	0x68($gp)
slt	$a0	$t2	$t5
sll	$a0	$a0	1
sltu	$a1	$t2	$t5
or	$a0	$a0	$a1
sll	$a0	$a0	1
sltu	$a1	$t5	$t2
or	$a0	$a0	$a1
sll	$a0	$a0	1
slt	$a1	$t2	$t2
or	$a0	$a0	$a1
sw	$a0	0x6c($gp)
# mult, multu, div, divu, mfhi, mflo, mthi, mtlo
sll	$t1	$t3	5
mult	$t1	$t1
mfhi	$t0
sw	$t0	0x70($gp)
mflo	$t0
sw	$t0	0x74($gp)
multu	$t1	$t1
mfhi	$t0
sw	$t0	0x78($gp)
mflo	$t0
sw	$t0	0x7c($gp)
lui	$t1	0x8000
mult	$t1	$t1
mfhi	$t0
sw	$t0	0x80($gp)
mflo	$t0
sw	$t0	0x84($gp)
multu	$t1	$t1
mfhi	$t0
sw	$t0	0x88($gp)
mflo	$t0
sw	$t0	0x8c($gp)
addi	$t2	$zero	2
mult	$t1	$t2
mfhi	$t0
sw	$t0	0x90($gp)
mflo	$t0
sw	$t0	0x94($gp)
multu	$t1	$t2
mfhi	$t0
sw	$t0	0x98($gp)
mflo	$t0
sw	$t0	0x9c($gp)
mthi	$t4
mfhi	$s4
mtlo	$t6
mflo	$s6
sw	$s4	0xa0($gp)
sw	$s6	0xa4($gp)
addi	$at	$gp	0xa8
div	$t4	$t3
mfhi	$a0
sw	$a0	0($at)
addi	$at	$at	4
mflo	$a0
sw	$a0	0($at)
addi	$at	$at	4
divu	$t4	$t3
mfhi	$a0
sw	$a0	0($at)
addi	$at	$at	4
mflo	$a0
sw	$a0	0($at)
addi	$at	$at	4
# full R-R, HI, LO passed

# test full BRANCH
lui	$a0	0x1024
addi	$a0	$a0	0x1024
lui	$a1	0xacac
ori	$a1	$a1	0xacac
andi	$t0	$t3	0
addi	$t1	$zero	1
addi	$t2	$zero	-1
# BLTSZ
sw	$a0	0($at)
bltz	$t0	next1
sw	$a1	0($at)
next1:
addi	$at	$at	4

sw	$a0	0($at)
bltz	$t1	next2
sw	$a1	0($at)
next2:
addi	$at	$at	4

sw	$a1	0($at)
bltz	$t2	next3
sw	$a0	0($at)
next3:
addi	$at	$at	4
# BGEZ
sw	$a1	0($at)
bgez	$t0	next4
sw	$a0	0($at)
next4:
addi	$at	$at	4

sw	$a1	0($at)
bgez	$t1	next5
sw	$a0	0($at)
next5:
addi	$at	$at	4

sw	$a0	0($at)
bgez	$t2	next6
sw	$a1	0($at)
next6:
addi	$at	$at	4
# BLEZ
sw	$a1	0($at)
blez	$t0	next7
sw	$a0	0($at)
next7:
addi	$at	$at	4

sw	$a0	0($at)
blez	$t1	next8
sw	$a1	0($at)
next8:
addi	$at	$at	4

sw	$a1	0($at)
blez	$t2	next9
sw	$a0	0($at)
next9:
addi	$at	$at	4
# BGTZ
sw	$a0	0($at)
bgtz	$t0	next10
sw	$a1	0($at)
next10:
addi	$at	$at	4

sw	$a1	0($at)
bgtz	$t1	next11
sw	$a0	0($at)
next11:
addi	$at	$at	4

sw	$a0	0($at)
bgtz	$t2	next12
sw	$a1	0($at)
next12:
addi	$at	$at	4
# BEQ
sw	$a1	0($at)
beq	$t0	$t0 next13
sw	$a0	0($at)
next13:
addi	$at	$at	4

sw	$a0	0($at)
beq	$t1	$t0 next14
sw	$a1	0($at)
next14:
addi	$at	$at	4
# BNE
sw	$a0	0($at)
bne	$t0	$t0 next15
sw	$a1	0($at)
next15:
addi	$at	$at	4

sw	$a1	0($at)
bne	$t1	$t0 next16
sw	$a0	0($at)
next16:
addi	$at	$at	4
# Branch back
addi	$t2	$zero	-10
branchback:
addi	$t2	$t2	1
addi	$a0	$a0	0x7fff
sw	$a0	0($at)
addi	$at	$at	4
blez	$t2	branchback
# BRANCH passed

# test JUMP
lui	$a0	0x1024
ori	$a0	$a0	0xffff
andi	$a0	$a0	0x1024

ori	$a1	$zero	0xacc1
sw	$a1	0($at)
j	jump1
sw	$a0	0($at)
jump1:
addi	$at	$at	4

ori	$a1	$zero	0xacc2
sw	$a1	0($at)
addi	$at	$at	4
jal	jump2
ori	$a1	$zero	0xacc3
sw	$a1	0($at)
addi	$at	$at	4
j	jump3

jump2:
ori	$a1	$zero	0xacc4
sw	$a1	0($at)
addi	$at	$at	4
jr	$ra

jump3:
ori	$a1	$zero	0xacc5
sw	$a1	0($at)
addi	$at	$at	4
addi	$s6	$ra	56
jalr	$s7	$s6
j	jump4

ori	$a1	$zero	0xacc6
sw	$a1	0($at)
addi	$at	$at	4
jr	$s7

jump4:
ori	$a1	$zero	0xacc7
sw	$a1	0($at)
addi	$at	$at	4
# JUMP passed

# test CP0
ori	$a1	$zero	0xeca0
sw	$a1	0($at)
addi	$at	$at	4
break
syscall
ori	$a1	$zero	0xeca1
sw	$a1	0($at)
addi	$at	$at	4
lui	$v0	0x7fff
ori	$v0	$v0	0xffff
addi	$v0	$v0	1
sw	$v0	0($at)
addi	$at	$at	4
ori	$a1	$zero	0xeca2
sw	$a1	0($at)
addi	$at	$at	4



.ktext 0x80000180
ori	$a1	$zero	0xece1
sw	$a1	0($at)
addi	$at	$at	4
mfc0	$t0	$13
sw	$t0	0($at)
addi	$at	$at	4
mfc0	$t0	$14
addi	$t0	$t0	4
mtc0	$t0	$14
eret