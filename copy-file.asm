.ifndef MACROS
	.include "includes\macros.asm"
.endif
.ifndef DISK
	.include "includes\disk.asm"
.endif

						;jmp end_copy
						
;						
; file copy inputs 
; 						
file1_dev				.byte 0
file1_name_ptr			.word 0000
file1_type				.word 0					;should contain S,P,U
file2_dev				.byte 0
file2_name_ptr			.word 0000
file2_type				.byte 0					;should contain S,P,U
;
; file copy variables
;
file1_channel			.byte 20
file1_cmd_channel		.byte 25				;for secondary address 15 
file2_channel			.byte 30
file2_cmd_channel		.byte 35				;for secondary address 15

copy_file
						lda file1_channel			
						ldx file1_dev			
						ldy #4
						
						jsr SETLFS
						
						;#get_filename_len file1_name_ptr
						ldx file1_name_ptr
						
						rts
;						
;	\1 should be either file1_ or file2_name_ptr						
;						
get_filename_len		.macro

;						lda #<\1
;						ldy #>\1
;						;jsr str_ptr 
						
						.endm
