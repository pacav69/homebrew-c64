ChibiSoundAgain:
	pla
	jmp ChibiSoundB
ChibiSound:

	and #255				;Test A
	beq ChibiSoundDone		;=0?
	
	pha
	
		eor #%00111111		;Flip bits of tone	
		and #%00111111
		ora #%00000011
		tax
		
		lda #1
		sta z_as
		lda #>ProgramStart	;We're using the program code as a noise source!
		sta z_h
		lda #<ProgramStart
		sta z_l
		lda #255 				;Enable noise effect
		sta z_d
	pla
	pha
		and #%10000000
		bne ChibiSoundNoise
		lda #0					;Disable noise effect on nonoise
		sta z_d
ChibiSoundNoise:		
	pla
	and #%00111111
	clc
	adc #1
ChibiSoundB:	
	tay
	pha
	
	txa
	pha
		inc z_l						;next noise byte
		
		lda (z_hl)					;Get in noise data
		and z_d						;AND in 'noise setting' 
		ror
		bcs ChibiSound_Pausey		;will always be zero if noise disabled
		
		lda $C030	;Reading C030 'beeps' the speaker
	
ChibiSound_Pausey:		
		ldx #2
ChibiSound_Pause:		
		dex
		bne ChibiSound_Pause		
		dey
		bne ChibiSound_Pausey		;pause for pitch
		
	pla
	tax
	dex
	bne ChibiSoundAgain				;Loop tone
	dec z_as
	bne ChibiSoundAgain
	pla
ChibiSoundDone:
	rts