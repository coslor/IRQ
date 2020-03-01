.ifndef constants
.include "const.asm"
.endif

macros=1


push_axy	.macro
			pha
			txa
			pha
			tya
			pha
			.endm

pull_axy	.macro						
			pla
			tay
			pla
			tax
			pla
			.endm			
;
;	"~" character prints as CR(13)
;
print_str	.macro
			
			pha
			txa
			pha
			
			#print_str_addr rtxt
			
exit
			jmp end_text		
						
rtxt			.null "@1"

end_text							
			pla						
			tax						
			pla						
									
			.endm

print_str_addr .macro			
			ldx #0
			
loop			
			lda \1,x
			beq exit
			
			cmp #126		;'~'in ASCII, PI-symbol in PETSCII
			bne print
			
			lda #CR
			
print			
			jsr CHROUT			
			inx			
			bne loop			
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
			;jsr LINPRT
			#print_ay			
			
			pla
			tay
			pla
			.endm

print_int_var .macro
			pha
			tya
			pha
			
			lda \1+1
			ldy \1
			;jsr LINPRT
			#print_ay			
			
			pla
			tay
			pla
			.endm

; loads a,y with the value of the int pointed to 
;	by 16-bit ptr \1
get_ptr_int	.macro
			
			ldy #0
			lda (\1),y
			
			pha
			iny
			lda (\1),y
			
			tax
			pla
			tay
			txa

			.endm
;
; print a 16-bit int referenced by the
;	zero-page 16-bit pointer starting at \1
;
print_int_ptr .macro
			#push_axy			
			
			#get_ptr_int \1			

			#print_ay
			
			#pull_axy
			.endm

print_char_ptr .macro			
			#push_axy			
						
			ldy #0
			lda (\1),y						
									
			jsr CHROUT			
						
			#pull_axy			
			.endm			
						
;
; print a zt string referenced by the zero-page 
;	16-bit pointer starting at \1
;
print_str_ptr .macro
			#push_axy			

			ldy #0
			
loop			
			lda (\1),y
			beq exit
			
			cmp #126		;'~'in ASCII, PI-symbol in PETSCII
			bne print
			
			lda #CR
			
print			
			jsr CHROUT			
			iny			
			bne loop			

;finished						
;			#pull_axy
;			jmp exit
;			
;temp_a		.byte 00			
;temp_y		.byte 00			

exit		
			#pull_axy
			.endm

;
;	
;
print_ay	.macro
			push_axy
			
			;jsr LINPRT
			jsr GIVAYF
			jsr FOUT
			jsr STROUT
			
			pull_axy
			.endm
			

print_char	.macro
			pha	
				
			lda #\1
			jsr CHROUT
			
			pla
			.endm
			
print_spc	.macro			
			#print_char SPC			
			.endm			
						
print_cr	.macro						
			#print_char CR						
			.endm						
															
			
print_a		.macro
			
			sta temp
			txa
			pha
			
			lda temp
			#print_a_bare
			
			;jsr A_TO_FAC1
			;jsr FOUT
			;jsr STROUT
;			pha
;			tya
;			pha
;			
;			lda temp
;			ldy #0
;			#print_ay
;			
;			pla
;			tay
;			pla
			
			pla
			tax
			lda temp	
			jmp exit	
				
temp		.byte 00				

exit				
			.endm

print_a_bare .macro			
			tax			
			lda #0
			
			jsr LINPRT
			
			.endm
			
			
print_byte	.macro
			pha
			txa
			pha

			lda #\1
			
			#print_a_bare
			
			pla
			tax
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
								
;			pha					
;								
;			clc
;			lda \1					
;			#print_str "inc16:a="					
;			#print_a					
;			#print_char 13					
;			adc #1					
;			#print_str "inc16:after inc, a="				
;			#print_a				
;			#print_char 13				
;							
;			sta \1					
;			lda \2					
;			adc #0					
;			sta \2					
;								
;			pla								

	label1											
	label2											
												
			.ifdef DEBUG_MACROS								
				#print_str "inc16:before="								
				#print_int \1								
				#print_char CR								
			.endif								
											
			inc \1					
			bne done					
								
			inc \1+1					
								
								
done								
			.ifdef DEBUG_MACROS			
				#print_str "inc16:after="			
				#print_int \1			
				#print_char CR			
			.endif			
						
			.endm								

;											
; store a 16-bit constant \2 in location \1											
;	NOTE: does not save contents of A!											
;											
store16		.macro											
														
			lda #<\1											
			sta \2											
														
			lda #>\1											
			sta \2+1											
														
			.endm											

;											
; store the value of 16-bit var \2 in location \1											
;	NOTE: does not save contents of A!											
;											
store16var	.macro											
														
			lda \1											
			sta \2											
														
			lda \1+1											
			sta \2+1											
														
			.endm											
														
;											
; compare two 16-bit pointers.											
;	OUT: A=0 if equal, 1 otherwise 											
;											
cmp16vars	.macro						
			.ifdef DEBUG_MACROS						
				#print_str "cmp16vars:/1="						
				#print_int_var \1						
				#print_str " /2="						
				#print_int_var \2						
				#print_char SPC						
			.endif						
									
			lda \1						
			cmp \2										
			bne not_equal					
								
			lda \1+1					
			cmp \2+1					
			bne not_equal					
	equal								
			.ifdef DEBUG_MACROS					
				#print_str "EQUAL!"					
			.endif					
			lda #0								
			beq exit	;always taken							
										
	not_equal										
			lda #1										
								
exit																
			.ifdef DEBUG_MACROS															
				#print_char CR															
			.endif															
			.endm						


; hi ma!									
;									
; compare a 16-bit var to a constant									
;	OUT: A=0 if equal, 1 otherwise 											
;									
cmp16const	.macro						
			.ifdef DEBUG_MACROS						
				#print_str "cmp16const:/1="						
				#print_int \1						
				#print_str " /2="						
				#print_int \2						
				#print_char SPC						
			.endif						
																		
			lda \1						
			cmp #<\2					
			bne not_equal					
								
			lda \1+1					
			cmp #>\2					
			bne not_equal					
								
equal								
			.ifdef DEBUG_MACROS					
				#print_str "EQUAL!"					
			.endif					
			lda #0					
			beq exit	; always taken					
								
not_equal								
			.ifdef DEBUG_MACROS					
				#print_str "NOT EQUAL!"					
			.endif					
			lda #1								
								
exit																
			.ifdef DEBUG_MACROS															
				#print_char CR															
			.endif															
			.endm						

;									
; 16-bit ints: \1 = \1+\2						
;									
add16		.macro									
			clc									
												
			lda \1									
			adc \2									
			sta \1									
												
			lda \1+1
			adc \2+1
			sta \1+1
			
			clc
			.endm
			
			 									