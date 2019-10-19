ChibiSound:			;%NVPPPPPP	N=Noise  V=Volume  P=Pitch
		pha
			and #%01000000	;Volume bit
			lsr
			lsr
			lsr
			ora #%00110111	;CCLEVVVV - Fixed Volume, Disable Clock
			tax
		pla
		
		beq ChibiSound_Silent
		
		bit Bit7			;Noise
		bne ChibiSound_Noise
		
		stx $4000 			;CCLEVVVV - APU Volume/Decay Channel 1 (Rectangle) 
		
		jsr swapnibbles		;Swap Pitch Bits --FFffff to ffff--FF
		pha
			and #%00000011	;Top 2 bits
			ora #%11111000
			sta $4003		;CCCCCHHH - APU Length Channel 1 (Rectangle)		
		pla
		and #%11110000
		sta $4002 			;LLLLLLLL - APU Frequency Channel 1 (Rectangle)
				
		lda #%00000001
ChibiSound_Silent:			;A=0 for silent
		sta $4015		;DF-54321 - DMC/IRQ/length counter status/channel enable 			
	rts
	
ChibiSound_Noise:	
		stx $400C 			;CCLEVVVV - APU Volume/Decay Channel 1 (Rectangle)

		and #%00111100
		lsr
		lsr
		sta $400E			;LLLLLLLL - APU Channel 4 (Noise) Frequency (W)
		
		
		lda #%00001000	;DF-54321 - DMC/IRQ/length counter status/channel enable 	
						;We also use this for setting the bottom 3 bits of the noise H freq.
		
		sta $400F			;CCCCCHHH - APU Channel 4 (Noise) Length (W)
		
		jmp ChibiSound_Silent 

