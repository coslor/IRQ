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

*=$c000

.const DEFAULT_DEV=8

#import "const.asm"
#import "macros.asm"

tinydir: {
//
//	Jump over the print code so that we can run from the 
//		beginning of our memory map.
//
			jmp print_copyright
			
#import "print_macros.asm"
			
print_copyright: 
			.encoding "petscii_mixed"
			print_char(RVS_ON)
			print_str("      tinydir (c)2020 chris coslor      ")
			print_str("shift-pauses ctrl-slows run/stop-breaks ")
			print_char(RVS_OFF)

//
//	If we have a last-used device # of at least 8,
//		use that device #. Otherwise, use the default.
//
last_dev:
			lda FA		
					// last device # used	

			#if DEBUG 				
				pha					
				print_a	
				print_char(CR)					
				pla	
				pha	
			#endif
				
			and #8
			
			#if DEBUG 
				print_a
				print_char(CR)
			#endif
			
			// is last dev at least 8(i.e. a disk)?
			beq	use_default

			#if DEBUG 		
				pla
				
				print_str("using last dev #")
				print_a()
				print_char(CR)
			#endif
			
			// restore the dev # and use it
			lda FA	
			bcc print_dir	//always take

use_default:
			lda #DEFAULT_DEV
			
			#if DEBUG 
				pha
				print_str("using default drive #")
				print_a()
				print_char(CR)
				pla
			#endif


print_dir:
			tax
			lda #8
			ldy #0
			jsr SETLFS
			bcs error
			
			lda #1
			ldx #<dirname
			ldy #>dirname
			jsr SETNAM
			bcs error
			
			jsr OPEN
			bcs error
			
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
			
//
// TODO: will this code work inside an interrupt? 
			
			//doesn't seem to work at all
			// 
			//lda $91
			//cmp #$7f
			//bne read_junk
			
			jsr STOP
			bne read_junk
			
			jmp done

read_junk:
			//			
			// first 2 bytes are useless to us			
			//			
			jsr CHRIN			
			jsr CHRIN			
						
			//			
			//	next 2 are the size of the file, in blocks
			// 			
			jsr CHRIN			
			sta file_size			
			jsr CHRIN			
			sta file_size+1			
			print_int_var(file_size)
			//jsr CHROUT
			
			lda #32
			jsr CHROUT

check_status:
			jsr READST
			bne done
			
read:
			jsr CHRIN
			
			sta temp

			bne cleanup			
						
			//
			// 0 means end of line, so print CR and 
			//	process next line
			//
			lda #13			
			jsr CHROUT			
						
						
			jmp check_keys			
						
			//			
			// clean up character before we print it
			// 			
						
cleanup:
			and #%11100000		//char <32?
			beq read			// If so, ignore it
			
			lda temp
			and #%01111111		//char >127?
			beq read			// If so, ignore it

			//for sd2iec: exchange DOS backslash for 
			//	C64-friendly slash																				
			cmp #'\'																				
			bne now_print																																														
			lda #'/'																									
																												
now_print:
			jsr CHROUT
			
			clc
			bcc read
			
done:
			lda #8																																		
			jsr CLOSE																																		
			jsr CLRCHN																																		

			//#print_str "done!"
																																					
			rts																																		
																																					

temp:		.byte 00																																					
file_size:	.byte $a4, $06																																					
dirname:	.text "$" 
			.byte 00
			
			}