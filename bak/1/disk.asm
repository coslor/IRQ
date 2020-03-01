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

						txa
						pha
						#print_str "read_dir:x="
						pla
						#print_a
						#print_char 13
						
						#print_str "dir string="																
						;lda #<dir_string																
						;ldy #>dir_string																
						;jsr STROUT																
						#print_char 13																
																						
																						
						lda #8																
						ldy #0																
						jsr SETLFS																
																						
						lda #8																
						ldx #<dir_string															
						ldy #>dir_string															
						jsr OPEN															
						bcc rb11															
																					
						sta temp_a															
						#print_str "error on open:"															
						lda temp_a															
						#print_a															
						#print_char 13															
						jmp exit															
																					
																					
rb11																					
						ldx #8															
						jsr CHKIN															
						bcc rb20															
						#print_str "error on chkin:"															
						lda temp_a															
						#print_a															
						#print_char 13															
						jmp exit															
																					
rb20																					
						;															
						; burn some bytes at the start of															
						;	the dir															
						;															
						jsr CHRIN															
						jsr CHRIN															
																					
rb30																					
						;lda #"."
						;jsr CHROUT
						
						;
						; burn some more at the start
						;	of each line
						;
						jsr CHRIN															
						jsr CHRIN															
						jsr CHRIN															
						jsr CHRIN															
						
						;
						; read STatus, exit if >0
						;

rb40																					
						#print_str "read st:"																				

						lda 144
						
						;jsr READST																				
																										
						sta temp_a																				
						#print_a																				
						#print_char 13																				
						lda temp_a																				
																										
						beq rb50																				
						jmp finished																				
																										
						;																									
						; read a char																									
						;																									
rb50																																	 																		
	
						jsr CHRIN																				
						sta temp_a																				
																										
						jsr CHROUT																				
						lda temp_a																				
																																														
						bne rb60																				
																										
						;																				
						; if char is 0, store in buffer																				
						;	and continue reading																				
						;																				
																										
rb55																										
						jsr store_in_buffer																										
						jmp rb30																										
																																																										
						;																																																				
						; if char is a quote, then invert																																																				
						;	quote mode, continue																																																				
																										
rb60					cmp 34	; quote	 																			
						bne rb70																																						
																																												
						lda quote_mode																
						eor #1	;NOT																
						sta quote_mode																						
						jmp rb50																						

						;																																												
						; if quote mode active, then we're																																												
						;	inside a filename. save the																																												
						;	char in the buffer, then loop.																																												
						;																																												
																												
rb70																																		
						lda quote_mode																												
rb4																																		
						beq rb80																												
																																		
						jmp rb50																																		
																																								
rb80																																								
						lda temp_a																																	
						jsr store_in_buffer																																							
																																													
						jmp rb30																																	

						;																																							
						; all done. close our files																																							
						;	and return.																																							
finished																																							
						lda #0																																							
						jsr store_in_buffer																																							
																																												
exit																																												
						lda #8																																		
						jsr CLOSE																																		
						jsr CLRCHN																																		
						rts																																		

quote_mode				.byte 00
temp_a					.byte 00
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
																						
																						