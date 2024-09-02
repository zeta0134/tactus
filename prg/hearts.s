        .include "hearts.inc"
        .include "zeropage.inc"

        .segment "RAM"

heart_hp: .res ::TOTAL_HEART_SLOTS
heart_type: .res ::TOTAL_HEART_SLOTS

already_damaged: .res 1

        .segment "PRGFIXED_E000"

.proc FIXED_is_player_considered_dead
        lda heart_hp+0
        .repeat ::TOTAL_HEART_SLOTS-1, i
        ora heart_hp+i+1
        .endrepeat
        beq hes_dead_jim
        lda #0
        rts
hes_dead_jim:
        lda #$FF
        rts
.endproc

        .segment "CODE_4"

initial_heart_hp:
        .byte 0 ; none
        .byte 4 ; regular
        .byte 1 ; glass
        .byte 4 ; regular armored
        .byte 4 ; temporary
        .byte 4 ; temporary armored

.proc FAR_initialize_hearts_for_game
        lda #HEART_TYPE_NONE
        ldy #0
        .repeat ::TOTAL_HEART_SLOTS, i
        sta heart_type+i
        sty heart_hp+i
        .endrepeat
        rts
.endproc

.proc FAR_reset_hearts_for_beat
        lda #0
        sta already_damaged
        rts
.endproc

.proc remove_this_heart
CurrentHeartIndex := R1
        ; from this position to max-1, shift all hearts to the left
        ldx CurrentHeartIndex
loop:
        cpx #TOTAL_HEART_SLOTS-1
        beq done_shifting_hearts
        lda heart_hp+1, x
        sta heart_hp, x
        lda heart_type+1, x
        sta heart_type, x
        inx
        jmp loop
done_shifting_hearts:
        ; replace the last heart slot with nothing
        lda #HEART_TYPE_NONE
        sta heart_type, x
        lda #0
        sta heart_hp, x
        rts
.endproc

; this can succeed or fail! The return value is written back to R0
.proc FAR_add_heart
NewHeartType := R0
ReturnStatus := R0
DestinationSlot := R1
        ; sanity check: is there room for another heart?
        lda heart_type+TOTAL_HEART_SLOTS-1
        cmp #HEART_TYPE_NONE
        ; TODO: should non-temp hearts be allowed to replace temp hearts?
        beq safe_to_add
failed_to_add_heart:
        lda #$FF
        sta ReturnStatus
        rts
safe_to_add:
        ldx #0
find_destination_slot_loop:
        lda heart_type, x
        cmp #HEART_TYPE_NONE
        beq found_slot
        ; if we are spawning a non-temporary heart...
        lda NewHeartType
        cmp #HEART_TYPE_TEMPORARY
        beq try_next_slot
        cmp #HEART_TYPE_TEMPORARY_ARMORED
        beq try_next_slot
        ; and this slot IS a temporary heart...
        ; ... then select it, and we'll shift the temporary
        ; hearts over by 1 later
        lda heart_type, x
        cmp #HEART_TYPE_TEMPORARY
        beq found_slot
        lda heart_type, x
        cmp #HEART_TYPE_TEMPORARY_ARMORED
        beq found_slot
try_next_slot:
        inx
        cpx #TOTAL_HEART_SLOTS
        beq failed_to_add_heart
        jmp find_destination_slot_loop
found_slot:
        ; okay so, from this location shift all of the hearts to the right by 1
        ; this should move any temporary hearts out of the way, if present
        stx DestinationSlot
        ldx #TOTAL_HEART_SLOTS-1
shift_loop:
        cpx DestinationSlot
        beq done_shifting
        lda heart_hp-1, x
        sta heart_hp, x
        lda heart_type-1, x
        sta heart_type, x
        dex
        jmp shift_loop
done_shifting:
        lda NewHeartType
        sta heart_type, x
        tay
        lda initial_heart_hp, y
        sta heart_hp, x

        lda #0
        sta ReturnStatus
        rts
.endproc

; damage amount in R0, clobbers R1-R3
.proc FAR_receive_damage
RemainingDamage := R0
CurrentHeartIndex := R1
HeartDmgProc := R2
        lda #TOTAL_HEART_SLOTS
        sta CurrentHeartIndex
loop:
        ldx CurrentHeartIndex
        lda heart_type, x
        asl
        tay
        lda heart_damage_functions+0, y
        sta HeartDmgProc+0
        lda heart_damage_functions+1, y
        sta HeartDmgProc+1
        jmp (HeartDmgProc)
