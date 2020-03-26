//
// test opening screen as an input file
//
*= $c000

#import "print_macros.asm"			
#import "math.asm"			

//*= $801
//BasicUpstart(start)


start: {
			print_char(CLR)
			print_str("screen-file-poc~")
			print_str("output value is:~")
			print_str("1717~")
			print_char(UP)
			//print_char(HOME)
			
			//print_str(">")


open_screen:
			lda #3
			ldx #3
			ldy #0
			jsr SETLFS
			bcc next
			print_str("error getting logical file. exiting.~")
			jmp exit
			
next:
			lda #0
			jsr SETNAM
			bcc next1
			print_str("error setting empty name. exiting~");
			jmp exit

next1:
			//lda #15
			jsr OPEN
			bcc next2
			print_str("error opening file. exiting.~")
			jmp exit
//			
//	NOTE: SETLFS requires the LFN in A, CHKIN in X. Don't mix them up!			
//			
next2:		
			ldx #3
			jsr CHKIN
			bcs chkin_error
			jmp next3
			
chkin_error:			
			pha
			print_str("error using file as input. error code:")
			pla
			print_a()
			print_char(CR)
			jmp exit

next3:			
			store16_in_ay(input_str)
			jsr read_line		

			// A is trashed, so re-load values for skip_spaces()					
			store16_in_ay(input_str)
			jsr skip_spaces			
						
			// X is now the length of the string, but we haven't changed			
			//	the string itself. truncate it by adding a 0 at the (new) end.			
			lda #0			
			sta input_str,x			
						
							
print_line:	
									
			print_str("line read was:~")
			
			//NOTE: input_str is already null-terminated,
			//	 since the buffer was filled with 0s
			print_char('\'')
			print_str_addr(input_str)
			print_char('\'')
			print_char(CR)
			
compare:
			str_addr_to_fac1(input_str)

			fac1_to_int(temp_int)
			
			// We're looking for 1717, or $06b5
			cmp16const(temp_int,1717)
			beq success
			jmp failure
			
success:
			print_str("success! automated tests will be easier from now on!~")
			jmp exit
			
failure:
			print_str("failure! we were looking for 1717, but we got ")
			print_int_var(temp_int)
			print_char(CR)
			
exit:
			lda #15
				
			jsr CLOSE																																		
			jsr CLRCHN																																		

			rts

			
/*
*	Read a string from the current input device into the given
*		buffer. Reads all chars, including commas, colons, etc.
*		Stops upon reading a CR, or after reading 255 chars. 
* 
*		NOTE: DOES NOT zero-terminate the string - assumes that 
*		the buffer is filled with 0's beforehand. Does not store 
*		the final CR. 
*
*		A,Y IN - address of string buffer		
*		X OUT - string length, NOT including CR or ending 0		
*/
read_line:{			
			store_ay_in_var(MISC_PTR0)			
			ldx #0
						
read_chars:			
			jsr CHRIN			// CHRIN doesn't trash X, does it?	
			cmp #CR
			beq exit
			
			sta input_str,x	
			inx
			bne read_chars
exit:			
			// X points to CR at end of line. which we didn't store anyway.
			//	decrement it to point to the last stored char instead.
			dex
			
			rts
}				
			
/*
*	Given a string, figure out how long it should be 
*		without trailing spaces.
*
*		A,Y IN - lo,hi addr of string
*		X IN - original string length
*		X OUT - length, minus trailing spaces
*
*		TRASHES: A,Y
*/
skip_spaces: {					
			.break					
											
			sta MISC_PTR0			
			sty MISC_PTR0+1			
			txa			
			tay			
						
loop:				
			lda (MISC_PTR0),y						
			cmp #$20						
			bne done						
			dey						
			bpl loop	//take unless y<0, in which case we're done anyway						
									
done:						
			iny			// y is currently a 0-based INDEX, and we need a 1-based COUNT				
							
			tya						
			tax					
								
			rts						
}					
temp_int:	.word 0000			
input_str: 	.fill 80,0		
}
