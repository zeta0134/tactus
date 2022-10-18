.PHONY: all clean dir run

ARTDIR := art
SOURCEDIR := prg
BUILDDIR := build
ROM_NAME := $(notdir $(CURDIR)).nes
DBG_NAME := $(notdir $(CURDIR)).dbg

# Assembler files, for building out the banks
PRG_ASM_FILES := $(wildcard $(SOURCEDIR)/*.s)
O_FILES := \
  $(patsubst $(SOURCEDIR)/%.s,$(BUILDDIR)/%.o,$(PRG_ASM_FILES))

ANIMATED_PNG_FILES := $(wildcard $(ARTDIR)/animated_tiles/*.png)
ANIMATED_CHR_FILES := \
	$(patsubst $(ARTDIR)/animated_tiles/%.png,$(BUILDDIR)/animated_tiles/%.chr,$(ANIMATED_PNG_FILES)) \

.PRECIOUS: $(BIN_FILES) $(ANIMATED_CHR_FILES)

all: dir $(ROM_NAME)

dir:
	@mkdir -p build
	@mkdir -p build/animated_tiles

clean:
	-@rm -rf build
	-@rm -f $(ROM_NAME)
	-@rm -f $(DBG_NAME)

run: dir $(ROM_NAME)
	rusticnes-sdl $(ROM_NAME)

mesen: dir $(ROM_NAME)
	mono vendor/Mesen-X-v1.0.0.exe $(ROM_NAME)

beta: dir $(ROM_NAME)
	/home/zeta0134/Downloads/MesenBeta/Mesen $(ROM_NAME)

debug: dir $(ROM_NAME)
	mono vendor/Mesen-X-v1.0.0.exe $(ROM_NAME) debug_entity_0.lua

profile: dir $(ROM_NAME)
	mono vendor/Mesen-X-v1.0.0.exe $(ROM_NAME) debug_color_performance.lua

everdrive: dir $(ROM_NAME)
	mono vendor/edlink-n8.exe $(ROM_NAME)

$(ROM_NAME): $(SOURCEDIR)/action53.cfg $(O_FILES)
	ld65 -m $(BUILDDIR)/map.txt --dbgfile $(DBG_NAME) -o $@ -C $^

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.s $(BIN_FILES) $(ANIMATED_CHR_FILES)
	ca65 -g -o $@ $<

$(BUILDDIR)/animated_tiles/%.chr: $(ARTDIR)/animated_tiles/%.png
	tools/animatedtile.py $< $@