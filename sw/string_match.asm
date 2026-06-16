
string_match.elf:     file format elf32-littleriscv


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
  28:	fe010113          	addi	sp,sp,-32 # fe0 <putchar+0xd18>
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
  dc:	1ec000ef          	jal	2c8 <putchar>
  e0:	ffc40413          	addi	s0,s0,-4
  e4:	ff2412e3          	bne	s0,s2,c8 <print_hex+0xa0>
  e8:	01c12083          	lw	ra,28(sp)
  ec:	01812403          	lw	s0,24(sp)
  f0:	01412483          	lw	s1,20(sp)
  f4:	01012903          	lw	s2,16(sp)
  f8:	02010113          	addi	sp,sp,32
  fc:	00008067          	ret

00000100 <main>:
 100:	fa010113          	addi	sp,sp,-96
 104:	04112e23          	sw	ra,92(sp)
 108:	04812c23          	sw	s0,88(sp)
 10c:	04912a23          	sw	s1,84(sp)
 110:	05212823          	sw	s2,80(sp)
 114:	05312623          	sw	s3,76(sp)
 118:	05412423          	sw	s4,72(sp)
 11c:	00010713          	mv	a4,sp
 120:	00010693          	mv	a3,sp
 124:	00000793          	li	a5,0
 128:	04000613          	li	a2,64
 12c:	00f68023          	sb	a5,0(a3)
 130:	00d78793          	addi	a5,a5,13
 134:	0ff7f793          	zext.b	a5,a5
 138:	00168693          	addi	a3,a3,1
 13c:	fec798e3          	bne	a5,a2,12c <main+0x2c>
 140:	04070613          	addi	a2,a4,64
 144:	00000413          	li	s0,0
 148:	01a00693          	li	a3,26
 14c:	00074783          	lbu	a5,0(a4)
 150:	40d787b3          	sub	a5,a5,a3
 154:	0017b793          	seqz	a5,a5
 158:	00f40433          	add	s0,s0,a5
 15c:	00170713          	addi	a4,a4,1
 160:	fec716e3          	bne	a4,a2,14c <main+0x4c>
 164:	c00007b7          	lui	a5,0xc0000
 168:	0007a783          	lw	a5,0(a5) # c0000000 <__stack_top+0xbffff000>
 16c:	00078493          	mv	s1,a5
 170:	c00007b7          	lui	a5,0xc0000
 174:	0047a783          	lw	a5,4(a5) # c0000004 <__stack_top+0xbffff004>
 178:	00078913          	mv	s2,a5
 17c:	c00007b7          	lui	a5,0xc0000
 180:	0087a783          	lw	a5,8(a5) # c0000008 <__stack_top+0xbffff008>
 184:	00078993          	mv	s3,a5
 188:	c00007b7          	lui	a5,0xc0000
 18c:	00c7a783          	lw	a5,12(a5) # c000000c <__stack_top+0xbffff00c>
 190:	00078a13          	mv	s4,a5
 194:	05300513          	li	a0,83
 198:	130000ef          	jal	2c8 <putchar>
 19c:	05400513          	li	a0,84
 1a0:	128000ef          	jal	2c8 <putchar>
 1a4:	05200513          	li	a0,82
 1a8:	120000ef          	jal	2c8 <putchar>
 1ac:	00d00513          	li	a0,13
 1b0:	118000ef          	jal	2c8 <putchar>
 1b4:	00a00513          	li	a0,10
 1b8:	110000ef          	jal	2c8 <putchar>
 1bc:	00040513          	mv	a0,s0
 1c0:	e69ff0ef          	jal	28 <print_hex>
 1c4:	00d00513          	li	a0,13
 1c8:	100000ef          	jal	2c8 <putchar>
 1cc:	00a00513          	li	a0,10
 1d0:	0f8000ef          	jal	2c8 <putchar>
 1d4:	04300513          	li	a0,67
 1d8:	0f0000ef          	jal	2c8 <putchar>
 1dc:	03a00513          	li	a0,58
 1e0:	0e8000ef          	jal	2c8 <putchar>
 1e4:	00048513          	mv	a0,s1
 1e8:	e41ff0ef          	jal	28 <print_hex>
 1ec:	00d00513          	li	a0,13
 1f0:	0d8000ef          	jal	2c8 <putchar>
 1f4:	00a00513          	li	a0,10
 1f8:	0d0000ef          	jal	2c8 <putchar>
 1fc:	04900513          	li	a0,73
 200:	0c8000ef          	jal	2c8 <putchar>
 204:	03a00513          	li	a0,58
 208:	0c0000ef          	jal	2c8 <putchar>
 20c:	00090513          	mv	a0,s2
 210:	e19ff0ef          	jal	28 <print_hex>
 214:	00d00513          	li	a0,13
 218:	0b0000ef          	jal	2c8 <putchar>
 21c:	00a00513          	li	a0,10
 220:	0a8000ef          	jal	2c8 <putchar>
 224:	05300513          	li	a0,83
 228:	0a0000ef          	jal	2c8 <putchar>
 22c:	03a00513          	li	a0,58
 230:	098000ef          	jal	2c8 <putchar>
 234:	00098513          	mv	a0,s3
 238:	df1ff0ef          	jal	28 <print_hex>
 23c:	00d00513          	li	a0,13
 240:	088000ef          	jal	2c8 <putchar>
 244:	00a00513          	li	a0,10
 248:	080000ef          	jal	2c8 <putchar>
 24c:	04600513          	li	a0,70
 250:	078000ef          	jal	2c8 <putchar>
 254:	03a00513          	li	a0,58
 258:	070000ef          	jal	2c8 <putchar>
 25c:	000a0513          	mv	a0,s4
 260:	dc9ff0ef          	jal	28 <print_hex>
 264:	00d00513          	li	a0,13
 268:	060000ef          	jal	2c8 <putchar>
 26c:	00a00513          	li	a0,10
 270:	058000ef          	jal	2c8 <putchar>
 274:	04400513          	li	a0,68
 278:	050000ef          	jal	2c8 <putchar>
 27c:	04f00513          	li	a0,79
 280:	048000ef          	jal	2c8 <putchar>
 284:	04e00513          	li	a0,78
 288:	040000ef          	jal	2c8 <putchar>
 28c:	04500513          	li	a0,69
 290:	038000ef          	jal	2c8 <putchar>
 294:	00d00513          	li	a0,13
 298:	030000ef          	jal	2c8 <putchar>
 29c:	00a00513          	li	a0,10
 2a0:	028000ef          	jal	2c8 <putchar>
 2a4:	00000513          	li	a0,0
 2a8:	05c12083          	lw	ra,92(sp)
 2ac:	05812403          	lw	s0,88(sp)
 2b0:	05412483          	lw	s1,84(sp)
 2b4:	05012903          	lw	s2,80(sp)
 2b8:	04c12983          	lw	s3,76(sp)
 2bc:	04812a03          	lw	s4,72(sp)
 2c0:	06010113          	addi	sp,sp,96
 2c4:	00008067          	ret

000002c8 <putchar>:
 2c8:	80000737          	lui	a4,0x80000
 2cc:	00072783          	lw	a5,0(a4) # 80000000 <__stack_top+0x7ffff000>
 2d0:	0017f793          	andi	a5,a5,1
 2d4:	fe079ce3          	bnez	a5,2cc <putchar+0x4>
 2d8:	800007b7          	lui	a5,0x80000
 2dc:	00a7a223          	sw	a0,4(a5) # 80000004 <__stack_top+0x7ffff004>
 2e0:	00008067          	ret

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
