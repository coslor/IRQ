#importonce
//
// utility routines
//
.const CLR_SCREEN = $e544
.const PLOTK = $e50a		// read/set cursor row(x), col(y) 
.const SCROL = $e8ea		// scroll the screen up 1 line 
.const DSPP = $ea31			// read the screen & put char in A, color in X 
.const MOVE_UP = $a3bf		// move a block of memory up, or move memory  
							//	from one non-overlapping region to another.
							//	$5f-$60=source block starting address
							//	$5a-5b=source block ending address +1
							//	$58-59=destination's ending address +1

.const CHKCOM = $aefd		// checks for a comma, and moves the
						//	BASIC char pointer up by one.
						
.const CHKCHAR = $aeff			// checks for any character, by setting A to the 
						//	desired character code. Prints syntax err
						//	message if not found

.const FRMEVAL = $ad9e			// Eval the next expression on the command line.
						//	Set the appropriate vals of VALTYP & INTFLAG,
						//	then call this. Displays a ?SYNTAX ERROR if
						//	the expression is invalid. 
						//	Puts numeric results in FAC1, string info
						// 	in the following bytes:
						//		FAC1:length
						//		FAC1+1:<address
						//		FAC1+2:>address
						//

.const FRMNUM = $ad8a			// Evals the next expression as floating point, 
						//	stores it into FAC1					
						
.const GETBYT = $b79e			// Evals the next expression as as unsigned byte,						
						//	stores it in X.						
										
.const COMBYT = $b7f1			// check for a comma, then call GETBYT										
.const ERROR = $a437			// prints an error message, error number in X-register. 
 						//	uses vector in ($0300) to jump to $E38B. 												  

.const FINDLN = $a613			// search for basic line number in $20-$21. if found,
						//	address of line in $5f-$60. C set if found, else clear.

.const INLIN = $a560			// input a line from keyboard into test buffer at $200 
.const FCERR = $b248			// print ILLEGAL QUANTITY error message

//
//	I/O ROUTINES
//
.const CHROUT = $FFD2			// write byte to default output
.const CHRIN = $FFCF			// read byte from default input

.const SETLFS = $FFBA			// set logical file numbers (open a,x,y)
.const SETNAM = $FFBD			// set file name(a=len,x/y=lo/hi for pointer)
.const OPEN = $FFC0			// open file (out:c=err, a=1,2,4,5,8 error code)
.const CLOSE = $FFC3			// close file (a=fileno)
.const CHKIN = $FFC6			// set file as default input(a=filenumber,C=error)
.const CHKOUT = $FFC9			// set file as default output(a=filenumber,C=error)
.const CLRCHN = $FFCC			// close default input/output files
.const LOAD = $FFD5
.const SAVE = $FFD8
.const GETIN = $FFE4			// read byte from default input (diff with CHRIN?)
.const CLALL = $FFE7			// clear file table & call CLRCHN
.const READST = $ffb7			// read STatus, leaves it in A
.const STATUS = $90			// ST for serial devices.						
						//	For serial devices:						
						//		bit 0:timeout (write)
						//		bit 1:timeout (read)
						//		bit 6:EOF
						//		bit 7:device not present 						

.const STROUT = $ab1e			// print zt string,addr in A/Y
.const LINPRT = $BDCD			// print UNSIGNED int in A/X 

.const PRTSPC = $ab4d			// print a space character
.const CRDO = $aad7			// print a CR character, followed by LF
						//	if channel > 128
						
.const STOP = $ffe1			// check for STOP key. If pressed, 
						// 	set Z (BEQ), call CLRCHN, print "break".
						

 
//
// interrupt vectors
//
.const CVINV = $314			// point to IRQ handler, normally $ea31.
						//	NOTE: A,X,Y are saved on the stack before calling,
						//		but they are NOT automatically restored
						
.const CBINV = $316			// BRK interrupt handler. Normally $fe66.  
.const NMINV = $318			// NMI handler, normally $fe47.  
						//	NOTE: to disable RS/RESTORE, store a 0 in $318.
						

						  						 

//
// passing data between basic and ml
//


.const A_STORAGE = $30c			// the registers are read from these 
.const X_STORAGE = $30d 		//		locations before running a SYS routine,
.const Y_STORAGE = $30e 		// 		and the results are stored back into 
.const P_STORAGE = $30f 		//		them after the RTS. doesn't apply to USR.

.const USERADD = $311			// the 16-bit address of a USR routine can be 
								// 		put into this vector. for example:
								//			x=usr(17) 								
								//		...puts the value of 17 in FAC1, calls
								// 		the routine in $311-312, and assigns the
								//		value of FAC1 upon exiting, to the var x.
//
// other basic stuff
//
.const CHRGET = $73				// reads the next character for processing by basic.
								//	sets P to indicate what kind of char,  
								// 	and returns the char in A. C=0-9,Z=end of stmt.
						
.const CHRGOT = $79				// does the same thing, but doesn't increment the						
								//	char pointer.						
												
