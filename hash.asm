;
; Hashes the string

; Hashes the string pointed to by strptr
; Hash is returned in A
; Destroys A,X,Y
Pearson: 
        ldy #$00            ; i = 0
        lda (strptr),Y      ; Return if str[0] == 0
        beq @done

        ldx #$00            ; hash = 0

@loop:  txa                 ; hash (=X) -> A
        eor (strptr),Y      ; hash (=A) ^ input (=M[strptr+Y]) -> A

        tax                 ; calculated index -> X
        lda PearsonLUT,X    ; new hash -> A

        tax                 ; hash (=A) -> X
        iny                 ; strptr++
        beq @done           ; Finish on overflow
        lda (strptr),Y
        bne @loop           ; loop if *strptr != 0

@done:  txa
        rts
