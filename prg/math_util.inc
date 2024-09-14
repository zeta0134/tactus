; These are not fast. Use sparingly!

; Inputs in A, Y
; Result in A (low), Y (high)
.global mul8_multiply ; ~120 cycles worst case
; Inputs in dividend (16bit), divisor (8bit)
; Result in quotient, remainder in A
.global div16_divide
.globalzp quotient, dividend, divisor

