; After we release our first demo, bump this if we need to
; break the save file. We'll probably do this fairly often :(
; We might want to reserve some bytes ahead of time to be kind
; to playtesters once we have some real state to save.
TACTUS_SAVE_VERSION_NUMBER = 1

; Big giant def containing *everything* that
; bears weight in a typical save file.
; Options, events, progress, if the save file
; select screen affects it at all, it goes here.

; Note on padding: try to use Reserved space before
; changing the size of this struct. Every size change
; requires us to bump the save file version, which
; makes old testers lose their save files.
.struct SaveFile
    ; PLAYER PERSONALIZATION PRIMITIVES
    PlayerName .byte 16      ; this might be too long in practice? depends on where we use it I guess.
    ; GAME STATE
    EnemiesEncounteredFlags .byte 32
    ItemsDiscoveredFlags .byte 32
    ; PLAYER PERSONALIZATION PREFERENCES
    PlayerPalettePreset .byte
    PlayerPalettePhonesIndex .byte
    PlayerPalettePajamasIndex .byte
    PlayerPalettePigmentIndex .byte
    PlayerReserved .byte 4 ; pad out to 8 bytes total
    ; OPTIONS
    OptionDiscoFloor .byte
    OptionRhythmMode .byte
    OptionsReserved .byte 14 ; pad out to 16 bytes total
    ; FUTURE
    GeneralReserved .byte 24
.endstruct ; total size should be 128 bytes

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

.global FAR_load_file   ; from index in A, sets current_save_slot
.global FAR_save_file   ; to index in A, sets current_save_slot
.global FAR_is_new_file ; FilePtr in R0
.global FAR_save_current_file ; index in current_save_slot
.global FAR_update_last_accessed_file ; File index in A
.global FAR_init_save_subsystem  ; call once during engine init. (call again to fully reload, this will overwrite any unsaved data!)
.global FAR_create_new_file ; FilePtr in R0
.global FAR_persist_block_to_storage

; Helpful macros for dealing with event flags
.macro check_flag base_addr, flag_number
    lda base_addr + (flag_number >> 3)
    and #(1 << (flag_number & 7))
.endmacro

.macro set_flag base_addr, flag_number
    lda base_addr + (flag_number >> 3)
    ora #(1 << (flag_number & 7))
    sta base_addr + (flag_number >> 3)
.endmacro

.macro clear_flag base_addr, flag_number
    lda base_addr + (flag_number >> 3)
    and #($FF-(1 << (flag_number & 7)))
    sta base_addr + (flag_number >> 3)
.endmacro

; Subroutines for doing the same thing.
; ptr in R0
; flag number in A, clobbers X, Y
.global FIXED_check_flag
.global FIXED_set_flag
.global FIXED_clear_flag