//-------------------------------------------------------------------------------
// DEC2HEX
// Convert 8-bit binary in $fb to two hex characters in $fc and $fd

dec2hex:
{
				lax P0FREE            // Get the original byte into .A and .X (UNDOCUMENTED OPCODE)
				and #$0f 	            // Mask-off upper nybble
				tay                   // Stash index in .Y
				lda chars,y					// Get character
				sta P0FREE+2          // Save it in the hex string
				txa                   // Get the original byte again
				lsr                   // Shift right one bit
				lsr                   // Shift right one bit
				lsr                   // Shift right one bit
				lsr                   // Shift right one bit
				tay                   // Stash index in .Y
				lda chars,y  	      // Get character
				sta P0FREE+1     	    // Save it in the hex string
				rts
}
          // Conversion table
chars			.text "0123456789ABCDEF"
