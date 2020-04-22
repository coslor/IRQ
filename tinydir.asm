/**
*	Not-so barebones directory reader!
*		(c) 2020 Chris Coslor
*		IN: set address (start_address + 3) to the value we want for
*			device #; otherwise, the last-used device # will be used,
*			or if none, 8 will be used
*		OUT: A will hold the error code. Any value but 0 means an error.
*				Most error codes are STatus errors, while
*				codes >200 are Kernal errors (actual error code=
*				returned code - 200). 
*
*		For STatus codes, see: https://www.c64-wiki.com/wiki/STATUS
*		For Kernal codes, see: http://www.devili.iki.fi/Computers/
			Commodore/C64/Programmers_Reference/Chapter_5/page_306.html#Error
*
*	TODO:
*	- DONE ===>>make device # configurable!! <<==
*
*	- DONE fix the final "blocks free" line - it's in 2's complement
*	- DONE get rid of that last number(?) it is anything useful?
*	- DONE make it interruptable. Should be pretty easy.
*	- DONE display the first line in reverse text? let rvs/rvs off 
*		through the filter?
*	- DONE test with very long directories
* 	- DONE test on real hardware!
* 	- figure out where in memory we want this to live
*	- make it completely relocatable(?)
*	- "tiny"dir is not so tiny these days, mostly due to print_macros. 
*		The printing needs of this program really aren't very complex, 
*		so refactor and remove references to it. That should bring the 
*		program size down, and give us more options to put tinydir 
*		in more places 
*	- add an option to add a "dir" command to BASIC, probably via  
*		the IERROR vector  
*	- add a way to change the default dir command, adding wildcard   
*		searches (e.g. "$tiny*" or "$0:*=s")   
*	- write a version that stored the dir as a list of structs in 
*		RAM, and returns a pointer (in X/Y?) to that list     
*	- write a client for the above version, that pages through     
*		the the list of file structs, and lets the user perform     
*		some basic functions on a selected file (del, copy, read, etc)     
**/
.const DEFAULT_DEV=8

tinydir_start: {
/**
*	Jump over the print code so that we can run from the 
*		beginning of our memory map.
**/
			jmp print_copyright

/**
*	Set this byte to a non-0 value to override the device #
*/
override_dev: .byte 00						
									
#import "file-macros.asm"

#import "print_macros.asm"
			
print_copyright: 
			.encoding "petscii_mixed"

			print_char(CLR);
			print_reversed_str("tinydir (c)2020 chris coslor");
			print_reversed_str("shift-pauses ctrl-slows run/stop-breaks");
			

check_override:
			lda override_dev
			bne open_dir_file

/**
*	If we have a last-used device # of at least 8,
*		use that device #. Otherwise, use the default.
**/
last_dev:
			lda FA				// last device # used	
			and #8				// is last dev at least 8(i.e. a disk)?
			beq	use_default
			lda FA				// restore the dev # and use it	
			bcc open_dir_file		//always take

use_default:
			lda #DEFAULT_DEV	//last device# was not a drive, so use our default
			
open_dir_file:

			tax
			lda#18
			ldy#0
			open_file_barebones(dirname,dirname_end - dirname)
			bne error
			

			ldx #18
			jsr CHKIN
			bcs error
			
			jsr CHRIN
			jsr CHRIN
			
			jmp check_keys

error:
			//print_str("error reading directory. code:")																																	
			//print_a()
			//print_char(CR)
			//rts																																			
			clc																																			
			adc #200			// error codes >200 are Kernal, not STatus, errors																																			
			sta return_value																																			
			jmp done																																			
			
check_keys:
/**
*	pause display if SHIFT pressed. 
*		SHIFTLOCK stays indefinitely.
**/
			lda SHIFT_KEYS
			and #KEY_SHIFT
			bne check_keys
			
			jsr STOP
			bne read_junk
			
			lda #0
			sta return_value
			
			jmp done

new_line:

read_junk:
			//			
			// first 2 bytes are useless to us			
			//			
			jsr CHRIN			
			jsr CHRIN			

read_size:						
			//			
			//	next 2 are the size of the file, in blocks
			// 			
			jsr CHRIN			
			sta file_size			
			jsr CHRIN			
			sta file_size+1			
						
check_status:
			jsr READST
			beq status_ok
			
			cmp #$40			//STatus of 64 = EOF
			bne print_final_status
			lda #0
			sta return_value
			
			jmp done
			
status_ok:			 
			jmp print_size
			
print_final_status:			
//			sta temp_a
//			print_str("error status:")
//			lda temp_a
//			print_a()
//			print_cr()
//			print_str("exiting...~")
			
//			lda temp_a
			sta return_value
			
			jmp done
						
print_size:						
			clear_v()						
			print_unsigned_int_var(file_size)
			
			print_spc()

read_filename:			
			jsr CHRIN
			sta temp

			beq end_of_line		// if char=0 then goto end_of_line
			jmp cleanup			
					
end_of_line:				
			//
			// 0 means end of line, so print CR, 
			//	determine whether to pause the screen,and 
			//	process next line
			//
print_cr:			
			print_cr()

			lda TBLx			// current cursor physical line # (starts with 0)											
									
compare_num_lines:									
			cmp #23				
			bcs screen_full			// if >= num_lines		
			jmp next_line
			
screen_full:								
			print_reversed_str("press any key to continue")					
			jsr wait_for_key					
			jsr clear_keys					
			
			print_char(CLR)
								
next_line:						
			jmp check_keys			
						
			//			
			// clean up character before we print it
			// 			
cleanup:
			and #%11100000		//char <32?
			bne !+
			jmp read_filename	// If so, ignore it
			
!:			
			lda temp
			and #%01111111		//char >127?
			bne !+
			jmp read_filename	// If so, ignore it

!:
			//for sd2iec: exchange DOS backslash for 
			//	C64-friendly slash																				
			cmp #'\'																				
			bne now_print																																														
			lda #'/'																									
																												
now_print:
			jsr CHROUT
			
loop:			
			jmp read_filename
			
done:
			lda #18																																		
			jsr CLOSE																																		
			jsr CLRCHN																																	
																																			
			lda return_value																																
			rts																																		
																																					

temp:		.byte 00																																					
file_size:	.byte $a4, $06																																					
dirname:	.text "$dir*"  
dirname_end:
			
//num_lines:	.byte 00
//last_row:	.byte 00
temp_a:		.byte 00
return_value: .byte 0
			}
			