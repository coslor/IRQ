//        1         2         3         4         5         6         7
//2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

/*************************
* TODO: write a BASIC loader to load this program at 49152 and execute it
* OR...
* put it at a protected area of BASIC RAM and write a loader to deal with that
**************************/

//.segmentdef Setup [start = $c800]
//.segmentdef Handlers [startAfter = "Setup" max=$ceff]
//.segmentdef Variables [start=$cf00 max=$cfff]

//.segment Setup [start = $0810,outPrg="bin/scolors-init"]
.segment Setup [start = $98ef,min=$98ef,max = $9eff,outPrg="scolors-init"]
//#import "print_macros.asm"


//#import "macros.asm"
#import "print_macros.asm"
#import "matrix-key-codes.asm"

.encoding "petscii_mixed"

/**
*	Set the irq vector to execute our code
*		before running the normal C64 IRQ vector
**/
init:
			print_reversed_str("Color Controller (c)2020 by Chris Coslor")			
						
			lda #$17		// set upper-lower character set
			sta $d018
			//print_char(8)	// ...and disable switching 

			
			jsr check_active
			bcc activate
			jmp deactivate
			
activate:
			
			//print_str("Saving old vector...~")			
			store16var(CVINV,old_irq)	// old_irq=(CVINV)
			//print_str("Old vector saved:")
			//set_v()
			//print_int_var(old_irq)
			//print_cr()

			//print_str("Setting new vector...~")
			
			sei
			store16(main,CVINV)	// CVINV=(main)
			
			//print_str("new vector set:")
			//set_v()
			//print_cr()

			
			store16var(NMINV,old_nmi)		
			//print_str("Old NMI vector saved!~")		
					
			//store16var(nmi_routine,NMINV)			
			lda #<nmi_routine			
			sta NMINV			
			lda #>nmi_routine+1			
			sta NMINV+1			
						
			//print_str("New NMI vector set:")	
			//print_int_ptr(NMINV)	
			//print_cr()	
				
			//print_int(NMINV)
			//print_cr()

			jsr load_setcolors
			print_str("setcolors loaded!~")
			
			print_str("New vectors set!~")
			
			print_str("To deactivate, run again~")
			
			
			cli			
						
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
			store16var(old_nmi,NMINV)
			cli		

			print_str("Deactivated!~")
			print_str("Run again to re-activate~")
			rts		

sc_fname:	.text "setcolors"
.const		sc_fname_len = *-sc_fname

load_setcolors:
			lda #%11000000	//turn on Kernal error and status messages 
			jsr SETMSG
			
			lda #8
			ldx #8
			ldy #1			//use starting address in file
			jsr SETLFS
			
			lda #sc_fname_len
			ldx #<sc_fname
			ldy #>sc_fname
			jsr SETNAM
			
			ldx #0			//X,Y will be ignored
			ldy #0
			jsr LOAD
			rts

/**			
*	Checks to see if IRQ is active. Sets carry accordingly.			
**/			
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

//*=$c000 "Handlers"
.segment Handlers [start=$9f00,max=$9ff0,outPrg="bin/setcolors"]

code_begin:
			
			jmp main


.const wait_start = 20
				
//init:
//			lda wait_start
//			sta wait_count
//			jmp main
			

/**
* Check for commodore-(F1,F3,F5) key pressed,
*	and change background, border, or text color 
*	respectively.
*	OUT:c=1 if color was changed
**/
check_key:
{
			//sec
			
			lda SHIFT_KEYS
			and #KEY_COMM
			beq no_key
			
			lda SFDX	
				
check_f1:				
			cmp #MATRIX_F1	
			bne check_f3

			inc BACKG_COLOR
			rts
			
check_f3:
			cmp #MATRIX_F3
			bne check_f5
			
			inc BORDER_COLOR
			
			rts
			
check_f5:			
			cmp #MATRIX_F5			
			bne no_key			
						
			inc COLOR			
						
			rts			
						
no_key:		
			//	combo not pressed, so reset key countdown 
			lda #1
			sta wait_count
									
			rts						
}									


/**				
*	Main routine, which runs every IRQ period (60 times/sec				
*		for NTSC machines). 				
*					
**/				
				
main:
{			
			lda wait_count				
			bne call_old
			dec wait_count	//count down until we can execute key check again
			
			lda #wait_start	//countdown is complete! reset the counter...
			sta wait_count
			
			jsr check_key	//...and check for our key presses
						
call_old:						
//			jmp $EA31
			jmp (old_irq)		// default $EA31	
}



/** MOS 6510 System Reset routine
* Reset vector (Kernal address $FFFC) points here.
* 
* If cartridge is detected then cartridge cold start 
*	routine is activated.
* If no cartridge is detected then I/O and memory 
*	are initialised, our IRQ vector is set, 
*	and the BASIC cold start routine is activated.
**/
reset_routine:{

			ldx #$FF        // 
			sei             // set interrupt disable
			txs             // transfer .X to stack
			cld             // clear direction flag
			//jsr $FD02       // check for cart
			//bne $FCEF       // .Z=0? then no cart detected
			//jmp ($8000)     // direct to cartridge cold start via vector
			stx $D016       // sets bit 5 (MCM) off, bit 3 (38 cols) off
			jsr $FDA3       // initialise I/O
			jsr $FD50       // initialise memory
			jsr $FD15       // set I/O vectors ($0314..$0333) to kernal defaults
			jsr $FF5B       // more initialising... mostly set system IRQ to correct value and start
			cli             // clear interrupt flag

			jsr code_begin	//re-set our IRQ routine
			
			jmp ($A000)     // direct to BASIC cold start via vector
}


// A replacement for the default NMI handler code

nmi_routine:{
			pha
			txa
			pha
			tya
			pha
			lda #$7f
			sta $dd0d			//CIA #2 Interrupt Control Register
			ldy $dd0d			//Did any CIA #2 source cause an interrupt?
			bpl no_rs232
			jmp $fe71			//NMI RS-232 Handler
no_rs232:			
//			jsr $fd02			//Check for an Autostart Cartridge
//			bne no_cart
//run_cart:
//			jmp ($8002)			//Cartridge start vector
//			
no_cart:
			//jsr $f6bc			//Update Stop key indicator, 
								//	at memory address $0091.								
			//jsr $ffe1			//Test STOP Key
			//bpl no_stop
			//jmp $fe71			//NMI RS-232 Handler
no_stop:
//			jsr $fd15			//Restore RAM Vectors
			jsr $fda3			//Initialize CIA I/O Devices
			jsr $e518			//Initialize Screen and Keyboard
			
			print_reversed_str("Color Controller (c)2020 by Chris Coslor")			
			
			jmp ($a002)			//BASIC warm start vector
			
}

.segment Variables [start=$9ff0,max=$9fff]

old_irq:		.word $FFFF
old_nmi:		.word $FFFF

wait_count:		.byte 00

				
//color_key_table:			
//				.byte MATRIX_1,MATRIX_2,MATRIX_3,MATRIX_4,MATRIX_5,MATRIX_6,MATRIX_7		
code_end:
