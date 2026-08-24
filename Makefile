# object files
OBJ_DIR = objects

OBJ = $(addprefix $(OBJ_DIR)/, \
	boot.o \
	main.o \
	print.o \
	idt_asm.o \
	idt_c-code.o \
	io.o \
	ps2_driver.o \
	pic_driver.o \
	pmm.o \
	heap.o \
	paging.o \
	ata_driver.o \
	pci_driver.o \
	initramfs.o \
	fat16.o \
	mbr.o \
	vfs.o \
	elf32.o \
	shell.o \
	interpreter.o \
	fs_commands.o \
	sysinfo_commands.o \
	util.o \
	syscall.o \
)

# flags and path to headers folder
CFLAGS = -m32 -ffreestanding -O0 -fno-pic -fno-pie -fno-stack-protector \
	-Ikernel/headers -Ikernel -Ikernel/drivers/cpu -Ikernel/drivers/sleep \
	-mno-sse -mno-sse2 -mno-mmx -msoft-float -c

all: aldise.iso

# rule to ensure objects directory exists
$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

# ---------------------------------------------------------
# Boot
# ---------------------------------------------------------

$(OBJ_DIR)/boot.o: boot.asm | $(OBJ_DIR)
	# assemble bootloader to elf32 for grub
	nasm -f elf32 boot.asm -o $(OBJ_DIR)/boot.o

# ---------------------------------------------------------
# Core kernel
# ---------------------------------------------------------

$(OBJ_DIR)/main.o: kernel/main.c | $(OBJ_DIR)
	# compile main kernel code
	gcc $(CFLAGS) kernel/main.c -o $(OBJ_DIR)/main.o

$(OBJ_DIR)/print.o: kernel/print.c | $(OBJ_DIR)
	# compile printing and screen functions
	gcc $(CFLAGS) kernel/print.c -o $(OBJ_DIR)/print.o

$(OBJ_DIR)/io.o: kernel/io.c | $(OBJ_DIR)
	# compile hardware port input/output functions
	gcc $(CFLAGS) kernel/io.c -o $(OBJ_DIR)/io.o

# ---------------------------------------------------------
# Interrupts
# ---------------------------------------------------------

$(OBJ_DIR)/idt_asm.o: kernel/idt/idt_asm.asm | $(OBJ_DIR)
	# compile interrupt descriptor table assembly
	nasm -f elf32 kernel/idt/idt_asm.asm -o $(OBJ_DIR)/idt_asm.o

$(OBJ_DIR)/idt_c-code.o: kernel/idt/idt.c | $(OBJ_DIR)
	# compile C version of IDT
	gcc $(CFLAGS) kernel/idt/idt.c -o $(OBJ_DIR)/idt_c-code.o

$(OBJ_DIR)/pic_driver.o: kernel/interrupts/pic.c | $(OBJ_DIR)
	# compile PIC driver
	gcc $(CFLAGS) kernel/interrupts/pic.c -o $(OBJ_DIR)/pic_driver.o

# ---------------------------------------------------------
# Hardware drivers
# ---------------------------------------------------------

$(OBJ_DIR)/ps2_driver.o: kernel/drivers/ps2.c | $(OBJ_DIR)
	# compile PS/2 driver
	gcc $(CFLAGS) kernel/drivers/ps2.c -o $(OBJ_DIR)/ps2_driver.o

$(OBJ_DIR)/ata_driver.o: kernel/drivers/ata.c | $(OBJ_DIR)
	# compile ATA PIO disk driver
	gcc $(CFLAGS) kernel/drivers/ata.c -o $(OBJ_DIR)/ata_driver.o

$(OBJ_DIR)/pci_driver.o: kernel/drivers/pci.c | $(OBJ_DIR)
	# compile PCI driver
	gcc $(CFLAGS) kernel/drivers/pci.c -o $(OBJ_DIR)/pci_driver.o

# ---------------------------------------------------------
# Memory management
# ---------------------------------------------------------

$(OBJ_DIR)/pmm.o: kernel/mm/pmm.c | $(OBJ_DIR)
	# compile physical memory manager
	gcc $(CFLAGS) kernel/mm/pmm.c -o $(OBJ_DIR)/pmm.o

$(OBJ_DIR)/heap.o: kernel/mm/heap.c | $(OBJ_DIR)
	# compile kernel heap allocator
	gcc $(CFLAGS) kernel/mm/heap.c -o $(OBJ_DIR)/heap.o

$(OBJ_DIR)/paging.o: kernel/mm/paging.c | $(OBJ_DIR)
	# compile paging
	gcc $(CFLAGS) kernel/mm/paging.c -o $(OBJ_DIR)/paging.o

