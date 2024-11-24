    .macpack longbranch

    .include "../build/tile_defs.inc"

    .include "_globals.inc"

    .include "saves.inc"

    .include "far_call.inc"
    .include "prng.inc"
    .include "rainbow.inc"
    .include "word_util.inc"
    .include "zeropage.inc"

    .zeropage

    .segment "RAM"
current_save: .res .sizeof(SaveFile)
current_save_slot: .res 1

    .segment "PRGRAM"
current_block: .res .sizeof(SaveBlock)

    .segment "LEVEL_RAM_0"
persisted_block_0: .res .sizeof(SaveBlock)
persisted_block_3: .res .sizeof(SaveBlock)

    .segment "LEVEL_RAM_1"
persisted_block_1: .res .sizeof(SaveBlock)
persisted_block_4: .res .sizeof(SaveBlock)

    .segment "LEVEL_RAM_2"
persisted_block_2: .res .sizeof(SaveBlock)
persisted_block_5: .res .sizeof(SaveBlock)

    .segment "CODE_1"

.define SavePersistencePtrs persisted_block_0, persisted_block_1, persisted_block_2, persisted_block_3, persisted_block_4, persisted_block_5
PERSISTENCE_TABLE_LENGTH = 6

persistence_table_low: .lobytes SavePersistencePtrs
persistence_table_high: .hibytes SavePersistencePtrs
persistence_table_banks: ; .bankbytes SavePersistencePtrs well no, we can't do this actually
    .byte <.bank(persisted_block_0)
    .byte <.bank(persisted_block_1)
    .byte <.bank(persisted_block_2)
    .byte <.bank(persisted_block_3)
    .byte <.bank(persisted_block_4)
    .byte <.bank(persisted_block_5)

