
#CROSS_COMPILE ?= aarch64-none-linux-gnu-
CROSS_COMPILE ?= /home/oscar/Documentos/github/LinuxSP/arm-cross-compiler/gcc-arm-10.2-2020.11-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
CC=$(CROSS_COMPILE)gcc


default:
	gcc -o writer writer.c
CROSS_COMPILE:
	$(CC) -o writer writer.c
clean:
	rm -f writer
	rm -f *.o
