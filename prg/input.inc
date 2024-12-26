; Usage note: ButtonsHeld does NOT include the first press frame
;             ButtonsThisFrame DOES include the first press frame
.globalzp ButtonsDown, ButtonsUp, ButtonsHeld, ButtonsThisFrame, ButtonsLastFrame
.global poll_input