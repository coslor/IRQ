#importonce 

#import "macros.asm"
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

;		-FOR loops can be nested, more or less
;			indefinitely. however, the "for_index"
;			of the inner loop shadows the outer ones. Ex:
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
					#push_axy
					
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
								
					#pull_axy		
								
FOR_loop					
					.endm
					
NEXT				.segment
					#push_axy
					
					pha
					
					jsr STOP	; RUN/STOP pressed?
					bne NEXT_compare
					jmp FOR_exit

NEXT_compare
					#cmp16vars for_index,for_limit
					beq FOR_exit
					 					
					pla
					
					#add16 for_index,for_inc 
					
					#pull_axy
					
					jmp FOR_loop
					
;#VARIABLES					
					
for_index			.word 00
for_limit			.word 00
for_inc				.word 00
;#END_VARS

FOR_exit
; we didn't get a chance to empty the stack earlier

					pla			; throw this away				
									
					#pull_axy				

					.bend
					.endm
					
					
					
;do     				.segment
;       					.block
;loop   
;	   				.endm
;
;while  				.segment    ;start macro def
;       					b@1 loop    ;the @1 will be replaced by a text argument
;       					.bend
;       				.endm       ;end macro def

DO     				.segment
       				.block
do_loop   			
					.endm

;
; It is recommended that you use the extended versions of 
;	this macro (WHILE_EQ, WHILE_NEG, etc.), instead of this one,
;	as it is prone to typos.
;
WHILE  				.segment    		
						b@1 do_loop    	
						.bend
       				.endm       		
;while result =
WHILE_EQ			.segment
						#WHILE "eq"
					.endm
					
;while result !=
WHILE_NEQ			.segment
						#WHILE "ne"
					.endm
; while result < 0
WHILE_NEG			.segment
						#WHILE "ne"			
					.endm			
								
;while result > 0			
WHILE_PL			.segment 
						#WHILE "pl"			
					.endm			

; while >=			
WHILE_GEQ			.segment
						#WHILE "cs"			
					.endm			
			
;while <			
WHILE_LE			.segment
						#WHILE "cc"			
					.endm							

; It is recommended that you use the extended versions of 
;	this macro (IF_EQ, IF_NEG, etc.), instead of this one,
;	as it is prone to typos.
;

IF					.segment
					.block
if_start
						b@1 if_true
						;
						; This is an attempt to get around TMP's lack of
						;	optional structures in macros. If you use:
						;		IF..THEN..ENDIF, these nop's stay as
						;	they are. But, if you put an ELSE
						;	in there, then it will rewrite the nop's
						;	as another BNE.
						; 
						nop
						nop
						;jmp if_end
						
if_true												
					.endm
					
ELSE				.segment					
					jmp if_end					
if_false					
					*=if_start+2	;jump back to the NOPs...					
					bne if_false	;...overwrite then with "BNE if_false"...				
					*=if_false		;...and jump back to where we were	
										
;					bne if_false					
;					jmp if_end					
					.endm					
										
ENDIF				.segment										
if_end										
					.bend										
										
;if result =
IF_EQ				.segment
						#IF "eq"
					.endm
					
;if result !=
IF_NEQ				.segment
						#IF "pl"
					.endm
;if result < 0
IF_NEG				.segment
						#IF "ne"			
					.endm			
								
;if result > 0			
IF_PL				.segment 
						#IF "pl"			
					.endm			

;if >=			
IF_GEQ				.segment
						#IF "cs"			
					.endm			
			
;if <			
IF_LE				.segment
						#IF "cc"			
					.endm							
						
IF_CS				.segment
						#IF "cs"
					.endm
					
;
; define a space for variables, so that there's
;	no danger of code running into the variable space
;	without us knowing about it.
;
VAR_SPACE			.segment					
										
					#print_str "ERROR:program entered var space. exiting.~"					
					rts					
					.endm					
										
END_SPACE			.segment										
					.endm										

;***DOES NOT WORK***. One way or another, we end up putting 
;	our subroutine inside a BLOCK, and the rest of the 
;	program can't see them!
;
; define a subroutine. each sub's 
;	labels are local, as they should be, and there's
;	no danger of outside code accidentally wandering	
;	into the sub.
;	NOTE: Syntax is:
; 		subroutine_name		#SUB					
;							...
;							rts
;
;							#END_SUB
;	
;
;SUB					.segment										
;					.block										
;					jmp end_sub																				
;					.endm										
;															
;END_SUB				.segment															
;end_sub				.bend																				
;					.endm																				
;																									

					
		
					
					