#importonce
#import "macros.asm"
#import "print-lib.asm"

.encoding "petscii_mixed"

//		
//	Print an 8-bit number. If V set, print in hex.
//
.macro print_byte(val) {
			push_ax()
			lda #val
			
			print_a_bare()
			pull_ax()
			}
			
.macro print_ay_hex_bare() {
			sec					// print $
			print_a_hex_bare()
			clc					//now, *dont* print $
			tya
			print_a_hex_bare()
			}
			
.macro print_ptr(ptr) {
			push_ay()
			lda ptr+1
			ldy ptr+2
			jsr LINPRT

			pull_ay()
			}
			
//			
// Prints contents of A in hex. Prints preceding $ if carry is set. 
// 			
.macro print_a_hex_bare() {
			//push_ax()
			sta temp_a
			
			txa			
			pha		
						
print_dsign:
			bcc print_hex						
			print_char($24)	//$	

				
print_hex:
			lda temp_a			
			and #$f0			
						
			ror	
			ror	
			ror	
			ror	
				
			tax
			inx					//workaround bug
			lda hex_chars, x
			jsr CHROUT
			
			lda temp_a
			and #$0F
			tax
			inx					//workaround bug
			lda hex_chars, x
			jsr CHROUT
			
			pla			
			tax
			
			jmp end_hex_chars
			
hex_chars:	.text "x0123456789abcdef" 
			.byte 00						
									
temp_a:		.byte 00						
						
end_hex_chars:
			//pull_ax()
			}			


.macro print_a_hex() {
			push_ax()
			print_a_hex_bare()
			pull_ax()
			}						
									
//
//	"~" character prints as CR(13)
//
//
.macro print_str(text) {

			print_str_addr(rtxt)
			
//exit
			jmp end_text		


			.encoding "petscii_mixed"
rtxt:		.text text
			.byte 00

end_text:
												
}

.macro print_str_addr(addr) {
print_str_addr:
			push_ax()
			
			lda #<addr
			sta MISC_PTR0
			lda #>addr
			sta MISC_PTR0+1
			jsr print_str
			
			pull_ax()
			}			
			
//print_str_cr .segment			
//			#print_str "@1"			
//			#print_char 13			
//			}			
						

.macro print_int(val) {
print_int:
			push_axy()
			lda #>val
			ldy #<val
			print_ya_bare()
			pull_axy()
			}

.macro print_int_var(loc) {
			push_axy()
			lda loc+1
			ldy loc
			print_ya_bare()
			pull_axy()
			}

// loads y,a with the value of the int pointed to 
//	by 16-bit ptr zp_ptr
.macro _get_ptr_int(zp_ptr) {
get_ptr_int:			
			ldy #0
			lda (zp_ptr),y
			pha
			
			iny
			lda (zp_ptr),y
			tay
			
			pla

			}
//
// print a 16-bit int referenced by the
//	zero-page 16-bit pointer starting at ptr
//
.macro print_int_ptr(ptr) {
print_int_ptr:
			push_axy()
			_get_ptr_int(ptr)		
					
			//swap_ay()					
								
			print_ya_bare()
			pull_axy()
			}

.macro print_char_ptr(zp_ptr) {
print_char_ptr:
			push_axy()
			ldy #0
			lda (zp_ptr),y						
									
			jsr CHROUT			
						
			pull_axy()
			}			
						
//
// print a zt string referenced by the zero-page 
//	16-bit pointer starting at zp_ptr
//
.macro print_str_ptr(zp_ptr) {
print_str_ptr:
			push_axy()
			ldy #0
loop:
			lda (zp_ptr),y
			beq exit
			
			cmp #126		//'~'in ASCII, PI-symbol in PETSCII
			bne print
			
			lda #CR
print:
			jsr CHROUT			
			iny			
			bne loop			

//finished						
//			pull_axy()
//			jmp exit
//			
//temp_a		.byte 00			
//temp_y		.byte 00			

exit:
			pull_axy()
			}

//
//	Print 16-bit number, held in A/Y, saving AXY.
//
.macro print_ya() {
print_ya:
			push_axy()
			print_ya_bare()
			pull_axy()
			}

//			
//	Print a 16-bit number, held in Y/A. Don't save any regs.		
//		If V set, print in hex. TODO--IS THIS STILL TRUE?
//		
.macro print_ya_bare() {
ya_bare:
			jsr GIVAYF		//GIVAYF is Y,A, NOT the other way around!
			jsr FLOATASC
			jsr STROUT
			
			}

.macro print_char(charval) {
print_char:
			pha	
				
			print_char_bare(charval)			
			pla
			}
			
.macro print_char_bare(charval) {
			lda #<charval
			jsr CHROUT
			}
			
.macro print_spc() {
print_spc:
			print_char(SPC)			
			}			
						
.macro print_cr() {
print_cr:
			print_char(CR)						
			}						
															
			
//		
//	Print an 8-bit number, held in A. If V set, print in hex.		
//		Saves regs
//		
.macro print_a() {
print_a:
			push_ax()
			print_a_bare()
			pull_ax()
			}

.macro print_a_bare() {			
print_a_bare:			
			tax			
			lda #0
			bvs hex
			
			jsr LINPRT
			jmp exit
			
hex:
			print_a_hex_bare()
exit:
			}
			
.macro print_x() {		
			push_ax()		
			txa		
			print_a_bare()		
			pull_ax()		
			}		

.macro print_y() {
			push_axy()
			tya
			print_a_bare()
			pull_axy()
			}
			
.macro print_a_binary() {			
			.for (var i=0; i<8; i++) {			
				rol			
				bcs print_1					
print_0:								
				print_char('0')								
				jmp next								
print_1:								
				print_char('1')
next:				
				}			
			}			
						
.macro print_byte_binary(val) {			
			pha			
						
			lda #val			
			print_a_binary()			
						
			pla			
			}		
					
.macro print_spaces(num) {
			.for (var i=0;i<num;i++) {
				print_char_bare(' ')
				}
			}

.function spaces_to_center(str) {
			.return ((40-str.size())/2)
			}
			
.macro print_centered_str(str) {
			
			.if (str.size() < 40) {
				print_spaces(spaces_to_center(str))
				}
			print_str(str)
			}

.macro print_reversed_str(str) {
			//TODO any other registers here?
			pha
			
			print_char_bare(RVS_ON)
			
			print_centered_str(str)
			
			.if (str.size() < 40) {
				.var trailing_spaces
				.eval trailing_spaces=spaces_to_center(str)
				.if((str.size() &1)==1) {
					.eval trailing_spaces--
					}
				print_spaces(trailing_spaces)
				}
			print_char_bare(RVS_OFF)
			
			pla
			}