;
;	disk I/O module
;

.ifndef constants
.include "const.asm"
.endif

.ifndef macros
.include "macros.asm"
.endif

.ifndef PACKAGE
* = $cf70
						ldx #8
						jmp read_dir
						rts

.endif
;
; used for kernal calls which indicate errors
;	by setting the carry bit, with the error #
;	in a. e.g. SETLFS,SETNAM,OPEN
;
;	first param is the name of the kernal call
;	second one is the label to jump to if the error
;	does *not* occur
;
;	ex: 
;		lda #0		; no filename
;		#call_kernal SETNAM, smooth_saling, fail
;
call_kernal				.macro																						
;.block																																							
;						#print_str "call-kernal "																																					
;						#print_str str_ptr																																					
;						#print_char ","																																					
;						#print_str ptr2																																					
;						#print_char ","																																					
;						#print_str ptr3																																					
;						#print_str "~"																																					
;																																											
;						gibberish																																					
;						#print_str "gibberish~"																																					
																																											
						#print_str "call-kernal~"																
																						
						#print_str "1="																
						;#print_int \1																
						#print_str "~"																
																																					
						nop																																											
						nop																																											
						nop																																											
						nop																																											
																																																	
																																																	
						jsr SETLFS ;\1																
																						
						bcs print_err 																						
						jmp \2																																												

print_err																												
;						#print_str "error calling "															
;						#print_str 	str_ptr														
;						#print_char ":"														
;						#print_a															
;						#print_char CR															
						jmp \3															
																					
str_ptr					.null "@1"																						

ptr2					.null "@2"
ptr3					.null "@3"
;.bend																						
						.endm																	

																																																							
;												
; read error channel (15) from drive and print to the screen.												
;	assumes that channel 15 is not being used.												
;	IN: param 1=drive number												
;												
read_disk_status		.macro	
.block			
									
set_lfs					#open_file 15,\1,15,"",0				
						;														
						; open file for reading														
						;														
open_channel
						ldx #$0f														
						;#call_kernal CHKIN, read_input,exit														
						jsr CHKIN														
																				
read_input																				
						jsr print_input_line																										
																				
						lda #15																											
						jsr CLOSE																											
						jsr CLRCHN																											
exit																																	
						rts																											
.bend																										
																										

print_input_line																																	

.block																														
loop																				
						jsr CHRIN																																						
						cmp #$0d	; return?																					
						beq exit																					
						jsr CHROUT																					
						bne loop																					
																											
exit					
.bend

						rts																																							
						.endm																																							
																																													
;																																													
;	syntax open_file 3 8 3 "filename" filename_length																																													
;																																													
open_file				.macro																																													

						lda #\1																																																																																										
						ldx #\2																																													
						ldy #\3																																													
																																																			
						#print_str "***call SETLFS...***~"																																													
						;#call_kernal SETLFS,do_setnam,exit 																																													
						jsr SETLFS																																													
																																																			
do_setnam																																																			
						lda #\5																																													
						ldx <fname
						ldy >fname
						#print_str "***call SETNAM...***~"																																													
						;#call_kernal SETNAM, do_open, exit
						jsr SETNAM

do_open						
						lda #\1						
						#print_str "***call OPEN...***~"																																																									
						;#call_kernal OPEN,exit,exit						
						jsr OPEN						
						bcs error						

						bcc exit	; skip over the string						
												
error					
						pha												
												
						clc												
						#print_str "error opening file:"												
						pla												
						#print_a												
						sec												
						#print_str ""												
						bcc exit	;skip over the string												
																		 																																													
																																																			
fname					.null "@4"																																																			
exit																																																																																																						
																																																																																																						
																																																																																																						
																																																									
.endm																																																			
																																																		
																																	
close_file				.macro																			
						lda #\1																			
						jsr CLOSE																			
.endm																			

;																			
; reads the dir in the supplied drive, and																			
;	stores it into a supplied buffer as a set																			
;	of zt strings. the caller needs to keep																			
;	track of the original start of the buffer.																			
;
;	on exit, the buffer pointers provided will																			
;	contain (address of end of the last string)+1 
; 
;	IN:x=drive number (e.g. 8) 
; 																				
read_dir																										
.block
						.ifdef DEBUG																
						#print_str "seventeen looks like "																
						lda #17																
						#print_a																
						#print_char 32																
						#print_int 17																
						#print_char CR																
						.endif																
																						
																						
						;#print_str "read_dir:dev="
						;pha
						;txa
						
						;lda #\1
						;#print_a
						;#print_char CR
						
						;pla

						;lda #\1
						;bne rb10
						
						;#print_str "ERROR:\1=0 in read_dir!~"
						;jmp exit
						
