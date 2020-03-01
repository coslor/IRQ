constants=1			
			
SHIFT_KEYS=$028d
KEY_SHIFT=%00000001
KEY_COMM=%000000010
KEY_CTRL=%00000100

PRA  =  $dc00			; CIA#1 (Port Register A)
DDRA =  $dc02			; CIA#1 (Data Direction Register A)

PRB  =  $dc01			; CIA#1 (Port Register B)
DDRB =  $dc03			; CIA#1 (Data Direction Register B)


CHROUT = $FFD2

CLR_SCREEN = $e544

SETLFS = $FFBA			; set logical file numbers (open a,x,y)
SETNAM = $FFBD			; set file name(a=len,x/y=lo/hi for pointer)
OPEN = $FFC0			; open file (out:c=err, a=1,2,4,5,8 error code)
CLOSE = $FFC3			; close file (a=fileno)
CHKIN = $FFC6			; set file as default input(a=filenumber,C=error)
CHKOUT = $FFC9			; set file as default output(a=filenumber,C=error)
CLRCHN = $FFCC			; close default input/output files
CHRIN = $FFCF			; read byte from default input
LOAD = $FFD5
SAVE = $FFD8
GETIN = $FFE4			; read byte from default input (diff with CHRIN?)
CLALL = $FFE7			; clear file table & call CLRCHN
READST = $ffb7			; read STatus, leaves it in A

STROUT = $ab1e			; print zt string,addr in A/Y
LINPRT = $BDCD			; Output int in A/Y

GIVAYF = $b391			; convert int in Y/A to FAC1
SNGET = $b3a2			; convert byte in Y to FAC1
FACINX = $B1AA			; convert FAC1 to 2/byte int in A/Y
FADDH = $b849			; add 0.5 to FAC1 for rounding
FSUBT = $b853			; FAC1=FAC2 - FAC1
FADDT = $b86f			; FAC1=FAC@ + FAC1
COMPLT = $b947			; FAC1= two's complement of FAC1
FMULTT = $ba30			; FAC1=FAC1 * FAC2
FDIVT = $bb14			; FAC1=FAC2 / FAC1
ROUND = $bc2b			; FAC1 = ROUND(FAC1)
SIGN = $bc2b			; A=(0 if FAC1=0, 1 if FAC1>0, $FF(-1) otherwise)
FIN = $bfc3				; convert string (pointed to by TXTPTR) 
						;	to float in FAC1
TXTPTR = $7a			; pointer into (usually BASIC) text						
MOVFA = $bbfc			; copy FAC2 to FAC1

						
STATUS = $90			; ST for serial devices						
FAC2 = $69
FAc1 = $66

AADD = $bd7e			; add A to FAC1
FOUT = $bddd			; convert FAC1 to ASCII string, starting at $100
						; 	and ending with a 0 term. On exit, A/Y holds
						; 	start address, so STROUT can be called.

						
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

PLOTK = $e50a			; read/set cursor row(x), col(y) 
SCROL = $e8ea			; scroll the screen up 1 line 
DSPP = $ea31			; read the screen & put char in A, color in X 

 								