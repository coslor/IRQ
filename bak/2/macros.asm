.ifndef constants
.include "const.asm"
.endif

macros=1

;
;	"~" character prints as CR(13)
;
print_str	.macro
			
			pha
			txa
			pha
			
			ldx #0
			
loop			
			lda txt,x
			beq exit
			
			
			cmp #126		;'~'in ASCII, PI-symbol in PETSCII
			bne print
			
			lda #13
			
			
print			
			jsr CHROUT			
			inx			
			bne loop			
			
			
;			lda #<txt
;			ldy #>txt
;			jsr STROUT
;			
exit
			jmp end_text		
						
txt			.null "@1"
end_text							
			pla						
			tax						
			pla						
									
			.endm
			
			
;print_str_cr .segment			
;			#print_str "@1"			
;			#print_char 13			
;			.endm			
						

print_int	.macro
			pha
			tya
			pha
			
			lda #>\1
			ldy #<\1
			jsr LINPRT
			
			pla
			tay
			pla
			.endm
			

print_char	.macro
			pha	
				
			lda #\1
			jsr CHROUT
			
			pla
			.endm
			
print_a		.macro
			pha
			txa
			pha
			
			tax
			lda #0
			jsr LINPRT
			
			pla
			tax
			pla
			.endm
			
print_byte	.macro
			pha

			lda #\1
			#print_a
			
			pla
			.endm
			
print_ptr	.macro
			
			pha
			tya
			pha
			
			lda \1+1
			ldy \1+2
			jsr LINPRT
			
			pla
			tay
			pla
			.endm
			
;			
;  increment a 16-bit value 
; 			
inc16		.macro					
			;#print_str "inc16"					
								
			pha					
								
			clc
			lda \1					
			#print_str "inc16:a="					
			#print_a					
			#print_char 13					
			adc #1					
			#print_str "inc16:after inc, a="				
			#print_a				
			#print_char 13				
							
			sta \1					
			lda \2					
			adc #0					
			sta \2					
								
			pla								
											
			;inc \1					
			;bne done					
			;					
			;inc \1+1					
done								
			.endm								
											
						