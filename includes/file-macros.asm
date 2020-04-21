/************************************************
*
*	File Macros
*
*************************************************/
#importonce
#import "macros.asm"

.macro open_file(file_num,dev_num,secondary_num,filename) {

open_file:
			open_file_addr(file_num,dev_num,secondary_num,fname,fname_end - fname)
			jmp fname_end
			
			.encoding "petscii_mixed"
fname:		.text filename
fname_end:			

}

.macro open_file_addr(file_num,dev_num,secondary_num,fn_addr,fn_len) { 
 			push_xy()

			lda #file_num
			ldx #dev_num
			ldy #secondary_num
			jsr SETLFS
			bcs error
			
			lda #fn_len
			ldx #<fn_addr
			ldy #>fn_addr
			jsr SETNAM
			bcs error
			
			jsr OPEN
			bcs error
						
			lda #0
			jmp exit
			
error:			

exit:			
			pull_xy()	
			

} 