return_from_dmg:
        ; Bail if there is no more damage left to deal
        lda RemainingDamage
        beq done
        ; Also bail if we've run out of hearts to process
        ; (if this occurs, the player is almost certainly dead)
        lda CurrentHeartIndex
        beq done
        dec CurrentHeartIndex
        jmp loop
done:
        rts
.endproc

heart_damage_functions:
        .addr heart_none_dmg
        .addr heart_regular_dmg
        .addr heart_glass_dmg
        .addr heart_regular_armored_dmg
        .addr heart_temporary_dmg
        .addr heart_temporary_armored_dmg

.proc heart_none_dmg
        ; Has absolutely no effect. RemainingDmg is unchanged.
        jmp FAR_receive_damage::return_from_dmg
.endproc

.proc heart_regular_dmg
RemainingDamage := R0
CurrentHeartIndex := R1
        ; if damage is blocked for this beat, don't take anything and
        ; cancel the incoming damage entirely
        lda already_damaged
        bne cancel_incoming_damage

        ldx CurrentHeartIndex
        lda heart_hp, x
        sec
        sbc RemainingDamage
        bpl took_all_damage
some_damage_remains:
        ; we're holding the remainder but it's negative
        ; so do a *-1 here
        eor #$FF
        clc
        adc #1
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
took_all_damage:
        sta heart_hp, x
cancel_incoming_damage:
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
.endproc

.proc heart_glass_dmg
RemainingDamage := R0
CurrentHeartIndex := R1
        ; don't take damage multiple times in one beat
        lda already_damaged
        bne cancel_incoming_damage
        ; only take damage if there is actually incoming dmg remaining
        ; (we shouldn't actually be called in this case, but better to be
        ; safe)
        lda RemainingDamage
        bne shatterheart
cancel_incoming_damage:
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
shatterheart:
        ; This heart is broken! Not only do we set its HP to 0, we 
        ; also reset the container state to nothing. Glass hearts
        ; cannot be refilled!
        jsr remove_this_heart
        ; TODO: play SFX, spawn particles, etc
        ; The glass heart took the entire blow! Set the remaining
        ; damage to 0, and make the player immune to future sources of
        ; damage.
        lda #0
        sta RemainingDamage
        lda #1
        sta already_damaged
        jmp FAR_receive_damage::return_from_dmg
.endproc

