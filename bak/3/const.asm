constants=1			

;
; utility routines
;
CLR_SCREEN = $e544
PLOTK = $e50a			; read/set cursor row(x), col(y) 
SCROL = $e8ea			; scroll the screen up 1 line 
DSPP = $ea31			; read the screen & put char in A, color in X 
MOVE_UP = $a3bf			; move a block of memory up, or move memory  
						;	from one non-overlapping region to another.
						;	$5f-$60=source block starting address
						;	$5a-5b=source block ending address +1
						;	$58-59=destination's ending address +1


;
;	I/O ROUTINES
;
CHROUT = $FFD2			; write byte to default output
CHRIN = $FFCF			; read byte from default input

SETLFS = $FFBA			; set logical file numbers (open a,x,y)
SETNAM = $FFBD			; set file name(a=len,x/y=lo/hi for pointer)
OPEN = $FFC0			; open file (out:c=err, a=1,2,4,5,8 error code)
CLOSE = $FFC3			; close file (a=fileno)
CHKIN = $FFC6			; set file as default input(a=filenumber,C=error)
CHKOUT = $FFC9			; set file as default output(a=filenumber,C=error)
CLRCHN = $FFCC			; close default input/output files
LOAD = $FFD5
SAVE = $FFD8
GETIN = $FFE4			; read byte from default input (diff with CHRIN?)
CLALL = $FFE7			; clear file table & call CLRCHN
READST = $ffb7			; read STatus, leaves it in A
STATUS = $90			; ST for serial devices.						
						;	For serial devices:						
						;		bit 0:timeout (write)
						;		bit 1:timeout (read)
						;		bit 6:EOF
						;		bit 7:device not present 						

STROUT = $ab1e			; print zt string,addr in A/Y
LINPRT = $BDCD			; print UNSIGNED int in A/X 

PRTSPC = $ab4d			; print a space character
CRDO = $aad7			; print a CR character, followed by LF
						;	if channel > 128
						
STOP = $ffe1			; check for STOP key. If pressed, 
						; 	set Z (BEQ), call CLRCHN, print "break".
FTXTPTR = $7a			; pointer into (usually BASIC) text						

;
;	FAC MATH
;
MOVFA = $bbfc			; copy FAC2 to FAC1
						
FAC1 = $61				; $61:exponent (power of 2). 128 or greater means 
						;	negative exponent
						; $62-65:mantissa. Also, $62-63 hold result of
						;	FAC1-to-int conversions
						; $66:sign. 0=positive, $ff=negative
						
FAC2 = $69				; same structure as FAC1


AADD = $bd7e			; add A to FAC1

