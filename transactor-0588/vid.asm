.include "..\includes\const.asm"

*= $c900
;------ video.move ------
; save screen and color memory to one of five sections under the Kernal.
;
; From Transactor magazine, May, 1988, 
;	"Three Movers for the C64", by Richard Curcio
;
; All 1024 bytes of the screen are saved, including thes ixteen unused bytes and the eight bytes of sprite data pointers.
; As in 'Color.Move',color ram is compacted into 512 bytes for a total of 1536 bytes per section.
; To save screen and color: 
;	sys VIDEO,section,screen org
; section is 0 to 4 
; screen org determines where the screen lives: 
; 	0: the routine use location 648 to find text screen 
;  	>0: uses VIC-II,CIA 2 to find currently displayed screen
;
; To recover screen and color:
;	sys VIDEO+4,section,screen org 
; 
; BASIC and Kernal ROMs are switched out during storage & retrieval.
;
; To call from another routine:
;	
;

TEMP = $c3

video_store	ldy #$ff; here to store
			bne setup
video_recover ldy #$00; here to recover
			
setup 		sty TEMP
			jsr COMBYT ;check for a comma, then call GETBYT, val in X
			cpx #$05; section 0-4
			bcs qty1
			lda #$e0; use #$a0 for bas.rom
			
again 		dex
			bmi cont; no addition
			clc
			adc #$06
			bcs qty1; no ëod
			bne again
cont 		tay; save result
			adc #$05; enough room
			bcc ok
;
qty1 		jmp FCERR; illegal quantity
;
ok 			sty $15; 			hi-byt of sect. #
			lda $0288			; hi-byt of screen loc.
			sta $af				; init. addresses
			lda #$00
			sta $ae
			sta $14
			jsr COMBYT			; which screen org.
			txa
			beq movit			; 0 = text screen
			lda $dd00			; vid.bank from cia 2
			ror					; bits 0 & 1
			ror					; into 6 & 7
			ror
			eor #$ff			; invert
			and #$c0			; zero others
			sta TEMP+1
			lda $d018			; vid.matrix from vic-ii
			ror
			ror
			and #$3c
			ora TEMP+1			; combine
			sta $af
			
movit 		sei
			lda $01
			pha
			and #$fd			; mask out roms
			sta $01
			ldx #$00
			ldy TEMP
			beq recover
			iny					; #$ff+1=00
			
store 		lda ($ae),y
			sta ($14),y
			iny
			bne store
			inc $15			 	;hb dest.
			inc $af				; hb src.
			inx
			cpx #$04
			bcc store
			
color 		lda #$d8			; hb of color ram
			sta $af
			
col1 		lda ($ae),y			; get a nybble
			asl
			asl
			asl
			asl					; move to hi nybble
			sta TEMP			; save it
			inc $af
			lda ($ae),y
			and #$0f
			ora TEMP
			dec $af
			sta ($14),y
			iny
			bne col1
			inx
			cpx #$06
			beq done
			inc $15
			inc $af
			inc $af
			bne col1
;
recover 	lda ($14),y
			sta ($ae),y
			iny
			bne recover
			inc $15				; hb src.
			inc $af				; hb dest.
			inx
			cpx #$04
			bcc recover
reccol 		lda #$d9			; pg2 of color ram
			sta $af
col2 		lda ($14),y			; get a byte
			sta ($ae),y			; ignore hi-nybble
			lsr
			lsr
			lsr
			lsr					; move to lo nyb
			dec $af
			sta ($ae),y			; store it
			inc $af
			iny					; pointer
			bne col2
			inx
			cpx #$06			; enough times
			beq done
			inc $15
			inc $af
			inc $af
			bne col2
;
done 		pla					; get config
			sta $01				; and restore it
			cli
endrec rts


