
benchmark.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00001137          	lui	sp,0x1
   4:	01000513          	li	a0,16
   8:	01000593          	li	a1,16
   c:	00b55863          	bge	a0,a1,1c <bss_clear_done>

00000010 <bss_clear_loop>:
  10:	00052023          	sw	zero,0(a0)
  14:	00450513          	addi	a0,a0,4
  18:	feb54ce3          	blt	a0,a1,10 <bss_clear_loop>

0000001c <bss_clear_done>:
  1c:	0e4000ef          	jal	100 <main>

00000020 <halt>:
  20:	00000073          	ecall
  24:	ffdff06f          	j	20 <halt>

00000028 <print_hex>:
  28:	fe010113          	addi	sp,sp,-32 # fe0 <putchar+0xca0>
  2c:	00112e23          	sw	ra,28(sp)
  30:	00812c23          	sw	s0,24(sp)
  34:	00912a23          	sw	s1,20(sp)
  38:	01212823          	sw	s2,16(sp)
  3c:	00050493          	mv	s1,a0
  40:	03000793          	li	a5,48
  44:	00f10023          	sb	a5,0(sp)
  48:	03100793          	li	a5,49
  4c:	00f100a3          	sb	a5,1(sp)
  50:	03200793          	li	a5,50
  54:	00f10123          	sb	a5,2(sp)
  58:	03300793          	li	a5,51
  5c:	00f101a3          	sb	a5,3(sp)
  60:	03400793          	li	a5,52
  64:	00f10223          	sb	a5,4(sp)
  68:	03500793          	li	a5,53
  6c:	00f102a3          	sb	a5,5(sp)
  70:	03600793          	li	a5,54
  74:	00f10323          	sb	a5,6(sp)
  78:	03700793          	li	a5,55
  7c:	00f103a3          	sb	a5,7(sp)
  80:	03800793          	li	a5,56
  84:	00f10423          	sb	a5,8(sp)
  88:	03900793          	li	a5,57
  8c:	00f104a3          	sb	a5,9(sp)
  90:	04100793          	li	a5,65
  94:	00f10523          	sb	a5,10(sp)
  98:	04200793          	li	a5,66
  9c:	00f105a3          	sb	a5,11(sp)
  a0:	04300793          	li	a5,67
  a4:	00f10623          	sb	a5,12(sp)
  a8:	04400793          	li	a5,68
  ac:	00f106a3          	sb	a5,13(sp)
  b0:	04500793          	li	a5,69
  b4:	00f10723          	sb	a5,14(sp)
  b8:	04600793          	li	a5,70
  bc:	00f107a3          	sb	a5,15(sp)
  c0:	01c00413          	li	s0,28
  c4:	ffc00913          	li	s2,-4
  c8:	0084d7b3          	srl	a5,s1,s0
  cc:	00f7f793          	andi	a5,a5,15
  d0:	01078793          	addi	a5,a5,16
  d4:	002787b3          	add	a5,a5,sp
  d8:	ff07c503          	lbu	a0,-16(a5)
  dc:	264000ef          	jal	340 <putchar>
  e0:	ffc40413          	addi	s0,s0,-4
  e4:	ff2412e3          	bne	s0,s2,c8 <print_hex+0xa0>
  e8:	01c12083          	lw	ra,28(sp)
  ec:	01812403          	lw	s0,24(sp)
  f0:	01412483          	lw	s1,20(sp)
  f4:	01012903          	lw	s2,16(sp)
  f8:	02010113          	addi	sp,sp,32
  fc:	00008067          	ret

