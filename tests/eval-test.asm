				* = $c000

.include "const.asm"				
				
start							
				jsr EVAL		; results now in FAC1								
				jsr FOUT	
				jsr STROUT	
					
				rts	
					
								