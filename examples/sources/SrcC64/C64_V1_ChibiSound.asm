ChibiSound:		;NVPPPPPP - N=Noise V=Volume P=Pitch
	pha
		and #%00111111	;Pitch bits
		eor #%00111111	;Flip Pitch bits
		sta $D401		;HHHHHHHH	Voice #1 frequency H (Higher values=higher pitch)
	pla
	beq ChibiSound_Silent ;See if sound is turned off
	
	pha
		and #%10000000	;Noise Bit
		bne ChibiSound_NoiseDone
		
		lda #%01000000	;ChibiSound_NoNoise
ChibiSound_NoiseDone:
		ora #%00000001
		sta $D404		;NPST-RSG	Voice #1 control register - Noise / Pulse / Sawtooth / Triangle / - test / Ring mod / Sync /Gate
		
		ldx #0
		stx $D402		;LLLLLLLL 	Voice #1 pulse width L
		stx $D405		;AAAADDDD	Voice #1 Attack and Decay length - Atack / Decay
		dex ;255
		stx $D400		;LLLLLLLL	Voice #1 frequency L
		stx $D403		;----HHHH	Voice #1 pulse width H
		stx $D406		;SSSSRRRR	Voice #1 Sustain volume and Release length - Sustain  / Release

	pla
	and #%01000000		;Volume bit -V------
	lsr
	lsr
	lsr
	ora #%00000111		;Move to   -----V111
	
ChibiSound_Silent:
	sta $D418			;MHBLVVVV	Volume and filter modes - Mute3 / Highpass / Bandpass / Lowpass / Volume (0=silent)
	rts
	
	








