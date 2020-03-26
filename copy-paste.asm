.ifndef CONSTANTS
	.include "includes\const.asm"
.endif

; NOTE: the characters in the paste buffer are in BACKWARDS order!
paste_bufr	.repeat $FF,00				
				
; Current length of paste buffer. Starts at 1. 0=empty paste buffer  				
buffer_len	.byte 00

;
; If there's room in the keyboard buffer, read the next char
;	from the paste buffer and put it in the keybd buffer.
;
paste
.block
is_keybd_full
			lda NDX			; # of chars currently in keybd buffer
			cmp XMAX		; max # of chars in keybd buffer
			bcs exit		; is NDX >= XMAX? if so, exit
			
is_paste_empty
			lda buffer_len
			beq exit		; is paste buffer empty? if so, exit
			
copy_chars
			inc NDX			; increase # of chars in keybd buffer by 1
			
;			
; NOTE: the number of chars in p			
;			
			dec bufr_end	; reduce # of chars in paste buffer by 1
			ldx bufr_end
			
			lda paste_bufr,x
			sta KEYBD_BUFR,x
			
exit
			rts
						
.bend
bufr_end	.byte 00


			
				
			
			

				