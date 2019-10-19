ChibiSound:		;NVPPPPPP - N=Noise V=Volume P=Pitch
	pha
		and #%00111111	;Get pitch bits --PPPPPP
		eor #%00111111	;Flip bits of pitch
		asl				;shift to -PPPPPP-
		
		ora #%10000000	;Top bit= enable channel
		
		tay				;Need to write to $900B/D depending on
		ldx #0			;if we're making Noise or Tone
	pla
	beq ChibSoundMute	;See if A=0
	pha
		and #%10000000 	;Test Noise Bit N-------
		beq ChibiSoundNoNoise
		
		tya				;Swap X and Y
		tax
		ldy #0
ChibiSoundNoNoise:	
		sty $900C		;Frequency for oscillator 2 (medium) 
		stx $900D		;Frequency of noise source
	pla
	and #%01000000		;Volume bit -V------
	lsr
	lsr
	lsr
	ora #%00000111		;Moved to	----V111
	
ChibSoundMute:			;A=0 at this point
	sta z_as
	
	lda $900E			;CCCCVVVV	V=Volume C=Aux color
	
	and #%11110000		;Get Aux Color bits CCCC----
	ora z_as			;OR in volume 		----VVVV
	
	sta $900E			;CCCCVVVV	V=Volume C=Aux color
	rts

	