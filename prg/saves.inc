; After we release our first demo, bump this if we need to
; break the save file. We'll probably do this fairly often :(
; We might want to reserve some bytes ahead of time to be kind
; to playtesters once we have some real state to save.
TACTUS_SAVE_VERSION_NUMBER = 1

; Big giant def containing *everything* that
; bears weight in a typical save file.
; Options, events, progress, if the save file
; select screen affects it at all, it goes here.
.struct SaveFile
    ; PLAYER PERSONALIZATION PRIMITIVES
    PlayerName .byte 16      ; this might be too long in practice? depends on where we use it I guess.
    PlayerPalettePreset .byte
    PlayerPalettePhones .byte
    PlayerPalettePajamas .byte
    PlayerPalettePigment .byte

    ; OPTIONS
    OptionDiscoFloor .byte
    OptionRhythmMode .byte

    ; GAME STATE
    EnemiesEncounteredFlags .byte 32
    ItemsDiscoveredFlags .byte 32
.endstruct

PLAYER_NAME_FIELD_LENGTH = 16
PLAYER_NAME_MAX_LENGTH = 15

FILE_VALID = 0
FILE_INVALID = 1

FILE_NEW = 0
FILE_IN_USE = 1

; 
.struct SaveBlock
    SaveSlot1 .byte .sizeof(SaveFile)
    SaveSlot2 .byte .sizeof(SaveFile)
    SaveSlot3 .byte .sizeof(SaveFile)
    ; BASICS
    GenerationalIndex .dword ; ignored for active, used during save/load
    Nonce .dword             ; might as well; helps to detect save file corruption
    SaveVersion .byte        ; if we change saves in a byte incompatible way, increment this version
    LastUsedSlot .byte       ; which save slot was used most recently. range: 0-2
    Checksum .word           ; the sum of all save bytes must match this
.endstruct

BLOCK_VALID = 0
BLOCK_INVALID = 1

; Which of the 3 save slots is currently active. Note
; that there is always at least one active slot, which
; might be visually "new". The init routine will populate
; these as required. At boot, the most recently saved
; file will be selected automatically, as this affects
; the title screen and other default options.
.global CurrentSaveIndex

; A 32bit number containing the "next ID" for a particular
; save. When writing a save we'll always increment this ID.
; It is shared between all slots.
.global CurrentGenerationIndex

; Pointer to the currently loaded SaveFile at any given
; moment. When the file select screen loads a file, it copies
; the relevant data into this struct. When a file is saved,
; the data is copied back out of this struct and into the
; save system. Thus, during gameplay, most of the rest of the
; game systems can fully ignore the save system and just use
; this block of data.
.global current_save

; Pointer to the currently loaded SaveBlock. SaveFiles are
; loaded from this block. When written, this should immediately
; be **persisted** using whatever abstraction does that. On
; load, this block is populated as the most recent (by generation)
; valid (by checksum, save version, etc) block, or initialized
; to an empty block if no valid block is found.
.global current_block