ADDH = $b849			; add 0.5 to FAC1 for rounding
FSUBT = $b853			; FAC1=FAC2 - FAC1
FADDT = $b86f			; FAC1=FAC@ + FAC1
NEGFAC = $b947			; FAC1=negative (2's complement) of FAC1
FMULTT = $ba30			; FAC1=FAC1 * FAC2
FDIVT = $bb14			; FAC1=FAC2 / FAC1
ROUND = $bc2b			; FAC1 = ROUND(FAC1)
SIGN = $bc2b			; A=(0 if FAC1=0, 1 if FAC1>0, $FF(-1) otherwise)
						
FOUTIM = $be68			; convert TI to ASCII string at $100 
SQR = $bf71				; FAC1=SQR(FAC1) 
FPWRT = $bf78			; FAC1=FAC2^FAC1 
NEGOP = $bfb4			; FAC1 = NOT(FAC1) 
EXP = $bfed				; FAC1=e^EXP1 
RND = $e097				; FAC1=RND(FAC1), using BASIC's RND() logic 
COS = $e264				; FAC1=COS(FAC1) 
SIN = $e26b				; FAC1=SIN(FAC1) 
TAN = $e2b4				; FAC1=TAN(FAC1) 
ATN = $e30e				; FAC1=ATAN(FAC1) 
EVAL = $ae83			; evaluate an arithmetic term from ASCII  
						;	to a floating point value.   

;
;	FAC CONVERSION ROUTINES
;
PETSCII_TO_FAC1=$bcf3	; convert a PETSCII string containing 
						; 	a FP constant, to FAC1. before calling,  
						; 	store the address of the string in $7a/7b, 
						; 	then JSR $79.
						
STRVAL = $b7b5			; convert PETSCII-string to FAC1. Expects 
						;   string-address in $22/$23 and 
						;	length of string in accumulator.
						
GIVAYF = $b391			; convert signed int in Y/A to FAC1; range -32768 to 32767
FACINX = $B1AA			; convert FAC1 to 2-byte signed int in A/Y
FIN = $bfc3				; convert string (pointed to by TXTPTR) 
						;	to float in FAC1
FOUT = $bddd			; convert FAC1 to ASCII string, starting at $100
						; 	and ending with a 0 term. On exit, A/Y holds
						; 	start address, so STROUT can be called.
A_TO_FAC1 = $bc3c		; convert unsigned 8-bit int in A to FAC1						
SNGET = $b3a2  			; convert unsigned 8-bit int in Y to FAC1 
QINT = $bc9b			; convert FAC1 into 4-byte signed int from $62-65 
GETADR = $b7f7			; convert FAC1 to a 16-bit int, in $14/$15						
 
 
;
; interrupt vectors
;
CVINV = $314			; point to IRQ handler, normally $ea31.
						;	NOTE: A,X,Y are saved on the stack before calling,
						;		but they are NOT automatically restored
						
CBINV = $316			; BRK interrupt handler. Normally $fe66.  
NMINV = $318			; NMI handler, normally $fe47.  
						;	NOTE: to disable RS/RESTORE, store a 0 in $318.
						

						  						 

;
; passing data between basic and ml
;


A_STORAGE = $30c		; the registers are read from these 
X_STORAGE = $30d 		;	locations before running a SYS routine,
Y_STORAGE = $30e 		; 	and the results are stored back into 
P_STORAGE = $30f 		;	them after the RTS. doesn't apply to USR.

USERADD = $311			; the 16-bit address of a USR routine can be 
						; 	put into this vector. for example:
						;		x=usr(17) 								
						;	...puts the value of 17 in FAC1, calls
						; 	the routine in $311-312, and assigns the
						;	value of FAC1 upon exiting, to the var x.
;
; other basic stuff
;
CHRGET = $73			; reads the next character for processing by basic.
						;	sets P to indicate what kind of char,  
						; 	and returns the char in A. C=0-9,Z=end of stmt.
						
CHRGOT = $79			; does the same thing, but doesn't increment the						
						;	char pointer.						
												
VERCK = $A				; flag:0=LOAD,1=VERIFY												
VALTYP = $D				; flag:$FF=string,0=numeric							
INTFLG = $E				; flag:$80=int,0=fp												
INPFLG = $11			; flag:0=INPUT,$40=GET,$98=READ												
CHANNL = $13			; current logical file number (not dev#)												
TXTTAB = $2b			; beginning of BASIC text, normally $801 
MEMSIZ = $37			; end of BASIC-available memory 
CURLIN = $39			; current BASIC line#. $ff in $40 means immediate mode 
VARPNT = $47			; descriptor of current BASIC variable value 
OPMASK = $4D			; comparison operation flag: 1=<,2=> 
DSCPNT = $50			; $50-51 point to current string descriptor, 
						; 	$52 holds string length
						
ARISGN = $6f			; result of comparison between FAC1,FAC2						
						;	0=like signs, $ff=unlike signs						

STKEY = $91				; value of the last row of the keybd when last scanned. 												 
						;	$ff=none,$fe=1,$fd=<-,$fb=CTRL,$ef=SPACE,
						;	$df=Commodore,$bf=Q,$7f=STOP.
						;	NOTE: this means that you can do this:
						;		LDA STKEY
						;		BPL handle_stop
						
VERCK2 = $93				; flag for load routine: 0=load/1=verify												
DFLTN = $99				; current default input device
DFLTO = $9A				; current default output device
TIME = $A0				; software jiffy clock, from $a0-a2. 
						;	24-bit count of jiffies (60/sec) since start.
						;	resets every 24 hours.

FNLEN = $b7				; size of current filename						
LA = $b8				; current logical file number(for a different						
						;	purpose then $13)						
SA = $b9				; current secondary address												
FA = $ba				; current device number												
FNADR = $BB				; 2-byte pointer to filename												
LSTX = $c5				; matrix coordinate of *last* keypress; 64=none												
NDX = $c6				; # of characters in keyboard buffer												
RVS = $c7				; flag: print reverse characters? 0=no												
						;	NOTE: you can poke 0 here to cancel reverse mode												
SFDX = $cb				; matrix coords of *current* keypress; 64=none
BLNSW = $cc				; cursor blink enable:0=flash
GDBLN = $ce				; screen code of char under cursor
PNTR = $d3				; cursor column on current line
QTSW = $d4				; editor in quote mode? 0=no
TBLx = $d6				; current cursor physical line #
INSRT = $d8				; insert mode? >0 is # of inserts
USER = $f3				; 2-byte pointer to current screen color location

COLOR = $286			; current foreground color for text
GDCOL = $287			; color of character under cursor
HIBASE = $288			; page of screen memory; normally contains 4(*256=1024)
						;	NOTE: $d018/$dd00 change ths *display*
						;	screen location - the one that shown onscreen.
						; 	this one is the memory written into by CHROUT,etc.
						
XMAX	= $289			; max keyvoard buffer size; should be <=10						
RPTFLAG = $28a			; flag: which keys should repeat?						
						;	0=normal,$80=all,$40=none						
												
SHFLAG = $653			; flag: modifier keys currently pressed?											
						;	bits: 1=SHIFT,2=Commodore,4=CTRL											
																	
MODE = $291				; flag: enable changing char sets with SHIFT/C= ?																	
						;	$80=disabled, 0=enabled																	
																							
AUTODN = $292			; flag: scroll screen on col 40/last line?																							
						;	0=yes; otherwise=no																							
																													
																													
																		 
BUF = $200				; BASIC line editor input buffer 
 
 												
;
; PETSCII
;
SPC = $20
CR = $0d
RVS_ON = $12 
RVS_OFF = $92 
CLR = $93 
BLACK = $90
WHITE = $05
RED = $1c
GREEN = $1e
BLUE = $1f
ORANGE = $81
BROWN = $95
PURPLE = $9c
YELLOW = $9e
CYAN = $9f
LT_RED = $96
DK_GRAY = $97
GRAY = $98
LT_GRAY = $9b
LT_GREEN = $99
LT_BLUE = $9a
HOME = $13
DEL = $14
UP = $91
DOWN = $11
LEFT = $9d
RIGHT = $1d
SHIFT_ON = $09
SHIFT_OFF = $08
MODE_TEXT = $0e
MODE_GRAPH = $8e
F1 = $85
F2 = $86
F3 = $87
F4 = $88
F5 = $89
F6 = $8a
F7 = $8b
F8 = $8c 
DBL_QUOTE = $22 
SNGL_QUOTE = $27 
GRAPH_SLASH = $6e 
GRAPH_BACKSLASH = $6d 
PIPE = $7d 
DASH = $60 

;			
; keyboard constants			
;			
SHIFT_KEYS=$028d
KEY_SHIFT=%00000001
KEY_COMM=%000000010
KEY_CTRL=%00000100

;
; zero page locations
;
; used by tape routines
;
TSERVO = $92
TEOB = $96
TEMPXY = $97
TPARIT = $9b
TBYTFL = $9c
HDRTYP = $9e
PTR1 = $9e
PTR2 = $9f
TSFCNT = $a3
TBTCNT = $a4
CNTDN = $A5
BUFPNT = $a6
PASNUM = $a7
RIDATA = $aa
TCKS = $ab
CMP00 = $b0
CMPB01 = $b1
TAPE10 = $b2
TAPE11 = $b3
;
; used by rs-232
RIBUF0 = $f7
RIBUF1 = $f8
ROBUF0 = $f9
ROBUF1 = $fa
;
; unused
;
MISC_PTR0 = $fb
MISC_PTR1 = $fc 

;
; I/O Registers
;
SPRITE0_X = $d000
SPRITE0_Y = $d001
SPRITE1_X = $d002
SPRITE1_Y = $d003
SPRITE2_X = $d004
SPRITE2_Y = $d005
SPRITE3_X = $d006
SPRITE3_Y = $d007
SPRITE4_X = $d008
SPRITE4_Y = $d009
SPRITE5_X = $d00a
SPRITE5_Y = $d00b
SPRITE6_X = $d00c
SPRITE6_Y = $d00d
SPRITE7_X = $d00e
SPRITE7_Y = $d00f

SPRITE_MSB = $d010	; sprite 0-7 MSB of x coord
SCREEN_REG1= $d011	; bits 0-2:vertical raster roll
					; bit 3: screenm height (24/25 rows)
					; bit 4: screen off/on
					; bit 5: text/bitmap screen
					; bit 6: extended background mode
					; bit 7: 	read: current raster line
					;			write: line to generate IRQ at
					
RASTER_LINE = $d012 ; read: current raster line
LIGHTPEN_X = $d013
LIGHTPEN_Y = $d014
SPRITE_EN = $d015		; enable/disable bits for sprites 0-7

SCREEN_CTRL = $d016	; 	bits 0-2:horiz raster scroll	
					;	bit 3: screen width - 38/40 cols	
					;	bit 4: multicolor mode	
						
SPRITE_2X_HT = $d017
MEM_SETUP = $d018	;	bits 1-3: in text mode, pointer to
					;		character memory
					; 	bits 4-7: pointer to screen memory
					
SPRITE_PRI = $d01b 	;	bits determine whether sprite x drawn  
					;		in front of/behind background
					
SPRITE_MULTI = $d01a ; sprites 0-7 multicolor on/off 
SPRITE_2X_WD = $d01d					
SPR2SPR_COLL = $d01e ; 	read: sprites have collided,					
					;	write: detect sprite-sprite collisions					
										
BORDER_COLOR = $d020 ; bits 0-3 										
BACKG_COLOR = $d021	; bits 0-3				
BKG_MULTI_CLR1 = $d022			
BKG_MULTI_CLR2 = $d023			
BKG_MULTI_CLR3 = $d024			
SPR_MULTI_CLR1 = $d025			
SPR_MULTI_CLR2 = $d026			
			
SPRITE0_COLOR = $d027 ; bits 0-3						
SPRITE1_COLOR = $d028 ; bits 0-3						
SPRITE2_COLOR = $d029 ; bits 0-3						
SPRITE3_COLOR = $d02a ; bits 0-3						
SPRITE4_COLOR = $d02b ; bits 0-3						
SPRITE5_COLOR = $d02c ; bits 0-3						
SPRITE6_COLOR = $d02d ; bits 0-3						
SPRITE7_COLOR = $d02e ; bits 0-3						
						
PROCESSOR_DDR = $0	; bits 0-7: set read/write for bit x 
					;	of processor port					
										
PROCESSOR_PORT = $1	; 	bit 0: RAM/ROM at $a000-bfff										
					;	bit 1: RAM/ROM at $e000-ffff										
					;	bit 2: RAM/IO ports at $d000-dfff										
					;	bits 3-5: datasette										
															
PRA  =  $dc00			; CIA#1 (Port Register A)
DDRA =  $dc02			; CIA#1 (Data Direction Register A)

PRB  =  $dc01			; CIA#1 (Port Register B)
DDRB =  $dc03			; CIA#1 (Data Direction Register B)

SCREEN_RAM = $400
COLOR_RAM = $d800
															  					