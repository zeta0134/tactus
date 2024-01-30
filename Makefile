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

STATIC_PNG_FILES := $(wildcard $(ARTDIR)/static_tiles/*.png)
STATIC_CHR_FILES := \
	$(patsubst $(ARTDIR)/static_tiles/%.png,$(BUILDDIR)/static_tiles/%.chr,$(STATIC_PNG_FILES)) \

LAYOUT_TMX_FILES := $(wildcard $(ARTDIR)/layouts/*.tmx)
LAYOUT_INCS_FILES := \
	$(patsubst $(ARTDIR)/layouts/%.tmx,$(BUILDDIR)/layouts/%.incs,$(LAYOUT_TMX_FILES)) \

FLOOR_TMX_FILES := $(wildcard $(ARTDIR)/floors/*.tmx)
FLOOR_INCS_FILES := \
	$(patsubst $(ARTDIR)/floors/%.tmx,$(BUILDDIR)/floors/%.incs,$(FLOOR_TMX_FILES)) \

.PRECIOUS: $(BIN_FILES) $(ANIMATED_CHR_FILES) $(STATIC_CHR_FILES) $(LAYOUT_INCS_FILES) $(FLOOR_INCS_FILES)

all: dir $(ROM_NAME)

dir:
	@mkdir -p build
	@mkdir -p build/animated_tiles
	@mkdir -p build/static_tiles
	@mkdir -p build/layouts
	@mkdir -p build/floors

clean:
	-@rm -rf build
	-@rm -f $(ROM_NAME)
	-@rm -f $(DBG_NAME)

run: dir $(ROM_NAME)
	rusticnes-sdl $(ROM_NAME)

mesen: dir $(ROM_NAME)
	vendor/Mesen.AppImage $(ROM_NAME)

beta: dir $(ROM_NAME)
	/home/zeta0134/Downloads/MesenBeta/Mesen $(ROM_NAME)

osx: dir $(ROM_NAME)
	/Users/zeta0134/Github/Mesen2/bin/osx-arm64/Release/osx-arm64/publish/Mesen $(ROM_NAME)

debugzpcm: dir $(ROM_NAME)
	vendor/Mesen.AppImage $(ROM_NAME) debug_zpcm_timing.lua

profile: dir $(ROM_NAME)
	vendor/Mesen.AppImage $(ROM_NAME) debug_profile.lua

everdrive: dir $(ROM_NAME)
	mono vendor/edlink-n8.exe $(ROM_NAME)

$(ROM_NAME): $(SOURCEDIR)/rainbow.cfg $(O_FILES)
	ld65 -m $(BUILDDIR)/map.txt --dbgfile $(DBG_NAME) --define "__ZPCM_ADDRESS__=0x4011" --define "__BANK_MASK__=0x07" --define "__BANK_OFFSET__=0x00" -o "build/tactus-zpcm.bin" -C $^
	ld65 -m $(BUILDDIR)/map.txt                       --define "__ZPCM_ADDRESS__=0x5011" --define "__BANK_MASK__=0x07" --define "__BANK_OFFSET__=0x08" -o "build/tactus-base.bin" -C $^
	# We need to talk about
	tools/parallel_universes.py build/tactus-zpcm.bin build/tactus-base.bin 65536 $@

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.s $(BIN_FILES) $(ANIMATED_CHR_FILES) $(STATIC_CHR_FILES) $(LAYOUT_INCS_FILES) $(FLOOR_INCS_FILES)
	ca65 -g -o $@ $<

$(BUILDDIR)/animated_tiles/%.chr: $(ARTDIR)/animated_tiles/%.png
	tools/animatedtile.py $< $@

$(BUILDDIR)/static_tiles/%.chr: $(ARTDIR)/static_tiles/%.png
	tools/statictile.py $< $@

$(BUILDDIR)/layouts/%.incs: $(ARTDIR)/layouts/%.tmx
	tools/layout.py $< $@

$(BUILDDIR)/floors/%.incs: $(ARTDIR)/floors/%.tmx
	tools/floor.py $< $@