.ifndef FOR_MACROS
	.include "includes\for-macros.asm"
.endif
.ifndef PRINT_MACROS
	.include "includes\print_macros.asm"
.endif
;
; A collection of useful string routines
;
;.ifndef FOR_MACROS
;	.include "for-macros.asm"
;.endif

STRING_LIB=$0001
;						
; Goes through the string buffer starting at (A,Y). 
;	Returns	the number of bytes (in A) until a 0 is reached, 						
;	or $FF if no 0 is present.					
;					
; trashes:A,X,Y					
;					
;get_str_len						
;.block						
;str_ptr = $fb						
;						ldx #$00								
;						sta str_ptr
;						sty str_ptr+1
;
;count_loop				
;						#DO							
;							lda (str_ptr),y
;							beq count_exit		; exit if we found a 0
;							dex
;						#WHILE_NEQ
;						
;; we've looped back around to 0,so set X to $FF	
;	
;						ldx #$FF 								
;
;count_exit				
;						txa
;						rts
;.bend

;
; Adds a char to a string, in place.
;	The string is pointed to by A,Y, and the char to concat is in Y.
;	Assumes that the string length can go up to $FF.
;
;	Sets C if concat fails because the string is full.
;
;concat_str_char
;.block										
;str_ptr = !MISC_PTR0						
;						sta str_ptr
;						sty str_ptr+1
;						stx new_char
;						
;						jsr get_str_len
;						
;						cmp #$FF
;						#IF_NEQ
;							tay
;							lda new_char
;							sta (str_ptr),y
;							lda #0
;							iny
;							sta (str_ptr),y
;							clc
;						#ELSE
;							sec
;						#ENDIF
;							
;						rts
;
;new_char				.byte 0
;.bend										

;
; Hashes the string

; Hashes the string pointed to by (A,Y).
; Hash is returned in A
; Destroys A,X,Y
; Based on implementation by Eddie Antonio here:
;	https://gist.github.com/eddieantonio/0177cf4db52f17120fef
;
;hash_str 
;.block
;strptr = MISC_PTR0
;						ldy #$00            ; i = 0
;						lda (strptr),Y      ; Return if str[0] == 0
;						beq done
;						
;						ldx #$00            ; hash = 0
;						
;loop  
;						txa                 ; hash (=X) -> A
;						eor (strptr),Y      ; hash (=A) ^ input (=M[strptr+Y]) -> A
;						
;						tax                 ; calculated index -> X
;						lda PearsonLUT_strings,X    ; new hash -> A
;						
;						tax                 ; hash (=A) -> X
;						iny                 ; strptr++
;						beq done           ; Finish on overflow
;						lda (strptr),Y
;						bne loop           ; loop if *strptr != 0
;
;done  
;						txa
;        				rts
;.bend        
;;        
;; Takes 32-byte hex string pointer in STR_PTR0.        
;;	Prints a list of 16 quoted, 2-byte strings, for use in ASM source	
;;	        
convert_hex_str_bytes
.block
						ldy #0
;						
loop
						lda #0
						sta line_end
						
						;#FOR 0,1,0	;loop forever
						;#DO
							lda (MISC_PTR0),y
							#IF_NEQ
								;pha
								#FOR 0,15,1
									#print_char DOLLAR_SIGN  
									#FOR 0,1,1
										
										;#IF_EQ
											;inc line_end
											
											;;pla		;clean up stack		
											;;pla		;clean up stack		
											;;pla		;clean up stack		
											;jmp loop_end 	;if 0, then no more strings
										;#ENDIF
										;pla
										jsr CHROUT
										#inc16 MISC_PTR0
									#NEXT
									lda for_index
									cmp #15
									bcs loop1
									;#IF_LE
										#print_char COMMA
									;#ENDIF
loop1									
								#NEXT
								#print_cr
								#inc16 MISC_PTR0			; skip over trailing 0
							#ENDIF
						;#NEXT
							
loop_end						
						rts

line_end				.byte 00							
temp					.byte 00							
							
.bend				
	
PearsonLUT_strings
						.null "a44b50e89a8bb46226beb27edb05acc5"
						.null "2829b6e07bcd5b08988e54588487f4c2"
						.null "d5fc739db7bf078814e2da567fb91d25"
						.null "761eb806bd5df6dd92ca3803fd43d0eb"
						.null "ccd81f4d6d69ec80998f1a5979c69f40"
						.null "2df039eeb1a0279c01aa6a860446fb0a"
						.null "0d7d191bc936204815616b17116096d2"
						.null "e17867cfc4bc4ce9516333de65d3d4dc"
						.null "3c16496f123a53cb18ba89f92f5f820c"
						.null "d93b9497ad47a62a212bef3574d69be3"
						.null "34e48c0f8de5316c0e3f3d712c5ea122"
						.null "a7b0d1a2a8e6c8a94a422e32af10f166"
						.null "4ec11cfaae8aea934509c7f3ed446ebb"
						.null "247c00abf2f75c9195812372c3705752"
						.null "0bf85a02a5687a37e7d7df3013b34fb5"
						.null "55857577a390f59e643e83c041cefe01"								
						.byte 0,0								