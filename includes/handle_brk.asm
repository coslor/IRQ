#importonce

#import "const.asm"
#import "macros.asm"
#import "print_macros.asm"


.const HANDLE_BRK =1

activate_brk:
{
			store16var(CBINV,old_brk)
			store16(handle_brk,CBINV)
			rts
}

deactivate_brk:
{
			store16var(old_brk, CBINV)
			rts
}

handle_brk:
{
			lda #$0
			sta BACKG_COLOR
			
			lda #RED
			sta BORDER_COLOR
			
			//lda PETSCII_COLR_TBL,x
			//jsr CHROUT
			
			print_str("**SOFTWARE FAILURE***~")
			print_cr()
			print_str("GURU MEDITATION:")
//
// from https://www.c64-wiki.com/wiki/Interrupt:
//
//	now the stack contains:
//		--return address high byte
//		--return address low byte
//		--processor status at time of IRQ
//		--A register at time of IRQ
//		--X register at time of IRQ
//		--Y register at time of IRQ
			
			print_str(".Y=")
			pla	//Y
			sec				// print $
			print_a_hex()
			
			print_str(" .X=")
			pla	//X
			print_a_hex()
			
			print_str(" .A=")
			pla	//A
			print_a_hex()
			print_cr()

			print_str("Status Reg:")
						
			//ldx 7(		)
			//rol			
			//clc			
						
			pla	//Status reg	
			clc			
						
			ldx #8		
					
loop:					
			rol					
			bcs print_1					
print_0:								
			print_char('0')								
			jmp next								
print_1:								
			print_char('1')
			
next:			
			dex			
			bne loop			
						
			print_str("~           NVBBDIZC~")
			

endless:
			jmp endless
}

old_brk:		.word $0000
flag_text:	.text "NVBDIZC"
			.byte 0
