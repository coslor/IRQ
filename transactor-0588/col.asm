.include "..\includes\const.asm"

*= $c878
;--- color.move ---
; saves the contents of color RAM 
;
; From Transactor magazine, May, 1988, 
;	"Three Movers for the C64", by Richard Curcio
;
; saves the contents of color RAM to 1 of 16 sections
;	"under" the Kernal ROM. because color RAM 
;	consists of 1024 nybbles, each colormap is 
;	compacted into 512 bytes. 
;
; To save a color map:
; 	sys COLOR,section#
;
; To restore:
;	sys COLOR+4,section
;
; To store colors under the BASIC ROM:
;	poke COLOR+19,160
; To change back to the Kernal:
;	poke COLOR+19,224
; This makes a total of 32 colormaps available
;
			TEMP = $c3
;
			ldy #$ff; 		flag = store
			bne setup
			ldy #$00		; flag = recover
setup 		sty TEMP		; save entry
			jsr $b7f1		; section # in .x
			cpx #$10		; chk. range 0-15
			bcs qty1		; ±$0f illegal
			txa
			asl				; times 2
			clc
			adc #$e0		; use a0 forfor  bas.rom
			bcs qty1		; rolled over. no room
			tax
			inx
			beq qty1		; will roll over. no room
			ldx #$00
			sta $25			; init. addresses
			stx $22
			stx $24
			ldx #$fe		; counter
			ldy TEMP		; which way ?
			beq recover
			
savcol 		iny				; #$ffª1
			lda #$d8		; hb of color ram
			sta $23			; $22-23 = source
			
col1 		lda ($22),y		; get a nybble
			asl
			asl
			asl
			asl				; move to hi nybble
			sta TEMP		; save it
			inc $23			; next pg. of col. mem.
			lda ($22),y		; get it
			and #$0f
			ora TEMP		; combine 'em
			dec $23			; prepare for  next
			sta ($24),y
			iny
			bne col1
			inx
			beq exit		; enough times
			inc $25
			inc $23
			inc $23
			bne col1			; branch always
;
qty1 		jmp FCERR; illegal quant.

recover 	sei
			lda $01; get config.
			pha
			and #$fd; mask out roms
			sta $01
			lda #$d9; pg2 of color ram
			sta $23
			col2 lda ($24),y; get a byte
			sta ($22),y; ignore hi-nybble
			lsr
			lsr
			lsr
			lsr; move to lo nyb
			dec $23
			sta ($22),y; store it
			inc $23
			iny; pointer
			bne col2
			inx
			beq rdone
			inc $25
			inc $23
			inc $23
			bne col2
			
rdone 		pla; get config
			sta $01; and restore it
			cli
			
exit 		rts


