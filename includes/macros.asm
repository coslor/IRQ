#importonce 
#import "const.asm"
#import "math.asm"

.macro push_axy() {
			sta temp
			
			pha
			txa
			pha
			tya
			pha
			
			lda temp
			jmp after_temp
			
temp:		.byte 00			

after_temp:			
}

.macro pull_axy() {						
			pla
			tay
			pla
			tax
			pla
}			
						
.macro push_ax() {
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
			pla
			tax
			pla
}			
						
.macro push_ay() {
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

.macro push_int(val) {			
			lda #<val			
			pha			
			lda #>val			
			pha			
}			

.macro pull_int() {			
			pla			
			tax			
			pla		
}			

.macro pull_var(loc) {
			pull_int()
			sta loc
			sty loc+1
}

//			
//  increment a 16-bit value 
// 			
.macro inc16(loc) {					
								
			pha					
												
			inc loc					
			bne done					
								
			inc loc+1					
																
done:								
			pla			
}								

//											
// store a 16-bit constant val in location loc											
//											
.macro store16(val,loc) {											
			pha											
														
			lda #<val											
			sta loc											
														
			lda #>val											
			sta loc+1											
														
			pla											
}									

.macro store16_in_ay(val) {									
			lda #<val									
			ldy #>val									
}									

.macro store16_in_xy(val) {									
			ldx #<val									
			ldy #>val									
}									

.macro store_ay_in_var(ptr) {									
			sta ptr									
			sty ptr+1									
}									

//											
// store the value of 16-bit var loc1 in location loc2											
//											
.macro store16var(loc1,loc2) {											
			pha											
														
			lda loc1											
			sta loc2											
														
			lda loc1+1											
			sta loc2+1											
														
			pla											
}											
														
//											
// compare two 16-bit variables.											
//	OUT: A=0 if equal, 1 otherwise 											
//											
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


//									
// compare a 16-bit var to a constant									
//	OUT: A=0 if equal, 1 otherwise 											
//									
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

//									
// 16-bit ints: loc1 = loc1+loc2						
//									
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
			sta temp
			tya temp
			ldy temp
			jmp after_temp
temp:		.byte 00
after_temp:
}

.macro swap_ax() {
			sta temp
			txa temp
			ldx temp
			jmp after_temp
temp:		.byte 00
after_temp:
}
				
.macro swap_xy() {
			stx temp
			tya
			tax
			ldy temp
			jmp after_temp
temp:		.byte 00
after_temp:
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

.macro print_float(loc) {
			float_to_fac1(loc)
			print_fac1()
}

.macro print_FAC1_bytes() {
			.for (var i=0;i<6;i++) {
				lda FAC1+i
				print_a_hex()
				print_spc()
			}
			print_cr()
}

.macro fac1_to_int(loc) {
			jsr QINT			// convert FAC1 into 32-bit int in $62-65
			lda FAC1+3
			ldy FAC1+4
			sty loc
			sta loc+1
}