;rb10						
						;#open_file 8,\1,0,"$",1
						
												
						;#print_str "calling SETLFS...~"						
						lda #8																
						ldy #0																
						jsr SETLFS																
						;#call_kernal SETLFS,rb1,exit																
																						
rb1
						;#print_str "calling SETNAM now...~"						
						lda #1	;dir name len																						
						ldx #<dir_string															
						ldy #>dir_string															
						jsr SETNAM															
						;#call_kernal SETNAM,rb2,exit															
																					

rb2																												
						;#print_str "calling OPEN... now~"						
						;#call_kernal OPEN,rb11,exit															
						jsr OPEN															
																					
rb11																					
						;#print_str "calling CHKIN...~"						

						ldx #8															
						jsr CHKIN															
						;#call_kernal CHKIN,rb20,exit															
																					
rb20																					
						;#print_str "reading file...~"																
																						
						lda #0																
						sta quote_mode																
																						
						;															
						; burn some bytes at the start of															
						;	the dir															
						;															
						jsr CHRIN															
						;jsr CHROUT																				

rb25																					
						jsr CHRIN															
						;jsr CHROUT																				
																					
																					
process_entry																					
						;lda #"."
						;jsr CHROUT
						
						;
						; burn some more at the start
						;	of each entry
						;
						;lda #"("
						;jsr CHROUT
						
						jsr CHRIN															
						;jsr CHROUT																				
						jsr CHRIN															
						;jsr CHROUT																				
						jsr CHRIN															
						;jsr CHROUT																				
						jsr CHRIN															
						;jsr CHROUT																				
																										
						;lda #")"																				
						;jsr CHROUT																				
																										
						
						;
						; read STatus, exit if >0
						;

check_status																					
						;#print_str "read st:"																				

						;lda 144
						
						jsr READST																				
																										
						;sta temp_a																				
						;#print_a																				
						;#print_char CR																				
						;lda temp_a																				
																										
						beq read_char																				
						jmp finished																				
																										
						;																									
						; read a char																									
						;																									
read_char																																	 																		
	
						jsr CHRIN																				
																										
																										
						;exchange DOS backslash for 
						;	C64-friendly slash																				
						cmp #"\"																				
						bne process_char																																														
						lda #"/"																									

process_char																										
						sta temp_char																				
																										
						;sta temp_a																				
						;jsr CHROUT																				
						;lda temp_a																				
																										
						;#print_str "is dir entry done?~"																				
						lda temp_char																				
																																														
						beq next_entry																				
																										
						jmp check_quote																				
																										
																										
						;																				
						; if char is 0, ????????????????																			
						;	and continue reading																				
						;																				
																										
next_entry																										
						;jsr store_in_buffer																										
						#print_char CR																										
						;#print_str "dir entry done!~"																										
																																
																																
						jmp process_entry																										
																																																										
						;																																																				
						; if char is a quote, then invert																																																				
						;	quote mode, continue																																																				
																																														
check_quote					
						;sta temp_a
						;jsr CHROUT
						;lda temp_a
						
						cmp #DBL_QUOTE	 																			
						bne check_quote_mode																																						
																																												
						;#print_str "quote!~"																																						
						;lda temp_a																																						
																																												
						lda quote_mode																
						eor #1	;NOT																
						sta quote_mode																						
																												
						;#print_str "quote_mode is now "																						
						;lda quote_mode																						
						;#print_a																						
						;#print_char CR																						
																												
						jmp read_char																						

						;																																												
						; if quote mode active, then we're																																												
						;	inside a filename. save the																																												
						;	char in the buffer, then loop.																																												
						;																																												
																												
check_quote_mode																																		
						;lda temp_a																																		
						;#print_a																																		
						;#print_char CR																																		
																																								
																																														
						lda quote_mode																												
						bne print_entry																												
																																		
						jmp read_char																																		
																																								
print_entry																																								
						lda temp_char																																	
						;jsr store_in_buffer																																							
						jsr CHROUT																																							
																																													
						jmp read_char																																	

						;																																							
						; all done. close our files																																							
						;	and return.																																							
finished																																							
						;lda #0																																							
						;jsr store_in_buffer																																							
																																												
exit																																												
						lda #8																																		
						jsr CLOSE																																		
						jsr CLRCHN																																		
						rts																																		

quote_mode				.byte 00
;
;	temp storage for the char read from the disk
;
temp_char				.byte 00

dir_string				.null "$"																						
.bend
						;.endm																																				
																																										
