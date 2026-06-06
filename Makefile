ASM = nasm
CC = gcc
CCFLAGS = -no-pie -z noexecstack -m64
ASMFLAGS = -f elf64 -g
NAME = guess_number
PROGRAM = $(NAME).out
OBJ = $(NAME).o
ASMFILE = $(NAME).asm
DBG = gdb
args=

build: $(PROGRAM)

run: $(PROGRAM)
	./$< $(args)

debug: $(PROGRAM)
	$(DBG) ./$< $(args)

$(PROGRAM): $(OBJ)
	$(CC) $(CCFLAGS) -o $@ $^

$(OBJ): $(ASMFILE)
	$(ASM) $(ASMFLAGS) -o $@ $^

clean:
	rm -f *.o *.out
