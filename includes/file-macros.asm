//
//	Macros for file I/O 
// 
 
#importonce 
#import "const.asm"

.macro open_file(file_num, dev_num, secondary, filename, filename_len, error_rtn){
			lda #file_num
			ldx #dev_num
			ldy #secondary
			jsr SETLFS
			bcs error
			
			lda #filename_len
			ldx #<filename_len
			ldy #>filename_len
			jsr SETNAM
			bcs error
			
			jsr OPEN
			bcs error
			
//			ldx #file_num
//			jsr CHKIN
//			bcs error

}
