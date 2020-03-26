.ifndef FOR_MACROS
	.include "..\includes\for-macros.asm"
.endif
.ifndef PRINT_MACROS
	.include "..\includes\print_macros.asm"
.endif

#BASIC

					#print_str "**structure macro tests**~"					
										
					#print_str "~*for test*~"					
																				
					#FOR 1,5,1
						
						#print_str "for_index:"
						#print_int_var for_index
						#print_cr
						#FOR 10,40,10
;								;#print_char 19 ;TAB
								#print_str "for_index:"
								#print_int_var for_index
								#print_cr
								
								#inc16 counter
								  
						#NEXT
					#NEXT

					#print_str "counter (should be 20):"
					#print_int_var counter
					#print_cr
														
test_do
					#print_str "~*do..while test*~"
					
					#print_str "print stars! (should be 5 groups of 3)~"
					
					ldx #5      
					#DO
					    ldy #2         
						lda #"*"
						#DO         
							jsr CHROUT   ; print star	
							dey
						#WHILE_PL
						
						lda #" "    ;print space
						jsr CHROUT
						dex
					#WHILE_NEG 
					#print_cr

test_if
					#print_str "~*if test*~"
					
					#print_str "this should say 4~"
					lda #8
					ror
					cmp #4
					#IF_EQ
						jsr is_four
						#print_str "isn't that great??~"
					#ELSE
						jsr is_not_four
					#ENDIF

					#print_str "this should not say 4~"
					lda #8
					ror
					cmp #3
					#IF_EQ
						jsr is_four
					#ELSE
						jsr is_not_four
						#print_str "now, brace yourself...~"
					#ENDIF
					
					#print_str "~structure test over!~"
					
test_exit
					rts
					
					

is_four 					
					#print_str "4~"
					#print_str "(not 2)~"
					rts	
					
is_not_four					

					#print_str "I don't know what it is, but...~"
					#print_str "...it's not 4!~"
					rts					

																
counter				.word 0000					
					
;#END_VARS					
