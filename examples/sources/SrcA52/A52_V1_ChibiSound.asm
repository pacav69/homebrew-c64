		
		
ChibiSound:					;%NVPPPPPP N=Noise V=Volume P=Pitch
	cmp #0
	beq silent
	
	pha
		and #%10000000		;Noise Bit
		
		beq ChibiSoundNoNoise
		lda #%00000111		;NNNNVVVV	NNNN=%0000 = Distortion
		jmp ChibiSoundNoiseDone
ChibiSoundNoNoise:
		lda #%10100111		;NNNNVVVV	NNNN=%1010 = Square wave
ChibiSoundNoiseDone:
		sta z_as			;Store for later
		
		lda #0				;Reset POKEY sound Control
		sta  POKEY+$08	;N1234HHS	N=Noise bit depth 1234=Channel Clocks 
								;H=highpass filters S=main clockspeed
	pla
	
	pha
		and #%00111111		;Pitch bits
		asl
		asl					;Pitch Channel 0 (lower=higher pitch)
		sta POKEY+$00		;FFFFFFFF	F=Frequency
	pla 
	
	and #%01000000			;Volume Bit
	lsr
	lsr
	lsr
	ora z_as				;Or in Noise/Tone 	
	
silent:						;Silent when a=0
	sta  POKEY+$01			;NNNNVVVV	N=Noise V=Volume
	rts

	
	