# ---------------------------------------------------------
# Initramfs
# ---------------------------------------------------------

$(OBJ_DIR)/initramfs.o: kernel/initramfs.c | $(OBJ_DIR)
	# compile initramfs
	gcc $(CFLAGS) kernel/initramfs.c -o $(OBJ_DIR)/initramfs.o

# ---------------------------------------------------------
# Filesystem
# ---------------------------------------------------------

$(OBJ_DIR)/fat16.o: kernel/fs/fat16.c | $(OBJ_DIR)
	# compile FAT16 filesystem
	gcc $(CFLAGS) kernel/fs/fat16.c -o $(OBJ_DIR)/fat16.o

$(OBJ_DIR)/mbr.o: kernel/fs/mbr.c | $(OBJ_DIR)
	# compile MBR support
	gcc $(CFLAGS) kernel/fs/mbr.c -o $(OBJ_DIR)/mbr.o

$(OBJ_DIR)/vfs.o: kernel/fs/vfs.c | $(OBJ_DIR)
	# compile virtual filesystem
	gcc $(CFLAGS) kernel/fs/vfs.c -o $(OBJ_DIR)/vfs.o

# ---------------------------------------------------------
# ELF
# ---------------------------------------------------------

$(OBJ_DIR)/elf32.o: kernel/elf/elf32.c | $(OBJ_DIR)
	# compile ELF32 loader from clean kernel folder tree
	gcc $(CFLAGS) kernel/elf/elf32.c -o $(OBJ_DIR)/elf32.o

# ---------------------------------------------------------
# Shell
# ---------------------------------------------------------

$(OBJ_DIR)/shell.o: kernel/shell/shell.c | $(OBJ_DIR)
	# compile shell
	gcc $(CFLAGS) -Ikernel/shell/headers kernel/shell/shell.c -o $(OBJ_DIR)/shell.o

$(OBJ_DIR)/interpreter.o: kernel/shell/interpreter.c | $(OBJ_DIR)
	# compile shell command interpreter
	gcc $(CFLAGS) -Ikernel/shell/headers kernel/shell/interpreter.c -o $(OBJ_DIR)/interpreter.o

$(OBJ_DIR)/fs_commands.o: kernel/shell/fs_commands.c | $(OBJ_DIR)
	# compile filesystem shell commands
	gcc $(CFLAGS) -Ikernel/shell/headers kernel/shell/fs_commands.c -o $(OBJ_DIR)/fs_commands.o

$(OBJ_DIR)/sysinfo_commands.o: kernel/shell/sysinfo_commands.c | $(OBJ_DIR)
	# compile system information commands
	gcc $(CFLAGS) -Ikernel/shell/headers kernel/shell/sysinfo_commands.c -o $(OBJ_DIR)/sysinfo_commands.o

$(OBJ_DIR)/util.o: kernel/shell/util.c | $(OBJ_DIR)
	# compile shell utilities
	gcc $(CFLAGS) -Ikernel/shell/headers kernel/shell/util.c -o $(OBJ_DIR)/util.o

# ---------------------------------------------------------
# Syscalls
# ---------------------------------------------------------

$(OBJ_DIR)/syscall.o: kernel/syscalls/syscall.c | $(OBJ_DIR)
	# compile syscall layer
	gcc $(CFLAGS) kernel/syscalls/syscall.c -o $(OBJ_DIR)/syscall.o

# ---------------------------------------------------------
# Link kernel
# ---------------------------------------------------------

kernel.bin: $(OBJ)
	# link everything using linker script
	ld -m elf_i386 -T linker.ld --build-id=none $(OBJ) -o kernel.bin

# ---------------------------------------------------------
# Build ISO
# ---------------------------------------------------------

aldise.iso: kernel.bin
	# build GRUB ISO image for Aldise base kernel
	mkdir -p iso/boot/grub
	cp kernel.bin iso/boot/
	cp grub.cfg iso/boot/grub/
	grub-mkrescue -o aldise.iso iso

# ---------------------------------------------------------
# Clean
# ---------------------------------------------------------

clean:
	rm -rf $(OBJ_DIR) *.bin aldise.iso iso/

# ---------------------------------------------------------
# Run
# ---------------------------------------------------------

run: aldise.iso
	qemu-system-i386 -cdrom aldise.iso

run_wdisk: aldise.iso
	# run ISO with a raw disk attached to the primary ATA bus
	qemu-system-i386 -cdrom aldise.iso -hda disk.img -boot d