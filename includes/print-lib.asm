#importonce

#import "const.asm"
/**
*	Print a 2-digit hex number
*
*	IN: A contains value to print
*		if C is set, print a $ before the digits
*
*	TRASHES: A,X
*/
print_hex:{
			pha

print_hex_sign:
			bcc print_digits
			lda #'$'
			jsr CHROUT
			
print_digits:
			pla
			pha
			and #$f0			
						
			ror	
			ror	
			ror	
			ror	
				
			tax
			inx					//workaround bug
			lda hex_chars,x
			jsr CHROUT
			
			pla
			and #$0F
			tax
			inx					//workaround bug
			lda hex_chars,x
			jsr CHROUT
						
			jmp end_hex_chars
			
hex_chars:	.text "x0123456789abcdef" 
			.byte 00						
									
temp_a:		.byte 00						
						
end_hex_chars:
			rts
}			

/**
*	IN: ZP pointer to string to be printed is in MISC_PTR0
	TRASHES: A,Y
*/
print_str: {
			ldy #0
loop:
			lda (MISC_PTR0),y
			beq exit
			
			cmp #126		//'~'in ASCII, PI-symbol in PETSCII
			bne print
			
			lda #CR
print:
			jsr CHROUT			
			iny			
			bne loop			
exit:
			rts
}

/*
*	Returns the length of a 0-term string, or $FF if no 0 is found
*
*		A,Y IN - address of string
*		A OUT - length of string
*/
get_str_len: {
			sta MISC_PTR0
			sty MISC_PTR0+1
			
			ldy #0
			
loop:			
			lda (MISC_PTR0),y			
			beq exit			
			iny			
			bne loop			
						
exit:						
			tya						
			rts						
}

/*
*	A OUT - 0 for BREAK pressed, 0 for any other key
*/
wait_for_key: {
clear_keys:
			lda #0
			sta NDX			//clear keyboard buffer
			
check_key:		
			lda STKEY
			bpl stop
			cmp #$ff
			beq check_key
			
normal:			
			lda #1
			rts
			
stop:	
			lda #0	
			rts
}
