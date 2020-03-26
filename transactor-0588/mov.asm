.include "..\includes\const.asm"
.include "..\includes\math.asm"

;=========== move.plus ===========
; copy a block of memory to anywhere else 
;
; From Transactor magazine, May, 1988, 
;	"Three Movers for the C64", by Richard Curcio
;
; move.plus can move any chunk of memory to any location.
; syntax is:
;	sys MOVE,source addr,destination addr,# bytes,mask

; DESTination address can be under the Kernal or BASIC.
; if mask > 0, interrupts are disabled and BASIC 
;	and the Kernal ROMs are switched out, allowing
;	access to the RAM underneath the ROMS.
;
; NOTE: if # of bytes copied causes the dest addr to
;	roll over to $0, the routine stops, and sets
;	Y to 255. SYREG is set to that value when the
;	routine returns to BASIC.
;
; To call from another routine:
;	lda #<MY_SOURCE
;	sta SRCE
;	lda #>MY_SOURCE
;	sta SRCE+1
;	lda #<MY_DEST
;	sta DEST
;	lda #>MY_DEST
;	sta DEST+1
;	jsr calc
;

			*=$c800
			
;frmnum = $ad8a
;chkcom = $aefd
;getadr = $b7f7
SRCE = $c3
NBYTES = $14
DEST = $c1
;
; get and store source and destination
;
begin 		jsr CHKCOM
			jsr FRMNUM
			jsr GETADR
			sty SRCE	
			sta SRCE+1
			jsr CHKCOM
			jsr FRMNUM
			jsr GETADR
			sty DEST
			sta DEST+1
			jsr CHKCOM
;
; get number of bytes and mask value
;
			jsr GETNUM	; two bytes in $14-15, a comma, then one byte in x
;
; $14-$15 has number of bytes
;
			txa
			beq calc	; if mask = 0
			sei
			lda $01		; get mem. config.
			pha
			and #$fd	; mask basic and kernel
			sta $01
;
; calculate end address
;
calc 		clc			; add #bytes to DEST.
			lda NBYTES
			adc DEST
			sta NBYTES
			lda NBYTES+1
			adc DEST+1
			sta NBYTES+1 ; $14­15= DEST.end+1
			ldy #$00
			
start 		lda (SRCE),y
			sta (DEST),y
			
bump1	 	inc SRCE
			bne bump2
			inc SRCE+1
			
bump2 		inc DEST
			bne comp
			inc DEST+1
			beq rollo	; if DEST. rolls over
			
comp 		lda DEST+1
			cmp NBYTES+1
			bne start
			lda DEST
			cmp NBYTES
			bne start
			
done 		txa			; was mask = 0 ?
			beq exit	; yeah
			pla			; restore mem. config.
			sta $01
			cli
exit 		rts
	;
rollo 		dey			; leave 255 in
			bne done	; location 782