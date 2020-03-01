;			
;	test numerical macro routines			
;			
.include "macros.asm"			

*= $801
.block
.word s, 10
.byte $9e
.null "2061"
s .word 0
.bend

number = 1777	
	
			#print_str "*** test macros ***~"

			
			
			#print_cr
			
			#print_str "a(17):"
			lda #17
			#print_a
			
			#print_str "~a(145):"
			lda #145
			#print_a
			
			#print_str "~int(17):"
			#print_int 17
			
			#print_str "~int(1707):"
			#print_int 1707
			
			#print_str "~int(40000):"
			#print_int 40000
			

			#print_str "~byte(34):"
			#print_byte 34
			
			#print_str "~byte(129):"
			#print_byte 129
			
						
			#print_str "~integer constant(1777):"
			#print_int number
			
			#print_str "~integer variable(1700):"						
			#print_int_var line_num

			#store16 variable,MISC_PTR0									
			#print_str "~int pointer(1717):"
			#print_int_ptr MISC_PTR0 
			#print_str "~location held in pointer:"			 
			#print_int_var MISC_PTR0
			#print_str "~location *of* pointer:"
			#print_int MISC_PTR0
			
			#print_str "~string pointer('seventeen'):"
			#store16 str_var,MISC_PTR0
			#print_str_ptr MISC_PTR0
			
			#store16 test_char,MISC_PTR0
			#print_str "~char pointer('z'):"
			#print_char_ptr MISC_PTR0
			
			rts

line_num	.byte $a4, $06																																					

variable	.word 1717																																					
str_var		.null "seventeen"																																					
test_char	.byte "z"																																					
																																					
																																					
