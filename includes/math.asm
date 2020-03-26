#importonce
//
//	FAC MATH
//
						
.const FAC1 = $61				//  $61:exponent (power of 2). 128 or greater means 
								//		negative exponent
								//  $62-65:mantissa. Also, $62-63 hold result of
								//		FAC1-to-int conversions
								//  $66:sign. 0=positive, $ff=negative
						
.const FAC2 = $69				//  same structure as FAC1

//FAC1 <-> FAC2 math
.const MOVFA = $bbfc			//  FAC1=FAC2
.const FSUBT = $b853			//  FAC1=FAC2 - FAC1
.const FADDT = $b86f			//  FAC1=FAC2 + FAC1
.const NEGFAC = $b947			//  FAC1=negative (2's complement) of FAC1
.const FMULTT = $ba30			//  FAC1=FAC1 * FAC2
.const FDIVT = $bb14			//  FAC1=FAC2 ÷ FAC1
.const FPWRT = $bf78			//  FAC1=FAC2^FAC1 
.const ARISGN = $6f			 	//  Result of comparison between FAC1,FAC2						
								//		0=like signs, $ff=unlike signs						


//FAC1-only math
.const AADD = $bd7e			 	//  Add A to FAC1
.const ADDH = $b849			 	//  Add 0.5 to FAC1 for rounding
.const SIGN = $bc2b			 	//  A=(0 if FAC1=0, 1 if FAC1>0, $FF(-1) otherwise). Also sets N,Z
								//		according to value of FAC1
						
.const ROUND = $bc2b			//  FAC1= ROUND(FAC1)						
.const SQR = $bf71				//  FAC1=SQR(FAC1) 
.const NEGOP = $bfb4			//  FAC1=NOT(FAC1) 
.const EXP = $bfed				//  FAC1=e^EXP1 
.const RND = $e097				//  FAC1=RND(FAC1), using BASIC's RND() logic 
.const COS = $e264				//  FAC1=COS(FAC1) 
.const SIN = $e26b				//  FAC1=SIN(FAC1) 
.const TAN = $e2b4				//  FAC1=TAN(FAC1) 
.const ATN = $e30e				//  FAC1=ATAN(FAC1) 
.const FCOMP = $bc5b			//  Compare FAC1 with 5-byte FP value pointed to by (A,Y). 
								//		A=-1 if FAC<RAM, 0 if FAC=RAM, 1 if FAC>RAM.
								//		Also sets N,Z depending whether FAC1 is <,=,or >0 

// FAC1<-> A,Y math
.const MEMFAC = $BBA2 			//  FAC1=memory (pointed to by A,Y)
.const FACMEM = $BBD4			//  Memory (pointed to by X,Y)=FAC1  
.const PLUS = $B867			 	//  FAC1=A/Y + FAC1
.const MINUS = $B850 			//  FAC1=A/Y - FAC1
.const MULT = $BA28 			//  FAC1=A/Y * FAC
.const DIVID = $BB0F 			//  FAC1=A/Y ÷ FAC
//
//	FAC CONVERSION ROUTINES
//

// string to FAC1
.const PETSCII_TO_FAC1 = $bcf3	//  Convert a PETSCII string containing 
								// 		a FP constant, to FAC1. before calling,  
								// 		store the address of the string in $7a/7b, 
								// 		then JSR $79.						
														
.const STRVAL = $b7b5			//  Convert PETSCII-string to FAC1. Expects 
								//  	string-address in $22/$23 and 
								//		length of string in accumulator.						

.const TXTPTR = $7a				// pointer into (usually BASIC) text														
														
.const FIN = $bcf3				//  Convert string (pointed to by TXTPTR) 
								//		to float in FAC1

// A/Y to FAC1												
.const GIVAYF = $b395			//  Convert signed int in Y/A to FAC1
								//		range -32768 to 32767
								
.const AY_TO_FAC1=$bc49			// 	Convert unsigned 16-bit int in Y/A to FAC1
								//		range 0-65535
								
.const A_TO_FAC1 = $bc3c		//  Convert unsigned 8-bit int in A to FAC1						
.const SNGET = $b3a2  			//  Convert unsigned 8-bit int in Y to FAC1 

// FAC1 to string
.const FLOATASC = $bddd			//  Convert FAC1 to ASCII string, starting at $100
								// 		and ending with a 0 term. On exit, A/Y holds
								// 		start address, so STROUT can be called.
								//		WARNING: OVERWRITES FAC1 WHEN CALLED!

// FAC1 to int												
.const QINT = $bc9b			 	//  Convert FAC1 into 4-byte signed int from $62-65 
.const GETADR = $b7f7			//  Convert FAC1 to a 16-bit UNSIGNED int, in A/Y, also $14/$15.						
.const FACTOINT = $B1AA		 	//  Convert FAC1 to 16-bit signed int in Y/A, (*NOT* A/Y)

//TODO what's this?
//.const MOVMF = 

//misc math 
.const FOUTIM = $be68			//  Convert TI to ASCII string at $100 
.const EVAL = $ae83			 	//  Evaluate an arithmetic term from ASCII  
								//		to a floating point value.
						 
.const GETNUM = $b7eb			//  Evaluates next value as an unsigned int, stores it in $14-$15.  
								//		Then, it looks for a comma, evaluates the next expr as
								//		a byte, and stores it in X. Think POKE or WAIT.

//
// FP representations of numbers
//
//ZERO  .byte $00,$00,$00,$00,$00
//ONE   .byte $81,$00,$00,$00,$00
//TWO   .byte $82,$00,$00,$00,$00
//THREE .byte $82,$40,$00,$00,$00
//FOUR  .byte $83,$00,$00,$00,$00
//FIVE  .byte $83,$20,$00,$00,$00
//SIX   .byte $83,$40,$00,$00,$00
//SEVEN .byte $83,$60,$00,$00,$00
//EIGHT .byte $84,$00,$00,$00,$00
//NINE  .byte $84,$10,$00,$00,$00