.include "macros.asm"

;
; FOR..NEXT macros. Syntax is:
;	#FOR <start>,<end>,<increment>
;		<line1>
;		<line2>
;	#NEXT
;
;	NOTES:
;		-an increment of 0 means an infinite loop
;		-negative increments are possible, using
;			2's complement arithmetic (e.g. 
;			-5=($FFFF-5) = 65536-5 = 65531/$FFFB ), 
;			so the line would be: FOR 20,10,$FFFB 
;		-if the increment is not 0, FOR won't loop
;			forever, but will stop after $FFFF loops.
;			e.g. FOR 20,10,1 runs 65535 times
;		-FOR loops can be interrupted via RUN/STOP

;		-FOR loopscan be nested, more or less
;			indefnitely. however, the "for_index"
;			of the inner loop shadows the outer ones. e.g.:
;					#FOR 1,5,1
;						#print_str "this index will never be >5:"
;						#print_int_var for_index
;						#print_cr
;						#FOR 10,40,10
;								#print_str "this index will never be <10"
;								#print_int_var for_index
;								#print_cr
;
;
;	BUGS:
;		-the index must hit the limit EXACTLY.
;			e.g. FOR 10,20,3 runs $FFFF times
;

FOR					.segment
					.block					
FOR_init			
					#store16 \1,for_index
					#store16 \2,for_limit
					#store16 \3,for_inc			
								
					.ifdef DEBUG_MACROS			
						#print_int_var for_index			
						#print_spc			
						#print_int_var for_limit			
						#print_spc			
						#print_int_var for_inc			
						#print_cr			
					.endif			
								
FOR_loop					
					.endm
					
NEXT				.segment
					pha
					
					jsr STOP	; RUN/STOP pressed?
					bne NEXT_compare
					jmp FOR_exit

NEXT_compare
					#cmp16vars for_index,for_limit
					beq FOR_exit
					 					
					pla
					
					#add16 for_index,for_inc 
					
					jmp FOR_loop
					
for_index			.word 00
for_limit			.word 00
for_inc				.word 00

FOR_exit
; we didn't get a chance to empty the stack earlier
					pla				

					.bend
					.endm
;
;	Syntax is: FOR1 <varname>,<start-index>,<end-index>
;FOR1				.macro
;	for_@1	
;					.byte <\2, >\2					
;
;for_start_@1
;					.endm
;					
;NEXT1				.macro					
;					#inc16 for_index_@1
;					#cmp16const for_@1,\3			
;					bcc for_start_@1
;					
;					.endm

