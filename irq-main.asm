//        1         2         3         4         5         6         7
//2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

* = $0801

BasicUpstart(init)
    
*=$810

//
//	Fiddling around with IRQ vectors
//

//#import "math.asm"
//#import "handle_brk.asm"
#import "print_macros.asm"
#import "tinydir.asm"
//DEBUG_MACROS	.var 0
.const DEBUG=1

//
// for indirect mode, our pointers need to be in ZP
//
.const screen_ptr =$f7		//	.byte <SCREEN_RAM, >SCREEN_RAM
.const color_ptr =$f9		//	.byte <COLOR_RAM, >COLOR_RAM
.const sbuf_ptr =$fb		//	.byte <screen_buffer, >screen_buffer
.const cbuf_ptr =$b0		//	.byte <color_buffer, >color_buffer

.const counter =$b2			//		.byte 00,00


code_begin:
			jmp init

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
			
			print_str("saving old vector...~")			
			store16var(CVINV,old_irq)	// old_irq=(CVINV)
			print_str("old vector saved:")
			set_v()
			print_int_var(old_irq)
			print_cr()

			print_str("setting new vector...~")
			
			sei
			store16(main,CVINV)	// CVINV=(main)
			cli
			
			//print_str("new vector set:")
			set_v()
			//print_int_var(CVINV)
			print_cr()
			
			//jsr activate_brk
			
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
			
//			lda #1
//			ldx #2
//			ldy #$FF
//			
//			sec
			
//break:		.byte $00			
			
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

			print_str("Setting IRQ to old value:")
			set_v()
			print_int_var(old_irq)
			print_cr()
			
			
			sei
			
			store16var(old_irq,CVINV)

					
			cli		

			//print_str("CVINV is now ")
			//set_v()
			//print_int_var(CVINV)
			//print_cr() 		
			

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
//	Main routine, which runs every IRQ period (60 times/sec				
//		for NTSC machines). 				
//					
//	At the moment, just sets the border color to black				
//		to remind the user that it's active, and				
//		clears the screen when the user hits commodore-c				
//				
				
main:
{			
			lda #0
			sta $d020		// set border color to black when 
							// 	custom IRQ is active		
			
			jsr check_key			
			lda key_index			
			bcc exit2			
						
			//jsr CLR_SCREEN
			//jsr tinydir_start
			
			//jsr save_stack
			//store16var(main_ret_addr,tinydir_start)
			//jsr restore_stack
			
			tsx
			pla 	//Y
			sta main_temp_y
			pla		//X
			sta main_temp_x
			pla		//A
			sta main_temp_a
			pla		//status
			sta main_temp_status
			
			pla		//return_hi
			sta main_ret_addr+1
			pla 	//return_lo
			sta main_ret_addr
			
			// Push rebuild_stack as return addr for tinydir
			lda #>rebuild_stack
			pha
			lda #<rebuild_stack
			pha 
			
			// Now add tinydir's addr to the stack, to be
			//	returned to by IRQ's RTI
			lda #>tinydir_start
			pha
			lda #<tinydir_start
			pha
			
			// Then put the registers bsck on
			lda main_temp_status
			pha
			lda main_temp_a
			pha
			lda main_temp_x
			pha
			lda main_temp_y
			pha
			
						
//			lda #>tinydir_start
//			sta STACK+6,x
//			lda #<tinydir_start
//			sta STACK+5,x

			/*
			*	Stack now looks like:
			*		Y
			*		X
			*		A
			*		status
			*		tinydir hi
			*		tinydir lo
			*		old return addr lo
			*		old return addr hi
			*/
			
			
exit_main:			
			nop			
			//rti
			
//			put_word_in_stack(tinydir_start, 5)
//			lda #<tinydir_start
//			pha
//			lda #>tinydir_start
//			pha
		
		
exit2:
 //continue IRQ servicing logic
			//lda old_irq
			//sta MISC_PTR0
			//lda old_irq+1
			//sta MISC_PTR0+1
//			jmp $EA31
			jmp (old_irq)		// default $EA31	
}

rebuild_stack: {

			ldy main_temp_y
			lda main_temp_a
			ldx main_temp_status
			txs
			ldx main_temp_x
			
			jmp (main_ret_addr)
}
//
//	Non-destructively read top bytes of stack and save to temp storage
//
save_stack: {
			tsx
			store_next_stack_byte(main_temp_y)
			store_next_stack_byte(main_temp_x)
			store_next_stack_byte(main_temp_a)
			store_next_stack_byte(main_temp_status)
			store_next_stack_word(main_ret_addr)

			rts
}

restore_stack: {
			
			restore_next_stack_byte(main_temp_y)
			restore_next_stack_byte(main_temp_x)
			restore_next_stack_byte(main_temp_a)
			restore_next_stack_byte(main_temp_status)
			restore_next_stack_word(main_ret_addr)
			
			rts
}

//count			.byte $ff
jump_index:	.word $0000						

old_irq:		.word $0000

//
// Temp storage for stack 
//
main_temp_y:			.byte 	00
main_temp_x:			.byte 	00
main_temp_a:			.byte 	00
main_temp_status:		.byte 	00
main_ret_addr:			.word 	0000
			
//screen_buffer:
//*=*+1000
//color_buffer:
//*=*+1000

			nop
			
code_end:
.const code_length =code_end-code_begin