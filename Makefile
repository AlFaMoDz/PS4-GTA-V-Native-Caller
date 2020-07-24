LIBPS4	:= $(PS4SDK)/libPS4

CC	:= gcc
OBJCOPY	:= objcopy
ODIR	:= build
SDIR	:= source
IDIRS	:= -I$(LIBPS4)/include -Iinclude
LDIRS	:= -L$(LIBPS4)
MAPFILE := $(shell basename $(CURDIR)).map
CFLAGS	:= $(IDIRS) -Os -std=gnu11 -ffunction-sections -fdata-sections -fno-builtin -nostartfiles -nostdlib -Wall -masm=intel -march=btver2 -mtune=btver2 -m64 -mabi=sysv -mcmodel=small -fpie
LFLAGS	:= $(LDIRS) -Xlinker -T $(LIBPS4)/linker.x -Xlinker -Map=$(MAPFILE) -Wl,--build-id=none
CFILES	:= $(wildcard $(SDIR)/*.c)
SFILES	:= $(wildcard $(SDIR)/*.s)
OBJS	:= $(patsubst $(SDIR)/%.c, $(ODIR)/%.o, $(CFILES)) $(patsubst $(SDIR)/%.s, $(ODIR)/%.o, $(SFILES))

LIBS	:= -lPS4

TARGET = $(shell basename $(CURDIR)).bin

$(TARGET): makeGtaPayload requiredClean $(ODIR) $(OBJS)
	$(CC) $(LIBPS4)/crt0.s $(ODIR)/*.o -o temp.t $(CFLAGS) $(LFLAGS) $(LIBS)
	$(OBJCOPY) -O binary temp.t $(TARGET)
	rm -f temp.t

$(ODIR)/%.o: $(SDIR)/%.c
	$(CC) -c -o $@ $< $(CFLAGS)

$(ODIR)/%.o: $(SDIR)/%.s
	$(AS) -c -o $@ $< $(SFLAGS)

$(ODIR):
	@mkdir $@

.PHONY: $(TARGET)

makeGtaPayload:
	$(MAKE) -C gtaPayload $?

requiredClean:
	rm -f $(TARGET) $(ODIR)/embed.o

clean:
	rm -f $(TARGET) $(ODIR)/*.o