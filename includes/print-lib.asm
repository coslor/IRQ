#importonce

#import "const.asm"
/**
*	IN: A,Y contain 16-bit value to print
**/
print_ya_hex: {
			sec
			jsr print_a_hex
			clc
			tya
			jsr print_a_hex
			rts
}

/**
*	Print a 2-digit hex number
*
*	IN: A contains value to print
*		if C is set, print a $ before the digits
*
*	TRASHES: A,X
*/
print_a_hex:{
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
			lda hex_chars,x
			jsr CHROUT
			
			pla
			and #$0F
			tax
			lda hex_chars,x
			jsr CHROUT
						
			jmp end_hex_chars
			
			
			.encoding "petscii_mixed"
hex_chars:	.text "0123456789abcdef" 
			.byte 00						
									
temp_a:		.byte 00						
						
end_hex_chars:
			rts
}			

/**
*	IN: ZP pointer to string to be printed is in P_PTR
	TRASHES: A,Y
*/
print_str_ptrX: {
			ldy #0
loop:
			lda (P_PTR),y
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
			sta P_PTR
			sty P_PTR+1
			
			ldy #0
			
loop:			
			lda (P_PTR),y			
			beq exit			
			iny			
			bne loop			
						
exit:						
			tya						
			rts						
}

/*
*	Zero out the pointer to the current char in the keyboard
*		buffer.
*/
clear_keys: {
			lda #0
			sta BUFPTR			//clear keyboard buffer
			rts
}

/*
*	A OUT - 0 for BREAK pressed, 0 for any other key
*/
wait_for_key: {
			jsr clear_keys			
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
//			
//	Print a 16-bit number, held in Y/A. Don't save any regs.		
//		If V set, print in hex.
//		
.macro print_ya_bare() {
ya_bare:
			bvs print_hex
print_dec:			
			jsr GIVAYF		//GIVAYF is Y,A, NOT the other way around!
			jsr FLOATASC
			jsr STROUT
			
			jmp exit
print_hex:			
			sec				// print $				
			jsr print_ya_hex			
						
exit:						
			}

.macro print_a_bare() {			
print_a_bare:			
			tax			
			lda #0
			bvs print_a_hex
			
print_a_dec:			jsr LINPRT
			jmp exit
			
print_a_hex:
			jsr print_a_hex
exit:
			}