00000100 <main>:
 100:	f9010113          	addi	sp,sp,-112
 104:	06112623          	sw	ra,108(sp)
 108:	06812423          	sw	s0,104(sp)
 10c:	06912223          	sw	s1,100(sp)
 110:	07212023          	sw	s2,96(sp)
 114:	05312e23          	sw	s3,92(sp)
 118:	05412c23          	sw	s4,88(sp)
 11c:	00f00793          	li	a5,15
 120:	00f12023          	sw	a5,0(sp)
 124:	00300793          	li	a5,3
 128:	00f12223          	sw	a5,4(sp)
 12c:	00900793          	li	a5,9
 130:	00f12423          	sw	a5,8(sp)
 134:	00800793          	li	a5,8
 138:	00f12623          	sw	a5,12(sp)
 13c:	01300793          	li	a5,19
 140:	00f12823          	sw	a5,16(sp)
 144:	00100793          	li	a5,1
 148:	00f12a23          	sw	a5,20(sp)
 14c:	00e00793          	li	a5,14
 150:	00f12c23          	sw	a5,24(sp)
 154:	00200793          	li	a5,2
 158:	00f12e23          	sw	a5,28(sp)
 15c:	00700793          	li	a5,7
 160:	02f12023          	sw	a5,32(sp)
 164:	00b00793          	li	a5,11
 168:	02f12223          	sw	a5,36(sp)
 16c:	00500793          	li	a5,5
 170:	02f12423          	sw	a5,40(sp)
 174:	01200793          	li	a5,18
 178:	02f12623          	sw	a5,44(sp)
 17c:	02012823          	sw	zero,48(sp)
 180:	00d00793          	li	a5,13
 184:	02f12a23          	sw	a5,52(sp)
 188:	00c00793          	li	a5,12
 18c:	02f12c23          	sw	a5,56(sp)
 190:	00a00793          	li	a5,10
 194:	02f12e23          	sw	a5,60(sp)
 198:	00400793          	li	a5,4
 19c:	04f12023          	sw	a5,64(sp)
 1a0:	01000793          	li	a5,16
 1a4:	04f12223          	sw	a5,68(sp)
 1a8:	01100793          	li	a5,17
 1ac:	04f12423          	sw	a5,72(sp)
 1b0:	00600793          	li	a5,6
 1b4:	04f12623          	sw	a5,76(sp)
 1b8:	00010413          	mv	s0,sp
 1bc:	04c10613          	addi	a2,sp,76
 1c0:	02c0006f          	j	1ec <main+0xec>
 1c4:	00478793          	addi	a5,a5,4
 1c8:	00c78e63          	beq	a5,a2,1e4 <main+0xe4>
 1cc:	0007a703          	lw	a4,0(a5)
 1d0:	0047a683          	lw	a3,4(a5)
 1d4:	fee6d8e3          	bge	a3,a4,1c4 <main+0xc4>
 1d8:	00d7a023          	sw	a3,0(a5)
 1dc:	00e7a223          	sw	a4,4(a5)
 1e0:	fe5ff06f          	j	1c4 <main+0xc4>
 1e4:	ffc60613          	addi	a2,a2,-4
 1e8:	00860663          	beq	a2,s0,1f4 <main+0xf4>
 1ec:	00040793          	mv	a5,s0
 1f0:	fddff06f          	j	1cc <main+0xcc>
 1f4:	c00007b7          	lui	a5,0xc0000
 1f8:	0007a783          	lw	a5,0(a5) # c0000000 <__stack_top+0xbffff000>
 1fc:	00078a13          	mv	s4,a5
 200:	c00007b7          	lui	a5,0xc0000
 204:	0047a983          	lw	s3,4(a5) # c0000004 <__stack_top+0xbffff004>
 208:	0087a903          	lw	s2,8(a5)
 20c:	00c7a483          	lw	s1,12(a5)
 210:	04300513          	li	a0,67
 214:	12c000ef          	jal	340 <putchar>
 218:	03a00513          	li	a0,58
 21c:	124000ef          	jal	340 <putchar>
 220:	000a0513          	mv	a0,s4
 224:	e05ff0ef          	jal	28 <print_hex>
 228:	00d00513          	li	a0,13
 22c:	114000ef          	jal	340 <putchar>
 230:	00a00513          	li	a0,10
 234:	10c000ef          	jal	340 <putchar>
 238:	04900513          	li	a0,73
 23c:	104000ef          	jal	340 <putchar>
 240:	03a00513          	li	a0,58
 244:	0fc000ef          	jal	340 <putchar>
 248:	00098513          	mv	a0,s3
 24c:	dddff0ef          	jal	28 <print_hex>
 250:	00d00513          	li	a0,13
 254:	0ec000ef          	jal	340 <putchar>
 258:	00a00513          	li	a0,10
 25c:	0e4000ef          	jal	340 <putchar>
 260:	05300513          	li	a0,83
 264:	0dc000ef          	jal	340 <putchar>
 268:	03a00513          	li	a0,58
 26c:	0d4000ef          	jal	340 <putchar>
 270:	00090513          	mv	a0,s2
 274:	db5ff0ef          	jal	28 <print_hex>
 278:	00d00513          	li	a0,13
 27c:	0c4000ef          	jal	340 <putchar>
 280:	00a00513          	li	a0,10
 284:	0bc000ef          	jal	340 <putchar>
 288:	04600513          	li	a0,70
 28c:	0b4000ef          	jal	340 <putchar>
 290:	03a00513          	li	a0,58
 294:	0ac000ef          	jal	340 <putchar>
 298:	00048513          	mv	a0,s1
 29c:	d8dff0ef          	jal	28 <print_hex>
 2a0:	00d00513          	li	a0,13
 2a4:	09c000ef          	jal	340 <putchar>
 2a8:	00a00513          	li	a0,10
 2ac:	094000ef          	jal	340 <putchar>
 2b0:	00d00513          	li	a0,13
 2b4:	08c000ef          	jal	340 <putchar>
 2b8:	00a00513          	li	a0,10
 2bc:	084000ef          	jal	340 <putchar>
 2c0:	05040993          	addi	s3,s0,80
 2c4:	00d00913          	li	s2,13
 2c8:	00a00493          	li	s1,10
 2cc:	00042503          	lw	a0,0(s0)
 2d0:	d59ff0ef          	jal	28 <print_hex>
 2d4:	00090513          	mv	a0,s2
 2d8:	068000ef          	jal	340 <putchar>
 2dc:	00048513          	mv	a0,s1
 2e0:	060000ef          	jal	340 <putchar>
 2e4:	00440413          	addi	s0,s0,4
 2e8:	fe8992e3          	bne	s3,s0,2cc <main+0x1cc>
 2ec:	04400513          	li	a0,68
 2f0:	050000ef          	jal	340 <putchar>
 2f4:	04f00513          	li	a0,79
 2f8:	048000ef          	jal	340 <putchar>
 2fc:	04e00513          	li	a0,78
 300:	040000ef          	jal	340 <putchar>
 304:	04500513          	li	a0,69
 308:	038000ef          	jal	340 <putchar>
 30c:	00d00513          	li	a0,13
 310:	030000ef          	jal	340 <putchar>
 314:	00a00513          	li	a0,10
 318:	028000ef          	jal	340 <putchar>
 31c:	00000513          	li	a0,0
 320:	06c12083          	lw	ra,108(sp)
 324:	06812403          	lw	s0,104(sp)
 328:	06412483          	lw	s1,100(sp)
 32c:	06012903          	lw	s2,96(sp)
 330:	05c12983          	lw	s3,92(sp)
 334:	05812a03          	lw	s4,88(sp)
 338:	07010113          	addi	sp,sp,112
 33c:	00008067          	ret

