.ifndef MACROS
.include "macros.asm"
.endif

* = $0801


; BASIC header
; 10 SYS (2064)
    .byte   $0E, $08, $0A, $00, $9E, $20, $28
    .text 	"2064"
    .byte 	$29, $00, $00, $00


PACKAGE=1

start
						#print_char $93	;CLR
						#print_str "disk library routines test~"
						;jsr test_create_file

						nop
						nop
						nop
						nop

						jsr test_read_dir
						jsr test_disk_status
						
						rts
						

.include "disk.asm"
						
test_disk_status
.block
						
						#print_str "disk status:"
						
						
						;ldx #8
						#read_disk_status 8
						#print_char CR
						
						l
						
						#print_str "finished!~"
						
						
						rts
.bend						
						
						
test_create_file						
.block						
						#print_str "========~"						
												
						#print_str "create file test~"				

						#print_str "opening file test-file...~"				
										
						#open_file 3,8,3,"test-file,s,w",13												
						bcc cmd_file												
						jmp error												
																		
cmd_file																		
						#print_str "setting file as output...~"											
																	
						ldx 3									
						jsr CHKOUT												
						bcc write_file												
						jmp error												
																		
write_file																		
						#print_str "This is a new file~"												
						#print_str "Did this work?~"												
						#print_char CR												
																		
						#close_file 8
						jsr CLRCHN
						
						sec
						#print_str "file test complete!~"

						clc						
						#print_str "Disk status:"
						
						lda #8
						jsr read_disk_status
						#print_char CR
						
						
						rts
						 																	
																								
error																								
						pha																			
						#print_str "***error running file operation***~"																								
						clc																								
						#print_str "error code:"																								
						pla																								
						#print_a																						
						#print_char CR																						
																												
						rts																						
																												
.bend																											


test_read_dir
.block
						nop
						nop
						nop
						nop
						

						#print_str "test-read-dir~"
						
						jsr READST	;throwaway, to clear old results
						
						
;						#print_str "dir_ptr starts at "
;						jsr get_buffer
;						sta dir_ptr
;						sty dir_ptr+1
;						
;						#print_int dir_ptr
;						#print_char 13
												
												
						ldx #8
						jsr read_dir
						


						;clc						 
						;#print_str "dir_ptr is now "
						;jsr get_buffer
						;sta dir_ptr
						;sty dir_ptr+1
						
						;#print_ptr dir_ptr
						;#print_char 13

						
;						clc
;						#print_str "1st dir entry:"
;						lda #<(dir_buf)
;						ldy #>(dir_buf)
;						jsr STROUT
;						
;						#print_str dir_buf 
						
						rts

dir_ptr					.byte 00,00						
						
 						
dir_buf	= * + 1000
						
						
						
.bend
