/**
*	BASIC program and ML routine to set the start of BASIC
*		1K lower, then load "setcolors" into that area 
* 
**/ 

.const sc_init_start=$98ef
.encoding "petscii_mixed"

.file [name="bin/load-sc",segments="BASIC,LoadSetcolor"] 
 
//* = $0801 "BASIC"
.segment BASIC [start=$0801,max=$0821]

// 10 poke 55,0:poke 56,152
// 20 sys 0000			
			.byte  21, 8, 10, 0, 151, 32, 53, 53
			.byte  44, 48, 58, 151, 32, 53, 54, 44
			.byte  49, 53, 50, 0, 32, 8, 20, 0
			.byte  158, 32, 50, 48, 56, 50, 0, 0, 0
    
.segment LoadSetcolor[start=$0822]

jmp load_setcolors

#import "print_macros.asm"

//POKE 55,0:poke 56,152:REM top of BASIC=38912
sc_fname:	.text "scolors-init"

.const		sc_fname_len = *-sc_fname

load_setcolors:
			lda #$17		// set upper-lower character set
			sta $d018
			print_char(8)	// ...and disable switching 

			lda #%11000000	//turn on Kernal error and status messages 
			jsr SETMSG
			
			print_str("Running STELFS...~")
			lda #8
			ldx #8
			ldy #1			//use starting address in file
			jsr SETLFS
			
			print_str("Running SETNAM...~")
			lda #sc_fname_len
			ldx #<sc_fname
			ldy #>sc_fname
			jsr SETNAM
			
			print_str("Loading...~")
			lda #0			//0=LOAD, anything else=VERIFY
			ldx #0			//X,Y will be ignored
			ldy #0
			jsr LOAD

			print_str("scolors-init loaded!~")
			print_str("Running...~")
			jsr sc_init_start

