.include "for-macros.asm"


*= $801
;
; BASIC
;
.block
		.word s, 10
		.byte $9e	; SYS
		.null "2061"
		s .word 0
.bend
					
					
					#FOR 1,5,1
						
						#print_str "for_index:"
						#print_int_var for_index
						#print_cr
						#FOR 10,40,10
								;#print_char 19 ;TAB
								#print_str "for_index:"
								#print_int_var for_index
								#print_cr
								
								#inc16 counter
								  
						#NEXT
					#NEXT

					#print_str "counter:"
					#print_int_var counter
					#print_cr
					
					rts					

counter				.word 0000					