; An extremely simple checksum: just sum all of the
; bytes in this memory area and return the 16bit result.
; not cryptographically secure!
; Note: DataPtr is preserved! Uses high R8 for stash
; Length is NOT preserved! (also don't use Length=0)
.proc compute_checksum
DataPtr := R0
Length := R2
ComputedSum := R4
TempPtr := R8
    lda DataPtr+0
    sta TempPtr+0
    lda DataPtr+1
    sta TempPtr+1
    ldy #0
    sty ComputedSum+0
    sty ComputedSum+1
loop:
    clc
    lda (TempPtr), y
    adc ComputedSum+0
    sta ComputedSum+0
    lda #0
    adc ComputedSum+1
    sta ComputedSum+1
    inc16 TempPtr
    dec16 Length
    lda Length+0
    ora Length+1
    bne loop
    rts
.endproc

; Sanity checks on a given individual file, mostly used to
; reject saves that would pose a safety issue
; Result in A
.proc is_valid_file
SaveFilePtr := R0
    ; somewhere in PlayerName must be a $0 byte!
    ; if we don't have this, we can lock up trying to draw the
    ; resulting string. (Empty string is acceptable, it signals this is a "new" file)
    ldx #0
    ldy #SaveFile::PlayerName
player_name_loop:
    lda (SaveFilePtr), y
    beq player_name_is_safe
    inx
    iny
    cpx #PLAYER_NAME_FIELD_LENGTH
    bne player_name_loop
    lda #FILE_INVALID
    rts
player_name_is_safe:
    ; TODO: other safety checks here, as required

    lda #FILE_VALID
    rts
.endproc

.proc FAR_is_new_file
SaveFilePtr := R0
    ; very trivial: is the player name an empty string? that is, does it contain
    ; all zeroes? if so, this is a new file!
    ; (to encode an actually empty string, if desired, write $0, $FF)
    ldx #0
    ldy #SaveFile::PlayerName
player_name_loop:
    lda (SaveFilePtr), y
    bne player_name_is_set
    inx
    iny
    cpx #PLAYER_NAME_FIELD_LENGTH
    bne player_name_loop
player_name_is_empty:
    lda #FILE_NEW
    rts
player_name_is_set:
    lda #FILE_IN_USE
    rts
.endproc

.proc compute_nonce
ComputedNonce := R4
    jsr next_gameplay_rand
    sta ComputedNonce+0
    jsr next_gameplay_rand
    sta ComputedNonce+1
    jsr next_gameplay_rand
    sta ComputedNonce+2
    jsr next_gameplay_rand
    sta ComputedNonce+3
    ; sanity check: reject any generated nonce that is all zero bytes
    lda ComputedNonce+0
    ora ComputedNonce+1
    ora ComputedNonce+2
    ora ComputedNonce+3 ; at least 1 bit in A should be set by this point
    beq compute_nonce   ; if not, do it all again
    rts
.endproc

; Note: Clobbers BlockPtr! (!)
.proc is_valid_block
BlockPtr := R0
FilePtr := R0

ChecksumDataPtr := R0
ChecksumLength := R2
ComputedSum := R4

TempPtr := R10
    ; Do some basic checks first, these are faster to compute

    ; Save blocks have a hardcoded version. For now, we only support loading
    ; the newest version. If we need to change the save file during development, we'll
    ; bump this version to force an otherwise valid block to fail to load. (Sorry!)
    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::SaveVersion
    ldy #0
    lda (TempPtr), y
    cmp #TACTUS_SAVE_VERSION_NUMBER
    jne block_invalid

    ; The last-accessed save slot should be in range from 0-2
    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::LastUsedSlot
    ldy #0
    lda (TempPtr), y
    cmp #3
    jcs block_invalid

    ; The nonce for a given save block should never be
    ; entirely zero filled. We reject this state during nonce
    ; generation, and it almost certainly indicates an empty or
    ; otherwise corrupt file

    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::Nonce
    ldy #0
    lda (TempPtr), y
    iny
    ora (TempPtr), y
    iny
    ora (TempPtr), y
    iny
    ora (TempPtr), y  ; at least 1 bit in Nonce should have been OR'd in by this point
    jeq block_invalid

    ; Ensure the checksum of the entire block is valid
    st16 ChecksumLength, (.sizeof(SaveBlock)-2) ; don't include the checksum bytes
    jsr compute_checksum
    ; Now make sure it matches what's written to this block
    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::Checksum
    ldy #0
    lda (TempPtr), y
    cmp ComputedSum+0
    bne block_invalid
    iny
    lda (TempPtr), y
    cmp ComputedSum+1
    bne block_invalid

    ; Finally, ensure each individual file is valid
    ; File and Block ptrs both use R0, so fix that up
    mov16 TempPtr, BlockPtr
    mov16 FilePtr, TempPtr
    add16w FilePtr, #SaveBlock::SaveSlot1
    jsr is_valid_file
    cmp #FILE_INVALID
    beq block_invalid
    mov16 FilePtr, TempPtr
    add16w FilePtr, #SaveBlock::SaveSlot2
    jsr is_valid_file
    cmp #FILE_INVALID
    beq block_invalid
    mov16 FilePtr, TempPtr
    add16w FilePtr, #SaveBlock::SaveSlot3
    jsr is_valid_file
    cmp #FILE_INVALID
    beq block_invalid
    ; restore the block ptr to be nice to the caller
    mov16 BlockPtr, TempPtr
    ; If we get here, this is a valid block. Yay!
    lda #BLOCK_VALID
    rts
block_invalid:
    lda #BLOCK_INVALID
    rts
.endproc

.proc FAR_create_new_file
FilePtr := R0
    ; Valid new files are mostly easy, just zero them out entirely. This will
    ; set the player name to all zeroes, which denotes the file as "new"
    ; in the UI and such
    lda #0
    ldy #0
loop:
    sta (FilePtr), y
    iny
    cpy #.sizeof(SaveFile)
    bne loop

    ; A few settings do need more explicit values though: we must default
    ; the player palette to something other than "personalized", otherwise
    ; we'll get grey title screen art. Here we choose a fixed value, any 
    ; fancy randomization happens during file creation.
    lda #EMPTY_FILE_DEFAULT_PALETTE
    ldy #SaveFile::PlayerPalettePreset
    sta (FilePtr), y

    rts
.endproc

; This is generally called exactly once, on a player's very first boot,
; if we can't find an otherwise valid block to load. Once we have this,
; we'll prefer to modify it in place (incrementing the generational index)
; for future saves.
; Note: clobbers pretty much everything!
.proc create_new_block
IncomingBlockPtr := R0
FilePtr := R0
TempPtr := R0

BlockPtr := R10

ComputedNonce := R4

ChecksumDataPtr := R0
ChecksumLength := R2
ComputedSum := R4

    mov16 BlockPtr, IncomingBlockPtr

    ; First initialize all 3 save files to valid contents
    mov16 FilePtr, BlockPtr
    add16w FilePtr, #SaveBlock::SaveSlot1
    near_call FAR_create_new_file
    mov16 FilePtr, BlockPtr
    add16w FilePtr, #SaveBlock::SaveSlot2
    near_call FAR_create_new_file
    mov16 FilePtr, BlockPtr
    add16w FilePtr, #SaveBlock::SaveSlot3
    near_call FAR_create_new_file

    ; All new blocks need a nonce (and we'll refresh this on every save)
    jsr compute_nonce

    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::Nonce
    ldy #0
    lda ComputedNonce+0
    sta (TempPtr), y
    iny
    lda ComputedNonce+1
    sta (TempPtr), y
    iny
    lda ComputedNonce+2
    sta (TempPtr), y
    iny
    lda ComputedNonce+3
    sta (TempPtr), y
    
    ; Use the most recent version number for new blocks
    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::SaveVersion
    ldy #0
    lda #TACTUS_SAVE_VERSION_NUMBER
    sta (TempPtr), y

    ; Set the initial generation index to 0
    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::GenerationalIndex
    ldy #0
    lda #0
    sta (TempPtr), y
    iny
    sta (TempPtr), y
    iny
    sta (TempPtr), y
    iny
    sta (TempPtr), y

    ; Finally compute a valid checksum for the whole thing (which we'll
    ; also later refresh on each save)
    mov16 ChecksumDataPtr, BlockPtr
    st16 ChecksumLength, (.sizeof(SaveBlock)-2) ; don't include the checksum bytes
    jsr compute_checksum

    mov16 TempPtr, BlockPtr
    add16w TempPtr, #SaveBlock::Checksum
    ldy #0
    lda ComputedSum+0
    sta (TempPtr), y
    iny
    lda ComputedSum+1
    sta (TempPtr), y

    ; Et voila, a valid block. (one hopes.)
    rts
.endproc

; returns $0000 (ptr) and $00 (bank) on failure
.proc find_candidate_block_to_load
BlockPtr := R0
BlockBank := R12
CandidateIndex := R13
FoundIndex := R14
FoundGeneration := R15
    lda #0
    sta CandidateIndex
    lda #$FF
    sta FoundIndex
loop:
    ldx CandidateIndex
    lda persistence_table_low, x
    sta BlockPtr+0
    lda persistence_table_high, x
    sta BlockPtr+1
    lda persistence_table_banks, x
    sta BlockBank
    access_ram_bank BlockBank
    jsr is_valid_block
    cmp #BLOCK_INVALID
    beq block_invalid
    ; Prepare to work with the generational index, which will determine
    ; which valid block we load if there are multiple
    add16w BlockPtr, #SaveBlock::GenerationalIndex
    ; if this is our first found index, keep it unconditionally
    lda FoundIndex
    cmp #$FF
    beq its_a_keeper
    ; otherwise, compare this block's generation with the one we already
    ; found, and keep this block only if it's a newer (higher) generation
    ldy #3
    lda (BlockPtr), y
    cmp FoundGeneration+3
    bne perform_generational_comparison
    ldy #2
    lda (BlockPtr), y
    cmp FoundGeneration+2
    bne perform_generational_comparison
    ldy #1
    lda (BlockPtr), y
    cmp FoundGeneration+1
    bne perform_generational_comparison
    ldy #0
    lda (BlockPtr), y
    cmp FoundGeneration+0
perform_generational_comparison:
    beq block_invalid ; how on earth?
    bcc block_invalid ; reject lower generations
its_a_keeper:
    lda CandidateIndex
    sta FoundIndex
    ldy #0
    lda (BlockPtr), y
    sta FoundGeneration+0
    iny
    lda (BlockPtr), y
    sta FoundGeneration+1
    iny
    lda (BlockPtr), y
    sta FoundGeneration+2
    iny
    lda (BlockPtr), y
    sta FoundGeneration+3
block_invalid:
    restore_previous_bank
    ; onward!
    inc CandidateIndex
    lda CandidateIndex
    cmp #PERSISTENCE_TABLE_LENGTH
    jne loop
    ; now that all 6 slots have been examined, did we find something?
    lda FoundIndex
    cmp #$FF
    beq not_found
    jmp found
not_found:
    lda #0
    sta BlockPtr+0
    sta BlockPtr+1
    sta BlockBank
    rts
found:
    ldx FoundIndex
    lda persistence_table_low, x
    sta BlockPtr+0
    lda persistence_table_high, x
    sta BlockPtr+1
    lda persistence_table_banks, x
    sta BlockBank
    rts
.endproc

; does not fail
.proc find_candidate_block_to_save
BlockPtr := R0
BlockBank := R12
CandidateIndex := R13
FoundIndex := R14
FoundGeneration := R15
    ; look for either the first invalid save slot, or the
    ; valid save slot with the lowest generational index
    ; for this purpose, initialize the generational index to $FFFFFFFF
    lda #$FF
    sta FoundGeneration+0
    sta FoundGeneration+1
    sta FoundGeneration+2
    sta FoundGeneration+3
    lda #0
    sta CandidateIndex
    sta FoundIndex
loop:
    ldx CandidateIndex
    lda persistence_table_low, x
    sta BlockPtr+0
    lda persistence_table_high, x
    sta BlockPtr+1
    lda persistence_table_banks, x
    sta BlockBank
    access_ram_bank BlockBank
    jsr is_valid_block
    ; If this is not a valid slot, select it for saving. We can skip all remaining checks.
    cmp #BLOCK_INVALID
    beq block_invalid
    ; Otherwise, compare this block's generational index
    ; to the one we found already, and keep it if it is lower
    add16w BlockPtr, #SaveBlock::GenerationalIndex
    ldy #3
    lda (BlockPtr), y
    cmp FoundGeneration+3
    bne perform_generational_comparison
    ldy #2
    lda (BlockPtr), y
    cmp FoundGeneration+2
    bne perform_generational_comparison
    ldy #1
    lda (BlockPtr), y
    cmp FoundGeneration+1
    bne perform_generational_comparison
    ldy #0
    lda (BlockPtr), y
    cmp FoundGeneration+0
perform_generational_comparison:
    bcs do_not_keep
its_a_keeper:
    lda CandidateIndex
    sta FoundIndex
do_not_keep:
    restore_previous_bank
    inc CandidateIndex
    lda CandidateIndex
    cmp #PERSISTENCE_TABLE_LENGTH
    jne loop
    jmp return_results

block_invalid:
    ; we are still banked to the block pointer at this point, so undo that
    restore_previous_bank
    lda CandidateIndex
    sta FoundIndex
    jmp return_results

return_results:
    ldx FoundIndex
    lda persistence_table_low, x
    sta BlockPtr+0
    lda persistence_table_high, x
    sta BlockPtr+1
    lda persistence_table_banks, x
    sta BlockBank
    rts
.endproc

.proc FAR_persist_block_to_storage
BlockPtr := R0
SourcePtr := R2
DataLength := R4

BlockBank := R12

ComputedNonce := R4

ChecksumDataPtr := R0
ChecksumLength := R2
ComputedSum := R4
    ; first, and always, increment the generational index
    inc32 current_block + SaveBlock::GenerationalIndex
    ; compute and store a new nonce
    jsr compute_nonce
    lda ComputedNonce+0
    sta current_block + SaveBlock::Nonce + 0
    lda ComputedNonce+1
    sta current_block + SaveBlock::Nonce + 1
    lda ComputedNonce+2
    sta current_block + SaveBlock::Nonce + 2
    lda ComputedNonce+3
    sta current_block + SaveBlock::Nonce + 3
    ; generate a valid checksum for the block we are about to save
    st16 ChecksumDataPtr, current_block
    st16 ChecksumLength, (.sizeof(SaveBlock)-2) ; don't include the checksum bytes
    jsr compute_checksum
    lda ComputedSum+0
    sta current_block + SaveBlock::Checksum + 0
    lda ComputedSum+1
    sta current_block + SaveBlock::Checksum + 1
    ; now that the block is prepred, locate a valid slot to persist it to
    jsr find_candidate_block_to_save
    ; bank that block in, and write the new data
    access_ram_bank BlockBank
    st16 SourcePtr, current_block
    st16 DataLength, .sizeof(SaveBlock)
    ldy #0
block_storage_loop:
    lda (SourcePtr), y
    sta (BlockPtr), y
    inc16 SourcePtr
    inc16 BlockPtr
    dec16 DataLength
    lda DataLength+0
    ora DataLength+1
    bne block_storage_loop
    ; cleanup, and done
    restore_previous_bank
    rts
.endproc

.proc retrieve_block_from_storage
BlockPtr := R0
DestPtr := R2
DataLength := R4
BlockBank := R12
    ; try to find a candidate block to load from storage. this may fail!
    jsr find_candidate_block_to_load
    ; did it fail?
    lda BlockPtr+0
    ora BlockPtr+1
    beq generate_fresh_block
    ; it did not! proceed to load the block from storage
    access_ram_bank BlockBank
    st16 DestPtr, current_block
    st16 DataLength, .sizeof(SaveBlock)
    ldy #0
block_retrieval_loop:
    lda (BlockPtr), y
    sta (DestPtr), y
    inc16 BlockPtr
    inc16 DestPtr
    dec16 DataLength
    lda DataLength+0
    ora DataLength+1
    bne block_retrieval_loop
    ; cleanup, and done
    restore_previous_bank
    rts

generate_fresh_block:
    ; there is no valid save file, which means this is a fresh cart
    ; (or a freshly replaced battery, or a deleted .sav, whatever)
    ; generate a shiny new block and load that instead
    st16 BlockPtr, current_block
    jsr create_new_block
    rts
.endproc

; file index in A
.proc FAR_load_file
DestFile := R0
SourceFile := R2
    cmp #0
    beq load_file_0
    cmp #1
    beq load_file_1
    cmp #2
    beq load_file_2
    ; PANIC! WHAT DO!?!? Erm... we should crash on purpose, but let's fall through
    ; to loading file 0 as a default. that's less incorrect, I guess?
load_file_0:
    sta current_save_slot
    st16 SourceFile, (current_block + SaveBlock::SaveSlot1)
    jmp file_load_converge
load_file_1:
    sta current_save_slot
    st16 SourceFile, (current_block + SaveBlock::SaveSlot2)
    jmp file_load_converge
load_file_2:
    sta current_save_slot
    st16 SourceFile, (current_block + SaveBlock::SaveSlot3)
file_load_converge:
    st16 DestFile, current_save

    ; individual files are smaller than 256 bytes, so we can use
    ; a simple loop here to load the contents
    ldy #0
file_load_loop:
    lda (SourceFile), y
    sta (DestFile), y
    iny
    cpy #.sizeof(SaveFile)
    bne file_load_loop

    rts
.endproc

; file index in A
.proc FAR_save_file
DestFile := R0
SourceFile := R2
    ; it's the same thing but in the other direction now
    cmp #0
    beq save_file_0
    cmp #1
    beq save_file_1
    cmp #2
    beq save_file_2
    ; PANIC! WHAT DO!?!? Erm... ... in this case, NOTHING.
    ; (Please do not save over existing files when a glitch
    ; breaks the destination. For heck's sake.)
    rts
save_file_0:
    sta current_save_slot
    st16 DestFile, (current_block + SaveBlock::SaveSlot1)
    jmp file_save_converge
save_file_1:
    sta current_save_slot
    st16 DestFile, (current_block + SaveBlock::SaveSlot2)
    jmp file_save_converge
save_file_2:
    sta current_save_slot
    st16 DestFile, (current_block + SaveBlock::SaveSlot3)
file_save_converge:
    st16 SourceFile, current_save

    ; individual files are smaller than 256 bytes, so we can use
    ; a simple loop here to write the contents
    ldy #0
file_save_loop:
    lda (SourceFile), y
    sta (DestFile), y
    iny
    cpy #.sizeof(SaveFile)
    bne file_save_loop

    ; Having just saved the file, now persist the block
    near_call FAR_persist_block_to_storage

    rts
.endproc

; convenience helper, which we'll call any time main gameplay
; needs to persist something to the player's save file. this is
; the usual pattern for file saving, the other functions are mainly
; used during init and during file manipulation operations on the
; main menu.
.proc FAR_save_current_file
    lda current_save_slot
    near_call FAR_update_last_accessed_file
    lda current_save_slot
    near_call FAR_save_file
    rts
.endproc

; file index in A
.proc FAR_update_last_accessed_file
    sta current_block + SaveBlock::LastUsedSlot
    rts
.endproc

; loads the last saved block, if present, and the
; last accessed file from that block. call this before
; rendering anything that depends on the save file being
; valid; this includes the title screen and logo sequence!
.proc FAR_init_save_subsystem
    jsr retrieve_block_from_storage
    lda current_block + SaveBlock::LastUsedSlot
    near_call FAR_load_file
    rts
.endproc
