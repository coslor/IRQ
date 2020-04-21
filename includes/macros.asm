#importonce 
#import "const.asm"
#import "math.asm"
#import "print-lib.asm"
#import "misc-lib.asm"

.macro phx() {
			sta temp_a
			txa
			pha
			lda temp_a
}

.macro plx() {
			sta temp_a
			pla
			tax
			lda temp_a
}

.macro phy() {
			sta temp_a
			tya
			pha
			lda temp_a
}

.macro ply() {
			sta temp_a
			pla
			tay
			lda temp_a
}

.macro push_axy() {
push_axy:
			sta temp_a
			
			pha
			txa
			pha
			tya
			pha
			
			lda temp_a
}

.macro pull_axy() {						
pull_axy:						
			pla
			tay
			pla
			tax
			pla
}			

.macro push_xy() {
push_xy:
			sta temp_a
			
			txa
			pha
			tya
			pha
			
			lda temp_a
}

.macro pull_xy() {						
pull_xy:						
			sta temp_a					
								
			pla
			tay
			pla
			tax
			
			lda temp_a
}			
						
.macro push_ax() {
push_ax:
			sta temp
			
			pha
			txa
			pha
			
			lda temp
			jmp after_temp
			
temp:		.byte 00			

after_temp:			
}

.macro pull_ax() {						
pull_ax:						
			pla
			tax
			pla
}			
						
.macro push_ay() {
push_ay:
			sta temp
			
			pha
			tya
			pha
			
			lda temp
			bcc after_temp
			bcs after_temp
			
temp:		.byte 00			

after_temp:			
}

.macro pull_ay() {						
pull_ay:						
			pla
			tay
			pla
}			

/**
*	Push the CONTENTS of the given ZP pointer onto the stack. 
* 
* 	TRASHES:A,Y 
**/ 
.macro push_ptr_val(ptr_loc) {						
			ldy #0						
			lda (ptr_loc),y						
			pha						
			iny						
			lda (ptr_loc),y						
}				
/**
*	Pull the next 2 bytes off the stack, and store them in the  
*		address POINTED TO by ZP pointer ptr_loc. 
* 
* 	TRASHES:A,Y 
**/ 							
.macro pull_ptr_val(ptr_loc) {				
			pla				
			ldy #0				
			sta (ptr_loc),y			
			pla			
			iny		
			sta (ptr_loc),y			
}			

/**
*	Push the 16-bit value given, in lo,hi byte order
*
*	TRASHES:A
**/
.macro push_int(val) {			
			lda #<val			
			pha			
			lda #>val			
			pha			
}			

/**
*	Pull the next 2 bytes off the stack and store them
*		in the given address. Bytes are pulled in hi,lo order.
*
*	TRASHES: A,Y
**/
.macro pull_var(loc) {
			pull_ay()
			sta loc
			sty loc+1
}

/**			
*  	Increment a 16-bit value 
*		
*	TRASHES: NONE		
*/		
.macro inc16(loc) {					
inc16:					
			pha					
												
			inc loc					
			bne done					
								
			inc loc+1					
																
done:								
			pla			
}								

/**											
*	Store a 16-bit constant val in location loc											
*	TRASHES: NONE											
**/											
.macro store16(val,loc) {											
store16:											
			pha											
														
			lda #<val											
			sta loc											
														
			lda #>val											
			sta loc+1											
														
			pla											
}									

.macro store16_in_ay(val) {									
store16_in_ay:									
			lda #<val									
			ldy #>val									
}									

.macro store16_in_xy(val) {									
store16_in_xy:									
			ldx #<val									
			ldy #>val									
}									

.macro store_ay_in_var(ptr) {									
store_ay_in_var:									
			sta ptr									
			sty ptr+1									
}									
/**											
*	Store the value of 16-bit var loc1 in location loc2											
*	TRASHES: NONE											
*/											
.macro store16var(loc1,loc2) {											
store16var:											
			pha											
														
			lda loc1											
			sta loc2											
														
			lda loc1+1											
			sta loc2+1											
														
			pla											
}											
														
/**											
* compare two 16-bit variables.											
*	OUT: A=0 if equal, 1 otherwise 											
**/											
.macro cmp16vars(ptr1,ptr2) {						
									
			lda ptr1						
			cmp ptr2										
			bne not_equal					
								
			lda ptr1+1					
			cmp ptr2+1					
			bne not_equal					
equal:
			lda #0								
			beq exit	//always taken							
										
not_equal:
			lda #1										
								
exit:
}						


