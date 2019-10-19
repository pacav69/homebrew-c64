
ChibiSound:			;%NVPPPPPP	N=Noise  V=Volume  P=Pitch
	cmp #0
	beq silent

	pha
		and #%01000000		
		ora #%00111111
		sta $fd20			;Volume (127=max 0=min)	
	pla 
	
	pha
		and #%00111111
		sta $fd24			;Timer Backup Value 
	pla							;(effectively frequency)
	
	and #%10000000			;Noise Bit
	beq ChibiSound_NoNoise
	lda #%11110000			;9= Noise
	jmp ChibiSound_NoiseSet
ChibiSound_NoNoise:	
	lda #%00010000			;1= Good Tone
ChibiSound_NoiseSet:
	sta $fd21				;FFFFFFFF	Effective sound of instrument
	
	stz $fd23				;SSSSSSSS	Shift Regsiter L
	stz $fd27				;SSSS-CBB	S=Shift Register H, 
										;C=Clock state B=Borrow
	stz $Fd50				;LLLLRRRR	LR Vol - 0=all on 255=all off

	lda #$80				;Silent
	sta $fd22				;Reset Audio Output Value 
	
	lda #%00011110 			;FTIRCKKK	F=Feedback bit 7 , reset Timer done, 
							;enable Integrate, enable Reload enable Count,
							;clocK select
	sta $fd25				;Audio Control bits
	rts
	
	
silent:
	stz $fd20	;Volume (127=max 0=min)
	rts

	
	
	;FD20 40 - amplitude
	;FD21 1F
	;FD22 3F - DAC output (this is what really gets to the speaker. It changes all the time.)
	;FD23 2C
	;FD24 8D - pitch
	;FD25 00
	;FD26 6E - count register (it also changes by itself all the time)
	;FD27 B2
