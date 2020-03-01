;
;	disk I/O module
;

.ifndef constants
.include "const.asm"
.endif

.ifndef macros
.include "macros.asm"
.endif

;
;	open file
;

stack_open					
						pla
						tay
						pla
						tax
						pla						
						jsr read_disk_status
						
						rts
						
						
stack_close						
						pla
						jsr CLOSE
						jsr CLRCHN
						rts
						

;
;	read the disk status, display on screen
;		IN: stack=filename
stack_read_disk_status						
						jsr stack_open						
												
						lda #0						
						jsr SETNAM						
												
						jsr OPEN						
												
						rts						
												
												
						
												
												
;												
; read error channel (15) from drive and print to the screen.												
;	assumes that channel 15 is not being used.												
;	IN: a=drive number												
;												
read_disk_status			
						tax			
									
						lda #15												
						ldy #15												
						jsr SETLFS												
																		
						;																
						; no name																
						;																
						lda #0												
						jsr SETNAM														
																				
						jsr OPEN														
																																								
						;														
						; open file for reading														
						;														
						ldx #$0f														
						jsr CHKIN														
																				
						jsr print_input_line																										
																				
						lda #15																											
						jsr CLOSE																											
						jsr CLRCHN																											
						rts																											

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
																																													
;																																													
;	syntax open_file 3 8 3 "filename" filename_length																																													
;																																													
open_file				.macro																																													

						lda #\1																																													
						ldx #\2																																													
						ldy #\3																																													
																																																			
						jsr SETLFS																																													
						lda #\5																																													
						ldx <fname
						ldy >fname
						jsr SETNAM
						
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

						#print_str "read_dir:dev="
						#print_a
						#print_char 13
						
						;#print_str "setlfs...~"
						
						lda #8																
						ldy #0																
						jsr SETLFS																
																						
						bcc rb1																
																						
						#print_str "error on SETLFS:"															
						#print_a															
						#print_char 13															
						jmp exit															

rb1
						;#print_str "setnam...~"
						
						lda #1	;dir name len																						
						ldx #<dir_string															
						ldy #>dir_string															
						jsr SETNAM															
																					
						bcc rb2																
																						
						#print_str "error on SETNAM:"															
						#print_a															
						#print_char 13															
						jmp exit															

rb2																												
						;#print_str "open...~"																						
																												
						jsr OPEN															
						bcc rb11															
																					
						#print_str "error on OPEN:"															
						#print_a															
						#print_char 13															
						jmp exit															
																					
																					
rb11																					
						;#print_str "chkin...~"																
																						
						ldx #8															
						jsr CHKIN															
						bcc rb20															
						#print_str "error on chkin:"															
						#print_a															
						#print_char 13															
						jmp exit															
																					
rb20																					
						#print_str "reading file...~"																
																						
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
																					
																					
rb30																					
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

rb40																					
						;#print_str "read st:"																				

						;lda 144
						
						jsr READST																				
																										
						;sta temp_a																				
						;#print_a																				
						;#print_char 13																				
						;lda temp_a																				
																										
						beq rb50																				
						jmp finished																				
																										
						;																									
						; read a char																									
						;																									
rb50																																	 																		
	
						jsr CHRIN																				
																										
																										
						;exchange DOS backslash for 
						;	C64-friendly slash																				
						;cmp #"\"																				
						;bne rb52																																														
						;lda #"/"																									

rb52																										
						sta temp_char																				
																										
						;sta temp_a																				
						;jsr CHROUT																				
						;lda temp_a																				
																										
						;#print_str "is dir entry done?~"																				
						;lda temp_a																				
																																														
						beq rb55																				
																										
						jmp rb60																				
																										
																										
						;																				
						; if char is 0, ????????????????																			
						;	and continue reading																				
						;																				
																										
rb55																										
						;jsr store_in_buffer																										
						#print_char 13																										
						;#print_str "dir entry done!~"																										
																																
																																
						jmp rb30																										
																																																										
						;																																																				
						; if char is a quote, then invert																																																				
						;	quote mode, continue																																																				
																																														
rb60					
						;sta temp_a
						;jsr CHROUT
						;lda temp_a
						
						cmp #"""	; quote	 																			
						bne rb70																																						
																																												
						;#print_str "quote!~"																																						
						;lda temp_a																																						
																																												
						lda quote_mode																
						eor #1	;NOT																
						sta quote_mode																						
																												
						;#print_str "quote_mode is now "																						
						;lda quote_mode																						
						;#print_a																						
						;#print_char 13																						
																												
						jmp rb50																						

						;																																												
						; if quote mode active, then we're																																												
						;	inside a filename. save the																																												
						;	char in the buffer, then loop.																																												
						;																																												
																												
rb70																																		
						;lda temp_a																																		
						;#print_a																																		
						;#print_char 13																																		
																																								
																																														
						lda quote_mode																												
						bne rb80																												
																																		
						jmp rb50																																		
																																								
rb80																																								
						lda temp_char																																	
						;jsr store_in_buffer																																							
						jsr CHROUT																																							
																																													
						jmp rb50																																	

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

																																											
store_in_buffer																
.block
						sta !$0000
						inc store_in_buffer+1
						bne exit
						inc store_in_buffer+2
exit						
						rts
.bend
												
get_buffer												
						lda store_in_buffer+1												
						ldy store_in_buffer+2												
						rts												

set_buffer																
						sta store_in_buffer+1																
						sty store_in_buffer+2																
						rts																
																						
																						