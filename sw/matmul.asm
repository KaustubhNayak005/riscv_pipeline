
matmul.elf:     file format elf32-littleriscv


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
  28:	fe010113          	addi	sp,sp,-32 # fe0 <putchar+0xc34>
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
  dc:	2d0000ef          	jal	3ac <putchar>
  e0:	ffc40413          	addi	s0,s0,-4
  e4:	ff2412e3          	bne	s0,s2,c8 <print_hex+0xa0>
  e8:	01c12083          	lw	ra,28(sp)
  ec:	01812403          	lw	s0,24(sp)
  f0:	01412483          	lw	s1,20(sp)
  f4:	01012903          	lw	s2,16(sp)
  f8:	02010113          	addi	sp,sp,32
  fc:	00008067          	ret

00000100 <main>:
 100:	f6010113          	addi	sp,sp,-160
 104:	08112e23          	sw	ra,156(sp)
 108:	08812c23          	sw	s0,152(sp)
 10c:	08912a23          	sw	s1,148(sp)
 110:	09212823          	sw	s2,144(sp)
 114:	09312623          	sw	s3,140(sp)
 118:	09412423          	sw	s4,136(sp)
 11c:	09512223          	sw	s5,132(sp)
 120:	09612023          	sw	s6,128(sp)
 124:	07712e23          	sw	s7,124(sp)
 128:	07812c23          	sw	s8,120(sp)
 12c:	07912a23          	sw	s9,116(sp)
 130:	07a12823          	sw	s10,112(sp)
 134:	00100793          	li	a5,1
 138:	04f12623          	sw	a5,76(sp)
 13c:	00200713          	li	a4,2
 140:	04e12823          	sw	a4,80(sp)
 144:	00300693          	li	a3,3
 148:	04d12a23          	sw	a3,84(sp)
 14c:	00400613          	li	a2,4
 150:	04c12c23          	sw	a2,88(sp)
 154:	00500593          	li	a1,5
 158:	04b12e23          	sw	a1,92(sp)
 15c:	00600513          	li	a0,6
 160:	06a12023          	sw	a0,96(sp)
 164:	00700813          	li	a6,7
 168:	07012223          	sw	a6,100(sp)
 16c:	00800893          	li	a7,8
 170:	07112423          	sw	a7,104(sp)
 174:	00900313          	li	t1,9
 178:	06612623          	sw	t1,108(sp)
 17c:	02612423          	sw	t1,40(sp)
 180:	03112623          	sw	a7,44(sp)
 184:	03012823          	sw	a6,48(sp)
 188:	02a12a23          	sw	a0,52(sp)
 18c:	02b12c23          	sw	a1,56(sp)
 190:	02c12e23          	sw	a2,60(sp)
 194:	04d12023          	sw	a3,64(sp)
 198:	04e12223          	sw	a4,68(sp)
 19c:	04f12423          	sw	a5,72(sp)
 1a0:	00c10933          	add	s2,sp,a2
 1a4:	04c10593          	addi	a1,sp,76
 1a8:	07010e93          	addi	t4,sp,112
 1ac:	00090e13          	mv	t3,s2
 1b0:	03410313          	addi	t1,sp,52
 1b4:	02810713          	addi	a4,sp,40
 1b8:	0005a883          	lw	a7,0(a1)
 1bc:	0045a803          	lw	a6,4(a1)
 1c0:	0085a503          	lw	a0,8(a1)
 1c4:	000e0613          	mv	a2,t3
 1c8:	00072783          	lw	a5,0(a4)
 1cc:	02f887b3          	mul	a5,a7,a5
 1d0:	00c72683          	lw	a3,12(a4)
 1d4:	02d806b3          	mul	a3,a6,a3
 1d8:	00d787b3          	add	a5,a5,a3
 1dc:	01872683          	lw	a3,24(a4)
 1e0:	02d506b3          	mul	a3,a0,a3
 1e4:	00d787b3          	add	a5,a5,a3
 1e8:	00f62023          	sw	a5,0(a2)
 1ec:	00460613          	addi	a2,a2,4
 1f0:	00470713          	addi	a4,a4,4
 1f4:	fc671ae3          	bne	a4,t1,1c8 <main+0xc8>
 1f8:	00ce0e13          	addi	t3,t3,12
 1fc:	00c58593          	addi	a1,a1,12
 200:	fbd59ae3          	bne	a1,t4,1b4 <main+0xb4>
 204:	c00007b7          	lui	a5,0xc0000
 208:	0007a783          	lw	a5,0(a5) # c0000000 <__stack_top+0xbffff000>
 20c:	00078b93          	mv	s7,a5
 210:	c00007b7          	lui	a5,0xc0000
 214:	0047a783          	lw	a5,4(a5) # c0000004 <__stack_top+0xbffff004>
 218:	00078c13          	mv	s8,a5
 21c:	c00007b7          	lui	a5,0xc0000
 220:	0087a783          	lw	a5,8(a5) # c0000008 <__stack_top+0xbffff008>
 224:	00078c93          	mv	s9,a5
 228:	c00007b7          	lui	a5,0xc0000
 22c:	00c7a783          	lw	a5,12(a5) # c000000c <__stack_top+0xbffff00c>
 230:	00078d13          	mv	s10,a5
 234:	04d00513          	li	a0,77
 238:	174000ef          	jal	3ac <putchar>
 23c:	04100513          	li	a0,65
 240:	16c000ef          	jal	3ac <putchar>
 244:	05400513          	li	a0,84
 248:	164000ef          	jal	3ac <putchar>
 24c:	00d00513          	li	a0,13
 250:	15c000ef          	jal	3ac <putchar>
 254:	00a00513          	li	a0,10
 258:	154000ef          	jal	3ac <putchar>
 25c:	02490b13          	addi	s6,s2,36
 260:	00d00a93          	li	s5,13
 264:	00a00a13          	li	s4,10
 268:	00300993          	li	s3,3
 26c:	00090493          	mv	s1,s2
 270:	00000413          	li	s0,0
 274:	0004a503          	lw	a0,0(s1)
 278:	db1ff0ef          	jal	28 <print_hex>
 27c:	000a8513          	mv	a0,s5
 280:	12c000ef          	jal	3ac <putchar>
 284:	000a0513          	mv	a0,s4
 288:	124000ef          	jal	3ac <putchar>
 28c:	00140413          	addi	s0,s0,1
 290:	00448493          	addi	s1,s1,4
 294:	ff3410e3          	bne	s0,s3,274 <main+0x174>
 298:	00c90913          	addi	s2,s2,12
 29c:	fd6918e3          	bne	s2,s6,26c <main+0x16c>
 2a0:	04300513          	li	a0,67
 2a4:	108000ef          	jal	3ac <putchar>
 2a8:	03a00513          	li	a0,58
 2ac:	100000ef          	jal	3ac <putchar>
 2b0:	000b8513          	mv	a0,s7
 2b4:	d75ff0ef          	jal	28 <print_hex>
 2b8:	00d00513          	li	a0,13
 2bc:	0f0000ef          	jal	3ac <putchar>
 2c0:	00a00513          	li	a0,10
 2c4:	0e8000ef          	jal	3ac <putchar>
 2c8:	04900513          	li	a0,73
 2cc:	0e0000ef          	jal	3ac <putchar>
 2d0:	03a00513          	li	a0,58
 2d4:	0d8000ef          	jal	3ac <putchar>
 2d8:	000c0513          	mv	a0,s8
 2dc:	d4dff0ef          	jal	28 <print_hex>
 2e0:	00d00513          	li	a0,13
 2e4:	0c8000ef          	jal	3ac <putchar>
 2e8:	00a00513          	li	a0,10
 2ec:	0c0000ef          	jal	3ac <putchar>
 2f0:	05300513          	li	a0,83
 2f4:	0b8000ef          	jal	3ac <putchar>
 2f8:	03a00513          	li	a0,58
 2fc:	0b0000ef          	jal	3ac <putchar>
 300:	000c8513          	mv	a0,s9
 304:	d25ff0ef          	jal	28 <print_hex>
 308:	00d00513          	li	a0,13
 30c:	0a0000ef          	jal	3ac <putchar>
 310:	00a00513          	li	a0,10
 314:	098000ef          	jal	3ac <putchar>
 318:	04600513          	li	a0,70
 31c:	090000ef          	jal	3ac <putchar>
 320:	03a00513          	li	a0,58
 324:	088000ef          	jal	3ac <putchar>
 328:	000d0513          	mv	a0,s10
 32c:	cfdff0ef          	jal	28 <print_hex>
 330:	00d00513          	li	a0,13
 334:	078000ef          	jal	3ac <putchar>
 338:	00a00513          	li	a0,10
 33c:	070000ef          	jal	3ac <putchar>
 340:	04400513          	li	a0,68
 344:	068000ef          	jal	3ac <putchar>
 348:	04f00513          	li	a0,79
 34c:	060000ef          	jal	3ac <putchar>
 350:	04e00513          	li	a0,78
 354:	058000ef          	jal	3ac <putchar>
 358:	04500513          	li	a0,69
 35c:	050000ef          	jal	3ac <putchar>
 360:	00d00513          	li	a0,13
 364:	048000ef          	jal	3ac <putchar>
 368:	00a00513          	li	a0,10
 36c:	040000ef          	jal	3ac <putchar>
 370:	00000513          	li	a0,0
 374:	09c12083          	lw	ra,156(sp)
 378:	09812403          	lw	s0,152(sp)
 37c:	09412483          	lw	s1,148(sp)
 380:	09012903          	lw	s2,144(sp)
 384:	08c12983          	lw	s3,140(sp)
 388:	08812a03          	lw	s4,136(sp)
 38c:	08412a83          	lw	s5,132(sp)
 390:	08012b03          	lw	s6,128(sp)
 394:	07c12b83          	lw	s7,124(sp)
 398:	07812c03          	lw	s8,120(sp)
 39c:	07412c83          	lw	s9,116(sp)
 3a0:	07012d03          	lw	s10,112(sp)
 3a4:	0a010113          	addi	sp,sp,160
 3a8:	00008067          	ret

000003ac <putchar>:
 3ac:	80000737          	lui	a4,0x80000
 3b0:	00072783          	lw	a5,0(a4) # 80000000 <__stack_top+0x7ffff000>
 3b4:	0017f793          	andi	a5,a5,1
 3b8:	fe079ce3          	bnez	a5,3b0 <putchar+0x4>
 3bc:	800007b7          	lui	a5,0x80000
 3c0:	00a7a223          	sw	a0,4(a5) # 80000004 <__stack_top+0x7ffff004>
 3c4:	00008067          	ret

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
