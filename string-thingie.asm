.encoding "petscii_mixed"

.macro print_str(str) {	
			jmp print
msg:		.text str
			.byte 13,0	
print:		
			ldx #0	
loop:			
			lda msg,x			
			beq exit			
			jsr $FFD2			
			inx			
			bne loop			
					
exit:	
}		

*= $801
BasicUpstart(start)

*= $810			
start:			
		print_str("hello world!")		
		print_str("another message!")		
				
		rts
		