00000340 <putchar>:
 340:	80000737          	lui	a4,0x80000
 344:	00072783          	lw	a5,0(a4) # 80000000 <__stack_top+0x7ffff000>
 348:	0017f793          	andi	a5,a5,1
 34c:	fe079ce3          	bnez	a5,344 <putchar+0x4>
 350:	800007b7          	lui	a5,0x80000
 354:	00a7a223          	sw	a0,4(a5) # 80000004 <__stack_top+0x7ffff004>
 358:	00008067          	ret

Disassembly of section .data:

00000000 <FLUSH_CNT>:
   0:	000c                	.insn	2, 0x000c
   2:	c000                	.insn	2, 0xc000

00000004 <STALL_CNT>:
   4:	0008                	.insn	2, 0x0008
   6:	c000                	.insn	2, 0xc000

00000008 <INSTR_CNT>:
   8:	0004                	.insn	2, 0x0004
   a:	c000                	.insn	2, 0xc000

0000000c <CYCLE_CNT>:
   c:	0000                	.insn	2, 0x0000
   e:	c000                	.insn	2, 0xc000

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	2941                	.insn	2, 0x2941
   2:	0000                	.insn	2, 0x0000
   4:	7200                	.insn	2, 0x7200
   6:	7369                	.insn	2, 0x7369
   8:	01007663          	bgeu	zero,a6,14 <__bss_end+0x4>
   c:	001f 0000 1004      	.insn	6, 0x10040000001f
  12:	7205                	.insn	2, 0x7205
  14:	3376                	.insn	2, 0x3376
  16:	6932                	.insn	2, 0x6932
  18:	7032                	.insn	2, 0x7032
  1a:	5f31                	.insn	2, 0x5f31
  1c:	326d                	.insn	2, 0x326d
  1e:	3070                	.insn	2, 0x3070
  20:	7a5f 6d6d 6c75      	.insn	6, 0x6c756d6d7a5f
  26:	7031                	.insn	2, 0x7031
  28:	0030                	.insn	2, 0x0030

Disassembly of section .comment:

00000000 <.comment>:
   0:	3a434347          	.insn	4, 0x3a434347
   4:	2820                	.insn	2, 0x2820
   6:	5078                	.insn	2, 0x5078
   8:	6361                	.insn	2, 0x6361
   a:	4e47206b          	.insn	4, 0x4e47206b
   e:	2055                	.insn	2, 0x2055
  10:	4952                	.insn	2, 0x4952
  12:	562d4353          	.insn	4, 0x562d4353
  16:	4520                	.insn	2, 0x4520
  18:	626d                	.insn	2, 0x626d
  1a:	6465                	.insn	2, 0x6465
  1c:	6564                	.insn	2, 0x6564
  1e:	2064                	.insn	2, 0x2064
  20:	20434347          	.insn	4, 0x20434347
  24:	3878                	.insn	2, 0x3878
  26:	5f36                	.insn	2, 0x5f36
  28:	3436                	.insn	2, 0x3436
  2a:	2029                	.insn	2, 0x2029
  2c:	3531                	.insn	2, 0x3531
  2e:	322e                	.insn	2, 0x322e
  30:	302e                	.insn	2, 0x302e
	...
