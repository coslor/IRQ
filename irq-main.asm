//        1         2         3         4         5         6         7
//2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

//
//	Fiddling around with IRQ vectors
//

#import"math.asm"
#import"handle_brk.asm"
#import"print_macros.asm"
//DEBUG_MACROS	.var 0


* = $0801

//
// for indirect mode, our pointers need to be in ZP
//
.const screen_ptr =$f7		//	.byte <SCREEN_RAM, >SCREEN_RAM
.const color_ptr =$f9		//	.byte <COLOR_RAM, >COLOR_RAM
.const sbuf_ptr =$fb		//	.byte <screen_buffer, >screen_buffer
.const cbuf_ptr =$b0		//	.byte <color_buffer, >color_buffer

.const counter =$b2			//		.byte 00,00

BasicUpstart(init)
    
*=$810

code_begin:
			jmp init

//
// copy 2 regions (e.g. screencode,color data) from
//	locations pointed at by \1 to \2, and from \3 to \4.
//	\5 is the total number of 256-byte pages to copy. 
//


//			
//	Checks to see if IRQ is active. Sets carry accordingly.			
//			
check_active:
{			//cmp16const(CVINV,main)	
			lda CVINV+1
			cmp #>main
			bne not_active
			lda CVINV
			cmp #<main
			bne not_active
			
			sec
			jmp exit_check
			
not_active:
			clc			
						
exit_check:
			rts						
}						

//
//	set the irq vector to execute our code
//		before running the normal C64 IRQ vector
//
init:

			print_str("irq-main.init()~")
			
			lda #$17		// set upper-lower character set
			sta $d018
			print_char(8)	// ...and disable switching 
			
			jsr check_active
			bcc activate
			jmp deactivate
			
activate:
			sei
			
			print_str("setting new vector...~")
			
			//store16var(CVINV,old_irq)	// old_irq=(CVINV)
			//store16(main,CVINV)	// CVINV=(main)
			
			jsr activate_brk
			
			lda $d020
			sta old_bgcolor
			
			lda #$0
			sta $d020
			
			//cli

			print_str("new vector set!~")
			
//lockup:		jmp lockup			
			
			//jsr store_screens
			
			print_str("To deactivate, run again")
			print_char(CR)
			//print_int(code_length)
			//print_str(" bytes total~")
			
			lda #1
			ldx #2
			ldy #$FF
			
			sec
			
break:		.byte $00			
			
			rts



//
//	restore the IRQ vector to the system default, assuming 
//		that's it's been previously set. Otherwise, complain.
//
deactivate:
		
			jsr check_active		
			bcs deactivate2	
				
			jmp activate	
		

deactivate2:
			sei
			
			store16var(CVINV,old_irq)
					
			cli		

			lda old_bgcolor
			sta $d020
			
			//jsr restore_screens
			
			print_str("Deactivated!~")
			print_str("Run again to re-activate~")
			rts		

old_bgcolor:	.byte $0					

//
// check for 'commodore-c' key pressed,
//	OUT:c=1 if pressed, 0 if not
//
check_key:
{
			lda #0
			sta key_index	// clear index value
			
			lda SHIFT_KEYS
			and #(KEY_COMM)
			beq ck1
			
			lda $cb			
			cmp #$14		//'c'			
						
			bne ck1			
				
			lda #1
			sta key_index
			rts
			
ck1:			cmp #$88		//'v'
			bne ck2
			
			lda #2
			sta key_index
			rts

ck2:
			rts
}
key_index:	.byte $00


//				
//	main routine, which runs every IRQ period (60 times/sec				
//		for NTSC machines). 				
//					
//	at the moment, just sets the border color to black				
//		to remind the user that it's active, and				
//		clears the screen when the user hits commodore-c				
//				
				
main:
{			
			lda #0
			sta $d020	// set border color to black when 
						 	//custom IRQ is active		
			
			jsr check_key			
			lda key_index			
						
			bcc exit2			
						
						
			jsr CLR_SCREEN
		
		
exit2:
//continue IRQ servicing logic
			lda old_irq
			sta MISC_PTR0
			lda old_irq+1
			sta MISC_PTR0+1
			//jmp $EA31
			jmp (old_irq)		// default $EA31	
}


//count			.byte $ff
jump_index:	.word $0000						

old_irq:		.word $0000


//screen_buffer:
//*=*+1000
//color_buffer:
//*=*+1000

			nop
			
code_end:
.const code_length =code_end-code_begin