.ifndef PRINT_MACROS
	.include "..\includes\print_macros.asm"
.endif

.include "..\copy-paste.asm"

#BASIC
*=$810

test_paste
.block
			#print_str "test paste~"
			#print_str "should put 'now is the time...' in the keyboard buffer~"
			
.bend	
			