.proc heart_regular_armored_dmg
RemainingDamage := R0
CurrentHeartIndex := R1
        ; don't take damage multiple times in one beat
        lda already_damaged
        bne cancel_incoming_damage
        ; Safety: If incoming damage happens to be 0, we're done
        ; (otherwise we would force it to 1 and deal damage when we shouldn't have)
        lda RemainingDamage
        bne continue
cancel_incoming_damage:
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
continue:
        ; First, reduce incoming damage by half, rounded down
        ; (don't worry about preserving it, we block damage propogation anyway)
        lsr RemainingDamage
        ; If that's nonzero, proceed, otherwise force it to a minimum of 0
        ; (armored hearts do not negate all damage)
        bne process_reduced_damage
        lda #1
        sta RemainingDamage
process_reduced_damage:
        ; Reduce!
        ldx CurrentHeartIndex
        sec
        lda heart_hp, x
        sbc RemainingDamage
        ; if we hit zero or we went negative, the heart armor breaks!
        beq break_heart_armor
        bmi break_heart_armor
        ; otherwise, keep the new value
        sta heart_hp, x
        ; zero out remaining damage and exit; we're done here.
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
break_heart_armor:
        ; When breaking heart armor, explicitly protect the left-most hearts from future
        ; damage sources on the same beat
        lda #1
        sta already_damaged
        lda #HEART_TYPE_REGULAR
        sta heart_type, x
        ; TODO: play a SFX, maybe spawn some heart armor particles, etc.
        ; Special mercy rule: if this is the player's last heart, heal
        ; it back to 1 HP
        ldx CurrentHeartIndex
        beq last_heart
        ; otherise, the now-regular heart is left fully depleted
        lda #0
        sta heart_hp, x
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
last_heart:
        lda #1
        sta heart_hp, x
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
.endproc

; Like regular hearts, but these VANISH when depleted
.proc heart_temporary_dmg
RemainingDamage := R0
CurrentHeartIndex := R1
        ; don't take damage multiple times in one beat
        ; (this really shouldn't happen for temporary hearts with
        ; the current design, but just in case...)
        lda already_damaged
        bne cancel_incoming_damage

        ldx CurrentHeartIndex
        lda heart_hp, x
        sec
        sbc RemainingDamage
        bpl took_all_damage
some_damage_remains:
        ; we're holding the remainder but it's negative
        ; so do a *-1 here
        eor #$FF
        clc
        adc #1
        sta RemainingDamage
        jmp check_vanish
took_all_damage:
        sta heart_hp, x
        lda #0
        sta RemainingDamage
check_vanish:
        ; if we depleted ourselves to 0, then go away!
        lda heart_hp, x
        beq destroy_self
        jmp FAR_receive_damage::return_from_dmg
destroy_self:
        ; TODO: play SFX, spawn particles, etc
        jsr remove_this_heart
        jmp FAR_receive_damage::return_from_dmg
cancel_incoming_damage:
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
.endproc

; Like armored hearts, but vanish when depleted
.proc heart_temporary_armored_dmg
RemainingDamage := R0
CurrentHeartIndex := R1
        ; don't take damage multiple times in one beat
        lda already_damaged
        bne cancel_incoming_damage
        ; Safety: If incoming damage happens to be 0, we're done
        ; (otherwise we would force it to 1 and deal damage when we shouldn't have)
        lda RemainingDamage
        bne continue
        jmp FAR_receive_damage::return_from_dmg
continue:
        ; First, reduce incoming damage by half, rounded down
        ; (don't worry about preserving it, we block damage propogation anyway)
        lsr RemainingDamage
        ; If that's nonzero, proceed, otherwise force it to a minimum of 0
        ; (armored hearts do not negate all damage)
        bne process_reduced_damage
        lda #1
        sta RemainingDamage
process_reduced_damage:
        ; Reduce!
        ldx CurrentHeartIndex
        sec
        lda heart_hp, x
        sbc RemainingDamage
        ; if we hit zero or we went negative, the heart armor breaks!
        beq break_heart_armor
        bmi break_heart_armor
        ; otherwise, keep the new value
        sta heart_hp, x
        ; zero out remaining damage and exit; we're done here.
cancel_incoming_damage:
        lda #0
        sta RemainingDamage
        jmp FAR_receive_damage::return_from_dmg
break_heart_armor:
        ; When breaking heart armor, explicitly protect the left-most hearts from future
        ; damage sources on the same beat
        lda #1
        sta already_damaged
        ; Zero out remaining damage; we block this from propagating
        lda #0
        sta RemainingDamage
        ; Now remove this heart container entirely. Notably, temporary
        ; armored hearts do not apply the mercy rule, as they should really
        ; never be in slot 0 to begin with
        jsr remove_this_heart
        jmp FAR_receive_damage::return_from_dmg
.endproc

; healing amount in R0
.proc FAR_receive_healing
RemainingHealing := R0
CurrentHeartIndex := R1
HeartHealingProc := R2
        lda #0
        sta CurrentHeartIndex
loop:
        ldx CurrentHeartIndex
        lda heart_type, x
        asl
        tay
        lda heart_healing_functions+0, y
        sta HeartHealingProc+0
        lda heart_healing_functions+1, y
        sta HeartHealingProc+1
        jmp (HeartHealingProc)
return_from_healing:
        ; Bail if there is no more healing left to apply
        lda RemainingHealing
        beq done
        ; Also bail if we've run out of hearts to process
        ; (if this occurs, the player's healthbar is completely full)
        inc CurrentHeartIndex
        lda CurrentHeartIndex
        cmp #TOTAL_HEART_SLOTS
        beq done
        jmp loop
done:
        rts
.endproc

heart_healing_functions:
        .addr heart_do_not_heal  ; none
        .addr heart_heal_to_four ; regular
        .addr heart_do_not_heal  ; glass (has no concept of health)
        .addr heart_heal_to_four ; regular, armored
        .addr heart_do_not_heal  ; temporary hearts cannot receive healing
        .addr heart_do_not_heal  ; (ditto for armored temporary hearts)

.proc heart_do_not_heal
        ; Do not pass go. Do not collect $200
        jmp FAR_receive_healing::return_from_healing
.endproc

.proc heart_heal_to_four
RemainingHealing := R0
CurrentHeartIndex := R1
        ldx CurrentHeartIndex
        ; if we're already at full, bail
        lda heart_hp, x
        cmp #4
        bcc apply_healing
        jmp FAR_receive_healing::return_from_healing
apply_healing:
        lda heart_hp, x
        clc
        adc RemainingHealing
        cmp #4
        bcs handle_overflow
        sta heart_hp, x
        lda #0
        sta RemainingHealing
        jmp FAR_receive_healing::return_from_healing
handle_overflow:
        sec
        sbc #4
        sta RemainingHealing
        lda #4
        sta heart_hp, x
        jmp FAR_receive_healing::return_from_healing
.endproc
