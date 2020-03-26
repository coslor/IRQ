.ifndef FOR_MACROS
	.include "..\includes\for-macros.asm"
.endif
.ifndef PRINT_MACROS
	.include "..\includes\print_macros.asm"
.endif
;
; Demonstrates the use of the COMMA routine ($aefd),
; as well as some other parsing routines.
;
; The idea is that the user calls this routine like:
;	sys 49152,1334
;
; The code will then return:
;	The number you used was: 1334
;
; If you left out the comma, you'd get:
;	?illegal quantity error
;
; If we're looking for a number, and:
; 1) if we use letters,
; 	the routine assumes that we mean a variable name, so
; 	it will actually use existing variables:
;		let a=1337
;		sys 49152,a
; 	...returns:
;		The number you used was:1337
;
; 2) If you try to use a float, it just truncates the
;		decimal point:
;		sys 49152,12.5
; 	...returns:
;		The number you used was: 12
;
; 3) If you try to use a string literal:
;		sys 49152,"a"
; 	...you get:	
;   	The number you used was: 0	
; 	It doesn't seem to matter what the literal is.	
;	
; 4) If you try to use TI (w/o quotes), you get:	
;		?illegal quantity error	
;	
; If you ask for a string, and one is available, it's info	
; is put into FAC1 as follows:	
;	FAC1: length of string	
;	FAC1+1: lobyte of string address	
;	FAC1+2: hibyte of string address	
; NOTE: The string is *NOT* zero-terminated! You must use the	
; string length.		
;

;#BASIC
					*=$801
					;
					; BYO BASIC line
					;
line_num	= 10
					.byte <next_line,>next_line
					.byte <line_num, >line_num
					.byte $9e						;SYS
					.text "2080,1337,"
					.byte $22						;quote
					.text "hithere"
					.byte $22						;quote
next_line			.byte $00,$00
					
					*=$820
start				

					lda #$17		; set upper-lower character set
					sta MEM_SETUP
					;#print_char 8	; ...and disable switching 
					
					jsr CHKCOM	; comma

					lda #0		; numeric
					sta VALTYP
					lda #$80	; int
					sta INTFLG
					jsr $ad9e	; FRMEVAL
					jsr FACTOINT	; put FAC1 into A/Y
					
					; move value of Y into X; preserve A
					pha
					tya
					tax
					pla
					
					#print_str "The number you used was:"
					jsr LINPRT
					#print_cr
					
					jsr CHKCOM
					
					lda #$FF		; string
					sta INTFLG
					jsr FRMEVAL
										
					#print_str "The string was:"
					
					; NOTE: We can't use #print_str_ptr, because it's
					;	not zero-terminated!
					
					ldy #0
print_loop					
					#DO
							lda (FAC1+1),y					
							jsr CHROUT					
							iny					
							tya					
							cmp FAC1											
					#WHILE_NEQ		
															
					#print_cr					
					
					
					rts

dump_basic_line			
					#print_str "BASIC line dump:~"	
						
					ldx #0				
										
