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

BACKGROUND_PNG_FILES := $(wildcard $(ARTDIR)/background_tiles/*.png)
SPRITE_PNG_FILES := $(wildcard $(ARTDIR)/sprite_tiles/*.png)
RAW_CHR_TILES := $(wildcard $(ARTDIR)/raw_chr/*.chr)

ROOM_TMX_FILES := $(wildcard $(ARTDIR)/rooms/*.tmx)
ROOM_INCS_FILES := \
	$(patsubst $(ARTDIR)/rooms/%.tmx,$(BUILDDIR)/rooms/%.incs,$(ROOM_TMX_FILES)) \

FLOOR_TMX_FILES := $(wildcard $(ARTDIR)/floors/*.tmx)
FLOOR_INCS_FILES := \
	$(patsubst $(ARTDIR)/floors/%.tmx,$(BUILDDIR)/floors/%.incs,$(FLOOR_TMX_FILES)) \

.PRECIOUS: $(BIN_FILES) $(LAYOUT_INCS_FILES) $(FLOOR_INCS_FILES) $(ROOM_INCS_FILES)

all: dir $(ROM_NAME)

dir:
	@mkdir -p build
	@mkdir -p build/floors
	@mkdir -p build/rooms

clean:
	-@rm -rf build
	-@rm -f $(ROM_NAME)
	-@rm -f $(DBG_NAME)

run: dir $(ROM_NAME)
	rustico-sdl $(ROM_NAME)

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

$(ROM_NAME): $(BUILDDIR)/output_chr.bin $(BUILDDIR)/torchlight/torchlight_0.incs $(SOURCEDIR)/rainbow.cfg $(O_FILES)
	ld65 -m $(BUILDDIR)/map.txt --dbgfile $(DBG_NAME) --define "__ZPCM_ADDRESS__=0x4011" --define "__BANK_MASK__=0x07" --define "__BANK_OFFSET__=0x00" -o "build/tactus-zpcm.bin" -C $(SOURCEDIR)/rainbow.cfg $(O_FILES)
	ld65 -m $(BUILDDIR)/map.txt                       --define "__ZPCM_ADDRESS__=0xFF11" --define "__BANK_MASK__=0x07" --define "__BANK_OFFSET__=0x08" -o "build/tactus-base.bin" -C $(SOURCEDIR)/rainbow.cfg $(O_FILES)
	# We need to talk about
	tools/parallel_universes.py build/tactus-zpcm.bin build/tactus-base.bin 65536 $@

$(BUILDDIR)/%.o: $(SOURCEDIR)/%.s $(BIN_FILES) $(FLOOR_INCS_FILES) $(ROOM_INCS_FILES)
	ca65 -g -o $@ $<

$(BUILDDIR)/animated_tiles/%.chr: $(ARTDIR)/animated_tiles/%.png
	tools/animatedtile.py $< $@

$(BUILDDIR)/static_tiles/%.chr: $(ARTDIR)/static_tiles/%.png
	tools/statictile.py $< $@

$(BUILDDIR)/rooms/%.incs: $(ARTDIR)/rooms/%.tmx
	tools/room.py $< $@

$(BUILDDIR)/floors/%.incs: $(ARTDIR)/floors/%.tmx
	tools/floor.py $< $@

$(BUILDDIR)/output_chr.bin: $(BACKGROUND_PNG_FILES) $(SPRITE_PNG_FILES) $(RAW_CHR_TILES)
	tools/build_chrrom.py

$(BUILDDIR)/torchlight/torchlight_0.incs: dir
	tools/lighting.py