.const VERCK = $A				// flag:0=LOAD,1=VERIFY												
.const VALTYP = $D				// flag:$FF=string,0=numeric							
.const INTFLG = $E				// flag:$80=int,0=fp												
.const INPFLG = $11			// flag:0=INPUT,$40=GET,$98=READ												
.const CHANNL = $13			// current logical file number (not dev#)												
.const TXTTAB = $2b			// beginning of BASIC text, normally $801 
.const MEMSIZ = $37			// end of BASIC-available memory 
.const CURLIN = $39			// current BASIC line#. $ff in $40 means immediate mode 
.const VARPNT = $47			// descriptor of current BASIC variable value 
.const OPMASK = $4D			// comparison operation flag: 1=<,2=> 
.const DSCPNT = $50			// $50-51 point to current string descriptor, 
						// 	$52 holds string length
						
.const STKEY = $91				// value of the last row of the keybd when last scanned. 												 
						//	$ff=none,$fe=1,$fd=<-,$fb=CTRL,$ef=SPACE,
						//	$df=Commodore,$bf=Q,$7f=STOP.
						//	NOTE: this means that you can do this:
						//		LDA STKEY
						//		BPL handle_stop
						
.const KEYBD_BUFR = $277		// keyboard buffer, from $277-$280 (10 bytes)						
						
.const VERCK2 = $93				// flag for load routine: 0=load/1=verify												
.const DFLTN = $99				// current default input device
.const DFLTO = $9A				// current default output device
.const TIME = $A0				// software jiffy clock, from $a0-a2. 
						//	24-bit count of jiffies (60/sec) since start.
						//	resets every 24 hours.

.const FNLEN = $b7				// size of current filename						
.const LA = $b8				// current logical file number(for a different						
						//	purpose then $13)						
.const SA = $b9				// current secondary address												
.const FA = $ba				// current device number												
.const FNADR = $BB				// 2-byte pointer to filename												
.const LSTX = $c5				// matrix coordinate of *last* keypress// 64=none												
.const NDX = $c6				// # of characters in keyboard buffer												
.const RVS = $c7				// flag: print reverse characters? 0=no												
						//	NOTE: you can poke 0 here to cancel reverse mode												
.const SFDX = $cb				// matrix coords of *current* keypress// 64=none
.const BLNSW = $cc				// cursor blink enable:0=flash
.const GDBLN = $ce				// screen code of char under cursor
.const PNTR = $d3				// cursor column on current line
.const QTSW = $d4				// editor in quote mode? 0=no
.const TBLx = $d6				// current cursor physical line #
.const INSRT = $d8				// insert mode? >0 is # of inserts
.const USER = $f3				// 2-byte pointer to current screen color location

.const COLOR = $286			// current foreground color for text
.const GDCOL = $287			// color of character under cursor
.const HIBASE = $288			// page of screen memory// normally contains 4(*256=1024)
						//	NOTE: $d018/$dd00 change ths *display*
						//	screen location - the one that shown onscreen.
						// 	this one is the memory written into by CHROUT,etc.
						
.const XMAX	= $289			// max keyvoard buffer size// should be <=10						
.const RPTFLAG = $28a			// flag: which keys should repeat?						
						//	0=normal,$80=all,$40=none						
												
.const SHFLAG = $653			// flag: modifier keys currently pressed?											
						//	bits: 1=SHIFT,2=Commodore,4=CTRL											
																	
.const MODE = $291				// flag: enable changing char sets with SHIFT/C= ?																	
						//	$80=disabled, 0=enabled																	
																							
.const AUTODN = $292			// flag: scroll screen on col 40/last line?																							
						//	0=yes// otherwise=no																							
																													
																													
																		 
.const BUF = $200				// BASIC line editor input buffer 
 
 												
//
// PETSCII
//
.const SPC = $20
.const CR = $0d
.const RVS_ON = $12 
.const RVS_OFF = $92 
.const CLR = $93 
.const BLACK = $90
.const WHITE = $05
.const RED = $1c
.const GREEN = $1e
.const BLUE = $1f
.const ORANGE = $81
.const BROWN = $95
.const PURPLE = $9c
.const YELLOW = $9e
.const CYAN = $9f
.const LT_RED = $96
.const DK_GRAY = $97
.const GRAY = $98
.const LT_GRAY = $9b
.const LT_GREEN = $99
.const LT_BLUE = $9a
.const HOME = $13
.const DEL = $14
.const UP = $91
.const DOWN = $11
.const LEFT = $9d
.const RIGHT = $1d
.const SHIFT_ON = $09
.const SHIFT_OFF = $08
.const MODE_TEXT = $0e
.const MODE_GRAPH = $8e
.const F1 = $85
.const F2 = $86
.const F3 = $87
.const F4 = $88
.const F5 = $89
.const F6 = $8a
.const F7 = $8b
.const F8 = $8c 
.const DBL_QUOTE = $22 
.const SNGL_QUOTE = $27 
.const GRAPH_SLASH = $6e 
.const GRAPH_BACKSLASH = $6d 
.const PIPE = $7d 
.const DASH = $60
.const DOLLAR_SIGN=$24
.const COMMA=$2c