/**									
*	Compare a 16-bit var to a constant.									
*	OUT: A=0 if equal, 1 otherwise 											
**									
.macro cmp16const(loc,val) {					
								
			lda loc						
			cmp #<val					
			bne not_equal					
								
			lda loc+1					
			cmp #>val					
			bne not_equal					
								
equal:
			lda #0					
			jmp exit					
								
not_equal:
			lda #1								
								
exit:
}						

/**									
*	Add 16-bit ints: loc1 = loc1+loc2						
*									
*	TRASHES: NONE									
*/									
.macro add16(loc1,loc2) {									
			pha									
												
			clc									
												
			lda loc1									
			adc loc2									
			sta loc1									
												
			lda loc1+1
			adc loc2+1
			sta loc1+1
			
			clc
			
			pla
			
}

.macro swap_ay() {
			sta temp_a
			tya
			ldy temp_a
}

.macro swap_ax() {
			sta temp_a
			txa
			ldx temp_a
}
				
.macro swap_xy() {
			stx temp_a
			tya
			tax
			ldy temp_a
}

.macro str_to_fac1(str,len) {
			store16(txt,$22)
			lda #len
			jsr STRVAL

			jmp end_text
			
			.encoding "petscii_mixed"
txt:		.text str
			.byte 00
end_text:
}

.macro str_addr_to_fac1(str_addr) {
			store16(str_addr, $22)
			get_str_len(str_addr)
			jsr STRVAL
			
}

/**
*		WARNING: THE ROUTINE UNDERLYING THIS MACRO WILL OVERWRITE FAC1
*/
.macro print_fac1() {
			jsr FLOATASC
			jsr STROUT
}

.macro fac1_to_float(loc) {
			store16_in_xy(loc)
			jsr FACMEM
}

.macro float_to_fac1(loc) {
			store16_in_ay(loc)
			jsr MEMFAC
}

.macro str_to_float(str,strlen,loc) {
			str_to_fac1(str,strlen)
			fac1_to_float(loc)			
}

.macro str_addr_to_float(str_addr,loc) {
			str_addr_to_fac1(str_addr)
			fac1_to_float(loc)
}

.macro get_str_len(str_addr) {
			store16_in_ay(str_addr)
			jsr get_str_len
}

.macro fac1_to_int(loc) {
			jsr QINT			// convert FAC1 into 32-bit int in $62-65
			lda FAC1+3
			ldy FAC1+4
			sty loc
			sta loc+1
}


/**			
*		NOTE: this routine MAY NOT WORK if the kernal ROM has been switched out!		
**/			
.macro set_v() {
			bit $FFFF	//ROM - byte contains $ff, so N and V are set 
}

/**
*		NOTE: this routine MAY NOT WORK if the kernal ROM has been switched out!		
**/
.macro clear_v() {
			bit $FADE	//ROM - byte contains $0c, so N and V are cleared
}

/*
*	To use: call tsx first, then call store_next_stack_byte() as many times
*		as necessary. Works backwards through the stack. 
*		Does NOT alter the stack pointer itself.
*
*		TRASHES: A,X
*/
.macro store_next_stack_byte(loc) {
			lda STACK,x
			sta loc
			dex
}

/*
*		TRASHES: A,X
*/
.macro store_next_stack_word(loc) {
store_next_stack_word:
			store_next_stack_byte(loc)
			.eval loc=loc+1
			store_next_stack_byte(loc)
}

/*
*		TRASHES: A,X
*/
.macro restore_next_stack_byte(loc) {
			lda loc
			sta STACK,x
			inx
}

/*
*		TRASHES: A,X
*/
.macro restore_next_stack_word(loc) {
restore_next_stack_word:
			restore_next_stack_byte(loc)
			.eval loc=loc+1
			restore_next_stack_byte(<loc)
}

/*
*		TRASHES: A,X
*/
.macro put_byte_in_stack(index,val) { 
			lda #val
			ldx #index
			sta STACK,x  
} 

/*
*		TRASHES: A,X
*/
.macro put_word_in_stack(index, val) {
put_word_in_stack:
			put_byte_in_stack(index,>val)
			.eval index=index+1
			.eval val=val+1
			put_byte_in_stack(index+1,>val+1)
}

/*
*		TRASHES: A
*/
.macro get_byte_from_stack(index, loc) {
			get_a_from_stack(index)
			sta loc
}

/*
*		TRASHES: A
*/
.macro get_word_from_stack(index, loc) {
get_word_from_stack:
			get_byte_from_stack(index,loc)
			get_byte_from_stack(index+1,loc+1)
}
			
/*
*		TRASHES: A
*/
.macro get_a_from_stack(index) {
			ldx #index
			lda STACK,x
}

