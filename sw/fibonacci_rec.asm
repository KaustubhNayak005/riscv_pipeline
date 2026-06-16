
fibonacci_rec.elf:     file format elf32-littleriscv


Disassembly of section .text:

00000000 <_start>:
   0:	00001137          	lui	sp,0x1
   4:	02400513          	li	a0,36
   8:	02400593          	li	a1,36
   c:	00b55863          	bge	a0,a1,1c <bss_clear_done>

00000010 <bss_clear_loop>:
  10:	00052023          	sw	zero,0(a0)
  14:	00450513          	addi	a0,a0,4
  18:	feb54ce3          	blt	a0,a1,10 <bss_clear_loop>

0000001c <bss_clear_done>:
  1c:	0d0000ef          	jal	ec <main>

00000020 <halt>:
  20:	00000073          	ecall
  24:	ffdff06f          	j	20 <halt>

00000028 <print_hex>:
  28:	fe010113          	addi	sp,sp,-32 # fe0 <putchar+0xd68>
  2c:	00112e23          	sw	ra,28(sp)
  30:	00812c23          	sw	s0,24(sp)
  34:	00912a23          	sw	s1,20(sp)
  38:	01212823          	sw	s2,16(sp)
  3c:	00050493          	mv	s1,a0
  40:	00000793          	li	a5,0
  44:	0007a603          	lw	a2,0(a5)
  48:	0047a683          	lw	a3,4(a5)
  4c:	0087a703          	lw	a4,8(a5)
  50:	00c12023          	sw	a2,0(sp)
  54:	00d12223          	sw	a3,4(sp)
  58:	00e12423          	sw	a4,8(sp)
  5c:	00c7a783          	lw	a5,12(a5)
  60:	00f12623          	sw	a5,12(sp)
  64:	01c00413          	li	s0,28
  68:	ffc00913          	li	s2,-4
  6c:	0084d7b3          	srl	a5,s1,s0
  70:	00f7f793          	andi	a5,a5,15
  74:	01078793          	addi	a5,a5,16
  78:	002787b3          	add	a5,a5,sp
  7c:	ff07c503          	lbu	a0,-16(a5)
  80:	1f8000ef          	jal	278 <putchar>
  84:	ffc40413          	addi	s0,s0,-4
  88:	ff2412e3          	bne	s0,s2,6c <print_hex+0x44>
  8c:	01c12083          	lw	ra,28(sp)
  90:	01812403          	lw	s0,24(sp)
  94:	01412483          	lw	s1,20(sp)
  98:	01012903          	lw	s2,16(sp)
  9c:	02010113          	addi	sp,sp,32
  a0:	00008067          	ret

000000a4 <fib>:
  a4:	ff010113          	addi	sp,sp,-16
  a8:	00112623          	sw	ra,12(sp)
  ac:	00812423          	sw	s0,8(sp)
  b0:	00050413          	mv	s0,a0
  b4:	00100793          	li	a5,1
  b8:	02a7d263          	bge	a5,a0,dc <fib+0x38>
  bc:	00912223          	sw	s1,4(sp)
  c0:	fff50513          	addi	a0,a0,-1
  c4:	fe1ff0ef          	jal	a4 <fib>
  c8:	00050493          	mv	s1,a0
  cc:	ffe40513          	addi	a0,s0,-2
  d0:	fd5ff0ef          	jal	a4 <fib>
  d4:	00a48533          	add	a0,s1,a0
  d8:	00412483          	lw	s1,4(sp)
  dc:	00c12083          	lw	ra,12(sp)
  e0:	00812403          	lw	s0,8(sp)
  e4:	01010113          	addi	sp,sp,16
  e8:	00008067          	ret