//			
// keyboard constants			
//			
.const SHIFT_KEYS=$028d
.const KEY_SHIFT=%00000001
.const KEY_COMM=%000000010
.const KEY_CTRL=%00000100

//
// zero page locations
//
// used by tape routines
//
.const TSERVO = $92
.const TEOB = $96
.const TEMPXY = $97
.const TPARIT = $9b
.const TBYTFL = $9c
.const HDRTYP = $9e
.const PTR1 = $9e
.const PTR2 = $9f
.const TSFCNT = $a3
.const TBTCNT = $a4
.const CNTDN = $A5
.const BUFPNT = $a6
.const PASNUM = $a7
.const RIDATA = $aa
.const TCKS = $ab
.const CMP00 = $b0
.const CMPB01 = $b1
.const TAPE10 = $b2
.const TAPE11 = $b3
//
// used by rs-232
.const RIBUF0 = $f7
.const RIBUF1 = $f8
.const ROBUF0 = $f9
.const ROBUF1 = $fa
//
// unused
//
.const MISC_PTR0 = $fb
.const MISC_PTR1 = $fc 

//
// I/O Registers
//
.const SPRITE0_X = $d000
.const SPRITE0_Y = $d001
.const SPRITE1_X = $d002
.const SPRITE1_Y = $d003
.const SPRITE2_X = $d004
.const SPRITE2_Y = $d005
.const SPRITE3_X = $d006
.const SPRITE3_Y = $d007
.const SPRITE4_X = $d008
.const SPRITE4_Y = $d009
.const SPRITE5_X = $d00a
.const SPRITE5_Y = $d00b
.const SPRITE6_X = $d00c
.const SPRITE6_Y = $d00d
.const SPRITE7_X = $d00e
.const SPRITE7_Y = $d00f

.const SPRITE_MSB = $d010	// sprite 0-7 MSB of x coord
.const SCREEN_REG1= $d011	// bits 0-2:vertical raster roll
					// bit 3: screenm height (24/25 rows)
					// bit 4: screen off/on
					// bit 5: text/bitmap screen
					// bit 6: extended background mode
					// bit 7: 	read: current raster line
					//			write: line to generate IRQ at
					
.const RASTER_LINE = $d012 // read: current raster line
.const LIGHTPEN_X = $d013
.const LIGHTPEN_Y = $d014
.const SPRITE_EN = $d015		// enable/disable bits for sprites 0-7

.const SCREEN_CTRL = $d016	// 	bits 0-2:horiz raster scroll	
					//	bit 3: screen width - 38/40 cols	
					//	bit 4: multicolor mode	
						
.const SPRITE_2X_HT = $d017
.const MEM_SETUP = $d018	//	bits 1-3: in text mode, pointer to
					//		character memory
					// 	bits 4-7: pointer to screen memory
					
.const SPRITE_PRI = $d01b 	//	bits determine whether sprite x drawn  
					//		in front of/behind background
					
.const SPRITE_MULTI = $d01a // sprites 0-7 multicolor on/off 
.const SPRITE_2X_WD = $d01d					
.const SPR2SPR_COLL = $d01e // 	read: sprites have collided,					
					//	write: detect sprite-sprite collisions					
										
.const BORDER_COLOR = $d020 // bits 0-3 										
.const BACKG_COLOR = $d021	// bits 0-3				
.const BKG_MULTI_CLR1 = $d022			
.const BKG_MULTI_CLR2 = $d023			
.const BKG_MULTI_CLR3 = $d024			
.const SPR_MULTI_CLR1 = $d025			
.const SPR_MULTI_CLR2 = $d026			
			
.const SPRITE0_COLOR = $d027 // bits 0-3						
.const SPRITE1_COLOR = $d028 // bits 0-3						
.const SPRITE2_COLOR = $d029 // bits 0-3						
.const SPRITE3_COLOR = $d02a // bits 0-3						
.const SPRITE4_COLOR = $d02b // bits 0-3						
.const SPRITE5_COLOR = $d02c // bits 0-3						
.const SPRITE6_COLOR = $d02d // bits 0-3						
.const SPRITE7_COLOR = $d02e // bits 0-3						
						
.const PROCESSOR_DDR = $0	// bits 0-7: set read/write for bit x 
					//	of processor port					
										
.const PROCESSOR_PORT = $1	// 	bit 0: RAM/ROM at $a000-bfff										
					//	bit 1: RAM/ROM at $e000-ffff										
					//	bit 2: RAM/IO ports at $d000-dfff										
					//	bits 3-5: datasette										
															
.const PRA  =  $dc00			// CIA#1 (Port Register A)
.const DDRA =  $dc02			// CIA#1 (Data Direction Register A)

.const PRB  =  $dc01			// CIA#1 (Port Register B)
.const DDRB =  $dc03			// CIA#1 (Data Direction Register B)

.const SCREEN_RAM = $400
.const COLOR_RAM = $d800

.const PETSCII_COLR_TBL = $E8D1 //PETASCII Color Code Equivalent Table
