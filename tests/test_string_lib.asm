.ifndef MACROS
	.include "..\includes\macros.asm"
.endif
.ifndef FOR_MACROS
	.include "..\includes\for-macros.asm"
.endif

					;
					; BYO BASIC line
					;
line_num	= 10
*=$801
					.byte <next_line,>next_line
					.byte <line_num, >line_num
					;.byte 0a,00
					.byte $9e						;SYS
					.text "2064"
next_line			.byte $00,$00
					
					*=$810


						;#print_str "**test string lib**~~"
						
						;#print_str "*get_str_len testing*~"
						
						lda #<PearsonLUT_strings
						sta MISC_PTR0
						lda #>PearsonLUT_strings
						sta MISC_PTR0+1
						jsr convert_hex_str_bytes
						
						rts 
						
buffer					;.repeat $ff,0
						
					.include "..\string_lib.asm"