000000ec <main>:
  ec:	fe010113          	addi	sp,sp,-32
  f0:	00112e23          	sw	ra,28(sp)
  f4:	00812c23          	sw	s0,24(sp)
  f8:	00912a23          	sw	s1,20(sp)
  fc:	01212823          	sw	s2,16(sp)
 100:	01312623          	sw	s3,12(sp)
 104:	01412423          	sw	s4,8(sp)
 108:	00f00513          	li	a0,15
 10c:	f99ff0ef          	jal	a4 <fib>
 110:	00050413          	mv	s0,a0
 114:	c00007b7          	lui	a5,0xc0000
 118:	0007a783          	lw	a5,0(a5) # c0000000 <__stack_top+0xbffff000>
 11c:	00078493          	mv	s1,a5
 120:	c00007b7          	lui	a5,0xc0000
 124:	0047a783          	lw	a5,4(a5) # c0000004 <__stack_top+0xbffff004>
 128:	00078913          	mv	s2,a5
 12c:	c00007b7          	lui	a5,0xc0000
 130:	0087a783          	lw	a5,8(a5) # c0000008 <__stack_top+0xbffff008>
 134:	00078993          	mv	s3,a5
 138:	c00007b7          	lui	a5,0xc0000
 13c:	00c7a783          	lw	a5,12(a5) # c000000c <__stack_top+0xbffff00c>
 140:	00078a13          	mv	s4,a5
 144:	04600513          	li	a0,70
 148:	130000ef          	jal	278 <putchar>
 14c:	04900513          	li	a0,73
 150:	128000ef          	jal	278 <putchar>
 154:	04200513          	li	a0,66
 158:	120000ef          	jal	278 <putchar>
 15c:	00d00513          	li	a0,13
 160:	118000ef          	jal	278 <putchar>
 164:	00a00513          	li	a0,10
 168:	110000ef          	jal	278 <putchar>
 16c:	00040513          	mv	a0,s0
 170:	eb9ff0ef          	jal	28 <print_hex>
 174:	00d00513          	li	a0,13
 178:	100000ef          	jal	278 <putchar>
 17c:	00a00513          	li	a0,10
 180:	0f8000ef          	jal	278 <putchar>
 184:	04300513          	li	a0,67
 188:	0f0000ef          	jal	278 <putchar>
 18c:	03a00513          	li	a0,58
 190:	0e8000ef          	jal	278 <putchar>
 194:	00048513          	mv	a0,s1
 198:	e91ff0ef          	jal	28 <print_hex>
 19c:	00d00513          	li	a0,13
 1a0:	0d8000ef          	jal	278 <putchar>
 1a4:	00a00513          	li	a0,10
 1a8:	0d0000ef          	jal	278 <putchar>
 1ac:	04900513          	li	a0,73
 1b0:	0c8000ef          	jal	278 <putchar>
 1b4:	03a00513          	li	a0,58
 1b8:	0c0000ef          	jal	278 <putchar>
 1bc:	00090513          	mv	a0,s2
 1c0:	e69ff0ef          	jal	28 <print_hex>
 1c4:	00d00513          	li	a0,13
 1c8:	0b0000ef          	jal	278 <putchar>
 1cc:	00a00513          	li	a0,10
 1d0:	0a8000ef          	jal	278 <putchar>
 1d4:	05300513          	li	a0,83
 1d8:	0a0000ef          	jal	278 <putchar>
 1dc:	03a00513          	li	a0,58
 1e0:	098000ef          	jal	278 <putchar>
 1e4:	00098513          	mv	a0,s3
 1e8:	e41ff0ef          	jal	28 <print_hex>
 1ec:	00d00513          	li	a0,13
 1f0:	088000ef          	jal	278 <putchar>
 1f4:	00a00513          	li	a0,10
 1f8:	080000ef          	jal	278 <putchar>
 1fc:	04600513          	li	a0,70
 200:	078000ef          	jal	278 <putchar>
 204:	03a00513          	li	a0,58
 208:	070000ef          	jal	278 <putchar>
 20c:	000a0513          	mv	a0,s4
 210:	e19ff0ef          	jal	28 <print_hex>
 214:	00d00513          	li	a0,13
 218:	060000ef          	jal	278 <putchar>
 21c:	00a00513          	li	a0,10
 220:	058000ef          	jal	278 <putchar>
 224:	04400513          	li	a0,68
 228:	050000ef          	jal	278 <putchar>
 22c:	04f00513          	li	a0,79
 230:	048000ef          	jal	278 <putchar>
 234:	04e00513          	li	a0,78
 238:	040000ef          	jal	278 <putchar>
 23c:	04500513          	li	a0,69
 240:	038000ef          	jal	278 <putchar>
 244:	00d00513          	li	a0,13
 248:	030000ef          	jal	278 <putchar>
 24c:	00a00513          	li	a0,10
 250:	028000ef          	jal	278 <putchar>
 254:	00000513          	li	a0,0
 258:	01c12083          	lw	ra,28(sp)
 25c:	01812403          	lw	s0,24(sp)
 260:	01412483          	lw	s1,20(sp)
 264:	01012903          	lw	s2,16(sp)
 268:	00c12983          	lw	s3,12(sp)
 26c:	00812a03          	lw	s4,8(sp)
 270:	02010113          	addi	sp,sp,32
 274:	00008067          	ret

00000278 <putchar>:
 278:	80000737          	lui	a4,0x80000
 27c:	00072783          	lw	a5,0(a4) # 80000000 <__stack_top+0x7ffff000>
 280:	0017f793          	andi	a5,a5,1
 284:	fe079ce3          	bnez	a5,27c <putchar+0x4>
 288:	800007b7          	lui	a5,0x80000
 28c:	00a7a223          	sw	a0,4(a5) # 80000004 <__stack_top+0x7ffff004>
 290:	00008067          	ret

Disassembly of section .data:

00000000 <FLUSH_CNT-0x14>:
   0:	3130                	.insn	2, 0x3130
   2:	3332                	.insn	2, 0x3332
   4:	3534                	.insn	2, 0x3534
   6:	3736                	.insn	2, 0x3736
   8:	3938                	.insn	2, 0x3938
   a:	4241                	.insn	2, 0x4241
   c:	46454443          	.insn	4, 0x46454443
  10:	0000                	.insn	2, 0x0000
	...

00000014 <FLUSH_CNT>:
  14:	000c                	.insn	2, 0x000c
  16:	c000                	.insn	2, 0xc000

00000018 <STALL_CNT>:
  18:	0008                	.insn	2, 0x0008
  1a:	c000                	.insn	2, 0xc000

0000001c <INSTR_CNT>:
  1c:	0004                	.insn	2, 0x0004
  1e:	c000                	.insn	2, 0xc000

00000020 <CYCLE_CNT>:
  20:	0000                	.insn	2, 0x0000
  22:	c000                	.insn	2, 0xc000

Disassembly of section .riscv.attributes:

00000000 <.riscv.attributes>:
   0:	2941                	.insn	2, 0x2941
   2:	0000                	.insn	2, 0x0000
   4:	7200                	.insn	2, 0x7200
   6:	7369                	.insn	2, 0x7369
   8:	01007663          	bgeu	zero,a6,14 <FLUSH_CNT>
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
