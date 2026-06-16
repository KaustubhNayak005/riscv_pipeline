
primes.elf:     file format elf32-littleriscv


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
  28:	fe010113          	addi	sp,sp,-32 # fe0 <putchar+0xcc4>
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
  dc:	240000ef          	jal	31c <putchar>
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
 10c:	05512a23          	sw	s5,84(sp)
 110:	05612823          	sw	s6,80(sp)
 114:	05712623          	sw	s7,76(sp)
 118:	05812423          	sw	s8,72(sp)
 11c:	00200693          	li	a3,2
 120:	00000413          	li	s0,0
 124:	00068593          	mv	a1,a3
 128:	00410513          	addi	a0,sp,4
 12c:	03200613          	li	a2,50
 130:	03c0006f          	j	16c <main+0x6c>
 134:	00170713          	addi	a4,a4,1
 138:	00d70e63          	beq	a4,a3,154 <main+0x54>
 13c:	00068793          	mv	a5,a3
 140:	fee6cae3          	blt	a3,a4,134 <main+0x34>
 144:	40e787b3          	sub	a5,a5,a4
 148:	fee7dee3          	bge	a5,a4,144 <main+0x44>
 14c:	fe0794e3          	bnez	a5,134 <main+0x34>
 150:	0140006f          	j	164 <main+0x64>
 154:	00241793          	slli	a5,s0,0x2
 158:	00a787b3          	add	a5,a5,a0
 15c:	00d7a023          	sw	a3,0(a5)
 160:	00140413          	addi	s0,s0,1
 164:	00168693          	addi	a3,a3,1
 168:	00c68863          	beq	a3,a2,178 <main+0x78>
 16c:	00200713          	li	a4,2
 170:	fcd5c6e3          	blt	a1,a3,13c <main+0x3c>
 174:	fe1ff06f          	j	154 <main+0x54>
 178:	c00007b7          	lui	a5,0xc0000
 17c:	0007a783          	lw	a5,0(a5) # c0000000 <__stack_top+0xbffff000>
 180:	00078a93          	mv	s5,a5
 184:	c00007b7          	lui	a5,0xc0000
 188:	0047a783          	lw	a5,4(a5) # c0000004 <__stack_top+0xbffff004>
 18c:	00078b13          	mv	s6,a5
 190:	c00007b7          	lui	a5,0xc0000
 194:	0087a783          	lw	a5,8(a5) # c0000008 <__stack_top+0xbffff008>
 198:	00078b93          	mv	s7,a5
 19c:	c00007b7          	lui	a5,0xc0000
 1a0:	00c7a783          	lw	a5,12(a5) # c000000c <__stack_top+0xbffff00c>
 1a4:	00078c13          	mv	s8,a5
 1a8:	05000513          	li	a0,80
 1ac:	170000ef          	jal	31c <putchar>
 1b0:	05200513          	li	a0,82
 1b4:	168000ef          	jal	31c <putchar>
 1b8:	04d00513          	li	a0,77
 1bc:	160000ef          	jal	31c <putchar>
 1c0:	00d00513          	li	a0,13
 1c4:	158000ef          	jal	31c <putchar>
 1c8:	00a00513          	li	a0,10
 1cc:	150000ef          	jal	31c <putchar>
 1d0:	04805c63          	blez	s0,228 <main+0x128>
 1d4:	06912223          	sw	s1,100(sp)
 1d8:	07212023          	sw	s2,96(sp)
 1dc:	05312e23          	sw	s3,92(sp)
 1e0:	05412c23          	sw	s4,88(sp)
 1e4:	00410913          	addi	s2,sp,4
 1e8:	00000493          	li	s1,0
 1ec:	00d00a13          	li	s4,13
 1f0:	00a00993          	li	s3,10
 1f4:	00092503          	lw	a0,0(s2)
 1f8:	e31ff0ef          	jal	28 <print_hex>
 1fc:	000a0513          	mv	a0,s4
 200:	11c000ef          	jal	31c <putchar>
 204:	00098513          	mv	a0,s3
 208:	114000ef          	jal	31c <putchar>
 20c:	00148493          	addi	s1,s1,1
 210:	00490913          	addi	s2,s2,4
 214:	fe9410e3          	bne	s0,s1,1f4 <main+0xf4>
 218:	06412483          	lw	s1,100(sp)
 21c:	06012903          	lw	s2,96(sp)
 220:	05c12983          	lw	s3,92(sp)
 224:	05812a03          	lw	s4,88(sp)
 228:	04300513          	li	a0,67
 22c:	0f0000ef          	jal	31c <putchar>
 230:	03a00513          	li	a0,58
 234:	0e8000ef          	jal	31c <putchar>
 238:	000a8513          	mv	a0,s5
 23c:	dedff0ef          	jal	28 <print_hex>
 240:	00d00513          	li	a0,13
 244:	0d8000ef          	jal	31c <putchar>
 248:	00a00513          	li	a0,10
 24c:	0d0000ef          	jal	31c <putchar>
 250:	04900513          	li	a0,73
 254:	0c8000ef          	jal	31c <putchar>
 258:	03a00513          	li	a0,58
 25c:	0c0000ef          	jal	31c <putchar>
 260:	000b0513          	mv	a0,s6
 264:	dc5ff0ef          	jal	28 <print_hex>
 268:	00d00513          	li	a0,13
 26c:	0b0000ef          	jal	31c <putchar>
 270:	00a00513          	li	a0,10
 274:	0a8000ef          	jal	31c <putchar>
 278:	05300513          	li	a0,83
 27c:	0a0000ef          	jal	31c <putchar>
 280:	03a00513          	li	a0,58
 284:	098000ef          	jal	31c <putchar>
 288:	000b8513          	mv	a0,s7
 28c:	d9dff0ef          	jal	28 <print_hex>
 290:	00d00513          	li	a0,13
 294:	088000ef          	jal	31c <putchar>
 298:	00a00513          	li	a0,10
 29c:	080000ef          	jal	31c <putchar>
 2a0:	04600513          	li	a0,70
 2a4:	078000ef          	jal	31c <putchar>
 2a8:	03a00513          	li	a0,58
 2ac:	070000ef          	jal	31c <putchar>
 2b0:	000c0513          	mv	a0,s8
 2b4:	d75ff0ef          	jal	28 <print_hex>
 2b8:	00d00513          	li	a0,13
 2bc:	060000ef          	jal	31c <putchar>
 2c0:	00a00513          	li	a0,10
 2c4:	058000ef          	jal	31c <putchar>
 2c8:	04400513          	li	a0,68
 2cc:	050000ef          	jal	31c <putchar>
 2d0:	04f00513          	li	a0,79
 2d4:	048000ef          	jal	31c <putchar>
 2d8:	04e00513          	li	a0,78
 2dc:	040000ef          	jal	31c <putchar>
 2e0:	04500513          	li	a0,69
 2e4:	038000ef          	jal	31c <putchar>
 2e8:	00d00513          	li	a0,13
 2ec:	030000ef          	jal	31c <putchar>
 2f0:	00a00513          	li	a0,10
 2f4:	028000ef          	jal	31c <putchar>
 2f8:	00000513          	li	a0,0
 2fc:	06c12083          	lw	ra,108(sp)
 300:	06812403          	lw	s0,104(sp)
 304:	05412a83          	lw	s5,84(sp)
 308:	05012b03          	lw	s6,80(sp)
 30c:	04c12b83          	lw	s7,76(sp)
 310:	04812c03          	lw	s8,72(sp)
 314:	07010113          	addi	sp,sp,112
 318:	00008067          	ret

0000031c <putchar>:
 31c:	80000737          	lui	a4,0x80000
 320:	00072783          	lw	a5,0(a4) # 80000000 <__stack_top+0x7ffff000>
 324:	0017f793          	andi	a5,a5,1
 328:	fe079ce3          	bnez	a5,320 <putchar+0x4>
 32c:	800007b7          	lui	a5,0x80000
 330:	00a7a223          	sw	a0,4(a5) # 80000004 <__stack_top+0x7ffff004>
 334:	00008067          	ret

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
