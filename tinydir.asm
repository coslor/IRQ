//
//	Not-so barebones directory reader!
//	(c) 2020 Chris Coslor
//
//	TODO:
//	- ===>>make device # configurable!! <<==
//
//	- DONE fix the final "blocks free" line - it's in 2's complement
//	- get rid of that last number(?) it is anything useful?
//	- DONE make it interruptable. Should be pretty easy.
//	- DONE display the first line in reverse text? let rvs/rvs off 
//		through the filter?
//	- test with very long directories
// 	- DONE test on real hardware!
// 	- figure out where in memory we want this to live
//	- make it completely relocatable(?)
//

.const DEFAULT_DEV=8
.const DEBUG=1
//.const MAX_LINES=23

//#import "const.asm"
//#import "macros.asm"
//#import "includes/handle_brk.asm"

tinydir_start: {
			//jsr activate_brk
//
//	Jump over the print code so that we can run from the 
//		beginning of our memory map.
//
			jmp print_copyright
			
#import "file-macros.asm"

#import "print_macros.asm"
			
print_copyright: 
			.encoding "petscii_mixed"

			print_char(CLR);
			print_reversed_str("tinydir (c)2020 chris coslor");
			//print_cr();
			print_reversed_str("shift-pauses ctrl-slows run/stop-breaks");
			
			//lda #2
			//sta num_lines
			//sta last_row		//set last_row to the NEXT line, since
								//	it's 0-based
			
			
//
//	If we have a last-used device # of at least 8,
//		use that device #. Otherwise, use the default.
//
last_dev:
			lda FA				// last device # used	
			and #8				// is last dev at least 8(i.e. a disk)?
			beq	use_default
			lda FA				// restore the dev # and use it	
			bcc open_file		//always take

use_default:
			lda #DEFAULT_DEV	//last device# was not a drive, so use our default
open_file:

			open_file(8,8,0,"$")
			bne error
			
			ldx #8
			jsr CHKIN
			bcs error
			
			jsr CHRIN
			jsr CHRIN
			
			//clc
			//bcc check_keys
			jmp check_keys

error:
			print_str("error reading directory. code:")																																	
			print_a()
			print_char(CR)
			rts																																			
			
check_keys:
//
//	pause display if SHIFT pressed. 
//		SHIFTLOCK stays indefinitely.
//
			lda SHIFT_KEYS
			and #KEY_SHIFT
			bne check_keys
			
			jsr STOP
			bne read_junk
			
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
print_size:						
			clear_v()						
			print_int_var(file_size)
			//jsr CHROUT
			
			print_spc()

check_status:
			jsr READST
			beq status_ok
			
			cmp #$40			//STatus of 64 = EOF
			bne print_final_status
			jmp done
			
status_ok:			 
			jmp read_filename
			
print_final_status:			
			pha
			print_str("error status:")
			pla
			print_a()
			print_cr()
			print_str("exiting...~")
			
			jmp done

read_filename:			
			jsr CHRIN
			sta temp

			beq end_of_line		// if char=0 then goto end_of_line
			jmp cleanup			
					
end_of_line:				
			//
			// 0 means end of line, so print CR and 
			//	process next line
			//

//check_long_line:
			//lda TBLx			// current cursor physical line # (starts with 0)
			//cmp last_row
			//bne long_line		// if screen row > last known screen row...
			//jmp print_cr
			
//long_line:
			//inc num_lines		//	...then we have a really long line,
			//					//		and we need to add 1 to num_lines

print_cr:			
			print_cr()
			//inc num_lines

			lda TBLx			// current cursor physical line # (starts with 0)											
			//sta last_row 		// update last_row

			//lda num_lines						
									
compare_num_lines:									
			cmp #23				
			bcs screen_full			// if >= num_lines		
			jmp next_line
			
screen_full:								
			//print_cr()		
			//print_str("sf:old num-lines=")		
			//print_byte(num_lines)		
			//print_cr()		
								
			print_reversed_str("press any key to continue")					
			jsr wait_for_key					
			jsr clear_keys					
			
			print_char(CLR)
			//// now, erase the message
			//print_char_bare(UP)					
			//print_centered_str("  ")					
			//print_char_bare(UP)					
								
			//lda #0					
			//sta num_lines				
			//print_str("sf:new num-lines=")		
			//print_byte_var(num_lines)		
			//print_cr()		
								
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
			
			
			//print_str("ll:old num-lines=")		
			//print_byte(num_lines)		
			//print_cr()		
 

inc_row:	
			//inc num_lines
			//print_str("ir:old num-lines=")		
			//print_byte(num_lines)		
			//print_cr()		


loop:			
			jmp read_filename
			
done:
			lda #8																																		
			jsr CLOSE																																		
			jsr CLRCHN																																	
																																				
			//jsr deactivate_brk																																	
																																				
			//jsr wait_for_key																																
			//jsr clear_keys					
																																


			//#print_str "done!"
																																					
			rts																																		
																																					

temp:		.byte 00																																					
file_size:	.byte $a4, $06																																					
dirname:	.text "$" 
			.byte 00
			
//num_lines:	.byte 00
//last_row:	.byte 00
temp_a:		.byte 00

			}
			