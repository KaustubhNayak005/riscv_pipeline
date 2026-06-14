CC = riscv-none-elf-gcc
OBJCOPY = riscv-none-elf-objcopy
OBJDUMP = riscv-none-elf-objdump

CFLAGS = -march=rv32im -mabi=ilp32 -O1 -ffreestanding -nostdlib -fno-builtin

TARGET ?= hello_world
SRCS = crt0.S demos/$(TARGET).c lib/uart.c

all: $(TARGET).mem $(TARGET).asm

$(TARGET).elf: $(SRCS) linker.ld
	$(CC) $(CFLAGS) -T linker.ld $(SRCS) -o $(TARGET).elf

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $(TARGET).elf $(TARGET).bin

$(TARGET).asm: $(TARGET).elf
	$(OBJDUMP) -D $(TARGET).elf > $(TARGET).asm

$(TARGET).mem: $(TARGET).bin
	python bin_to_mem.py $(TARGET).bin $(TARGET).mem

clean:
	rm -f *.elf *.bin *.mem *.asm
