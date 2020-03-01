.ifndef constants
.include "const.asm"
.endif

macros=1

;
;	"~" character prints as CR(13)
;
print_str	.macro
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
			.endm
			
			
;print_str_cr .segment			
;			#print_str "@1"			
;			#print_char 13			
;			.endm			
						

print_int	.macro
			lda #>\1
			ldy #<\1
			jsr LINPRT
			.endm
			

print_char	.macro
			lda #\1
			jsr CHROUT
			.endm
			
print_a		.macro
			tax
			lda #0
			jsr LINPRT
			.endm
			
print_byte	.macro
			lda #\1
			#print_a
			.endm
			
print_ptr	.macro
			lda \1+1
			ldy \1+2
			jsr LINPRT
			.endm
			
;			
;  increment a 16-bit value 
; 			
inc16		.macro					
			;#print_str "inc16"					
								
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
								
			inc $d020					
								
			;inc \1					
			;bne done					
			;					
			;inc \1+1					
done								
			.endm								
											
						