//			
//	test numerical macro routines			
//			
#import "print_macros.asm"			

/*
*	Mostly just useful for this file, thus a local macro
*/
.macro pause() {
			print_reversed_str("press any key to continue")
			jsr wait_for_key
			bne not_exit1
			
			rts			
						
not_exit1:			
			print_char_bare(UP)
			print_spaces(40)
			//print_char_bare(UP)
			}

			
*= $801
BasicUpstart(start)

*= $810
start:


			.const number = 1777	

			print_centered_str("*** test print macros ***")

			print_str("~a(17/$11):")
			lda #17
			print_a()
						
			print_str("~a(145):")
			lda #145
			print_a()
			
			print_str("~int(17):")
			print_int(17)
			
			print_str("~int(1707):")
			print_int(1707)
			
			print_str("~int(40000):")
			print_int(40000)
						
			print_str("~byte(34):")
			print_byte(34)
			
			print_str("~byte in hex (34=$22):")
			lda #34
			print_a_hex()
			
			print_str("~byte(129):")
			print_byte(129)
			
			print_str("~integer constant (1777):")
			print_int(number)
			print_str("~in hex ($6f1):")
			set_v()
			print_int(number)
			
			print_str("~integer variable(1700):")
			print_int_var(line_num)
			
			print_str("~hex byte ($42):")
			lda #$42
			sec
			print_a_hex()
			
			print_str("~int pointer(1717):")
			store16(variable,MISC_PTR0)
			print_int_ptr(MISC_PTR0)

			print_str("~location of variable:")
			print_int(variable)
			 
			print_str("~location held in pointer:")
			print_int_var(MISC_PTR0)
			print_str("~location *of* pointer:")
			print_byte(MISC_PTR0)
			
			print_str("~string pointer('seventeen'):")
			store16(str_var,MISC_PTR0)
			print_str_ptr(MISC_PTR0)
			
			print_str("~char pointer('z'):")
			store16(test_char,MISC_PTR0)
			print_char_ptr(MISC_PTR0)
			
			print_str("~string to fac1('234.56')")
			str_to_fac1("234.56",6)
			print_fac1()
			
			print_str("~string addr to fac1(17.17)")
			str_addr_to_fac1(float_str_var)
			print_fac1()
			
			print_str("~string to float(34.343)")
			str_to_float("34.343",6,float_var)
			print_float(float_var)
			
			print_str("~string with leading zeroes to fac1(0004)")
			str_to_fac1("0004",4)
			print_fac1()
			print_cr()

			pause()
						
			print_reversed_str("1234567")
			print_cr()
			
			print_reversed_str("12345678")
			print_cr()

			print_reversed_str("1")
			print_cr()
			
			print_reversed_str("01234567890123456789")
			print_cr()

			print_reversed_str("012345678901234567890123456789")
			print_cr()

			print_reversed_str("012345678901234567890123456789012345678901234")
			print_cr()
			
			print_reversed_str("")
			print_cr()
			
			print_str("~print binary for $aa(10101010)~")			
			print_byte_binary($aa)			
						
			print_str("~print binary for $55(01010101)~")			
			print_byte_binary($55)		
			print_cr()	
											
			pause()
						
			print_str("print binary for $ff~")
			print_byte_binary($ff)
			 
			print_str("~print binary for 0~")
			print_byte_binary(0)
			print_cr()
			print_cr()

			print_str("~print spaces(10)~")
			print_spaces(10)
			print_char('x')
			print_str("~123456789abcdef~")
			
			print_cr()
			
exit:
			rts

line_num:	.byte $a4, $06																																					

variable:	.word 1717																																					
str_var:	.text "seventeen" 
			.byte 00																																					
																																								
float_str_var: 	.text "17.17"
				.byte 00																																								
																																					
test_char:	.byte 'z'																																					
																																					
float_var:	.fill 5,0																																					

