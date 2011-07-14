###############################################################################
# Makefile for the project 3piControl
###############################################################################

## General Flags
PROJECT = 3piLib
MCU = atmega328p
TARGET = 3piLib.elf
CC = avr-gcc

CPP = avr-g++

## Options common to compile, link and assembly rules
COMMON = -mmcu=$(MCU)

## Compile options common for all C compilation units.
CFLAGS = $(COMMON)
CFLAGS += -Wall -gdwarf-2 -DF_CPU=20000000UL -Os -funsigned-char -funsigned-bitfields -fpack-struct -fshort-enums  -x c++ 
CFLAGS += -MD -MP -MT $(*F).o -MF dep/$(@F).d 

## Assembly specific flags
ASMFLAGS = $(COMMON)
ASMFLAGS += $(CFLAGS)
ASMFLAGS += -x assembler-with-cpp -Wa,-gdwarf2

## Linker flags
LDFLAGS = $(COMMON)
LDFLAGS +=  -Wl,-Map=3piLib.map


## Intel Hex file production flags
HEX_FLASH_FLAGS = -R .eeprom -R .fuse -R .lock -R .signature

HEX_EEPROM_FLAGS = -j .eeprom
HEX_EEPROM_FLAGS += --set-section-flags=.eeprom="alloc,load"
HEX_EEPROM_FLAGS += --change-section-lma .eeprom=0 --no-change-warnings


## Libraries
#LIBS = -lpololu_atmega328p 

## Objects that must be built in order to link
OBJECTS = 3piLib.o 

## Objects explicitly added by the user
LINKONLYOBJECTS = 

## Build
all: $(TARGET) 3piControl.hex 3piControl.eep 3piControl.lss size

## Compile
3piLib.o: ./3piLib.cpp
	$(CC) $(INCLUDES) $(CFLAGS) -c  $<

##Link
$(TARGET): $(OBJECTS)
	 $(CC) $(LDFLAGS) $(OBJECTS) $(LINKONLYOBJECTS) $(LIBDIRS) $(LIBS) -o $(TARGET)

%.hex: $(TARGET)
	avr-objcopy -O ihex $(HEX_FLASH_FLAGS)  $< $@

%.eep: $(TARGET)
	-avr-objcopy $(HEX_EEPROM_FLAGS) -O ihex $< $@ || exit 0

%.lss: $(TARGET)
	avr-objdump -h -S $< > $@

size: ${TARGET}
	@echo
	@avr-size -C --mcu=${MCU} ${TARGET}

## Clean target
.PHONY: clean
clean:
	-rm -rf $(OBJECTS) 3piLib.elf dep/* 3piLib.hex 3piLib.eep 3piLib.lss 3piLib.map


## Other dependencies
-include $(shell mkdir dep 2>/dev/null) $(wildcard dep/*)

