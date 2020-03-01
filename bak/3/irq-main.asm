;        1         2         3         4         5         6         7
;2345678901234567890123456789012345678901234567890123456789012345678901234567890123456789

;
;	Fiddling around with IRQ vectors
;

.ifndef constants
	.include "const.asm"
.endif
.ifndef macros
	.include "macros.asm"
.endif

DEBUG_MACROS	.var 0


* = $0801

;
; for indirect mode, our pointers need to be in ZP
;
screen_ptr=$f7;	.byte <SCREEN_RAM, >SCREEN_RAM
color_ptr=$f9;	.byte <COLOR_RAM, >COLOR_RAM

sbuf_ptr=$fb;	.byte <screen_buffer, >screen_buffer
cbuf_ptr=$b0;	.byte <color_buffer, >color_buffer

counter=$b2;		.byte 00,00


; BASIC header
; 10 SYS (2064)
    .byte   $0E, $08, $0A, $00, $9E, $20, $28
    .text 	"2064"
    .byte 	$29, $00, $00, $00
    

code_begin
			jmp init

;
; copy 2 regions (e.g. screencode,color data) from
;	locations pointed at by \1 to \2, and from \3 to \4.
;	\5 is the total number of 256-byte pages to copy. 
;
copy_scn_data .macro

			;.ifdef DEBUG
				#print_str "/1 start="
				#print_ptr \1
				#print_char CR
				
				#print_str "/2 start="
				#print_int_var \2
				#print_char CR
				
				#print_str "/3 start="
				#print_ptr \3
				#print_char CR
				
				#print_str "/4 start="
				#print_int_var \4
				#print_char CR
				
				#print_str "counter start="
				#print_int_var counter
				#print_char CR
				
				#print_str "/5="
				#print_int_var \5
				#print_char CR
			;.endif
			
			
			ldy #0
			sty counter
			
loop			
			;inc $0400	
				
				
			lda (\1),y
			sta (\2),y
			
			lda (\3),y
			sta (\4),y
			
			iny
			beq increment
			
			#inc16 counter			
			#cmp16const counter,\5
			bcc loop

increment			
			;inc $0401			
						
			inc \1+1
			inc \2+1
			inc \3+1
			inc \4+1
;DEBUG_MACROS .var 1
check_final						
			lda counter						
			cmp 4						
			bcc loop ;C set if >=						
exit

;DEBUG=1
			;.ifdef DEBUG
				#print_str "done!~"
				
				#print_str "/1 final="
				#print_ptr \1
				#print_char CR
				
				#print_str "/2 final="
				#print_int_var \2
				#print_char CR
				
				#print_str "/3 final="
				#print_ptr \3
				#print_char CR
				
				#print_str "/4 final="
				#print_int_var \4
				#print_char CR
				
				#print_str "counter final="
				#print_int_var counter
				#print_char CR
			;.endif
			
			
			.endm

;
; initializes screen pointers
;
set_screen_ptrs
			#store16 SCREEN_RAM,screen_ptr
			#store16 COLOR_RAM,color_ptr
			#store16 screen_buffer,sbuf_ptr
			#store16 color_buffer,cbuf_ptr
			#store16 0,counter
			
			rts
			
;
;	copy screen,color maps from display mem to buffers
;
store_screens	
.block
			jsr set_screen_ptrs						
									
			;.ifdef DEBUG
				#print_str "storing screens:"						
				#print_int_var screen_ptr						
				#print_str "->"						
				#print_int_var sbuf_ptr						
				#print_spc						
				#print_int_var color_ptr						
				#print_str "->"						
				#print_int_var cbuf_ptr						
				#print_cr						
			;.endif						
									
			#print_char $1c						
			#copy_scn_data screen_ptr,sbuf_ptr,color_ptr,cbuf_ptr,4 
								
			rts						
.bend			

;
;	copy screen,color maps from buffers to display mem
;
restore_screens 
 
.block 

			jsr set_screen_ptrs
			
			;.ifdef DEBUG
				#print_str "restoring screens:"						
				#print_int_var sbuf_ptr						
				#print_str "->"						
				#print_int_var screen_ptr						
				#print_spc						
				#print_int_var cbuf_ptr						
				#print_str "->"						
				#print_int_var color_ptr						
				#print_cr						
			;.endif						

			#print_char $1e
			#copy_scn_data sbuf_ptr,screen_ptr,cbuf_ptr,color_ptr,4  
			
			rts
						 
.bend 


;			
;	Checks to see if IRQ is active. Sets carry accordingly.			
;			
check_active				
.block				
			lda $315
			cmp #>main
			bne not_active
			lda $314
			cmp #<main
			bne not_active
			
			sec
			jmp exit
			
not_active	clc			
			jmp exit			
						
exit		rts						
.bend						

;
;	set the irq vector to execute our code
;		before running the normal C64 IRQ vector
;
init 
;.block
			lda #$17		; set upper-lower character set
			sta $d018
			#print_char 8	; ...and disable switching 
			
			
			jsr check_active
			bcc activate
			jmp deactivate
			
activate			
			sei
			
			lda #>main
			sta $315
			lda #<main
			sta $0314
			
			lda $d020
			sta old_bgcolor
			
			cli
			
			jsr store_screens
			
			#print_str "To deactivate, run again"
			#print_char CR
			
			#print_int code_length
			#print_str " bytes total~"
			
			
			rts
;.bend


;
;	restore the IRQ vector to the system default, assuming 
;		that's it's been previously set. Otherwise, complain.
;
deactivate		
.block		
			jsr check_active		
			bcs deactivate2	
				
			jmp activate	
		

deactivate2			
			sei
			
			lda #$31		
			sta $0314		
			lda #$EA		
			sta $0315		
					
			cli		

			lda old_bgcolor
			sta $d020
			
			jsr restore_screens
			
			#print_str "Deactivated!"
			#print_char CR
			#print_str "Run again to re-activate"
			#print_char CR
					
			clc		
			bcc exit	
exit 	
			rts
.bend

;
; check for 'commodore-c' key pressed,
;	OUT:c=1 if pressed, 0 if not
;
check_key
.block
			lda SHIFT_KEYS
			and #(KEY_COMM)
			beq ck1
			
			lda $cb			
			cmp #$14		;'c'			
						
			bne ck1			
						
			sec
			rts
			
ck1			clc
			rts
.bend

old_bgcolor	.byte 0					


;				
;	main routine, which runs every IRQ period (60 times/sec				
;		for NTSC machines). 				
;					
;	at the moment, just sets the border color to black				
;		to remind the user that it's active, and				
;		clears the screen when the user hits commodore-c				
;				
				
main	
			
			lda #0
			sta $d020	; set border color to black when 
						; 	custom IRQ is active		
			
			jsr check_key			
			bcc exit			
						
						
			jsr CLR_SCREEN
		
		
exit
			jmp $EA31	;continue IRQ servicing logic
			rts

;count			.byte $ff
								



screen_buffer
*=*+1000
color_buffer
*=*+1000

			nop
			
code_end

code_length=code_end-code_begin