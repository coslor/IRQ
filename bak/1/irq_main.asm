;        1         2         3         4         5         6         7
;2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

;
;	Fiddling around with IRQ vectors
;

.include "const.asm"
.include "macros.asm"


* = $0801

; BASIC header
; 10 SYS (2064)
    .byte   $0E, $08, $0A, $00, $9E, $20, $28
    .text 	"2064"
    .byte 	$29, $00, $00, $00
    

;
;	set the irq vector to execute our code
;		before running the normal C64 IRQ vector
;
activate 
.block
			lda #$17		; set upper-lower character set
			sta $d018
			#print_char 8	; ...and disable switching 
			
			
			jsr check_active
			bcs deactivate
			
			sei
			
			lda #>main
			sta $315
			lda #<main
			sta $0314
			
			lda $d020
			sta old_bgcolor
			
			cli
			
exit			
			#print_str "To deactivate, run again"
			#print_char 13
			
			rts
.bend


;
;	restore the IRQ vector to the system default, assuming 
;		that's it's been previously set. Otherwise, complain.
;
deactivate		
.block		
			jsr check_active		
			bcc activate	
		
			sei
			
			
			lda #$31		
			sta $0314		
			lda #$EA		
			sta $0315		
					
			cli		

			lda old_bgcolor
			sta $d020
			
			#print_str "Deactivated!"
			#print_char 13
			#print_str "Run again to re-activate"
			#print_char 13
					
			clc		
			bcc exit	
exit 	
			rts
.bend

;				
;	main routine, which runs every IRQ period (60 times/sec				
;		for NTSC machines). 				
;					
;	at the moment, just sets the border color to black				
;		to remind the user that it's active, and				
;		clears the screen when the user hits commodore-c				
;				
				
main	
			
			lda #0
			sta $d020	; set border color to black when 
						; 	custom IRQ is active		
			
			jsr check_key			
			bcc exit			
						
						
			jsr CLR_SCREEN
		
		
exit
			jmp $EA31	;continue IRQ servicing logic
			rts

count			.byte $ff

;			
;	Checks to see if IRQ is active. Sets carry accordingly.			
;			
check_active				
.block				
			lda $315
			cmp #>main
			bne not_active
			lda $314
			cmp #<main
			bne not_active
			
			sec
			jmp exit
			
not_active	clc			
			jmp exit			
						
exit		rts						
.bend						
			
					
;
; check for 'commodore-c' key pressed,
;	OUT:c=1 if pressed, 0 if not
;
check_key
.block
			lda SHIFT_KEYS
			and #(KEY_COMM)
			beq ck1
			
			lda $cb			
			cmp #$14		;'c'			
						
			bne ck1			
						
			sec
			rts
			
ck1			clc
			rts
.bend

old_bgcolor	.byte 0					


