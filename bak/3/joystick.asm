				*=$c000

.include "const.asm"				

				
				LDA #$7D
				STA $CFE0
				LDA #$00
				STA $CFE1
				LDA #$7D
				STA $CFE2
				LDA #$00
				STA $CFE3
				LDA #$7D
				STA SPRITE0_X
				STA SPRITE0_Y
				STA SPRITE1_X
				STA SPRITE1_Y
				LDA #$00
				STA SPRITE_MSB
				SEI
				LDA #<irq_routine
				STA $0314
				LDA #>irq_routine
				STA $0315
				CLI
				RTS
				
irq_routine				
				LDX #$00
				JSR jsr_c041
				LDX #$01
				JSR jsr_c041
				JMP $EA31
				
jsr_c041				
				LDA #$03
				STA SPRITE_EN
				LDA #$C0
				STA $07F8
				LDA #$04
				STA SPRITE0_COLOR
				LDA #$03
				STA SPRITE1_COLOR
				LDA #$C1
				STA $07F9
				LDA PRA,X
				AND #$0F
				STA $CFE4,X
				SEC
				LDA #$0F
				SBC $CFE4,X
				STA $CFE8,X
				LDY #$00
				
bc06d				
				INY
				TYA
				CMP $CFE8,X
				BNE bc06d
				
				CPX #$01
				BNE bc07a
				
				LDX #$02

bc07a				
				TYA
				ASL A
				TAY
				LDA vc087,Y
				PHA
				LDA vc086,Y
				PHA
				RTS
				
vc086				
				.byte $01
vc087
				.byte $C2
				.byte $D5,$C1,$D9,$C1,$01 
				.byte $C2,$E1,$C1,$E5,$C1,$EC,$C1,$01,$C2,$DD
				.byte $C1,$FA,$C1,$F3,$C1,$01,$C2				
				;$A9,$32
				   

				
;				ORA ($C2,X)
;				CMP $C1,X
;				CMP $01C1,Y
;				NOOP #$E1
;				CMP ($E5,X)
;				CMP ($EC,X)
;				CMP ($01,X)
;				NOOP #$DD
;				CMP ($FA,X)
;				CMP ($F3,X)
;				CMP ($01,X)
;				NOOP #$A9
;				JAM

jsr_c09e				
				LDA #$32
				CMP SPRITE0_Y,X
				BCS bc0b1
				LDA SPRITE0_Y,X
				SEC
				LDA SPRITE0_Y,X
				SBC #$01
				STA SPRITE0_Y,X
bc0b1				
				RTS
				
jsr_c0b2				
				LDA #$E5
				CMP SPRITE0_Y,X
				BCC bc0c5
				LDA SPRITE0_Y,X
				CLC
				LDA SPRITE0_Y,X
				ADC #$01
				STA SPRITE0_Y,X
bc0c5				
				RTS

jsr_c0c6			
				SEC
				LDA $CFE0,X
				SBC #$41
				STA $CFE4,X
				LDA $CFE1,X
				SBC #$01
				ORA $CFE4,X
				BCC bc0e6
				
				LDA #$41
				STA $CFE0,X
				LDA #$01
				STA $CFE1,X
				JMP jmp_c0f7

bc0e6				
				CLC
				LDA $CFE0,X
				ADC #$01
				STA $CFE0,X
				LDA $CFE1,X
				ADC #$00
				STA $CFE1,X
				
jmp_c0f7				
				SEC
				LDA $CFE0,X
				SBC #$00
				STA $CFE4,X
				LDA $CFE1,X
				SBC #$01
				ORA $CFE4,X
				BCC bc11d
				CPX #$02
				BEQ bc130
				LDA SPRITE_MSB
				ORA #$01
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS
				
bc11d				
				CPX #$02
				BEQ bc13f
				LDA SPRITE_MSB
				AND #$FE
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS
				
bc130				
				LDA SPRITE_MSB
				ORA #$02
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS
				
bc13f				
				LDA SPRITE_MSB
				AND #$FD
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS
				
jsr_c14e				
				SEC
				LDA $CFE0,X
				SBC #$19
				STA $CFE4,X
				LDA $CFE1,X
				SBC #$00
				ORA $CFE4,X
				BCS bc16e
				LDA #$18
				STA $CFE0,X
				LDA #$00
				STA $CFE1,X
				JMP jmp_c17f
				
bc16e				
				SEC
				LDA $CFE0,X
				SBC #$01
				STA $CFE0,X
				LDA $CFE1,X
				SBC #$00
				STA $CFE1,X

jmp_c17f				
				SEC
				LDA $CFE0,X
				SBC #$00
				STA $CFE4,X
				LDA $CFE1,X
				SBC #$01
				ORA $CFE4,X
				BCC bc1a5
				CPX #$02
				BEQ bc1b8
				LDA SPRITE_MSB
				ORA #$01
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS
				
bc1a5				
				CPX #$02
				BEQ bc1c7
				LDA SPRITE_MSB
				AND #$FE
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS

bc1b8				
				LDA SPRITE_MSB
				ORA #$02
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS
				
bc1c7				
				LDA SPRITE_MSB
				AND #$FD
				STA SPRITE_MSB
				LDA $CFE0,X
				STA SPRITE0_X,X
				RTS

;c1d6				
				JSR jsr_c09e
				RTS
				
;$c1da				
				JSR jsr_c0b2
				RTS
				
;$c1de				
				JSR jsr_c0c6
				RTS
;$c1e2				
				JSR jsr_c14e
				RTS
				
;$c1e6		
				JSR jsr_c09e
				JSR jsr_c14e
				RTS
				
;$c1ed				
				JSR jsr_c0b2
				JSR jsr_c14e
				RTS
				
;$c1f4				
				JSR jsr_c0b2
				JSR jsr_c0c6
				RTS
				
;$c1fb				
				JSR jsr_c09e
				JSR jsr_c0c6			
				RTS
				
;$c202				
				RTS
