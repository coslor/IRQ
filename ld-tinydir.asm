/**
*
*	Load tinydir 
*
**/
.file [name="bin/ld-tinydir",segments="BASIC,LoadTinydir"] 

.segment BASIC [start=$0801]

BasicUpstart(load_tinydir)

.segment LoadTinydir [start=$0810]

			jmp load_tinydir
			
#import "print_macros.asm"
			
tinydir_fname:	.text "tinydir-49152"

.const		tinydir_fname_len = *-tinydir_fname

load_tinydir:
			print_str("Loading tinydir...~")
						
			lda #$17		// set upper-lower character set
			sta $d018
			print_char(8)	// ...and disable switching 

			lda #%11000000	//turn on Kernal error and status messages 
			jsr SETMSG
			
			print_str("Running SETLFS...~")
			lda #8
			ldx #8
			ldy #1			//use starting address in file
			jsr SETLFS
			
			print_str("Running SETNAM...~")
			lda #tinydir_fname_len
			ldx #<tinydir_fname
			ldy #>tinydir_fname
			jsr SETNAM
			rts
			
			
			print_str("Loading...~")
			lda #0			//0=LOAD, anything else=VERIFY
			ldx #0			//X,Y will be ignored
			ldy #0
			jsr LOAD
			print_cr()

			print_str("tinydir loaded!~")
			
			print_str("Running...~")
			jmp $c000
			
			rts

.segment tinydir [start=$c000,outPrg="bin/tinydir-49152"]
#import "tinydir.asm"
